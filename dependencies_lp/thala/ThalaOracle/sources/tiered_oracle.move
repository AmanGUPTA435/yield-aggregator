module thala_oracle::tiered_oracle {
    use std::string::String;
    use std::option::{Self, Option};

    use aptos_std::table::{Self, Table};
    use aptos_std::event::{Self, EventHandle};
    use aptos_std::type_info;
    use aptos_framework::account;

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    use thala_oracle::params;
    use thala_oracle::package;
    use thala_oracle::status;
    use thala_oracle::pyth_oracle;
    use thala_oracle::simple_oracle;
    use thala_oracle::switchboard_oracle;
    use thala_oracle::stable_pool_twap_oracle;

    use thala_manager::manager;

    friend thala_oracle::oracle;

    ///
    /// Error codes
    ///

    const ERR_UNAUTHORIZED: u64 = 100;

    // Initialization
    const ERR_ORACLE_UNINITIALIZED: u64 = 101;
    const ERR_ORACLE_INITIALIZED: u64 = 102;

    // Collateral Initialization
    const ERR_ORACLE_COIN_INITIALIZED: u64 = 103;
    const ERR_ORACLE_COIN_UNINITIALIZED: u64 = 104;

    // Oracle Registration
    const ERR_ORACLE_NOT_EXIST: u64 = 105;

    // Oracle errors
    const ERR_ORACLE_INVALID_CONFIG: u64 = 106;
    const ERR_ORACLE_INVALID_PRICE: u64 = 107;

    ///
    /// Oracle Types
    ///

    /// Means that there's no oracle
    const ENUM_NULL_ORACLE: u8 = 0;

    /// Oracle for stablecoins that always returns fixed price 1 USD
    const ENUM_STABLECOIN_ORACLE: u8 = 1;

    /// Oracle with an off-chain cron job to update its price
    const ENUM_SIMPLE_ORACLE: u8 = 2;

    /// Pyth oracle
    const ENUM_PYTH_ORACLE: u8 = 3;

    /// Switchboard oracle
    const ENUM_SWITCHBOARD_ORACLE: u8 = 4;

    /// Thalaswap stable pool TWAP oracle
    const ENUM_THALASWAP_STABLE_POOL_TWAP_ORACLE: u8 = 5;

    ///
    /// Other Constants
    ///
    
    const ONE_HUNDRED: u64 = 100;

    ///
    /// Resources
    ///

    struct TieredOracle has key {
        data_table: Table<String, CoinData>,
        price_events: EventHandle<PriceEvent>,
        oracle_change_events: EventHandle<OracleChangeEvent>,
    }

    struct CoinData has copy, store, drop {
        last_price: FixedPoint64,
        tier_1: u8,
        tier_2: Option<u8>
    }

    ///
    /// Events
    ///

    /// Event emitted when oracle price is retrieved
    struct PriceEvent has drop, store {
        coin_name: String,
        price: FixedPoint64
    }

    /// Event emitted when oracle type is changed
    struct OracleChangeEvent has drop, store {
        coin_name: String,

        tier: u8,
        old_oracle: u8,
        new_oracle: u8
    }

    ///
    /// Initialization
    ///

    /// Initialize tiered oracle module
    public(friend) fun initialize() {
        pyth_oracle::initialize();
        simple_oracle::initialize();
        switchboard_oracle::initialize();
        stable_pool_twap_oracle::initialize();
        
        let resource_account = &package::resource_account_signer();
        move_to(resource_account, TieredOracle {
            data_table: table::new<String, CoinData>(),
            price_events: account::new_event_handle<PriceEvent>(resource_account),
            oracle_change_events: account::new_event_handle<OracleChangeEvent>(resource_account)
        });
    }

    /// Configure tier 1 oracle. It can be used to initialize tiered oracle for a coin, or to change tier 1 oracle for a coin
    /// If it is used to initialize, tier 2 is empty by default. new_oracle can be any supported oracle except ENUM_NULL_ORACLE
    public entry fun configure_tier_1<CoinType>(
        manager: &signer,
        new_oracle: u8
    ) acquires TieredOracle {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let coin_name = type_info::type_name<CoinType>();
        if (!params::initialized_coin(coin_name)) params::initialize_coin(coin_name);

        // for certain types of oracles, the config / price store must have been initialized
        if (new_oracle == ENUM_PYTH_ORACLE) {
            assert!(pyth_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_SWITCHBOARD_ORACLE) {
            assert!(switchboard_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_SIMPLE_ORACLE) {
            assert!(simple_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_THALASWAP_STABLE_POOL_TWAP_ORACLE) {
            assert!(stable_pool_twap_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_STABLECOIN_ORACLE) {
            // pass
        } else {
            // for any other unsupported oracle types
            abort ERR_ORACLE_INVALID_CONFIG
        };

        let tiered_oracle = borrow_global_mut<TieredOracle>(package::resource_account_address());
        let existing_tier_1 = if (table::contains(&tiered_oracle.data_table, coin_name)) {
            let oracle_config = table::borrow_mut(&mut tiered_oracle.data_table, coin_name);

            let (tier_1, tier_2) = extract_tier_1_and_2(oracle_config);
            
            // new oracle cannot be the same as existing oracle
            assert!(new_oracle != tier_1, ERR_ORACLE_INVALID_CONFIG);
            assert!(new_oracle != tier_2, ERR_ORACLE_INVALID_CONFIG);

            oracle_config.tier_1 = new_oracle;
            tier_1
        }
        else {
            table::add(&mut tiered_oracle.data_table, coin_name, CoinData {
                last_price: fixed_point64::zero(),
                tier_1: new_oracle,
                tier_2: option::none<u8>()
            });
            ENUM_NULL_ORACLE
        };

        let events = borrow_global_mut<TieredOracle>(package::resource_account_address());
        event::emit_event<OracleChangeEvent>(
            &mut events.oracle_change_events,
            OracleChangeEvent {
                coin_name,
                tier: 1,
                old_oracle: existing_tier_1,
                new_oracle
            }
        );
    }

    /// Configure tier 2 oracle. 
    /// Requires tier 1 oracle to be configured first.
    /// `new_oracle` can be any supported oracle type enum. If new_oracle is ENUM_NULL_ORACLE, it means there's no/unsets the tier 2 oracle
    public entry fun configure_tier_2<CoinType>(
        manager: &signer,
        new_oracle: u8
    ) acquires TieredOracle {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        let coin_name = type_info::type_name<CoinType>();

        // tiered oracle must be initialized by configuring tier 1 oracle first
        assert!(initialized_tiered_oracle(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);

        // for certain types of oracles, the config / price store must have been initialized
        if (new_oracle == ENUM_PYTH_ORACLE) {
            assert!(pyth_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_SWITCHBOARD_ORACLE) {
            assert!(switchboard_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_SIMPLE_ORACLE) {
            assert!(simple_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_THALASWAP_STABLE_POOL_TWAP_ORACLE) {
            assert!(stable_pool_twap_oracle::initialized_coin(coin_name), ERR_ORACLE_NOT_EXIST);
        } else if (new_oracle == ENUM_STABLECOIN_ORACLE) {
            // pass
        } else if (new_oracle == ENUM_NULL_ORACLE) {
            // pass
        } else {
            // for any other unsupported oracle types
            abort ERR_ORACLE_INVALID_CONFIG
        };

        let tiered_oracle = borrow_global_mut<TieredOracle>(package::resource_account_address());

        let oracle_config = table::borrow_mut(&mut tiered_oracle.data_table, coin_name);
        let (existing_tier_1, existing_tier_2) = extract_tier_1_and_2(oracle_config);
            
        // new oracle cannot be the same as existing oracle
        assert!(new_oracle != existing_tier_1, ERR_ORACLE_INVALID_CONFIG);
        assert!(new_oracle != existing_tier_2, ERR_ORACLE_INVALID_CONFIG);

        oracle_config.tier_2 = if (new_oracle == ENUM_NULL_ORACLE) option::none() else option::some(new_oracle);

        let events = borrow_global_mut<TieredOracle>(package::resource_account_address());
        event::emit_event<OracleChangeEvent>(
            &mut events.oracle_change_events,
            OracleChangeEvent {
                coin_name,
                tier: 2,
                old_oracle: existing_tier_2,
                new_oracle
            }
        );
    }

    /// This function can be triggered by an offchain cron job to update the last price of a specific coin
    public entry fun update_price<CoinType>() acquires TieredOracle {
        let coin_name = type_info::type_name<CoinType>();
        get_and_update_price(coin_name);
    }

    ///
    /// Functions
    ///

    /// Get price and update TieredOracle resource (which stores last price)
    public fun get_and_update_price(coin_name: String): FixedPoint64 acquires TieredOracle {
        assert!(initialized_tiered_oracle(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);

        let price_decision = get_price(coin_name);
        let resource_account_addr = package::resource_account_address();

        let tiered_oracle = borrow_global_mut<TieredOracle>(resource_account_addr);

        let coin_data = table::borrow_mut(&mut tiered_oracle.data_table, coin_name);
        coin_data.last_price = price_decision;

        event::emit_event<PriceEvent>(
            &mut tiered_oracle.price_events,
            PriceEvent {
                coin_name,
                price: price_decision
            }
        );

        price_decision
    }

    #[view]
    /// Use the tiering algorithm to resolute the price based on tier1 and tier2 oracle (if it exists)
    /// This method may abort with ERR_ORACLE_INVALID_PRICE
    /// Docs: https://docs.thala.fi/thala-protocol-design/move-dollar-mod/oracles
    public fun get_price(coin_name: String): FixedPoint64
    acquires TieredOracle {
        let (status, price) = get_price_unsafe(coin_name);
        assert!(!status::is_broken_status(status), ERR_ORACLE_INVALID_PRICE);
        price
    }

    #[view]
    /// Use the tiering algorithm to resolute the price based on tier1 and tier2 oracle (if it exists)
    /// Returns (oracle status, price)
    /// This method will not abort if oracle status is broken, but always return the status of the price
    public fun get_price_unsafe(coin_name: String): (u8, FixedPoint64)
    acquires TieredOracle {
        assert!(initialized_tiered_oracle(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);
        let (staleness_seconds, staleness_broken_seconds) = params::staleness_thresholds(coin_name);
        let price_deviate_reject_pct = params::price_deviate_reject_pct(coin_name);

        let tiered_oracle = borrow_global<TieredOracle>(package::resource_account_address());

        let oracle_data = *table::borrow(&tiered_oracle.data_table, coin_name);

        let (tier_1_status, tier_1_price) = get_single_price(
            coin_name, oracle_data.tier_1, oracle_data.last_price, staleness_seconds, staleness_broken_seconds, price_deviate_reject_pct);

        if (status::is_normal_status(tier_1_status)) {
            (tier_1_status, tier_1_price)
        } else {
            if (option::is_some(&oracle_data.tier_2)) {
                let (tier_2_status, tier_2_price) = get_single_price(
                    coin_name,
                    *option::borrow(&oracle_data.tier_2), 
                    oracle_data.last_price,
                    staleness_seconds,
                    staleness_broken_seconds,
                    price_deviate_reject_pct
                );

                // reconcile between tier_1 and tier_2
                if (status::is_stale_status(tier_1_status) && status::is_normal_status(tier_2_status)) {
                    (tier_2_status, tier_2_price)
                } else if (status::is_stale_status(tier_1_status)) {
                    // if primary is stale, and secondary is not normal (stale or broken)
                    // we use tier_1_price because we trust it more
                    (tier_1_status, tier_1_price)
                } else {
                    // if primary is broken, we use secondary if it's not broken
                    (tier_2_status, tier_2_price)
                }
            } else {
                // if there's no tier_2, we can only use tier 1
                (tier_1_status, tier_1_price)
            }
        }
    }

    /// Get price for a specific type of oracle
    /// Returns (Oracle status, FP64 price)
    fun get_single_price(
        coin_name: String,
        oracle_type: u8,
        last_price: FixedPoint64,
        staleness_seconds: u64,
        staleness_broken_seconds: u64,
        price_deviate_reject_pct: u64
    ): (u8, FixedPoint64) {
        if (oracle_type == ENUM_STABLECOIN_ORACLE) {
            (status::normal_status(), fixed_point64::one())
        } else if (oracle_type == ENUM_PYTH_ORACLE) {
            pyth_oracle::get_price(coin_name, staleness_seconds, staleness_broken_seconds, price_deviate_reject_pct, last_price)
        } else if (oracle_type == ENUM_SWITCHBOARD_ORACLE) {
            switchboard_oracle::get_price(coin_name, staleness_seconds, staleness_broken_seconds, price_deviate_reject_pct, last_price)
        } else if (oracle_type == ENUM_THALASWAP_STABLE_POOL_TWAP_ORACLE) {
            stable_pool_twap_oracle::get_price(coin_name, staleness_seconds, staleness_broken_seconds, price_deviate_reject_pct, last_price)
        } else if (oracle_type == ENUM_SIMPLE_ORACLE) {
            simple_oracle::get_price(coin_name, staleness_seconds, staleness_broken_seconds)
        } else {
            abort ERR_ORACLE_NOT_EXIST
        }
    }

    #[view]
    /// Get the tier1 and tier2 oracle types for a coin. If tier2 doesn't exist, return ENUM_NULL_ORACLE as tier2
    public fun get_tiers<CoinType>(): (u8, u8) acquires TieredOracle {
        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_tiered_oracle(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);

        let tiered_oracle = borrow_global<TieredOracle>(package::resource_account_address());
        let oracle_data = *table::borrow(&tiered_oracle.data_table, coin_name);
        extract_tier_1_and_2(&oracle_data)
    }

    #[view]
    public fun get_last_price<CoinType>(): FixedPoint64 acquires TieredOracle {
        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_tiered_oracle(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);

        let tiered_oracle = borrow_global<TieredOracle>(package::resource_account_address());
        let oracle_data = *table::borrow(&tiered_oracle.data_table, coin_name);
        oracle_data.last_price
    }

    fun extract_tier_1_and_2(tier_data: &CoinData): (u8, u8) {
        (tier_data.tier_1, option::get_with_default(&tier_data.tier_2, ENUM_NULL_ORACLE))
    }

    public fun initialized_tiered_oracle(coin_name: String): bool acquires TieredOracle {
        let oracle = borrow_global<TieredOracle>(package::resource_account_address());
        table::contains(&oracle.data_table, coin_name)
    }
}

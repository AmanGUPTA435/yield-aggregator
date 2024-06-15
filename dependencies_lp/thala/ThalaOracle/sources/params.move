module thala_oracle::params {
    use std::string::{Self, String};
    use aptos_std::table::{Self, Table};
    use aptos_std::event::{Self, EventHandle};
    use aptos_std::type_info;
    use aptos_framework::account;

    use thala_oracle::package;

    use thala_manager::manager;

    friend thala_oracle::oracle;
    friend thala_oracle::tiered_oracle;
    friend thala_oracle::simple_oracle;

    ///
    /// Error codes
    ///
    
    const ERR_UNAUTHORIZED: u64 = 0;

    // Initialization
    const ERR_ORACLE_UNINITIALIZED: u64 = 1;
    const ERR_ORACLE_INITIALIZED: u64 = 2;

    // Collateral Initialization
    const ERR_ORACLE_COIN_INITIALIZED: u64 = 3;
    const ERR_ORACLE_COIN_UNINITIALIZED: u64 = 4;

    // Oracle Configs
    const ERR_ORACLE_BAD_CONFIG: u64 = 8;
    
    ///
    /// Defaults
    ///

    const DEFAULT_STALENESS_SECONDS: u64 = 900;
    const DEFAULT_STALENESS_BROKEN_SECONDS: u64 = 3600;
    const DEFAULT_PRICE_DEVIATE_REJECT_PCT: u64 = 20;
    
    struct OracleParams has key {
        data_table: Table<String, CoinParam>,

        param_change_events: EventHandle<OracleParamChangeEvent>,
    }

    struct CoinParam has store, drop {
        /// price is regarded as stale if it's not updated for `staleness_seconds`
        /// we switch to secondary if possible, but otherwise accept the slightle stale price
        /// `staleness_seconds` must be smaller than `staleness_broken_seconds`
        staleness_seconds: u64,

        /// stale price is rejected after `staleness_broken_seconds`
        /// we mark the oracle status as broken
        staleness_broken_seconds: u64,

        /// if new price deviates last valid price by this percentage
        /// or if confidence interval of Pyth oracle is larger than this
        /// we reject the price
        price_deviate_reject_pct: u64
    }

    /// Event emitted when a parameter is changed
    struct OracleParamChangeEvent has drop, store {
        param_name: String,
        coin_name: String,

        prev_value: u64,
        new_value: u64
    }

    public(friend) fun initialize() {
        let resource_account = &package::resource_account_signer();
        move_to(resource_account, OracleParams {
            data_table: table::new<String, CoinParam>(),
            param_change_events: account::new_event_handle<OracleParamChangeEvent>(resource_account)
        });
    }

    /// Initialize oracle for a coin.
    /// Only callable from tiered_oracle
    public(friend) fun initialize_coin(coin_name: String) acquires OracleParams {
        assert!(!initialized_coin(coin_name), ERR_ORACLE_INITIALIZED);

        let resource_account = package::resource_account_address();
        let params = borrow_global_mut<OracleParams>(resource_account);

        table::add(&mut params.data_table, coin_name, CoinParam {
            staleness_seconds: DEFAULT_STALENESS_SECONDS,
            staleness_broken_seconds: DEFAULT_STALENESS_BROKEN_SECONDS,
            price_deviate_reject_pct: DEFAULT_PRICE_DEVIATE_REJECT_PCT
        });
    }

    public entry fun set_staleness_thresholds<CoinType>(
        manager: &signer,
        staleness_seconds: u64,
        staleness_broken_seconds: u64
    )
    acquires OracleParams {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_coin(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);
        assert!(staleness_broken_seconds > staleness_seconds && staleness_seconds > 0, ERR_ORACLE_BAD_CONFIG);

        let (prev_staleness_seconds, prev_staleness_broken_seconds) = staleness_thresholds(coin_name);
        let params = borrow_global_mut<OracleParams>(package::resource_account_address());

        let coin_params = table::borrow_mut(&mut params.data_table, coin_name);
        coin_params.staleness_seconds = staleness_seconds;
        coin_params.staleness_broken_seconds = staleness_broken_seconds;
        event::emit_event<OracleParamChangeEvent>(
            &mut params.param_change_events,
            OracleParamChangeEvent {
                coin_name,
                param_name: string::utf8(b"staleness_seconds"),
                prev_value: prev_staleness_seconds, new_value: staleness_seconds
            }
        );
        event::emit_event<OracleParamChangeEvent>(
            &mut params.param_change_events,
            OracleParamChangeEvent {
                coin_name,
                param_name: string::utf8(b"staleness_broken_seconds"),
                prev_value: prev_staleness_broken_seconds, new_value: staleness_broken_seconds
            }
        );
    }

    public entry fun set_price_deviate_reject_pct<CoinType>(manager: &signer, pct: u64)
    acquires OracleParams {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_coin(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);
        assert!(pct > 0, ERR_ORACLE_BAD_CONFIG);

        let prev_percent = price_deviate_reject_pct(coin_name);
        let params = borrow_global_mut<OracleParams>(package::resource_account_address());

        let coin_params = table::borrow_mut(&mut params.data_table, coin_name);
        coin_params.price_deviate_reject_pct = pct;

        event::emit_event<OracleParamChangeEvent>(
            &mut params.param_change_events,
            OracleParamChangeEvent {
                coin_name,
                param_name: string::utf8(b"price_deviate_reject_pct"), 
                prev_value: prev_percent, new_value: pct
            }
        );
    }

    public fun initialized_coin(coin_name: String): bool acquires OracleParams {
        let params = borrow_global<OracleParams>(package::resource_account_address());
        table::contains(&params.data_table, coin_name)
    }

    public fun price_deviate_reject_pct(coin_name: String): u64 acquires OracleParams {
        assert!(initialized_coin(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);
        
        let params = borrow_global<OracleParams>(package::resource_account_address());
        table::borrow(&params.data_table, coin_name).price_deviate_reject_pct
    }

    public fun staleness_seconds(coin_name: String): u64 acquires OracleParams {
        assert!(initialized_coin(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);
        
        let params = borrow_global<OracleParams>(package::resource_account_address());
        table::borrow(&params.data_table, coin_name).staleness_seconds
    }

    public fun staleness_broken_seconds(coin_name: String): u64 acquires OracleParams {
        assert!(initialized_coin(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);
        
        let params = borrow_global<OracleParams>(package::resource_account_address());
        table::borrow(&params.data_table, coin_name).staleness_broken_seconds
    }

    /// Returns (staleness_seconds, staleness_broken_seconds)
    public fun staleness_thresholds(coin_name: String): (u64, u64) acquires OracleParams {
        assert!(initialized_coin(coin_name), ERR_ORACLE_COIN_UNINITIALIZED);
        
        let params = borrow_global<OracleParams>(package::resource_account_address());
        let table = table::borrow(&params.data_table, coin_name);
        (table.staleness_seconds, table.staleness_broken_seconds)
    }
}
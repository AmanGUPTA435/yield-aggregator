/// simple_oracle accepts the price set by an off-chain cron job
module thala_oracle::simple_oracle {
    use std::string::String;
    use std::signer;

    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_std::table::{Self, Table};
    use aptos_std::type_info;
    use aptos_std::event::{Self, EventHandle};

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    use thala_oracle::math;
    use thala_oracle::params;
    use thala_oracle::package;
    use thala_oracle::status;

    use thala_manager::manager;

    friend thala_oracle::tiered_oracle;

    ///
    /// Error codes
    ///
    
    const ERR_UNAUTHORIZED: u64 = 0;
    const ERR_ORACLE_UNINITIALIZED: u64 = 1;
    const ERR_ORACLE_INITIALIZED: u64 = 2;

    const ERR_ORACLE_UPDATE_TOO_OFTEN: u64 = 3;
    const ERR_ORACLE_INVALID_PRICE: u64 = 4;
    
    // Two oracle updates cannot happen too close to prevent abnormal price movement and manipulation
    // If price is quoted from DEX, the cost of manipulation is proportional to the duration
    // Too short of an oracle update interval means more likely to be manipulated
    const MIN_UPDATE_INTERVAL_SECONDS: u64 = 30;

     
    struct SimpleOracle has key {
        data_table: Table<String, CoinData>,
        updater_address: address,
        price_update_events: EventHandle<PriceUpdateEvent>,
        updater_change_event: EventHandle<SimpleOracleConfigChangeEvent>,
    }

    // Stores the last updated price and timestamp (in seconds) of a coin
    struct CoinData has store, drop {
        last_price: FixedPoint64, // CONTRACT: last_price is initialized to be 0
        last_timestamp: u64,
    }

    /// Event emitted when oracle price is updated
    struct PriceUpdateEvent has drop, store {
        coin_name: String, 
        price: FixedPoint64,
        timestamp: u64
    }

    /// Event emitted when oracle updater config is changed
    struct SimpleOracleConfigChangeEvent has drop, store {
        old_updater_address: address,
        new_updater_address: address
    }

    public(friend) fun initialize() {
        let resource_account = &package::resource_account_signer();
        move_to(resource_account, SimpleOracle {
            data_table: table::new<String, CoinData>(),
            updater_address: @simple_oracle_updater,
            price_update_events: account::new_event_handle<PriceUpdateEvent>(resource_account),
            updater_change_event: account::new_event_handle<SimpleOracleConfigChangeEvent>(resource_account)
        });
    }

    /// Initialize oracle for a coin
    public entry fun initialize_coin<CoinType>(manager: &signer) acquires SimpleOracle {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let coin_name = type_info::type_name<CoinType>();
        assert!(!initialized_coin(coin_name), ERR_ORACLE_INITIALIZED);
        if (!params::initialized_coin(coin_name)) params::initialize_coin(coin_name);

        let resource_account = package::resource_account_address();
        let oracle = borrow_global_mut<SimpleOracle>(resource_account);
        
        table::add(&mut oracle.data_table, coin_name, CoinData {
            last_price: fixed_point64::zero(),
            last_timestamp: timestamp::now_seconds()
        });

        event::emit_event<PriceUpdateEvent>(
            &mut oracle.price_update_events,
            PriceUpdateEvent {
                coin_name,
                price: fixed_point64::zero(),
                timestamp: timestamp::now_seconds()
            }
        );
    }

    /// Configure oracle updater address
    public entry fun configure_simple_oracle(manager: &signer, new_updater_address: address) acquires SimpleOracle {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let oracle = borrow_global_mut<SimpleOracle>(package::resource_account_address());
        let old_updater_address = oracle.updater_address;
        oracle.updater_address = new_updater_address;

        event::emit_event<SimpleOracleConfigChangeEvent>(
            &mut oracle.updater_change_event,
            SimpleOracleConfigChangeEvent {
                old_updater_address,
                new_updater_address,
            }
        );
    }

    /// Entry point for the cron job
    /// `timestamp_seconds` should be the timestamp of tx submission set by the cron job to avoid tx confirmation delay
    public entry fun update_price<CoinType>(
        updater: &signer,
        numerator: u64,
        denominator: u64,
        timestamp_seconds: u64
    )
    acquires SimpleOracle {
        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_coin(coin_name), ERR_ORACLE_UNINITIALIZED);

        let resource_account = package::resource_account_address();
        let simple_oracle = borrow_global_mut<SimpleOracle>(resource_account);
        assert!(signer::address_of(updater) == simple_oracle.updater_address, ERR_UNAUTHORIZED);


        let oracle_data = table::borrow_mut(&mut simple_oracle.data_table, coin_name);

        assert!(
            oracle_data.last_timestamp < timestamp_seconds && timestamp_seconds - oracle_data.last_timestamp > MIN_UPDATE_INTERVAL_SECONDS,
            ERR_ORACLE_UPDATE_TOO_OFTEN
        );

        let price_fp = fixed_point64::fraction(numerator, denominator);
        let price_deviate_reject_pct = params::price_deviate_reject_pct(coin_name);
        if (math::deviate_largely_from_old_price(price_deviate_reject_pct, price_fp, oracle_data.last_price)) {
            abort ERR_ORACLE_INVALID_PRICE
        };
        oracle_data.last_price = price_fp;
        oracle_data.last_timestamp = timestamp_seconds;

        event::emit_event<PriceUpdateEvent>(
            &mut simple_oracle.price_update_events,
            PriceUpdateEvent {
                coin_name,
                price: price_fp,
                timestamp: timestamp_seconds
            }
        );
    }

    public fun get_price(coin_name: String, staleness_seconds: u64, staleness_broken_seconds: u64): (u8, FixedPoint64)
    acquires SimpleOracle {
        let simple_oracle = borrow_global_mut<SimpleOracle>(package::resource_account_address());
        let oracle_data = table::borrow_mut(&mut simple_oracle.data_table, coin_name);

        // price is initialized as 0
        // price == 0 means the oracle is never updated, so we report broken status
        if (fixed_point64::to_u128(oracle_data.last_price) == 0) {
            (status::broken_status(), oracle_data.last_price)
        }
        else {
            let now_seconds = timestamp::now_seconds();
            let freshness = if (now_seconds > oracle_data.last_timestamp) {
                status::check_freshness(
                now_seconds - oracle_data.last_timestamp,
                staleness_seconds,
                staleness_broken_seconds
            )
            } else {
                status::normal_status()
            };

            (freshness, oracle_data.last_price)
        }
    }

    #[view]
    /// Get timestamp of the price stored in SimpleOracle resource
    public fun get_timestamp_at_source<CoinType>(): u64 acquires SimpleOracle {
        let coin_name = type_info::type_name<CoinType>();
        let simple_oracle = borrow_global<SimpleOracle>(package::resource_account_address());
        let oracle_data = table::borrow(&simple_oracle.data_table, coin_name);
        oracle_data.last_timestamp
    }

    public fun initialized_coin(coin_name: String): bool acquires SimpleOracle {
        let oracle = borrow_global<SimpleOracle>(package::resource_account_address());
        table::contains(&oracle.data_table, coin_name)
    }
    
    public fun oracle_updater(): address acquires SimpleOracle {
        let oracle = borrow_global<SimpleOracle>(package::resource_account_address());
        oracle.updater_address
    }

    #[test_only]
    /// Set arbitrary price and update with the latest timestamp
    public fun set_simple_oracle_price_for_test(
        coin_name: String,
        price_numerator: u64,
        price_denominator: u64
    )
    acquires SimpleOracle {
        let price = fixed_point64::fraction(price_numerator, price_denominator);
        let simple_oracle = borrow_global_mut<SimpleOracle>(package::resource_account_address());

        table::upsert(&mut simple_oracle.data_table, coin_name, CoinData {
            last_price: price,
            last_timestamp: timestamp::now_seconds()
        });
    }

    #[test_only]
    /// Set arbitrary price and arbitrary timestamp
    public fun set_simple_oracle_data_for_test(
        coin_name: String,
        price_numerator: u64,
        price_denominator: u64,
        timestamp: u64
    )
    acquires SimpleOracle {
        let price = fixed_point64::fraction(price_numerator, price_denominator);
        
        let simple_oracle = borrow_global_mut<SimpleOracle>(package::resource_account_address());

        table::upsert(&mut simple_oracle.data_table, coin_name, CoinData {
            last_price: price,
            last_timestamp: timestamp
        });
    }

}
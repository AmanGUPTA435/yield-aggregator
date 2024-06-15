module thala_oracle::switchboard_oracle {
    use std::string::String;
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_std::table::{Self, Table};
    use aptos_std::type_info;
    use aptos_std::event::{Self, EventHandle};

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    use switchboard::aggregator;

    use thala_oracle::math;
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

    struct SwitchboardOracle has key {
        aggregator_addresses: Table<String, address>,
        config_change_events: EventHandle<SwitchboardConfigChangeEvent>
    }

    /// Event emitted when switchboard config is changed
    struct SwitchboardConfigChangeEvent has drop, store {
        coin_name: String,
        old_aggregator_address: address,
        new_aggregator_address: address
    }
    
    public(friend) fun initialize() {
        let resource_account = &package::resource_account_signer();
        move_to(resource_account, SwitchboardOracle {
            aggregator_addresses: table::new<String, address>(),
            config_change_events: account::new_event_handle<SwitchboardConfigChangeEvent>(resource_account)
        });
    }

    public entry fun configure_switchboard<CoinType>(manager: &signer, new_aggregator_address: address)
    acquires SwitchboardOracle {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        let coin_name = type_info::type_name<CoinType>();

        let resource_account = package::resource_account_address();

        let switchboard_oracle = borrow_global_mut<SwitchboardOracle>(resource_account);
        let old_aggregator_address = if (table::contains(&switchboard_oracle.aggregator_addresses, coin_name)) *table::borrow(&switchboard_oracle.aggregator_addresses, coin_name) else @0x0;

        table::upsert(&mut switchboard_oracle.aggregator_addresses, coin_name, new_aggregator_address);

        let events = borrow_global_mut<SwitchboardOracle>(resource_account);
        event::emit_event<SwitchboardConfigChangeEvent>(
            &mut events.config_change_events,
            SwitchboardConfigChangeEvent {
                coin_name,
                old_aggregator_address,
                new_aggregator_address,
            }
        );
    }

    /// Fetch price from Switchboard
    /// Switchboard price format reference: https://docs.switchboard.xyz/aptos/idl/types/SwitchboardDecimal
    /// Price USD = `value / 10^dec`
    /// normally, "neg" is never true, but we still check it
    /// Returns oracle status (u8) and price in USD (FixedPoint64)
    public fun get_price(
        coin_name: String,
        staleness_seconds: u64,
        staleness_broken_seconds: u64,
        price_deviate_reject_pct: u64,
        last_price: FixedPoint64
    ): (u8, FixedPoint64)
    acquires SwitchboardOracle {
        assert!(initialized_coin(coin_name), ERR_ORACLE_UNINITIALIZED);
        let switchboard_oracle = borrow_global<SwitchboardOracle>(package::resource_account_address());

        let (latest_value, confirmed_timestamp, _, _, _) = aggregator::latest_round(
            *table::borrow(&switchboard_oracle.aggregator_addresses, coin_name)
        );

        let (value, scaling_factor, neg) = switchboard::math::unpack(latest_value);

        if (neg) {
            return (status::broken_status(), fixed_point64::zero())
        };

        let price_fp64 = fixed_point64::fraction((value as u64), math::pow10((scaling_factor as u64)));

        if (confirmed_timestamp < timestamp::now_seconds() - staleness_broken_seconds) {
            return (status::broken_status(), price_fp64)
        };

        if (math::deviate_largely_from_old_price(price_deviate_reject_pct, price_fp64, last_price)) {
            return (status::broken_status(), price_fp64)
        };

        let freshness = status::check_freshness(
            timestamp::now_seconds() - confirmed_timestamp,
            staleness_seconds,
            staleness_broken_seconds
        );

        (freshness, price_fp64)
    }

    #[view]
    /// Get timestamp of the price from Switchboard
    public fun get_timestamp_at_source<CoinType>(): u64 acquires SwitchboardOracle {
        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_coin(coin_name), ERR_ORACLE_UNINITIALIZED);

        let switchboard_oracle = borrow_global<SwitchboardOracle>(package::resource_account_address());
        let (_, confirmed_timestamp, _, _, _) = aggregator::latest_round(
            *table::borrow(&switchboard_oracle.aggregator_addresses, coin_name)
        );
        confirmed_timestamp
    }

    public fun initialized_coin(coin_name: String): bool acquires SwitchboardOracle {
        let oracle = borrow_global<SwitchboardOracle>(package::resource_account_address());
        table::contains(&oracle.aggregator_addresses, coin_name)
    }
}
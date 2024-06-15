module thala_oracle::stable_pool_twap_oracle {
    use std::string::String;

    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_std::type_info;
    use aptos_std::event::{Self, EventHandle};

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    use thala_oracle::math;
    use thala_oracle::package;
    use thala_oracle::status;

    use thala_manager::manager;

    use thalaswap::stable_pool;
    use thalaswap::math_helper;

    ///
    /// Error codes
    ///
    
    const ERR_TWAP_ORACLE_UNAUTHORIZED: u64 = 0;
    const ERR_TWAP_ORACLE_UNINITIALIZED: u64 = 1;

    const ERR_TWAP_ORACLE_UPDATE_TOO_OFTEN: u64 = 2;
    const ERR_TWAP_ORACLE_INVALID_PERIOD: u64 = 3;
    const ERR_TWAP_ORACLE_TYPE_NOT_MATCH: u64 = 4;
    
    // Two oracle updates cannot happen too close to prevent abnormal price movement and manipulation
    // The cost of manipulating DEX price is proportional to the duration
    // Too short of an oracle update interval means more likely to be manipulated
    const MIN_PERIOD_SECONDS: u64 = 1000;
     
    struct TwapOracle has key {
        /// Mapping from coin name to CoinData
        data_table: SmartTable<String, CoinData>,
        price_update_events: EventHandle<PriceUpdateEvent>,
    }

    struct CoinData has store, drop {
        /// Last updated timestamp
        last_timestamp: u64,
        
        /// Last cumulative price obtained from Thalaswap stable pool
        last_cumulative_price: u128,

        /// Last updated average price
        last_average_price: FixedPoint64,

        /// Period for updating price average
        /// Note: price average is only guaranteed to be over at least 1 period, but may be over a longer period
        period: u64,

        /// Oracle in Thalaswap is idenfitied by <Asset0, Asset1, Asset2, Asset3, X, Y>
        /// in which Asset0/1/2/3 represent the 4 assets in the stable pool
        /// X, Y represent the 2 assets in the quote pair
        /// Below variables must match the oracle in Thalaswap
        asset_0: String,
        asset_1: String,
        asset_2: String,
        asset_3: String,
        asset_x: String,
        asset_y: String,
    }

    /// Event emitted when oracle price is updated
    struct PriceUpdateEvent has drop, store {
        coin: String,
        price: FixedPoint64
    }

    public entry fun initialize() {
        if (!exists<TwapOracle>(package::resource_account_address())) {
            let resource_account = &package::resource_account_signer();
            move_to(resource_account, TwapOracle {
                data_table: smart_table::new<String, CoinData>(),
                price_update_events: account::new_event_handle<PriceUpdateEvent>(resource_account)
            });
        }
    }

    /// Configure TWAP oracle for a coin. <Asset0, Asset1, Asset2, Asset3> identifies the stable pool to query. <X, Y> identifies the quote pair
    /// If quote_is_x is true, then we use coin X as the quote coin, otherwise we use coin Y as the quote coin
    public entry fun configure<Asset0, Asset1, Asset2, Asset3, X, Y>(manager: &signer, quote_is_x: bool, period_seconds: u64) acquires TwapOracle {
        assert!(manager::is_authorized(manager), ERR_TWAP_ORACLE_UNAUTHORIZED);
        assert!(stable_pool::oracle_exists<Asset0, Asset1, Asset2, Asset3, X, Y>(), ERR_TWAP_ORACLE_UNINITIALIZED);
        assert!(period_seconds >= MIN_PERIOD_SECONDS, ERR_TWAP_ORACLE_INVALID_PERIOD);

        let asset_x = type_info::type_name<X>();
        let asset_y = type_info::type_name<Y>();
        let quote_coin = if (quote_is_x) asset_x else asset_y;

        let resource_account = package::resource_account_address();
        let oracle = borrow_global_mut<TwapOracle>(resource_account);

        let (current_cumulative_price_x, current_cumulative_price_y) = stable_pool::current_cumulative_prices<Asset0, Asset1, Asset2, Asset3, X, Y>();
        let cumulative_price = if (quote_is_x) current_cumulative_price_x else current_cumulative_price_y;
        
        smart_table::upsert(&mut oracle.data_table, quote_coin, CoinData {
            last_average_price: fixed_point64::zero(),
            last_timestamp: timestamp::now_seconds(),
            period: period_seconds,
            last_cumulative_price: cumulative_price,
            asset_0: type_info::type_name<Asset0>(),
            asset_1: type_info::type_name<Asset1>(),
            asset_2: type_info::type_name<Asset2>(),
            asset_3: type_info::type_name<Asset3>(),
            asset_x,
            asset_y
        });
    }

    /// Configure TWAP period
    public entry fun set_period<CoinType>(manager: &signer, new_period: u64) acquires TwapOracle {
        assert!(manager::is_authorized(manager), ERR_TWAP_ORACLE_UNAUTHORIZED);
        assert!(new_period >= MIN_PERIOD_SECONDS, ERR_TWAP_ORACLE_INVALID_PERIOD);

        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_coin(coin_name), ERR_TWAP_ORACLE_UNINITIALIZED);

        let twap_oracle = borrow_global_mut<TwapOracle>(package::resource_account_address());
        let oracle_data = smart_table::borrow_mut(&mut twap_oracle.data_table, coin_name);
        oracle_data.period = new_period;
    }

    /// Entry point to observe cumulative prices of Thalaswap oracle
    /// and then calculate the average price.
    /// Anyone can call this entry function
    /// Asset0, Asset1, Asset2, Asset3, X, Y must match the oracle in Thalaswap
    /// If quote_is_x is true, then we use Coin X as the quote coin
    /// Otherwise, we use Coin Y as the quote coin
    public entry fun update_price<Asset0, Asset1, Asset2, Asset3, X, Y>(quote_is_x: bool) acquires TwapOracle {
        let coin_name = if (quote_is_x) type_info::type_name<X>() else type_info::type_name<Y>();
        assert!(initialized_coin(coin_name), ERR_TWAP_ORACLE_UNINITIALIZED);

        let twap_oracle = borrow_global_mut<TwapOracle>(package::resource_account_address());
        let oracle_data = smart_table::borrow_mut(&mut twap_oracle.data_table, coin_name);

        // Ensure that at least one full period has passed since the last update
        let now_seconds = timestamp::now_seconds();
        let time_elapsed = now_seconds - oracle_data.last_timestamp;
        assert!(time_elapsed >= oracle_data.period, ERR_TWAP_ORACLE_UPDATE_TOO_OFTEN);

        // Validate that type arguments Asset0, Asset1, Asset2, Asset3, X, Y must match stored oracle data
        assert!(type_info::type_name<Asset0>() == oracle_data.asset_0, ERR_TWAP_ORACLE_TYPE_NOT_MATCH);
        assert!(type_info::type_name<Asset1>() == oracle_data.asset_1, ERR_TWAP_ORACLE_TYPE_NOT_MATCH);
        assert!(type_info::type_name<Asset2>() == oracle_data.asset_2, ERR_TWAP_ORACLE_TYPE_NOT_MATCH);
        assert!(type_info::type_name<Asset3>() == oracle_data.asset_3, ERR_TWAP_ORACLE_TYPE_NOT_MATCH);
        assert!(type_info::type_name<X>() == oracle_data.asset_x, ERR_TWAP_ORACLE_TYPE_NOT_MATCH);
        assert!(type_info::type_name<Y>() == oracle_data.asset_y, ERR_TWAP_ORACLE_TYPE_NOT_MATCH);

        // Update oracle data
        let (current_cumulative_price_x, current_cumulative_price_y) = stable_pool::current_cumulative_prices<Asset0, Asset1, Asset2, Asset3, X, Y>();
        let current_cumulative_price = if (quote_is_x) current_cumulative_price_x else current_cumulative_price_y;
        // (Current cumulative price - last cumulative price) / time elapsed
        // Reference: https://github.com/Uniswap/v2-periphery/blob/master/contracts/examples/ExampleOracleSimple.sol#L50
        oracle_data.last_average_price = fixed_point64::from_u128(math_helper::wrap_sub(current_cumulative_price, oracle_data.last_cumulative_price) / (time_elapsed as u128));
        oracle_data.last_cumulative_price = current_cumulative_price;
        oracle_data.last_timestamp = now_seconds;

        event::emit_event<PriceUpdateEvent>(
            &mut twap_oracle.price_update_events,
            PriceUpdateEvent {
                coin: coin_name,
                price: oracle_data.last_average_price
            }
        );
    }

    public fun get_price(coin_name: String, staleness_seconds: u64, staleness_broken_seconds: u64, price_deviate_reject_pct: u64, last_price: FixedPoint64): (u8, FixedPoint64)
    acquires TwapOracle {
        assert!(initialized_coin(coin_name), ERR_TWAP_ORACLE_UNINITIALIZED);
        let twap_oracle = borrow_global_mut<TwapOracle>(package::resource_account_address());
        let oracle_data = smart_table::borrow_mut(&mut twap_oracle.data_table, coin_name);

        // price is initialized as 0
        // price == 0 means the oracle is never updated, so we report broken status
        if (fixed_point64::is_zero(&oracle_data.last_average_price)) {
            return (status::broken_status(), oracle_data.last_average_price)
        };

        if (math::deviate_largely_from_old_price(price_deviate_reject_pct, oracle_data.last_average_price, last_price)) {
            return (status::broken_status(), oracle_data.last_average_price)
        };
        
        let freshness = status::check_freshness(
            timestamp::now_seconds() - oracle_data.last_timestamp,
            staleness_seconds,
            staleness_broken_seconds
        );

        (freshness, oracle_data.last_average_price)
    }

    #[view]
    /// Helper method to inspect price related data. Returns (last_average_price, last_cumulative_price, last_timestamp)
    public fun price_data(coin_name: String): (FixedPoint64, u128, u64)  acquires TwapOracle {
        assert!(initialized_coin(coin_name), ERR_TWAP_ORACLE_UNINITIALIZED);
        let twap_oracle = borrow_global<TwapOracle>(package::resource_account_address());
        let coin_data = smart_table::borrow(&twap_oracle.data_table, coin_name);
        (coin_data.last_average_price, coin_data.last_cumulative_price, coin_data.last_timestamp)
    }

    #[view]
    /// Helper method to inspect coin configuration. Returns (period, asset_0, asset_1, asset_2, asset_3, asset_x, asset_y)
    public fun coin_config(coin_name: String): (u64, String, String, String, String, String, String)  acquires TwapOracle {
        assert!(initialized_coin(coin_name), ERR_TWAP_ORACLE_UNINITIALIZED);
        let twap_oracle = borrow_global<TwapOracle>(package::resource_account_address());
        let coin_data = smart_table::borrow(&twap_oracle.data_table, coin_name);
        (coin_data.period, coin_data.asset_0, coin_data.asset_1, coin_data.asset_2, coin_data.asset_3, coin_data.asset_x, coin_data.asset_y)
    }

    #[view]
    public fun initialized_coin(coin_name: String): bool acquires TwapOracle {
        let oracle = borrow_global<TwapOracle>(package::resource_account_address());
        smart_table::contains(&oracle.data_table, coin_name)
    }

}
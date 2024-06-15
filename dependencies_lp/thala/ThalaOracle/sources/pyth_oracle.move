module thala_oracle::pyth_oracle {
    use std::string::String;
    use std::vector;

    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_std::type_info;
    use aptos_std::table::{Self, Table};
    use aptos_std::event::{Self, EventHandle};

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    use thala_oracle::math;
    use thala_oracle::package;
    use thala_oracle::status;

    use thala_manager::manager;
    
    use pyth::i64;
    use pyth::price::{Self, Price as PythPrice};
    use pyth::price_identifier;
    use pyth::pyth;

    friend thala_oracle::tiered_oracle;

    ///
    /// Error codes
    ///
    
    const ERR_UNAUTHORIZED: u64 = 0;
    const ERR_ORACLE_UNINITIALIZED: u64 = 1;
    const ERR_ORACLE_INITIALIZED: u64 = 2;

    struct PythOracle has key {
        feed_ids: Table<String, vector<u8>>,
        config_change_events: EventHandle<PythConfigChangeEvent>
    }

    /// Event emitted when pyth config is changed
    struct PythConfigChangeEvent has drop, store {
        coin_name: String,
        old_feed_id: vector<u8>,
        new_feed_id: vector<u8>
    }

    public(friend) fun initialize() {
        let resource_account = &package::resource_account_signer();
        move_to(resource_account, PythOracle {
            feed_ids: table::new<String, vector<u8>>(),
            config_change_events: account::new_event_handle<PythConfigChangeEvent>(resource_account)
        });
    }

    public entry fun configure_pyth<CoinType>(manager: &signer, new_feed_id: vector<u8>)
    acquires PythOracle {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        let coin_name = type_info::type_name<CoinType>();

        let resource_account = package::resource_account_address();
        let oracle = borrow_global_mut<PythOracle>(resource_account);

        let old_feed_id = if (table::contains(&oracle.feed_ids, coin_name)) *table::borrow(&oracle.feed_ids, coin_name) else vector::empty<u8>();

        table::upsert(&mut oracle.feed_ids, coin_name, new_feed_id);

        event::emit_event<PythConfigChangeEvent>(
            &mut oracle.config_change_events,
            PythConfigChangeEvent {
                coin_name: coin_name,
                old_feed_id,
                new_feed_id
            }
        );
    }

    /// Fetch price from Pyth
    /// If last_price is 0, it means no last_price is available
    /// Returns oracle status (u8) and price in USD (FixedPoint64)
    public fun get_price(
        coin_name: String,
        staleness_seconds: u64,
        staleness_broken_seconds: u64,
        price_deviate_reject_pct: u64,
        last_price: FixedPoint64
    ): (u8, FixedPoint64)
    acquires PythOracle {
        assert!(initialized_coin(coin_name), ERR_ORACLE_UNINITIALIZED);
        let oracle = borrow_global<PythOracle>(package::resource_account_address());
        let feed_id = *table::borrow(&oracle.feed_ids, coin_name);

        // WARNING: the returned price can be from arbitrarily far in the past.
        // get_price_unsafe function makes no guarantees that the returned price is recent or
        // useful for any particular application. We should check the returned timestamp to 
        // ensure that the returned price is sufficiently recent
        // We don't use "get_price_no_older_than" because we don't want to abort immediately
        let pyth_price_data = pyth::get_price_unsafe(price_identifier::from_byte_vec(feed_id));
        parse_pyth_price(
            &pyth_price_data,
            last_price,
            staleness_seconds,
            staleness_broken_seconds,
            price_deviate_reject_pct
        )
    }

    #[view]
    /// Get timestamp of the price from Pyth 
    public fun get_timestamp_at_source<CoinType>(): u64 acquires PythOracle {
        let coin_name = type_info::type_name<CoinType>();
        assert!(initialized_coin(coin_name), ERR_ORACLE_UNINITIALIZED);

        let oracle = borrow_global<PythOracle>(package::resource_account_address());
        let feed_id = *table::borrow(&oracle.feed_ids, coin_name);
        let pyth_price_data = pyth::get_price_unsafe(price_identifier::from_byte_vec(feed_id));
        price::get_timestamp(&pyth_price_data)
    }

    public fun initialized_coin(coin_name: String): bool acquires PythOracle {
        let oracle = borrow_global<PythOracle>(package::resource_account_address());
        table::contains(&oracle.feed_ids, coin_name)
    }


    // Pyth price format reference: https://docs.pyth.network/consume-data/best-practices
    // See struct `Price` definition in https://github.com/pyth-network/pyth-crosschain/blob/main/aptos/contracts/sources/price.move
    //
    // Actual price = `price * 10^expo`. 
    // Confidence interval `conf` has the same unit as `price` (need to multiply by 10^expo to get actual value)
    //
    // Returns (Price status enum, FixedPoint64 Price in USD)
    fun parse_pyth_price(
        price_data: &PythPrice,
        last_price: FixedPoint64,
        staleness_seconds: u64,
        staleness_broken_seconds: u64,
        price_deviate_reject_pct: u64
    ): (u8, FixedPoint64) {
        let price = price::get_price(price_data);
        let conf = price::get_conf(price_data);
        let timestamp = price::get_timestamp(price_data);
        let expo = price::get_expo(price_data);
        if (i64::get_is_negative(&price)) {
            // status is `broken` if price is negative
            (status::broken_status(), fixed_point64::zero())
        } else {
            // price is positive or zero, continue
            let price_magnitude = i64::get_magnitude_if_positive(&price);
            if (price_magnitude == 0) {
                return (status::broken_status(), fixed_point64::zero())
            };
            let price_fp64 = if (i64::get_is_negative(&expo)) {
                // if expo is negative, real price = price magnitude / 10^(|exp|)
                let expo_magnitude = i64::get_magnitude_if_negative(&expo);
                fixed_point64::fraction(price_magnitude, math::pow10(expo_magnitude))
            } else {
                // if expo is positive, real price = price magnitude * 10^(|exp|)
                let expo_magnitude = i64::get_magnitude_if_positive(&expo);
                fixed_point64::encode(price_magnitude * math::pow10(expo_magnitude))
            };

            // equivalent to: `conf > price_magnitude * price_deviate_reject_pct / 100`
            // doing this to avoid truncation
            if (100 * conf > price_magnitude * price_deviate_reject_pct) {
                return (status::broken_status(), price_fp64)
            };

            if (math::deviate_largely_from_old_price(price_deviate_reject_pct, price_fp64, last_price)) {
                return (status::broken_status(), price_fp64)
            };

            let freshness = status::check_freshness(
                timestamp::now_seconds() - timestamp,
                staleness_seconds,
                staleness_broken_seconds
            );

            (freshness, price_fp64)
        }
    }

    ///////////////// TESTS /////////////////

    #[test_only]
    use pyth::price_feed;

    #[test_only]
    use pyth::price_info::{Self, PriceInfo};

    
    #[test_only]
    /// Pyth related test data are from https://github.com/pyth-network/pyth-crosschain/blob/main/aptos/contracts/sources/pyth.move
    /// A vector containing a single VAA with:
    /// - emitter chain ID 17
    /// - emitter address 0x71f8dcb863d176e2c420ad6610cf687359612b6fb392e0642b0ca6b1f186aa3b
    /// - payload corresponding to the batch price attestation of the prices returned by get_mock_price_infos()
    const TEST_VAAS: vector<vector<u8>> = vector[x"0100000000010036eb563b80a24f4253bee6150eb8924e4bdf6e4fa1dfc759a6664d2e865b4b134651a7b021b7f1ce3bd078070b688b6f2e37ce2de0d9b48e6a78684561e49d5201527e4f9b00000001001171f8dcb863d176e2c420ad6610cf687359612b6fb392e0642b0ca6b1f186aa3b0000000000000001005032574800030000000102000400951436e0be37536be96f0896366089506a59763d036728332d3e3038047851aea7c6c75c89f14810ec1c54c03ab8f1864a4c4032791f05747f560faec380a695d1000000000000049a0000000000000008fffffffb00000000000005dc0000000000000003000000000100000001000000006329c0eb000000006329c0e9000000006329c0e400000000000006150000000000000007215258d81468614f6b7e194c5d145609394f67b041e93e6695dcc616faadd0603b9551a68d01d954d6387aff4df1529027ffb2fee413082e509feb29cc4904fe000000000000041a0000000000000003fffffffb00000000000005cb0000000000000003010000000100000001000000006329c0eb000000006329c0e9000000006329c0e4000000000000048600000000000000078ac9cf3ab299af710d735163726fdae0db8465280502eb9f801f74b3c1bd190333832fad6e36eb05a8972fe5f219b27b5b2bb2230a79ce79beb4c5c5e7ecc76d00000000000003f20000000000000002fffffffb00000000000005e70000000000000003010000000100000001000000006329c0eb000000006329c0e9000000006329c0e40000000000000685000000000000000861db714e9ff987b6fedf00d01f9fea6db7c30632d6fc83b7bc9459d7192bc44a21a28b4c6619968bd8c20e95b0aaed7df2187fd310275347e0376a2cd7427db800000000000006cb0000000000000001fffffffb00000000000005e40000000000000003010000000100000001000000006329c0eb000000006329c0e9000000006329c0e400000000000007970000000000000001"];

    #[test_only]
    public fun setup_pyth_for_test() {
        account::create_account_for_test(@pyth);
        pyth::init_test(
            account::create_test_signer_cap(@pyth),
            500,
            23,
            x"5d1f252d5de865279b00c84bce362774c2804294ed53299bc4a0389a5defef92",
            vector[],
            0
        );
    }

    #[test_only]
    public fun get_mock_price_infos(): vector<PriceInfo> {
        vector<PriceInfo>[
            price_info::new(
                1663680747,
                1663074349,
                price_feed::new(
                    price_identifier::from_byte_vec(
                        x"c6c75c89f14810ec1c54c03ab8f1864a4c4032791f05747f560faec380a695d1"
                    ),
                    price::new(i64::new(1557, false), 7, i64::new(5, true), 1663680740),
                    price::new(i64::new(1500, false), 3, i64::new(5, true), 1663680740),
                ),
            ),
            price_info::new(
                1663680747,
                1663074349,
                price_feed::new(
                    price_identifier::from_byte_vec(
                        x"3b9551a68d01d954d6387aff4df1529027ffb2fee413082e509feb29cc4904fe"
                    ),
                    price::new(i64::new(1050, false), 3, i64::new(5, true), 1663680745),
                    price::new(i64::new(1483, false), 3, i64::new(5, true), 1663680745),
                ),
            ),
            price_info::new(
                1663680747,
                1663074349,
                price_feed::new(
                    price_identifier::from_byte_vec(
                        x"33832fad6e36eb05a8972fe5f219b27b5b2bb2230a79ce79beb4c5c5e7ecc76d"
                    ),
                    price::new(i64::new(1010, false), 2, i64::new(5, true), 1663680745),
                    price::new(i64::new(1511, false), 3, i64::new(5, true), 1663680745),
                ),
            ),
            price_info::new(
                1663680747,
                1663074349,
                price_feed::new(
                    price_identifier::from_byte_vec(
                        x"21a28b4c6619968bd8c20e95b0aaed7df2187fd310275347e0376a2cd7427db8"
                    ),
                    price::new(i64::new(1739, false), 1, i64::new(5, true), 1663680745),
                    price::new(i64::new(1508, false), 3, i64::new(5, true), 1663680745),
                ),
            ),
        ]
    }

    #[test(framework = @aptos_framework)]
    fun test_parse_pyth_price(framework: &signer) {
        timestamp::set_time_has_started_for_testing(framework);
        timestamp::update_global_time_for_test_secs(10000000);

        let price = i64::new(1000000, false);
        let conf = 1;
        let expo = i64::new(3, false);
        let timestamp = timestamp::now_seconds();
        let price_data = price::new(price, conf, expo, timestamp);
        let old_price = fixed_point64::encode(1000000000);
        let (status, price_fp64) = parse_pyth_price(&price_data, old_price, 900, 3600, 20);
        assert!(status::is_normal_status(status), 0);
        assert!(fixed_point64::decode(price_fp64) == 1000000000, 0);

        // negative expo
        price = i64::new(1000000, false);
        conf = 1;
        expo = i64::new(3, true);
        timestamp = timestamp::now_seconds();
        price_data = price::new(price, conf, expo, timestamp);
        old_price = fixed_point64::encode(1000);
        (status, price_fp64) = parse_pyth_price(&price_data, old_price, 900, 3600, 20);
        assert!(status::is_normal_status(status), 0);
        assert!(fixed_point64::decode(price_fp64) == 1000, 0);

        // stale timestamp
        price = i64::new(1000000, false);
        conf = 1;
        expo = i64::new(3, true);
        let staleness_seconds = 900;
        timestamp = timestamp::now_seconds() - staleness_seconds - 1;
        price_data = price::new(price, conf, expo, timestamp);
        (status, price_fp64) = parse_pyth_price(&price_data, old_price, staleness_seconds, 3600, 20);
        assert!(status::is_stale_status(status), 0);
        assert!(fixed_point64::decode(price_fp64) == 1000, 0);

        // reject very stale timestamp
        price = i64::new(1000000, false);
        conf = 1;
        expo = i64::new(3, true);
        let staleness_broken_seconds = 3600;
        timestamp = timestamp::now_seconds() - staleness_broken_seconds - 1;
        price_data = price::new(price, conf, expo, timestamp);
        (status, price_fp64) = parse_pyth_price(&price_data, old_price, 900, staleness_broken_seconds, 20);
        assert!(status::is_broken_status(status), 0);
        assert!(fixed_point64::decode(price_fp64) == 1000, 0);

        // conf too large
        price = i64::new(1000000, false);
        conf = 510000;
        expo = i64::new(3, true);
        timestamp = timestamp::now_seconds();
        price_data = price::new(price, conf, expo, timestamp);
        (status, price_fp64) = parse_pyth_price(&price_data, old_price, 900, 3600, 20);
        assert!(status::is_broken_status(status), 0);
        assert!(fixed_point64::decode(price_fp64) == 1000, 0);

        // deviation from old price too large
        price = i64::new(1000000, false);
        conf = 1;
        expo = i64::new(3, true);
        timestamp = timestamp::now_seconds();
        price_data = price::new(price, conf, expo, timestamp);
        old_price = fixed_point64::encode(700); // deviate by 30%, but threshold is 20%
        (status, price_fp64) = parse_pyth_price(&price_data, old_price, 900, 3600, 20);
        assert!(status::is_broken_status(status), 0);
        assert!(fixed_point64::decode(price_fp64) == 1000, 0);

        // zero price
        price = i64::new(0, false);
        conf = 1;
        expo = i64::new(3, true);
        timestamp = timestamp::now_seconds();
        price_data = price::new(price, conf, expo, timestamp);
        old_price = fixed_point64::zero();
        (status, price_fp64) = parse_pyth_price(&price_data, old_price, 900, 3600, 20);
        assert!(status::is_broken_status(status), 0);
        assert!(fixed_point64::decode(price_fp64) == 0, 0);
    }
}

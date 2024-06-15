module thala_oracle::thala_lp_oracle {

    use std::string;
    use std::string::String;
    use std::vector;

    use aptos_std::table::{Self, Table};
    use aptos_std::event::EventHandle;

    use aptos_framework::account;

    use fixed_point64::log_exp_math;
    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    use thala_oracle::package;
    use thala_oracle::status;
    use thala_oracle::oracle;

    use thalaswap::weighted_pool;
    use thalaswap::stable_pool;
    use thalaswap_math::stable_math;

    const ONE_HUNDRED: u64 = 100;
    const THALASWAP_NULL: vector<u8> = b"0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null";

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

    // Oracle errors
    const ERR_ORACLE_INVALID_PRICE: u64 = 7; // stay consistent with tiered oracle

    const ERR_NOT_THALA_LP_TOKEN: u64 = 8;

    const ERR_DEPRECATED: u64 = 100;

    #[deprecated]
    /// Thalaswap LP oracle returns the price of a Thalaswap LP token
    struct ThalaswapLpOracle has key {
        coin_config: Table<String, ThalaswapLpConfig>,
        config_change_events: EventHandle<ThalaswapLpOracleConfigChangeEvent>,
    }

    #[deprecated]
    /// Stores the underlying asset names of a Thalaswap LP token, and whether the LP type is weighted
    struct ThalaswapLpConfig has store, drop {
        asset_names: vector<String>,
        is_weighted: bool
    }

    #[deprecated]
    /// Event emitted when the underlying assets of a Thalaswap LP oracle is changed
    struct ThalaswapLpOracleConfigChangeEvent has drop, store {
        coin_name: String,
        asset_names: vector<String>
    }

    public(friend) fun initialize() {
        let resource_account = &package::resource_account_signer();
        move_to(resource_account, ThalaswapLpOracle {
            coin_config: table::new<String, ThalaswapLpConfig>(),
            config_change_events: account::new_event_handle<ThalaswapLpOracleConfigChangeEvent>(resource_account)
        });
    }

    #[view]
    /// Get the price of a Thalaswap LP token. Aborts if underlying asset oracle is broken, otherwise returns the price (even if stale)
    /// Returns (oracle status, price)
    public fun get_price(lp_name: String): FixedPoint64 {
        let (status, price) = get_price_unsafe(lp_name);
        assert!(!status::is_broken_status(status), ERR_ORACLE_INVALID_PRICE);
        price
    }

    #[view]
    /// Get the price of a Thalaswap LP token. Does not abort if underlying asset oracle is broken
    /// Returns (oracle status, price)
    /// 
    /// If any oracle of underlying assets is broken, this function returns broken status with zero price
    /// If none of the underlying assets is broken, but any is stale, this function returns stale status, and uses stale price to derive the LP price
    /// otherwise, returns normal status
    public fun get_price_unsafe(lp_name: String): (u8, FixedPoint64) {
        if (is_weighted_lp(lp_name)) get_weighted_lp_price_unsafe(lp_name)
        else if (is_stable_lp(lp_name)) get_stable_lp_price_unsafe(lp_name)
        else abort ERR_NOT_THALA_LP_TOKEN
    }

    /// Weighted LP coin price = (prod (balance_i * price_i / weight_i) ^ weight_i) / LP total supply
    ///
    /// The formula is introduced by Alpha Homora V2 https://blog.alphaventuredao.io/fair-lp-token-pricing/
    /// and explained in https://cmichel.io/pricing-lp-tokens/
    /// We extend the formula to support more than 2 coins
    ///
    /// Returns (oracle status, price)
    public fun get_weighted_lp_price_unsafe(lp_name: String): (u8, FixedPoint64) {
        let asset_names = pool_asset_names(lp_name);
        let (balances, weights, lp_coin_supply) = weighted_pool::pool_info(lp_name);
        let prod = fixed_point64::fraction(1, lp_coin_supply);

        let i = 0;
        let num_assets = vector::length(&asset_names);
        let stale = false;
        while (i < num_assets) {
            let (status, price) = oracle::get_price_by_name_unsafe(*vector::borrow(&asset_names, i));
            if (status::is_broken_status(status)) {
                return (status, fixed_point64::zero())
            }
            else if (status::is_stale_status(status)) {
                stale = true;
            };
            let balance = *vector::borrow(&balances, i);
            let weight = fixed_point64::fraction(*vector::borrow(&weights, i), ONE_HUNDRED);
            let prod_i = log_exp_math::pow(fixed_point64::div_fp(fixed_point64::mul(price, balance), weight), weight);
            prod = fixed_point64::mul_fp(prod, prod_i);

            i = i + 1;
        };

        let status = if (stale) { status::stale_status() } else { status::normal_status() };
        (status, prod)
    }

    /// StableSwap LP coin price = min_price * virtual_price
    /// where min_price = min(price1, price2, ..., priceN)
    /// and virtual_price = invariant D / LP total supply
    ///
    /// This formula is recommended by Chainlink https://blog.chain.link/using-chainlink-oracles-to-securely-utilize-curve-lp-pools/
    /// and Saber does the same thing https://docs.saber.so/developing/pricing-lp-tokens
    ///
    /// Returns (oracle status, price)
    public fun get_stable_lp_price_unsafe(lp_name: String): (u8, FixedPoint64) {
        let asset_names = pool_asset_names(lp_name);
        let (balances, amp, lp_coin_supply) = stable_pool::pool_info(lp_name);

        let inv = (stable_math::compute_invariant(&balances, amp) as u64);
        let virtual_price = fixed_point64::fraction(inv, lp_coin_supply);

        let min_price = fixed_point64::from_u128(1 << 127);
        let i = 0;
        let num_assets = vector::length(&asset_names);
        let stale = false;
        while (i < num_assets) {
            let (status, price) = oracle::get_price_by_name_unsafe(*vector::borrow(&asset_names, i));
            if (status::is_broken_status(status)) {
                return (status, fixed_point64::zero())
            }
            else if (status::is_stale_status(status)) {
                stale = true;
            };
            if (fixed_point64::lt(&price, &min_price)) {
                min_price = price;
            };

            i = i + 1;
        };

        let status = if (stale) { status::stale_status() } else { status::normal_status() };
        (status, fixed_point64::mul_fp(min_price, virtual_price))
    }

    #[deprecated]
    /// Configure the underlying assets or is_weighted flag of a Thalaswap LP oracle
    public entry fun configure_thala_lp_oracle<CoinType>(_manager: &signer, _asset_names: vector<String>, _is_weighted: bool) {
        abort ERR_DEPRECATED
    }

    #[deprecated]
    /// Stop using Thalaswap LP oracle for a specific CoinType
    public entry fun deregister_thala_lp_oracle<CoinType>(_manager: &signer)  {
        abort ERR_DEPRECATED
    }

    #[deprecated]
    /// Use get_weighted_lp_price_unsafe
    public fun get_weighted_lp_price(_lp_name: String, _asset_names: vector<String>): (u8, FixedPoint64) {
        abort ERR_DEPRECATED
    }

    #[deprecated]
    /// Use get_stable_lp_price_unsafe
    public fun get_stable_lp_price(_lp_name: String, _asset_names: vector<String>): (u8, FixedPoint64) {
        abort ERR_DEPRECATED
    }

    #[deprecated]
    public fun initialized_thala_lp_oracle(_coin_name: String): bool {
        abort ERR_DEPRECATED
    }

    fun is_weighted_lp(coin_name: String): bool {
        string::index_of(&coin_name, &string::utf8(b"WeightedPoolToken")) < string::length(&coin_name)
    }

    fun is_stable_lp(coin_name: String): bool {
        string::index_of(&coin_name, &string::utf8(b"StablePoolToken")) < string::length(&coin_name)
    }

    fun pool_asset_names(lpt_name: String): vector<String> {
        let asset_names = vector<String>[];
        let left_bracket = string::index_of(&lpt_name, &string::utf8(b"<"));
        let s = string::sub_string(&lpt_name, left_bracket + 1, string::length(&lpt_name));
        while (true) {
            let len = string::length(&s);
            let comma = string::index_of(&s, &string::utf8(b", "));
            if (comma == len) {
                break
            };
            let asset_name = string::sub_string(&s, 0, comma);
            if (asset_name == string::utf8(THALASWAP_NULL)) {
                break
            };
            vector::push_back(&mut asset_names, asset_name);
            if (vector::length(&asset_names) == 4) {
                break
            };
            s = string::sub_string(&s, comma + 2, len);
        };
        asset_names
    }

    #[test]
    fun test_pool_asset_names() {
        // 2-asset weighted pool
        assert!(
            pool_asset_names(string::utf8(b"0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::WeightedPool<0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD, 0x7fd500c11216f0fe3095d0c4b8aa4d64a4e2e04f83758462f2b127255643615::thl_coin::THL, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_20, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_80, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null>")) == vector[
                string::utf8(b"0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD"), 
                string::utf8(b"0x7fd500c11216f0fe3095d0c4b8aa4d64a4e2e04f83758462f2b127255643615::thl_coin::THL")],
            0
        );
        // 3-asset weighted pool
        assert!(
            pool_asset_names(string::utf8(b"0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::WeightedPool<0x5e156f1207d0ebfa19a9eeff00d62a282278fb8719f4fab3a586a0a2c0fffbea::coin::T, 0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC, 0x1::aptos_coin::AptosCoin, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_35, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_35, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_30, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null>")) == vector[
                string::utf8(b"0x5e156f1207d0ebfa19a9eeff00d62a282278fb8719f4fab3a586a0a2c0fffbea::coin::T"),
                string::utf8(b"0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC"),
                string::utf8(b"0x1::aptos_coin::AptosCoin")],
            0
        );
        // 4-asset weighted pool
        assert!(
            pool_asset_names(string::utf8(b"0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::WeightedPool<0x5e156f1207d0ebfa19a9eeff00d62a282278fb8719f4fab3a586a0a2c0fffbea::coin::T, 0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD, 0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC, 0x1::aptos_coin::AptosCoin, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_25, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_25, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_25, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::weighted_pool::Weight_25>")) == vector[
                string::utf8(b"0x5e156f1207d0ebfa19a9eeff00d62a282278fb8719f4fab3a586a0a2c0fffbea::coin::T"),
                string::utf8(b"0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD"),
                string::utf8(b"0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC"),
                string::utf8(b"0x1::aptos_coin::AptosCoin")],
            0
        );
        // 2-asset stable pool
        assert!(
            pool_asset_names(string::utf8(b"0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::stable_pool::StablePool<0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD, 0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null>"))
                == vector[string::utf8(b"0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD"), string::utf8(b"0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC")],
            0
        );
        // 3-asset stable pool
        assert!(
            pool_asset_names(string::utf8(b"0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::stable_pool::StablePool<0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD, 0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC, 0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null>")) == vector[
                string::utf8(b"0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD"),
                string::utf8(b"0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC"),
                string::utf8(b"0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT"),
            ],
            0
        );
        // 4-asset stable pool
        assert!(
            pool_asset_names(string::utf8(b"0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::stable_pool::StablePool<0x5e156f1207d0ebfa19a9eeff00d62a282278fb8719f4fab3a586a0a2c0fffbea::coin::T, 0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD, 0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC, 0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT, 0x48271d39d0b05bd6efca2278f22277d6fcc375504f9839fd73f74ace240861af::base_pool::Null>")) == vector[
                string::utf8(b"0x5e156f1207d0ebfa19a9eeff00d62a282278fb8719f4fab3a586a0a2c0fffbea::coin::T"),
                string::utf8(b"0x6f986d146e4a90b828d8c12c14b6f4e003fdff11a8eecceceb63744363eaac01::mod_coin::MOD"),
                string::utf8(b"0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC"),
                string::utf8(b"0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT"),
            ],
            0
        );
    }
}

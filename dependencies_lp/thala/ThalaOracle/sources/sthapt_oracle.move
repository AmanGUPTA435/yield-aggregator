/// sthAPT price is the multiplication of 3 values:
/// 1. APT-USD price, obtained from tiered_oracle module
/// 2. THAPT-APT price, obtained from thapt_oracle module
/// 3. STHAPT-THAPT conversion rate, obtained from thala_lsd::staking module
/// See thapt_oracle.move for the setup and operation guide
module thala_oracle::sthapt_oracle {
    use aptos_std::type_info;
    use aptos_framework::aptos_coin::AptosCoin;
    use fixed_point64::fixed_point64::{Self, FixedPoint64};
    use thala_oracle::status;
    use thala_oracle::tiered_oracle;
    use thala_lsd::staking::{Self, ThalaAPT};

    const ERR_STHAPT_ORACLE_INVALID_PRICE: u64 = 0;

    public fun get_and_update_price(): FixedPoint64 {
        let apt_usd_price = tiered_oracle::get_and_update_price(type_info::type_name<AptosCoin>());
        let thapt_apt_price = tiered_oracle::get_and_update_price(type_info::type_name<ThalaAPT>());
        let (num, denom) = staking::thAPT_sthAPT_exchange_rate_synced();
        multiply_prices(apt_usd_price, thapt_apt_price, num, denom)
    }

    #[view]
    /// This function does not abort if any tiered oracle is broken
    /// Instead, it returns the status enum that is the "worst" status of all underlying tiered oracles
    /// For example, if either of APT-USD or THAPT-APT is in "broken" status, this function will return "broken" status
    public fun get_price_unsafe(): (u8, FixedPoint64) {
        let (apt_usd_status, apt_usd_price) = tiered_oracle::get_price_unsafe(type_info::type_name<AptosCoin>());
        let (thapt_apt_status, thapt_apt_price) = tiered_oracle::get_price_unsafe(type_info::type_name<ThalaAPT>());
        let (num, denom) = staking::thAPT_sthAPT_exchange_rate_synced();
        let price = multiply_prices(apt_usd_price, thapt_apt_price, num, denom);
        // Normal status = 100, stale status = 101, broken status = 102
        // The "worst" status is the highest number
        let status = if (apt_usd_status > thapt_apt_status) {
            apt_usd_status
        } else {
            thapt_apt_status
        };
        (status, price)
    }

    #[view]
    public fun get_price(): FixedPoint64 {
        let (status, price) = get_price_unsafe();
        assert!(!status::is_broken_status(status), ERR_STHAPT_ORACLE_INVALID_PRICE);
        price
    }

    inline fun multiply_prices(apt_usd_price: FixedPoint64, thapt_apt_price: FixedPoint64, exchange_rate_num: u64, exchange_rate_denom: u64): FixedPoint64 {
        fixed_point64::mul_fp(apt_usd_price, fixed_point64::div(fixed_point64::mul(thapt_apt_price, exchange_rate_num), exchange_rate_denom))
    }

    #[test]
    fun test_multiply_prices() {
        let apt_usd_price = fixed_point64::fraction(75, 10); // 7.5
        let thapt_apt_price = fixed_point64::fraction(101, 100); // 1.01
        let exchange_rate_num = 1200000000000000; // 12M, in 8 decimals
        let exchange_rate_denom = 1000000000000000; // 10M, in 8 decimals
        let price = multiply_prices(apt_usd_price, thapt_apt_price, exchange_rate_num, exchange_rate_denom);
        // The result should be close to 9.09
        let expected_price = fixed_point64::fraction(909, 100);
        let diff = fixed_point64::sub_fp(expected_price, price);
        let epsilon = fixed_point64::fraction(1, 10000000);
        assert!(fixed_point64::lt(&diff, &epsilon), 0);
    }
}
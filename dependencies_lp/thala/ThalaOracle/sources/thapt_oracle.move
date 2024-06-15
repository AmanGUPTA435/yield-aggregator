/// thAPT price is the multiplication of 2 values:
/// 1. APT-USD price, obtained from tiered_oracle module
/// 2. THAPT-APT price, obtained from thapt_oracle module (it uses stable_pool_twap_oracle as the only tier-1 oracle under the hood)
/// 
/// Setup:
/// 1. Configure APTUSD Pyth price feed and set it as the tier-1 in tiered_oracle. Optionally, configure tier-2 oracle
/// 2. Call thalaswap::stable_pool::create_oracle<THAPT, APT, Null, Null, THAPT, APT> to enable cumulative price calculation
/// 3. Call thala_oracle::stable_pool_twap_oracle::configure<THAPT, APT, Null, Null, THAPT, APT> to enable TWAP price calculation.
///    Set quote_is_x = true and set a reasonable TWAP period
/// 4. Set tier-1 for THAPT to be the stable pool TWAP oracle
/// 5. (Optional) Call params::set_staleness_thresholds and set_price_deviate_reject_pct for THAPT
/// 
/// Remember:
/// ** tiered_oracle::get_price(thAPT) returns thAPT/APT TWAP exchange rate, not USD price **
/// 
/// Maintaining the price:
/// THAPT-APT TWAP price must be updated at an interval that is greater or equal than the TWAP period
/// It's required to set up a cron job to call stable_pool_twap_oracle::update_price<THAPT, APT, Null, Null, THAPT, APT>
module thala_oracle::thapt_oracle {
    use aptos_std::type_info;
    use aptos_framework::aptos_coin::AptosCoin;
    use fixed_point64::fixed_point64::{Self, FixedPoint64};
    use thala_oracle::status;
    use thala_oracle::tiered_oracle;
    use thala_lsd::staking::ThalaAPT;

    const ERR_THAPT_ORACLE_INVALID_PRICE: u64 = 0;

    public fun get_and_update_price(): FixedPoint64 {
        let apt_usd_price = tiered_oracle::get_and_update_price(type_info::type_name<AptosCoin>());
        let thapt_apt_price = tiered_oracle::get_and_update_price(type_info::type_name<ThalaAPT>());
        fixed_point64::mul_fp(apt_usd_price, thapt_apt_price)
    }

    #[view]
    /// This function does not abort if any tiered oracle is broken
    /// Instead, it returns the status enum that is the "worst" status of all underlying tiered oracles
    /// For example, if either of APT-USD or THAPT-APT is in "broken" status, this function will return "broken" status
    public fun get_price_unsafe(): (u8, FixedPoint64) {
        let (apt_usd_status, apt_usd_price) = tiered_oracle::get_price_unsafe(type_info::type_name<AptosCoin>());
        let (thapt_apt_status, thapt_apt_price) = tiered_oracle::get_price_unsafe(type_info::type_name<ThalaAPT>());
        let price = fixed_point64::mul_fp(apt_usd_price, thapt_apt_price);
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
        assert!(!status::is_broken_status(status), ERR_THAPT_ORACLE_INVALID_PRICE);
        price
    }
}
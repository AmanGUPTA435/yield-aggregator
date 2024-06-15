module thala_launch::fees {
    use std::string::{Self, String};

    use aptos_std::event::{Self, EventHandle};
    use aptos_std::table::{Self, Table};
    use aptos_std::type_info;
    use aptos_framework::account;
    use aptos_framework::coin::{Self, Coin};

    use thala_launch::package;

    use thala_manager::manager;

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    friend thala_launch::init;
    friend thala_launch::lbp;

    ///
    /// Error Codes
    ///

    // Authorization
    const ERR_UNAUTHORIZED: u64 = 0;

    // Initialization
    const ERR_INITIALIZED: u64 = 1;
    const ERR_UNINITIALIZED: u64 = 2;

    // Others
    const ERR_FEES_INVALID_PARAMETER: u64 = 3;
    const ERR_NO_CUSTOM_LBP_COMMISSION_RATE: u64 = 4;

    ///
    /// Defaults
    ///

    const DEFAULT_LBP_COMMISSION_BPS: u64 = 250;

    ///
    /// Constants
    ///

    const MAX_LBP_COMMISSION_BPS: u64 = 2000;

    const BPS_BASE: u64 = 10000;

    ///
    /// Resources
    ///

    struct FeeParams has key {
        lbp_commission_ratio: FixedPoint64,
        custom_lbp_commission_ratios: Table<String, FixedPoint64>,

        param_change_events: EventHandle<FeeParamChangeEvent>
    }

    ///
    /// Events
    ///

    struct FeeParamChangeEvent has drop, store {
        name: String,

        prev_value: u64,
        new_value: u64
    }

    ///
    /// Initialization
    ///

    public(friend) fun initialize() {
        let resource_account_signer = package::resource_account_signer();
        move_to(&resource_account_signer, FeeParams {
            lbp_commission_ratio: fixed_point64::fraction(DEFAULT_LBP_COMMISSION_BPS, BPS_BASE),
            custom_lbp_commission_ratios: table::new(),
            param_change_events: account::new_event_handle<FeeParamChangeEvent>(&resource_account_signer)
        });
    }

    ///
    /// Config & Param Management
    ///

    public entry fun set_default_lbp_commission_bps(manager: &signer, commission_bps: u64) acquires FeeParams {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(commission_bps <= MAX_LBP_COMMISSION_BPS, ERR_FEES_INVALID_PARAMETER);

        let fee_params = borrow_global_mut<FeeParams>(package::resource_account_address());
        let prev_bps = fixed_point64::decode(fixed_point64::mul(fee_params.lbp_commission_ratio, BPS_BASE));
        fee_params.lbp_commission_ratio = fixed_point64::fraction(commission_bps, BPS_BASE);

        event::emit_event<FeeParamChangeEvent>(
            &mut fee_params.param_change_events,
            FeeParamChangeEvent { name: string::utf8(b"lbp_commission_bps"), prev_value: prev_bps, new_value: commission_bps }
        );
    }

    public entry fun set_custom_lbp_commission_bps<CoinType>(manager: &signer, commission_bps: u64) acquires FeeParams {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(commission_bps <= MAX_LBP_COMMISSION_BPS, ERR_FEES_INVALID_PARAMETER);

        let coin_name = type_info::type_name<CoinType>();
        let fee_params = borrow_global_mut<FeeParams>(package::resource_account_address());
        let prev_bps =
            if (!table::contains(&fee_params.custom_lbp_commission_ratios, coin_name)) DEFAULT_LBP_COMMISSION_BPS
            else {
                let prev_commission_ratio = *table::borrow(&fee_params.custom_lbp_commission_ratios, coin_name);
                fixed_point64::decode(fixed_point64::mul(prev_commission_ratio, BPS_BASE))
            };

        // update
        table::upsert(&mut fee_params.custom_lbp_commission_ratios, coin_name, fixed_point64::fraction(commission_bps, BPS_BASE));

        let param_name = coin_name;
        string::append(&mut param_name, string::utf8(b":custom_lbp_commission_bps"));
        event::emit_event<FeeParamChangeEvent>(
            &mut fee_params.param_change_events,
            FeeParamChangeEvent { name:  param_name, prev_value: prev_bps, new_value: commission_bps }
        );
    }

    public entry fun unset_custom_lbp_commission_bps<CoinType>(manager: &signer) acquires FeeParams {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let coin_name = type_info::type_name<CoinType>();
        let fee_params = borrow_global_mut<FeeParams>(package::resource_account_address());
        assert!(table::contains(&fee_params.custom_lbp_commission_ratios, coin_name), ERR_NO_CUSTOM_LBP_COMMISSION_RATE);

        let commission_ratio = *table::borrow(&fee_params.custom_lbp_commission_ratios, coin_name);
        let prev_bps = fixed_point64::decode(fixed_point64::mul(commission_ratio, BPS_BASE));

        table::remove(&mut fee_params.custom_lbp_commission_ratios, coin_name);

        let param_name = coin_name;
        string::append(&mut param_name, string::utf8(b":custom_lbp_commission_bps"));
        event::emit_event<FeeParamChangeEvent>(
            &mut fee_params.param_change_events,
            FeeParamChangeEvent { name: param_name, prev_value: prev_bps, new_value: DEFAULT_LBP_COMMISSION_BPS }
        );
    }

    /// 
    /// Functions
    ///

    public(friend) fun absorb_fee<CoinType>(coin: Coin<CoinType>) {
        let resource_account_address = package::resource_account_address();
        if (!coin::is_account_registered<CoinType>(resource_account_address)) {
            coin::register<CoinType>(&package::resource_account_signer());
        };

        coin::deposit(resource_account_address, coin);
    }

    public fun withdraw_fee<CoinType>(manager: &signer, amount: u64): Coin<CoinType> {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        coin::withdraw<CoinType>(&package::resource_account_signer(), amount)
    }

    /// Calculate commission based on amount of base coin raised from LBP
    public fun lbp_commission_amount<CoinType>(amount: u64): u64 acquires FeeParams {
        assert!(initialized(), ERR_UNINITIALIZED);

        let coin_name = type_info::type_name<CoinType>();
        let fee_params = borrow_global<FeeParams>(package::resource_account_address());

        // we do not call `borrow_with_default` as that adds an entry to the table
        let default_commission_ratio = fee_params.lbp_commission_ratio;
        let commission_ratio =
            if (!table::contains(&fee_params.custom_lbp_commission_ratios, coin_name)) default_commission_ratio
            else *table::borrow(&fee_params.custom_lbp_commission_ratios, coin_name);

        fixed_point64::decode(fixed_point64::mul(commission_ratio, amount))
    }

    // Public Getters

    public fun initialized(): bool {
        exists<FeeParams>(package::resource_account_address())
    }

    public fun balance<CoinType>(): u64 {
        coin::balance<CoinType>(package::resource_account_address())
    }

    #[test_only]
    use thala_launch::coin_test;

    #[test_only]
    struct FakeCoin {}

    #[test_only]
    struct MODCoin {}

    #[test_only]
    public fun initialize_for_test(thala_launch: &signer) {
        // setup deps
        thala_manager::manager::initialize_for_test(std::signer::address_of(thala_launch));
        package::init_for_test();

        // initialize
        initialize();

        // initialize coin types
        coin_test::initialize_fake_coin<FakeCoin>(thala_launch);
        coin_test::initialize_fake_coin<MODCoin>(thala_launch);
    }

    #[test(thala_launch = @thala_launch)]
    fun initialized_ok(thala_launch: &signer) {
        initialize_for_test(thala_launch);
        assert!(initialized(), 0);
    }

    #[test(thala_launch = @thala_launch)]
    fun absorb_fee_ok(thala_launch: &signer) {
        initialize_for_test(thala_launch);

        absorb_fee(coin_test::mint_coin<FakeCoin>(thala_launch, 100));
        assert!(balance<FakeCoin>() == 100, 0);
    }

    #[test(thala_launch = @thala_launch)]
    #[expected_failure(abort_code = ERR_UNAUTHORIZED)]
    fun withdraw_fee_unauthorized_err(thala_launch: &signer) {
        initialize_for_test(thala_launch);
        absorb_fee(coin_test::mint_coin<FakeCoin>(thala_launch, 100));

        let non_manager = account::create_account_for_test(@0xA);
        coin::destroy_zero(withdraw_fee<FakeCoin>(&non_manager, 50));
    }

    #[test(thala_launch = @thala_launch)]
    fun withdraw_fee_ok(thala_launch: &signer) {
        initialize_for_test(thala_launch);
        absorb_fee(coin_test::mint_coin<FakeCoin>(thala_launch, 100));

        let fee = withdraw_fee<FakeCoin>(thala_launch, 50);
        assert!(coin::value(&fee) == 50, 0);

        coin_test::burn_coin(thala_launch, fee);
    }

    #[test(thala_launch = @thala_launch)]
    fun set_default_lbp_commission_ok(thala_launch: &signer) acquires FeeParams {
        initialize_for_test(thala_launch);

        set_default_lbp_commission_bps(thala_launch, 250); // 2.5%
        assert!(lbp_commission_amount<FakeCoin>(1000) == 25, 0);

        set_default_lbp_commission_bps(thala_launch, 100); // 1%
        assert!(lbp_commission_amount<FakeCoin>(1000) == 10, 0);
    }

    #[test(thala_launch = @thala_launch)]
    fun set_unset_custom_lbp_commission_ok(thala_launch: &signer) acquires FeeParams {
        initialize_for_test(thala_launch);

        set_default_lbp_commission_bps(thala_launch, 250); // default 2.5%
        assert!(lbp_commission_amount<FakeCoin>(1000) == 25, 0);
        assert!(lbp_commission_amount<MODCoin>(1000) == 25, 0);

        // custom rate only for MODCoin, 1%
        set_custom_lbp_commission_bps<MODCoin>(thala_launch, 100);
        assert!(lbp_commission_amount<FakeCoin>(1000) == 25, 0); // 2.5%
        assert!(lbp_commission_amount<MODCoin>(1000) == 10, 0); // 1%

        // unset mod
        unset_custom_lbp_commission_bps<MODCoin>(thala_launch);
        assert!(lbp_commission_amount<FakeCoin>(1000) == 25, 0); // 2.5%
        assert!(lbp_commission_amount<MODCoin>(1000) == 25, 0); // 2.5%
    }

    #[test(thala_launch = @thala_launch)]
    #[expected_failure(abort_code = ERR_NO_CUSTOM_LBP_COMMISSION_RATE)]
    fun unset_custom_lbp_commission_no_rate_err(thala_launch: &signer) acquires FeeParams {
        initialize_for_test(thala_launch);
        unset_custom_lbp_commission_bps<MODCoin>(thala_launch);
    }
}

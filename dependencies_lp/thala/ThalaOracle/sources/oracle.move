module thala_oracle::oracle {
    use std::string::String;
    use std::signer;

    use aptos_std::type_info;

    use fixed_point64::fixed_point64::FixedPoint64;

    use thala_oracle::package;
    use thala_oracle::params;
    use thala_oracle::sthapt_oracle;
    use thala_oracle::thapt_oracle;
    use thala_oracle::tiered_oracle;

    use thala_manager::manager;
    use thala_lsd::staking::{StakedThalaAPT, ThalaAPT};
    
    const ERR_UNAUTHORIZED: u64 = 0;
    const ERR_PACKAGE_UNINITIALIZED: u64 = 1;
    const ERR_MANAGER_UNINITIALIZED: u64 = 2;

    /// Entry point for the entire package
    public entry fun initialize(deployer: &signer) {
        assert!(signer::address_of(deployer) == @thala_oracle_deployer, ERR_UNAUTHORIZED);

        // Key dependencies
        assert!(package::initialized(), ERR_PACKAGE_UNINITIALIZED);
        assert!(manager::initialized(), ERR_MANAGER_UNINITIALIZED);
        
        params::initialize();
        tiered_oracle::initialize();
    }

    public fun get_and_update_price<CoinType>(): FixedPoint64 {
        get_and_update_price_by_name(type_info::type_name<CoinType>())
    }

    public fun get_and_update_price_by_name(coin_name: String): FixedPoint64 {
        if (coin_name == type_info::type_name<StakedThalaAPT>()) sthapt_oracle::get_and_update_price()
        else if (coin_name == type_info::type_name<ThalaAPT>()) thapt_oracle::get_and_update_price()
        else tiered_oracle::get_and_update_price(coin_name)
    }

    public fun get_price_by_name(coin_name: String): FixedPoint64 {
        if (coin_name == type_info::type_name<StakedThalaAPT>()) sthapt_oracle::get_price()
        else if (coin_name == type_info::type_name<ThalaAPT>()) thapt_oracle::get_price()
        else tiered_oracle::get_price(coin_name)
    }

    public fun get_price_by_name_unsafe(coin_name: String): (u8, FixedPoint64) {
        if (coin_name == type_info::type_name<StakedThalaAPT>()) sthapt_oracle::get_price_unsafe()
        else if (coin_name == type_info::type_name<ThalaAPT>()) thapt_oracle::get_price_unsafe()
        else tiered_oracle::get_price_unsafe(coin_name)
    }

    #[view]
    public fun get_price<CoinType>(): FixedPoint64 {
        get_price_by_name(type_info::type_name<CoinType>())
    }

    #[view]
    public fun get_price_unsafe<CoinType>(): (u8, FixedPoint64) {
        get_price_by_name_unsafe(type_info::type_name<CoinType>())
    }

    #[test_only]
    public fun initialize_for_test() {
        package::init_for_test();

        let deployer = aptos_framework::account::create_signer_for_test(@thala_oracle_deployer);
        initialize(&deployer);
    }
}

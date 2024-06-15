module avex::amnis_aries_amapt {
    use avex::helpers;
    use controller::controller;
    use controller::profile;
    use aptos_framework::aptos_coin::AptosCoin;
    use amnis::router;
    use amnis::stapt_token::{Self,StakedApt};
    use thalaswap::stable_pool;
    use thalaswap::base_pool;
    use amnis::amapt_token::AmnisApt;
    #[event]
    struct LeveragedAriesAmaptClaimRewards has drop, store {
        user: address,
        amount: u64,
    }
    #[event]
    struct LeveragedAriesAmaptDeposit has drop, store {
        user: address,
        amount: u64,
        leverage: u64,
    }
    #[event]
    struct LeveragedAriesAmaptUpdateLeverage has drop, store {
        user: address,
        old_leverage: u64,
        new_leverage: u64,
    }
    #[event]
    struct LeveragedAriesAmaptWithdraw has drop, store {
        user: address,
        amount: u64,
    }
    
    entry fun deposit(arg0: &signer, arg1: u64, arg2: u64) {
        validate_inputs(arg1, arg2);
        helpers::ensure_aries_profile_exists(arg0, b"avex::amnis_aries_amapt");
        let v0 = (((arg1 as u128) * (20 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer(arg0, @avex, v0);
        let v1 = arg1 - v0;
        add_position(arg0, v1, (((v1 as u128) * ((arg2 - 100) as u128) / (100 as u128)) as u64), 1);
        let v2 = LeveragedAriesAmaptDeposit{
            user     : 0x1::signer::address_of(arg0), 
            amount   : v1, 
            leverage : arg2,
        };
        0x1::event::emit<LeveragedAriesAmaptDeposit>(v2);
    }
    
    entry fun withdraw(arg0: &signer, arg1: bool, arg2: u64) {
        let v0 = 0x1::signer::address_of(arg0);
        let (_, _, v3, _, v5) = get_users_position(v0);
        if (v5 == 0) {
            return
        };
        repay_with_flashloan(arg0, v3, true);
        if (arg1) {
            let v6 = router::unstake(0x1::coin::withdraw<StakedApt>(arg0, helpers::balance<StakedApt>(v0)));
            let v10 = 0x1::coin::value<AmnisApt>(&v6);
            let v7 = stable_pool::swap_exact_in<AmnisApt, 0x1::aptos_coin::AptosCoin, base_pool::Null, base_pool::Null, AmnisApt, 0x1::aptos_coin::AptosCoin>(v6);
            let v9 = 0x1::coin::value<AptosCoin>(&v7);
            assert!(v9 >= helpers::min_amount_with_slippage(v10, arg2), 5);
            // assert!(0x1::coin::value<AptosCoin>(v9) >= helpers::min_amount_with_slippage(0x1::coin::value<AmnisApt>(&v6)), arg2), 5);
            0x1::coin::deposit<0x1::aptos_coin::AptosCoin>(v0, v7);
        };
        let v8 = LeveragedAriesAmaptWithdraw{
            user   : v0, 
            amount : v5,
        };
        0x1::event::emit<LeveragedAriesAmaptWithdraw>(v8);
    }
    
    fun add_position(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) {
        assert!(arg1 + arg2 > 0, 3);
        if (arg1 > 0) {
            let v0 = if (arg3 == 1) {
                router::deposit_and_stake(0x1::coin::withdraw<0x1::aptos_coin::AptosCoin>(arg0, arg1))
            } else {
                let v1 = if (arg3 == 2) {
                    router::stake(0x1::coin::withdraw<AmnisApt>(arg0, arg1))
                } else {
                    0x1::coin::withdraw<StakedApt>(arg0, arg1)
                };
                v1
            };
            let v2 = 0x1::coin::value<StakedApt> (&v0);
            0x1::aptos_account::deposit_coins<StakedApt>(0x1::signer::address_of(arg0), v0);
            controller::deposit<StakedApt>(arg0, b"avex::amnis_aries_amapt", v2, false);
        };
        if (arg2 > 0) {
            let (v3, v4) = controller::begin_flash_loan<AmnisApt>(arg0, 0x1::string::utf8(b"avex::amnis_aries_amapt"), arg2);
            controller::end_flash_loan<StakedApt>(v3, router::stake(v4));
        };
    }
    
    entry fun decrease_leverage(arg0: &signer, arg1: u64) {
        assert!(arg1 > 100, 2);
        let (_, v1, _, v3, _) = get_users_position(0x1::signer::address_of(arg0));
        if (arg1 < v3) {
            repay_with_flashloan(arg0, (((v1 as u128) * ((v3 - arg1) as u128) / (100 as u128)) as u64), false);
            let v5 = LeveragedAriesAmaptUpdateLeverage{
                user         : 0x1::signer::address_of(arg0), 
                old_leverage : v3, 
                new_leverage : arg1,
            };
            0x1::event::emit<LeveragedAriesAmaptUpdateLeverage>(v5);
        };
    }
    
    entry fun deposit_amapt(arg0: &signer, arg1: u64, arg2: u64) {
        validate_inputs(arg1, arg2);
        helpers::ensure_aries_profile_exists(arg0, b"avex::amnis_aries_amapt");
        let v0 = (((arg1 as u128) * (20 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer_coins<AmnisApt>(arg0, @avex, v0);
        let v1 = arg1 - v0;
        add_position(arg0, v1, (((v1 as u128) * ((arg2 - 100) as u128) / (100 as u128)) as u64), 2);
        let v2 = LeveragedAriesAmaptDeposit{
            user     : 0x1::signer::address_of(arg0), 
            amount   : v1, 
            leverage : arg2,
        };
        0x1::event::emit<LeveragedAriesAmaptDeposit>(v2);
    }
    
    entry fun deposit_stapt(arg0: &signer, arg1: u64, arg2: u64) {
        validate_inputs(arg1, arg2);
        helpers::ensure_aries_profile_exists(arg0, b"avex::amnis_aries_amapt");
        let v0 = (((arg1 as u128) * (20 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer_coins<StakedApt>(arg0, @avex, v0);
        let v1 = arg1 - v0;
        let v2 = (((v1 as u128) * (stapt_token::stapt_price() as u128) / (stapt_token::precision_u64() as u128)) as u64);
        add_position(arg0, v1, (((v2 as u128) * ((arg2 - 100) as u128) / (100 as u128)) as u64), 3);
        let v3 = LeveragedAriesAmaptDeposit{
            user     : 0x1::signer::address_of(arg0), 
            amount   : v2, 
            leverage : arg2,
        };
        0x1::event::emit<LeveragedAriesAmaptDeposit>(v3);
    }
    
    public fun get_users_position(arg0: address) : (u64, u64, u64, u64, u64) {
        let v0 = 0x1::string::utf8(b"avex::amnis_aries_amapt");
        let (_, v2) = profile::profile_deposit<StakedApt>(arg0, v0);
        if (v2 == 0) {
            return (0, 0, 0, 0, 0)
        };
        let (_, v4) = profile::profile_loan<AmnisApt>(arg0, v0);
        let v5 = (((v2 as u128) * (stapt_token::stapt_price() as u128) / (stapt_token::precision_u64() as u128)) as u64);
        if (v4 == 0) {
            return (v5, v5, 0, 0, v2)
        };
        let v6 = ((v4 / 1000000000000000000) as u64);
        let v7 = v5 - v6;
        (v5, v7, v6, (((v5 as u128) * (100 as u128) / (v7 as u128)) as u64), v2)
    }
    
    entry fun increase_leverage(arg0: &signer, arg1: u64) {
        assert!(arg1 <= 295, 1);
        let (_, v1, _, v3, _) = get_users_position(0x1::signer::address_of(arg0));
        if (v3 < arg1) {
            add_position(arg0, 0, (((v1 as u128) * ((arg1 - v3) as u128) / (100 as u128)) as u64), 1);
            let v5 = LeveragedAriesAmaptUpdateLeverage{
                user         : 0x1::signer::address_of(arg0), 
                old_leverage : v3, 
                new_leverage : arg1,
            };
            0x1::event::emit<LeveragedAriesAmaptUpdateLeverage>(v5);
        };
    }
    
    fun repay_with_flashloan(arg0: &signer, arg1: u64, arg2: bool) {
        let v0 = 0x1::signer::address_of(arg0);
        let (_, v2) = profile::profile_loan<AmnisApt>(v0, 0x1::string::utf8(b"avex::amnis_aries_amapt"));
        if (v2 > 0) {
            let (v3, v4) = controller::begin_flash_loan<StakedApt>(arg0, 0x1::string::utf8(b"avex::amnis_aries_amapt"), (((arg1 as u128) * (stapt_token::precision_u64() as u128) / (stapt_token::stapt_price() as u128)) as u64) + 1);
            controller::end_flash_loan<AmnisApt>(v3, router::unstake(v4));
        };
        if (arg2) {
            let (_, v6) = profile::profile_loan<AmnisApt>(v0, 0x1::string::utf8(b"avex::amnis_aries_amapt"));
            if (v6 > 0) {
                let (_, v8) = profile::profile_deposit<StakedApt>(v0, 0x1::string::utf8(b"avex::amnis_aries_amapt"));
                controller::withdraw<StakedApt>(arg0, b"avex::amnis_aries_amapt", v8 - 2, false);
            } else {
                controller::withdraw<StakedApt>(arg0, b"avex::amnis_aries_amapt", 18446744073709551615, false);
            };
        };
    }
    
    fun validate_inputs(arg0: u64, arg1: u64) {
        assert!(arg0 >= 150000000, 4);
        assert!(arg1 > 100, 2);
        assert!(arg1 <= 295, 1);
    }
    
    // decompiled from Move bytecode v6
}


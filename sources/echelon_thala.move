module avex::echel_thala {
    use lending::scripts;
    use thala::staking::{Self,StakedThalaAPT,ThalaAPT};
    use lending::lending;
    use thalaswap::base_pool;
    use thalaswap::stable_pool;
    use controller::controller;
    use controller::profile;
    use avex::helpers;
    #[event]
    struct LeveragedEchelonAPTClaimRewards has drop, store {
        user: address,
        amount: u64,
    }
    #[event]
    struct LeveragedEchelonAPTDeposit has drop, store {
        user: address,
        amount: u64,
        leverage: u64,
    }
    #[event]
    struct LeveragedEchelonAPTUpdateLeverage has drop, store {
        user: address,
        old_leverage: u64,
        new_leverage: u64,
    }
    #[event]
    struct LeveragedEchelonAPTWithdraw has drop, store {
        user: address,
        amount: u64,
    }
    
    entry fun deposit(arg0: &signer, arg1: u64, arg2: u64) {
        validate_inputs(arg1, arg2);
        let v0 = (((arg1 as u128) * (20 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer(arg0, @avex, v0);
        let v1 = arg1 - v0;
        add_position(arg0, v1, (((v1 as u128) * ((arg2 - 100) as u128) / (100 as u128)) as u64), 1);
        let v2 = LeveragedEchelonAPTDeposit{
            user     : 0x1::signer::address_of(arg0), 
            amount   : v1, 
            leverage : arg2,
        };
        0x1::event::emit<LeveragedEchelonAPTDeposit>(v2);
    }
    
    entry fun withdraw(arg0: &signer, arg1: bool, arg2: u64) {
        let v0 = 0x1::signer::address_of(arg0);
        let (_, _, v3, _, v5) = get_users_position(v0);
        if (v5 == 0) {
            return
        };
        if (v3 > 0) {
            repay_with_flashloan(arg0, v3, true, arg2);
        };
        let (_, _, _, _, v10) = get_users_position(v0);
        scripts::withdraw<StakedThalaAPT>(arg0, 0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42), lending::coins_to_shares(0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42), v10));
        if (arg1) {
            let v11 = staking::unstake_thAPT(arg0, 0x1::coin::withdraw<StakedThalaAPT>(arg0, helpers::balance<StakedThalaAPT>(v0) - helpers::balance<StakedThalaAPT>(v0)));
            let v14 = 0x1::coin::value<ThalaAPT>(&v11);
            let v12 = stable_pool::swap_exact_in<staking::ThalaAPT, 0x1::aptos_coin::AptosCoin, base_pool::Null, base_pool::Null, staking::ThalaAPT, 0x1::aptos_coin::AptosCoin>(v11);
            assert!(0x1::coin::value<0x1::aptos_coin::AptosCoin>(&v12) >= helpers::min_amount_with_slippage(v14, arg2), 5);
            0x1::coin::deposit<0x1::aptos_coin::AptosCoin>(v0, v12);
        };
        let v13 = LeveragedEchelonAPTWithdraw{
            user   : v0, 
            amount : v10,
        };
        0x1::event::emit<LeveragedEchelonAPTWithdraw>(v13);
    }
    
    fun add_position(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) {
        assert!(arg1 + arg2 > 0, 3);
        if (arg1 > 0) {
            let v0 = if (arg3 == 1) {
                stake_apt_to_sthapt(arg0, 0x1::coin::withdraw<0x1::aptos_coin::AptosCoin>(arg0, arg1))
            } else {
                let v1 = if (arg3 == 2) {
                    staking::stake_thAPT(arg0, 0x1::coin::withdraw<staking::ThalaAPT>(arg0, arg1))
                } else {
                    0x1::coin::withdraw<StakedThalaAPT>(arg0, arg1)
                };
                v1
            };
            let v2 = 0x1::coin::value<StakedThalaAPT>(&v0);
            0x1::aptos_account::deposit_coins<StakedThalaAPT>(0x1::signer::address_of(arg0), v0);
            scripts::supply<StakedThalaAPT>(arg0, 0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42), v2);
        };
        if (arg2 > 0) {
            let (v3, v4) = flashloan_apt(arg0, arg2);
            lending::supply<StakedThalaAPT>(arg0, 0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42), stake_apt_to_sthapt(arg0, v3));
            controller::end_flash_loan<0x1::aptos_coin::AptosCoin>(v4, lending::borrow<0x1::aptos_coin::AptosCoin>(arg0, 0x1::object::address_to_object<lending::Market>(@0x761a97787fa8b3ae0cef91ebc2d96e56cc539df5bc88dadabee98ae00363a831), arg2 + 1));
        };
    }
    
    entry fun decrease_leverage_with_slippage(arg0: &signer, arg1: u64, arg2: u64) {
        assert!(arg1 > 100, 2);
        let (_, v1, _, v3, _) = get_users_position(0x1::signer::address_of(arg0));
        if (arg1 < v3) {
            repay_with_flashloan(arg0, (((v1 as u128) * ((v3 - arg1) as u128) / (100 as u128)) as u64), false, arg2);
            let v5 = LeveragedEchelonAPTUpdateLeverage{
                user         : 0x1::signer::address_of(arg0), 
                old_leverage : v3, 
                new_leverage : arg1,
            };
            0x1::event::emit<LeveragedEchelonAPTUpdateLeverage>(v5);
        };
    }
    
    entry fun deposit_sthapt(arg0: &signer, arg1: u64, arg2: u64) {
        validate_inputs(arg1, arg2);
        let v0 = (((arg1 as u128) * (20 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer_coins<StakedThalaAPT>(arg0, @avex, v0);
        let v1 = arg1 - v0;
        let (v2, v3) = staking::thAPT_sthAPT_exchange_rate_synced();
        let v4 = (((v1 as u128) * (v2 as u128) / (v3 as u128)) as u64);
        add_position(arg0, v1, (((v4 as u128) * ((arg2 - 100) as u128) / (100 as u128)) as u64), 3);
        let v5 = LeveragedEchelonAPTDeposit{
            user     : 0x1::signer::address_of(arg0), 
            amount   : v4, 
            leverage : arg2,
        };
        0x1::event::emit<LeveragedEchelonAPTDeposit>(v5);
    }
    
    entry fun deposit_thapt(arg0: &signer, arg1: u64, arg2: u64) {
        validate_inputs(arg1, arg2);
        let v0 = (((arg1 as u128) * (20 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer_coins<staking::ThalaAPT>(arg0, @avex, v0);
        let v1 = arg1 - v0;
        add_position(arg0, v1, (((v1 as u128) * ((arg2 - 100) as u128) / (100 as u128)) as u64), 2);
        let v2 = LeveragedEchelonAPTDeposit{
            user     : 0x1::signer::address_of(arg0), 
            amount   : v1, 
            leverage : arg2,
        };
        0x1::event::emit<LeveragedEchelonAPTDeposit>(v2);
    }
    
    fun flashloan_apt(arg0: &signer, arg1: u64) : (0x1::coin::Coin<0x1::aptos_coin::AptosCoin>, profile::CheckEquity) {
        helpers::ensure_aries_profile_exists(arg0, b"");
        let (v0, v1) = controller::begin_flash_loan<0x1::aptos_coin::AptosCoin>(arg0, 0x1::string::utf8(b""), arg1);
        (v1, v0)
    }
    
    public fun get_users_position(arg0: address) : (u64, u64, u64, u64, u64) {
        let v0 = lending::account_coins(arg0, 0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42));
        if (v0 == 0) {
            return (0, 0, 0, 0, 0)
        };
        let v1 = lending::account_liability(arg0, 0x1::object::address_to_object<lending::Market>(@0x761a97787fa8b3ae0cef91ebc2d96e56cc539df5bc88dadabee98ae00363a831));
        let (v2, v3) = staking::thAPT_sthAPT_exchange_rate_synced();
        let v4 = (((v0 as u128) * (v2 as u128) / (v3 as u128)) as u64);
        if (v1 == 0) {
            return (v4, v4, 0, 0, v0)
        };
        let v5 = v4 - v1;
        (v4, v5, v1, (((v4 as u128) * (100 as u128) / (v5 as u128)) as u64), v0)
    }
    
    entry fun increase_leverage(arg0: &signer, arg1: u64) {
        assert!(arg1 <= 295, 1);
        let (_, v1, _, v3, _) = get_users_position(0x1::signer::address_of(arg0));
        if (v3 < arg1) {
            add_position(arg0, 0, (((v1 as u128) * ((arg1 - v3) as u128) / (100 as u128)) as u64), 1);
            let v5 = LeveragedEchelonAPTUpdateLeverage{
                user         : 0x1::signer::address_of(arg0), 
                old_leverage : v3, 
                new_leverage : arg1,
            };
            0x1::event::emit<LeveragedEchelonAPTUpdateLeverage>(v5);
        };
    }
    
    fun repay_with_flashloan(arg0: &signer, arg1: u64, arg2: bool, arg3: u64) {
        let (v0, v1) = flashloan_apt(arg0, arg1);
        lending::repay<0x1::aptos_coin::AptosCoin>(arg0, 0x1::object::address_to_object<lending::Market>(@0x761a97787fa8b3ae0cef91ebc2d96e56cc539df5bc88dadabee98ae00363a831), v0);
        let v2 = staking::unstake_thAPT(arg0, lending::withdraw<StakedThalaAPT>(arg0, 0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42), lending::coins_to_shares(0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42), lending::account_withdrawable_coins(0x1::signer::address_of(arg0), 0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42)))));
        let v7 = 0x1::coin::value<ThalaAPT>(&v2);
        let v3 = arg1 + 1;
        let (v4, v5) = stable_pool::swap_exact_out<staking::ThalaAPT, 0x1::aptos_coin::AptosCoin, base_pool::Null, base_pool::Null, staking::ThalaAPT, 0x1::aptos_coin::AptosCoin>(v2, v3);
        let v6 = v4;
        assert!(v7 - 0x1::coin::value<staking::ThalaAPT>(&v6) <= (((v3 as u128) * ((10000 + arg3) as u128) / (10000 as u128)) as u64), 5);
        controller::end_flash_loan<0x1::aptos_coin::AptosCoin>(v1, v5);
        if (0x1::coin::value<staking::ThalaAPT>(&v6) > 0) {
            if (arg2) {
                0x1::aptos_account::deposit_coins<StakedThalaAPT>(0x1::signer::address_of(arg0), staking::stake_thAPT(arg0, v6));
            } else {
                lending::supply<StakedThalaAPT>(arg0, 0x1::object::address_to_object<lending::Market>(@0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42), staking::stake_thAPT(arg0, v6));
            };
        } else {
            0x1::coin::destroy_zero<staking::ThalaAPT>(v6);
        };
    }
    
    fun stake_apt_to_sthapt(arg0: &signer, arg1: 0x1::coin::Coin<0x1::aptos_coin::AptosCoin>) : 0x1::coin::Coin<StakedThalaAPT> {
        staking::stake_thAPT(arg0, staking::stake_APT(arg0, arg1))
    }
    
    fun validate_inputs(arg0: u64, arg1: u64) {
        // assert!(arg0 >= 150000000, 4);
        assert!(arg1 > 100, 2);
        assert!(arg1 <= 295, 1);
    }
    
    // decompiled from Move bytecode v6
}


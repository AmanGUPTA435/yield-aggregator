module avex::aries_amni {
    use controller::controller;
    use amnis::router;
    use amnis::stapt_token::{Self,StakedApt};
    use amnis::amapt_token::{AmnisApt};
    use liquidswap_v05::liquidity_pool;
    use liquidswap_v05::router as router_ls;
    use liquidswap_v05::curves;
    use controller::profile;
    use avex::helpers;
    #[event]
    struct LeveragedAriesAmnisClaimRewards has drop, store {
        user: address,
        amount: u64,
    }
    #[event]
    struct LeveragedAriesAmnisDeposit has drop, store {
        user: address,
        amount: u64,
    }
    #[event]
    struct LeveragedAriesAmnisUpdateLeverage has drop, store {
        user: address,
        old_leverage: u64,
        new_leverage: u64,
    }
    #[event]
    struct LeveragedAriesAmnisWithdraw has drop, store {
        user: address,
        amount: u64,
    }
    
    entry fun deposit(user: &signer, deposit_amount: u64, leverage: u64) {
        // assert!(deposit_amount >= 150000000, 4);
        assert!(leverage > 100, 2);
        assert!(leverage <= 240, 1);
        helpers::ensure_aries_profile_exists(user, b"avex::aries_lending");
        let fee = (((deposit_amount as u128) * (15 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer(user, @avex, fee);
        // let v1 = deposit_amount - fee;
        let v1 = deposit_amount;
        let v3 = (((v1 as u128) * ((leverage - 100) as u128) / (100 as u128)) as u64);
        add_position(user, v1, v3);
        let v2 = LeveragedAriesAmnisDeposit{
            user   : 0x1::signer::address_of(user), 
            amount : v1,
        };
        0x1::event::emit<LeveragedAriesAmnisDeposit>(v2);
    }
    
    entry fun withdraw(user: &signer, arg1: bool, withdraw_amount: u64) {
        withdraw_with_profile(user, b"avex::aries_lending", arg1, withdraw_amount);
    }
    
    fun add_position(user: &signer, arg1: u64, arg2: u64) {
        assert!(arg1 + arg2 > 0, 3);
        if (arg1 > 0) {
            let v0 = router::deposit_and_stake(0x1::coin::withdraw<0x1::aptos_coin::AptosCoin>(user, arg1));
            let v7=0x1::coin::value<StakedApt>(&v0);
            0x1::aptos_account::deposit_coins<StakedApt>(0x1::signer::address_of(user), v0);
            controller::deposit<StakedApt>(user, b"avex::aries_lending", v7, false);
        };
        if (arg2 > 0) {
            let (v1, v2) = controller::begin_flash_loan<0x1::aptos_coin::AptosCoin>(user, 0x1::string::utf8(b"avex::aries_lending"), arg2);
            controller::end_flash_loan<StakedApt>(v1, router::deposit_and_stake(v2));
        };
    }
    
    entry fun decrease_leverage(user: &signer, reduced_leverage: u64) {
        assert!(reduced_leverage > 100, 2);
        let (_, v1, _, v3, _) = get_users_position(0x1::signer::address_of(user));
        if (reduced_leverage < v3) {
            let v4 = (((v1 as u128) * ((v3 - reduced_leverage) as u128) / (100 as u128)) as u64);
            repay_with_flashloan(user, b"avex::aries_lending", v4, false);
            let v5 = LeveragedAriesAmnisUpdateLeverage{
                user         : 0x1::signer::address_of(user), 
                old_leverage : v3, 
                new_leverage : reduced_leverage,
            };
            0x1::event::emit<LeveragedAriesAmnisUpdateLeverage>(v5);
        };
    }
    
    entry fun decrease_leverage_with_repay(user: &signer, arg1: u64) {
        let (_, v1, _, v3, _) = get_users_position(0x1::signer::address_of(user));
        if (arg1 < v3) {
            let v4 = (((v1 as u128) * ((v3 - arg1) as u128) / (100 as u128)) as u64);
            add_position(user, v4, 0);
            let v5 = LeveragedAriesAmnisUpdateLeverage{
                user         : 0x1::signer::address_of(user), 
                old_leverage : v3, 
                new_leverage : arg1,
            };
            0x1::event::emit<LeveragedAriesAmnisUpdateLeverage>(v5);
        };
    }
    
    public fun get_users_position(arg0: address) : (u64, u64, u64, u64, u64) {
        get_users_position_for_profile(arg0, b"avex::aries_lending")
    }
    
    fun get_users_position_for_profile(arg0: address, arg1: vector<u8>) : (u64, u64, u64, u64, u64) {
        let v0 = 0x1::string::utf8(arg1);
        let (_, v2) = profile::profile_deposit<StakedApt>(arg0, v0);
        if (v2 == 0) {
            return (0, 0, 0, 0, 0)
        };
        let (_, v4) = profile::profile_loan<0x1::aptos_coin::AptosCoin>(arg0, v0);
        let v5 = (((v2 as u128) * (stapt_token::stapt_price() as u128) / (stapt_token::precision_u64() as u128)) as u64);
        if (v4 == 0) {
            return (v5, v5, 0, 0, v2)
        };
        let v6 = ((v4 / 1000000000000000000) as u64);
        let v7 = v5 - v6;
        let v8 = (((v5 as u128) * (100 as u128) / (v7 as u128)) as u64);
        (v5, v7, v6, v8, v2)
    }
    
    entry fun increase_leverage(arg0: &signer, arg1: u64) {
        assert!(arg1 <= 240, 1);
        let (_, v1, _, v3, _) = get_users_position(0x1::signer::address_of(arg0));
        if (v3 < arg1) {
            let v4 = (((v1 as u128) * ((arg1 - v3) as u128) / (100 as u128)) as u64);
            add_position(arg0, 0, v4);
            let v5 = LeveragedAriesAmnisUpdateLeverage{
                user         : 0x1::signer::address_of(arg0), 
                old_leverage : v3, 
                new_leverage : arg1,
            };
            0x1::event::emit<LeveragedAriesAmnisUpdateLeverage>(v5);
        };
    }
    
    fun repay_with_flashloan(arg0: &signer, arg1: vector<u8>, arg2: u64, arg3: bool) {
        let (v0, v1, v2) = liquidity_pool::flashloan<amnis::amapt_token::AmnisApt, 0x1::aptos_coin::AptosCoin, curves::Stable>(0, arg2);
        0x1::coin::destroy_zero<AmnisApt>(v0);
        0x1::coin::deposit<0x1::aptos_coin::AptosCoin>(0x1::signer::address_of(arg0), v1);
        let v3 = if (arg3) {
            18446744073709551615
        } else {
            arg2
        };
        controller::deposit<0x1::aptos_coin::AptosCoin>(arg0, arg1, v3, true);
        let v4 = 0x1::signer::address_of(arg0);
        controller::withdraw<StakedApt>(arg0, arg1, (((router_ls::get_amount_in<AmnisApt, 0x1::aptos_coin::AptosCoin, curves::Stable>(arg2) as u128) * (stapt_token::precision_u64() as u128) / (stapt_token::stapt_price() as u128)) as u64) + 1, false);
        liquidity_pool::pay_flashloan<AmnisApt, 0x1::aptos_coin::AptosCoin, curves::Stable>(router::unstake(0x1::coin::withdraw<StakedApt>(arg0, helpers::balance<StakedApt>(v4))), 0x1::coin::zero<0x1::aptos_coin::AptosCoin>(), v2);
    }
    
    entry fun withdraw_from_main(arg0: &signer, arg1: bool, arg2: u64) {
        withdraw_with_profile(arg0, b"Main Account", arg1, arg2);
    }
    
    fun withdraw_with_profile(arg0: &signer, arg1: vector<u8>, arg2: bool, arg3: u64) {
        let v0 = 0x1::signer::address_of(arg0);
        let (_, _, v3, _, v5) = get_users_position_for_profile(v0, arg1);
        if (v5 == 0) {
            return
        };
        if (v3 > 0) {
            repay_with_flashloan(arg0, arg1, v3, true);
        };
        controller::withdraw<StakedApt>(arg0, arg1, 18446744073709551615, false);
        if (arg2) {
            let v6 = router::unstake(0x1::coin::withdraw<StakedApt>(arg0, helpers::balance<StakedApt>(v0)));
            let v8 = 0x1::coin::value<AmnisApt>(&v6);
            0x1::coin::deposit<0x1::aptos_coin::AptosCoin>(v0, router_ls::swap_exact_coin_for_coin<AmnisApt, 0x1::aptos_coin::AptosCoin, curves::Stable>(v6, helpers::min_amount_with_slippage(v8, arg3)));
        };
        let v7 = LeveragedAriesAmnisWithdraw{
            user   : v0, 
            amount : v5,
        };
        0x1::event::emit<LeveragedAriesAmnisWithdraw>(v7);
    }
    
    // decompiled from Move bytecode v6
}


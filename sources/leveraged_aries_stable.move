module avex::leverage_aries_stable {
    use coin::coin;
    use avex::helpers;
    // use 0x1::coin;
    use controller::controller;
    use bridge::asset::{USDC};
    use controller::profile::{Self,CheckEquity};
    use pancake::router as router_p;
    #[event]
    struct LeveragedAriesClaimRewards has drop, store {
        user: address,
        amount: u64,
    }
    #[event]
    struct LeveragedAriesDeposit has drop, store {
        user: address,
        amount: u64,
    }
    #[event]
    struct LeveragedAriesUpdateLeverage has drop, store {
        user: address,
        old_leverage: u64,
        new_leverage: u64,
    }
    #[event]
    struct LeveragedAriesWithdraw has drop, store {
        user: address,
        amount: u64,
    }
    
    entry public fun deposit(user: &signer, amount: u64, leverage: u64) {
        assert!(leverage > 100, 2);
        assert!(leverage <= 450, 1);
        helpers::ensure_aries_profile_exists(user, b"avex::aries_lending");
        helpers::ensure_aries_profile_exists(user, b"avex::aries_lending_2");
        let fee = (((amount as u128) * (20 as u128) / (10000 as u128)) as u64);
        0x1::aptos_account::transfer(user, @avex, fee);
        let final_deposit = amount - fee;
        let borrow_amount = (((final_deposit as u128) * ((leverage - 100) as u128) / (100 as u128)) as u64);
        add_position(user, final_deposit, borrow_amount, final_deposit);
        let deposit_event = LeveragedAriesDeposit{
            user   : 0x1::signer::address_of(user), 
            amount : final_deposit,
        };
        0x1::event::emit<LeveragedAriesDeposit>(deposit_event);
    }
    //18446744073709551615
    entry public fun withdraw(user: &signer,amount:u64) {
        let user_addr = 0x1::signer::address_of(user);
        let (_, v2) = get_users_position_for_profile<coin::T, USDC>(user_addr, b"avex::aries_lending_2");
        let (v3, _) = get_users_position_for_profile<USDC, coin::T>(user_addr, b"avex::aries_lending");
        let v5 = if (v2 > 0) {
            let (v6, v7) = controller::begin_flash_loan<USDC>(user, 0x1::string::utf8(b"avex::aries_lending"), v2);
            0x1::coin::deposit<USDC>(user_addr, v7);
            controller::deposit<USDC>(user, b"avex::aries_lending_2", amount, true);
            0x1::option::some<CheckEquity>(v6)
        } else {
            0x1::option::none<CheckEquity>()
        };
        let v8 = v5;
        controller::controller::withdraw<coin::T>(user, b"avex::aries_lending_2", amount, false);
        if (0x1::option::is_some<CheckEquity>(&v8)) {
            controller::controller::end_flash_loan<coin::T>(0x1::option::destroy_some<CheckEquity>(v8), 0x1::coin::withdraw<coin::T>(user, helpers::balance<coin::T>(user_addr)));
        } else {
            0x1::option::destroy_none<CheckEquity>(v8);
            controller::deposit<coin::T>(user, b"avex::aries_lending", amount, true);
        };
        let (_, v10) = get_users_position_for_profile<USDC, coin::T>(user_addr, b"avex::aries_lending");
        if (v10 > 0) {
            controller::withdraw<USDC>(user, b"avex::aries_lending", router_p::get_amount_in<USDC, coin::T>(v10 + 2), false);
            router_p::swap_exact_input<USDC, coin::T>(user, helpers::balance<USDC>(user_addr), 0);
            controller::deposit<coin::T>(user, b"avex::aries_lending", amount, true);
        };
        controller::controller::withdraw<USDC>(user, b"avex::aries_lending", amount, false);
        let v11 = LeveragedAriesWithdraw{
            user   : user_addr, 
            amount : v3,
        };
        0x1::event::emit<LeveragedAriesWithdraw>(v11);
    }
    
    fun add_position(user: &signer, amount: u64, arg2: u64, arg3: u64) {
        assert!(amount + arg2 > 0, 3);
        if (amount > 0) {
            controller::controller::deposit<USDC>(user, b"avex::aries_lending", amount, false);
        };
        if (arg2 > 0) {
            let v0 = 0x1::signer::address_of(user);
            let (v1, v2) = calculate_borrow_amounts(arg2, arg3);
            let (v3, v4) = controller::begin_flash_loan<coin::T>(user, 0x1::string::utf8(b"avex::aries_lending"), v1);
            // let v5 = v4;
            let v5 = 0x1::coin::value<coin::T>(&v4);
            0x1::aptos_account::deposit_coins<coin::T>(v0, v4);
            controller::deposit<coin::T>(user, b"avex::aries_lending_2", v5, false);
            controller::withdraw<USDC>(user, b"avex::aries_lending_2", v2, true);
            controller::end_flash_loan<USDC>(v3, 0x1::coin::withdraw<USDC>(user, helpers::balance<USDC>(v0) - helpers::balance<USDC>(v0)));
        };
    }
    
    fun calculate_borrow_amounts(arg0: u64, arg1: u64) : (u64, u64) {
        let v0 = (((arg0 as u128) * (arg0 as u128) / ((arg1 + 2 * arg0) as u128)) as u64);
        (arg0 - v0, v0)
    }
    
    entry fun claim_rewards(user: &signer) {
        let user_addr = 0x1::signer::address_of(user);
        if (!helpers::aries_profile_exists(user_addr, b"avex::aries_lending")) {
            return
        };
        controller::claim_reward<USDC, controller::reserve_config::DepositFarming, 0x1::aptos_coin::AptosCoin>(user, b"avex::aries_lending");
        controller::claim_reward<coin::T, controller::reserve_config::BorrowFarming, 0x1::aptos_coin::AptosCoin>(user, b"avex::aries_lending");
        if (helpers::aries_profile_exists(user_addr, b"avex::aries_lending_2")) {
            controller::claim_reward<coin::T, controller::reserve_config::DepositFarming, 0x1::aptos_coin::AptosCoin>(user, b"avex::aries_lending_2");
            controller::claim_reward<USDC, controller::reserve_config::BorrowFarming, 0x1::aptos_coin::AptosCoin>(user, b"avex::aries_lending_2");
        };
        let v1 = helpers::balance<0x1::aptos_coin::AptosCoin>(user_addr) - helpers::balance<0x1::aptos_coin::AptosCoin>(user_addr);
        if (v1 > 0) {
            let v2 = LeveragedAriesClaimRewards{
                user   : user_addr, 
                amount : v1,
            };
            0x1::event::emit<LeveragedAriesClaimRewards>(v2);
        };
    }
    
    public fun get_rewards(user: address) : u128 {
        if (!helpers::aries_profile_exists(user, b"avex::aries_lending")) {
            return 0
        };
        let (v0, _) = profile::profile_farm_coin<USDC, controller::reserve_config::DepositFarming, 0x1::aptos_coin::AptosCoin>(user, 0x1::string::utf8(b"avex::aries_lending"));
        let (v2, _) = profile::profile_farm_coin<coin::T, controller::reserve_config::BorrowFarming, 0x1::aptos_coin::AptosCoin>(user, 0x1::string::utf8(b"avex::aries_lending"));
        if (!helpers::aries_profile_exists(user, b"avex::aries_lending_2")) {
            return (v0 + v2) / 1000000000000000000
        };
        let (v4, _) = profile::profile_farm_coin<coin::T, controller::reserve_config::DepositFarming, 0x1::aptos_coin::AptosCoin>(user, 0x1::string::utf8(b"avex::aries_lending_2"));
        let (v6, _) = profile::profile_farm_coin<USDC, controller::reserve_config::BorrowFarming, 0x1::aptos_coin::AptosCoin>(user, 0x1::string::utf8(b"avex::aries_lending_2"));
        (v0 + v2 + v4 + v6) / 1000000000000000000
    }
    
    public fun get_users_position(user: address) : (u64, u64, u64, u64) {
        if (!helpers::aries_profile_exists(user, b"avex::aries_lending")) {
            return (0, 0, 0, 0)
        };
        let (v0, v1) = get_users_position_for_profile<USDC, coin::T>(user, b"avex::aries_lending");
        if (!helpers::aries_profile_exists(user, b"avex::aries_lending_2")) {
            let v2 = v0 - v1;
            let v8 = (((v0 as u128) * (100 as u128) / (v2 as u128)) as u64);
            return (v0, v2, v1, v8)
        };
        let (v3, v4) = get_users_position_for_profile<coin::T, USDC>(user, b"avex::aries_lending_2");
        let v5 = v0 + v3;
        let v6 = v4 + v1;
        let v7 = v5 - v6;
        let v9 = (((v5 as u128) * (100 as u128) / (v7 as u128)) as u64);
        (v5, v7, v6, v9)
    }
    
    public fun get_users_position_and_rewards(user: address) : (u64, u64, u64, u64, u128) {
        let (v0, v1, v2, v3) = get_users_position(user);
        (v0, v1, v2, v3, get_rewards(user))
    }
    
    fun get_users_position_for_profile<T0, T1>(user: address, arg1: vector<u8>) : (u64, u64) {
        let v0 = 0x1::string::utf8(arg1);
        let (_, v2) = profile::profile_deposit<T0>(user, v0);
        if (v2 == 0) {
            return (0, 0)
        };
        let (_, v4) = profile::profile_loan<T1>(user, v0);
        let v5 = ((v4 / 1000000000000000000) as u64);
        (v2, v5)
    }
    
    entry fun increase_leverage(user: &signer, arg1: u64) {
        helpers::ensure_aries_profile_exists(user, b"avex::aries_lending_2");
        assert!(arg1 <= 450, 1);
        let (_, v1, _, v3) = get_users_position(0x1::signer::address_of(user));
        if (v3 < arg1) {
            let v5 = (((v1 as u128) * ((arg1 - v3) as u128) / (100 as u128)) as u64);
            add_position(user, 0, v5, v1);
            let v4 = LeveragedAriesUpdateLeverage{
                user         : 0x1::signer::address_of(user), 
                old_leverage : v3, 
                new_leverage : arg1,
            };
            0x1::event::emit<LeveragedAriesUpdateLeverage>(v4);
        };
    }
    
    // decompiled from Move bytecode v6
}
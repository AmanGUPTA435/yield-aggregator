// module avex::stake_route{
//     use aptos_framework::aptos_coin::{AptosCoin};
//     use aptos_framework::coin::{Self, Coin};
//     use aptos_framework::object;
//     use std::string::{Self,String};
//     use std::signer;
//     use avex::helpers;
//     use abel::acoin_lend;
//     use abel::acoin::{Self,ACoin};
//     use abel::market;
//     use aptin::lend;
//     use amnis::amapt_token::{AmnisApt};
//     use amnis::stapt_token::{StakedApt};
//     use amnis::withdrawal::{WithdrawalToken};
//     use amnis::router;
//     use controller::controller;
//     use controller::profile;
//     use config::reserve_config::{DepositFarming};
//     use merkle::managed_house_lp;
//     use merkle::house_lp::MKLP;
//     use bridge::asset::USDC;
//     use thala::scripts;
//     use thala::staking::{ThalaAPT,StakedThalaAPT};
//     use thalaswap::base_pool;
//     use thalaswap::stable_pool;
//     use tortuga::stake_router;
    // use pancake::swap_utils;
    // use pancake::router as rrouter;
    // use pancake::swap;
    // use pancake_masterchef::masterchef;
    // use pancake_oft::oft::{CakeOFT};
//     use liquidswap_v05::coin_helper;
//     use liquidswap_v05::router as routerr;
//     use liquidswap_v05::curves;
//     use liquidswap::router as router0;
//     use liquidswap::curves as curves0;
//     use harvest::stake;
//     use liquidswap_lp::lp_coin;
//     use liquidswap_sp::lp_coin as coin0;
//     use avex::events;
//     use avex::dex_events;

//     const THALA : u64 = 1;
//     const AMNIS : u64 = 2;
//     const TORTUGA : u64 = 3;
//     const MERKLE : u64 = 4;
//     const ABEL : u64 = 5;
//     const ARIES : u64 = 6;
//     const APTIN : u64 = 7;

//     // public entry fun stake_entry(user:&signer,amount:u64,id:u64){
//     //     stake(user,amount,id);
//     // }

//     public fun stake(user:&signer,amount:u64,id:u64){
//         if(id==THALA){
//             stake_thala(user,amount);
//         }
//         else if(id==AMNIS){
//            stake_amnis(user,amount); 
//         }
//         else if(id==TORTUGA){
//             stake_tortuga(user,amount);
//         }
//         else if(id==MERKLE){
//             add_liquidity_merkle(user,amount);
//         }
//     }

//     // public entry fun unstake_entry(user:&signer,amount:u64,id:u64){
//     //     unstake(user,amount,id);
//     // }

//     public fun unstake(user:&signer,amount:u64,id:u64){
//         if(id==THALA){
//             unstake_thala(user,amount);
//         }
//         else if(id==AMNIS){
//            unstake_amnis(user,amount); 
//         }
//         else if(id==TORTUGA){
//             unstake_tortuga(user,amount);
//         }
//         else if(id==MERKLE){
//             withdraw_liquidity_merkle(user,amount);
//         }
//     }

//     // public entry fun claim_rewards_entry<T0,T1>(user:&signer,id:u64){
//     //     claim_rewards<T0,T1>(user,id);
//     // }

//     public fun claim_rewards_uni<T0,T1>(user:&signer,id:u64){
//         if(id==ABEL){
//             claim_rewards_abel(user);
//             events::emit_claim_reward(id);
//         }
//         else if(id==ARIES){
//            claim_rewards_aries<T0>(user); 
//            events::emit_claim_reward(id);
//         }
//         else if(id==APTIN){
//             claim_rewards_aptin<T0,T1>(user);
//             events::emit_claim_reward(id);
//         }
//     }

//     // public entry fun lend_entry<T0>(user:&signer,amount:u64,id:u64){
//     //     lend<T0>(user,amount,id);
//     // }

//     public fun lend<T0>(user:&signer,amount:u64,id:u64){
//         if(id==ABEL){
//             deposit_abel<T0>(user,amount);
//             events::emit_lend<T0>(id,amount);
//         }
//         else if(id==ARIES){
//             deposit_aries<T0>(user,amount);
//             events::emit_lend<T0>(id,amount);
//         }
//         else if(id==APTIN){
//             lend_aptin<T0>(user,amount,true);
//             events::emit_lend<T0>(id,amount);
//         }
//     }

//     // public entry fun withdraw_entry<T0>(user:&signer,amount:u64,id:u64){
//     //     withdraw<T0>(user,amount,id);
//     // }

//     public fun withdraw<T0>(user:&signer,amount:u64,id:u64){
//         if(id==ABEL){
//             withdraw_abel<T0>(user,amount);
//             events::emit_withdraw<T0>(id,amount);
//         }
//         else if(id==ARIES){
//             withdraw_aries<T0>(user,amount);
//             events::emit_withdraw<T0>(id,amount);
//         }
//         else if(id==APTIN){
//             withdraw_aptin<T0>(user,amount,signer::address_of(user));
//             events::emit_withdraw<T0>(id,amount);
//         }
//     }

//     // public entry fun repay_entry<CoinType>(user:&signer,amount:u64,id:u64){
//     //     repay<CoinType>(user,amount,id);
//     // }

//     public fun repay<T0>(user:&signer,amount:u64,id:u64){
//         if(id==ABEL){
//             repay_abel<T0>(user);
//             events::emit_repay<T0>(id,amount);
//         }
//         else if(id==ARIES){
//             repay_aries<T0>(user,amount);
//             events::emit_repay<T0>(id,amount);
//         }
//         else if(id==APTIN){
//             repay_aptin<T0>(user,amount);
//             events::emit_repay<T0>(id,amount);
//         }
//     }

//     // public entry fun borrow_entry<T0>(user:&signer,amount:u64,id:u64){
//     //     borrow<T0>(user,amount,id);
//     // }

//     public fun borrow<T0>(user:&signer,amount:u64,id:u64){
//         if(id==ABEL){
//             borrow_abel<T0>(user,amount);
//             events::emit_borrow<T0>(id,amount);
//         }
//         else if(id==ARIES){
//             borrow_aries<T0>(user,amount);
//             events::emit_borrow<T0>(id,amount);
//         }
//         else if(id==APTIN){
//             borrow_aptin<T0>(user,amount);
//             events::emit_borrow<T0>(id,amount);
//         }
//     }


//     ///// ABEL //////

//     fun deposit_abel<CoinType>(user: &signer,amount: u64){
//         // let coins = coin::withdraw<CoinType>(recipient, amount);
//         // let recipient_address = signer::address_of(recipient);
//         avex::helpers::ensure_abel_profile_exists<CoinType>(user);
//         acoin_lend::mint_entry<CoinType>(user,amount);
//     }

//     fun withdraw_abel<CoinType>(user: &signer, amount: u64){
//         acoin_lend::redeem_entry<CoinType>(user, amount);
//         // 0x1::aptos_account::deposit_coins<ACoin>(0x1::signer::address_of(user), v0);
//     }

//     fun repay_abel<T0>(user: &signer){
//         acoin_lend::repay_all<T0>(user,0x1::signer::address_of(user));
//     }

//     fun borrow_abel<T0>(user:&signer,amount:u64){
//         acoin_lend::borrow_entry<T0>(user,amount);
//     }

//     fun claim_rewards_abel(user:&signer){
//         market::claim_abel(signer::address_of(user));
//     }

//     ///// AMNIS /////

//     fun stake_amnis(user: &signer,amount: u64){
//         // let coins = coin::withdraw<CoinType>(user, amount);
//         let user_addr = signer::address_of(user);
//         let v0 = router::deposit_and_stake(0x1::coin::withdraw<AptosCoin>(user, amount));
//         0x1::aptos_account::deposit_coins<StakedApt>(user_addr, v0);
//         events::emit_stake(AMNIS,amount);

//     }

//     // fun get_users_position(arg0: address) : u64 {
//     //     helpers::balance<StakedApt>(arg0)
//     // }

//     fun unstake_amnis(user:&signer,amount:u64){
//         let user_addr = signer::address_of(user);
//         router::unstake_entry(user,amount,user_addr);
//         events::emit_unstake(AMNIS,amount);
//     }

//     //provides amAPT
//     fun deposit_apt(user:&signer,amount:u64){
//         let user_addr = signer::address_of(user);
//         let v0 = router::deposit(0x1::coin::withdraw<AptosCoin>(user, amount));
//         0x1::aptos_account::deposit_coins<AmnisApt>(user_addr, v0);
//     }

//     //Unstake stAPT to get amAPT
//     fun withdraw_stAPT(user:&signer, amount:u64){
//         let user_addr = signer::address_of(user);
//         let v0 = router::unstake(0x1::coin::withdraw<StakedApt>(user, amount));
//         0x1::aptos_account::deposit_coins<AmnisApt>(user_addr, v0);
//     }

//     fun get_token(user:&signer,amount:u64){
//         let user_addr = signer::address_of(user);
//         router::request_withdraw(coin::withdraw<AmnisApt>(user,amount),user_addr);
//         // router::withdraw(user,v0)
//     }

//     //BURN TICKET AND GET BACK APT STAKE
//     public fun withdraw_apt(user:&signer,ticket:address){
//         router::withdraw_entry(user,object::address_to_object<WithdrawalToken>(ticket));
//     }

//     //// MERKLE ////

//     fun add_liquidity_merkle(user: &signer, amount: u64) {
//         managed_house_lp::deposit<USDC>(user, amount);
//         events::emit_stake(MERKLE,amount);

//     }
    
//     public fun get_position_merkle(user: address) : u64 {
//         if (!coin::is_account_registered<MKLP<USDC>>(user)) {
//             0
//         } else {
//             coin::balance<MKLP<USDC>>(user)
//         }
//     }
    
//     fun withdraw_liquidity_merkle(user: &signer, amount: u64) {
//         merkle::managed_house_lp::withdraw<USDC>(user, amount);
//         events::emit_unstake(MERKLE,amount);
//     }

//     //// TORTUGA ////

//     fun stake_tortuga(user: &signer,amount: u64){
//         stake_router::stake(user,amount);
//         events::emit_stake(TORTUGA,amount);
//     }

//     fun unstake_tortuga(user:&signer,amount: u64){
//         stake_router::unstake(user,amount);
//         events::emit_unstake(TORTUGA,amount);
//     }

//     fun claim_ticket_tortuga(user:&signer,ticket_id:u64){
//         stake_router::claim(user,ticket_id);
//     }

//     //// THALA ////

//     fun stake_thala(user: &signer, amount: u64) {
//         let user_addr = 0x1::signer::address_of(user);
//         scripts::stake_APT(user, amount);
//         scripts::stake_thAPT(user, helpers::balance<ThalaAPT>(user_addr));
//         events::emit_stake(THALA,amount);
//     }
    
//     fun unstake_thala(user: &signer, amount: u64) {
//         scripts::unstake_thAPT(user, amount);
//         events::emit_unstake(THALA,amount);
//     }
    
//     public fun unstake_and_swap_thala(user: &signer, unstake_amount: u64, slippage: u64) {
//         scripts::unstake_thAPT(user, unstake_amount);
//         let thAPT_balance = 0x1::coin::balance<thala::staking::ThalaAPT>(0x1::signer::address_of(user));
//         let coins = stable_pool::swap_exact_in<ThalaAPT, 0x1::aptos_coin::AptosCoin, base_pool::Null, base_pool::Null, ThalaAPT, 0x1::aptos_coin::AptosCoin>(0x1::coin::withdraw<thala::staking::ThalaAPT>(user, thAPT_balance));
//         let amount = 0x1::coin::value<0x1::aptos_coin::AptosCoin>(&coins);
//         assert!(amount >= helpers::min_amount_with_slippage(thAPT_balance, slippage), 1);
//         0x1::coin::deposit<0x1::aptos_coin::AptosCoin>(0x1::signer::address_of(user), coins);
//     }

//     //// ARIES ////

//     fun withdraw_aries<T0>(user: &signer, amount: u64) {
//         controller::withdraw<T0>(user, b"avex::aries_lending", amount, false);
//     }
    
//     fun borrow_aries<T0>(user: &signer, amount: u64) {
//         controller::withdraw<T0>(user, b"avex::aries_lending", amount, true);
//     }
    
//     fun claim_rewards_aries<T0>(user: &signer) {
//         let v0 = 0x1::signer::address_of(user);
//         controller::claim_reward<T0, DepositFarming, AptosCoin>(user, b"avex::aries_lending");
//         // let v1 = helpers::balance<AptosCoin>(v0);
//         // if (v1 > 0) {
//         //     lending_events::emit_claim_rewards<T0, AptosCoin>(lending_events::aries(), v1);
//         // };
//     }

//     public fun get_pending_rewards_aries<T0>(user: address) : u64 {
//         if (!profile::is_registered(user) || !profile::profile_exists(user, string::utf8(b"avex::aries_lending"))) {
//             return 0
//         };
//         let (v0, _) = profile::profile_farm_coin<T0, DepositFarming, AptosCoin>(user, string::utf8(b"avex::aries_lending"));
//         ((v0 / 1000000000000000000) as u64)
//     }
    
//     public fun get_position_aries<T0>(user: address) : (u64, u64) {
//         if (!profile::is_registered(user) || !profile::profile_exists(user, string::utf8(b"avex::aries_lending"))) {
//             return (0, 0)
//         };
//         let (_, v1) = profile::profile_deposit<T0>(user, string::utf8(b"avex::aries_lending"));
//         (v1, get_pending_rewards_aries<T0>(user))
//     }
    
//     fun deposit_aries<T0>(user: &signer, amount: u64) {
//         helpers::ensure_aries_profile_exists(user, b"avex::aries_lending");
//         controller::deposit<T0>(user, b"avex::aries_lending", amount, false);
//     }
    
//     fun repay_aries<T0>(user: &signer, amount: u64) {
//         helpers::ensure_aries_profile_exists(user, b"avex::aries_lending");
//         controller::deposit<T0>(user, b"avex::aries_lending", amount, true);
//     }

//     //// APTIN ////

//     fun lend_aptin<CoinType>(user:&signer,amount:u64,myst:bool){
//         lend::supply<CoinType>(user,amount,myst);
//     }

//     fun withdraw_aptin<CoinType>(user:&signer,amount:u64,receiver:address){
//         lend::withdraw<CoinType>(user,amount,receiver);
//     }

//     fun repay_aptin<CoinType>(user:&signer,amount:u64){
//         lend::repay<CoinType>(user,amount);
//     }

//     fun borrow_aptin<CoinType>(user:&signer,amount:u64){
//         lend::borrow<CoinType>(user,amount);
//     }

//     fun claim_rewards_aptin<T0,T1>(user:&signer){
//         lend::claim<T0,T1>(user,signer::address_of(user));
//     }

//     //// ECHELON ////
//     // 0x761a97787fa8b3ae0cef91ebc2d96e56cc539df5bc88dadabee98ae00363a831 --> APT pool 
//     // 0xed6bf9fe7e3f42c6831ffac91824a545c4b8bfcb40a59b3f4ccfe203cafb7f42 --> StakedThalaAPT
//     // 0x447b3b516546f28e8c4f6825a6287b09161659e7c500c599c29c28a8492844b8 --> USDT
//     // 0xef2ae89796725d0eb363326ecb7df159feb949f6d1f400f76deeeebccbac00f1 --> MOD (Move Dollar)
//     // 0xa9c51ca3bcd93978d0c4aada7c4cf47c0791caced3cdc4e15f2c8e0797d1f93c --> USDC

//     //// PANCAKESWAP ////
    // entry fun add_liquidity_pancake<T0, T1>(user: &signer, amount1: u64, amount2: u64, slippage: u64) {
    //     add_liquidity_internal_pancake<T0, T1>(user, amount1, amount2, slippage);
    // }
    
    // entry fun remove_liquidity_pancake<T0, T1>(user: &signer, liquidity: u64, amount1: u64, amount2: u64) {
    //     remove_liquidity_internal_pancake<T0, T1>(user, liquidity, amount1, amount2);
    // }
    
    // public(friend) fun add_liquidity_internal_pancake<T0, T1>(user: &signer, amount1: u64, amount2: u64, slippage: u64) {
    //     if (!swap_utils::sort_token_type<T0, T1>()) {
    //         add_liquidity_pancake<T1, T0>(user, amount2, amount1, slippage);
    //         return
    //     };
    //     let v0 = 0x1::signer::address_of(user);
    //     rrouter::add_liquidity<T0, T1>(user, amount1, amount2, helpers::min_amount_with_slippage(amount1, slippage), helpers::min_amount_with_slippage(amount2, slippage));
    //     masterchef::deposit<swap::LPToken<T0, T1>>(user, helpers::balance<swap::LPToken<T0, T1>>(v0));
    //     avex::dex_events::emit_add_liquidity<T0, T1>(avex::dex_events::pancakeswap(), amount1, amount2);
    // }
    
    // entry fun claim_rewards_pancake<T0, T1>(user: &signer) {
    //     claim_rewards_internal_pancake<T0, T1>(user);
    // }
    
    // public(friend) fun claim_rewards_internal_pancake<T0, T1>(user: &signer) {
    //     if (!swap_utils::sort_token_type<T0, T1>()) {
    //         claim_rewards_pancake<T1, T0>(user);
    //         return
    //     };
    //     let v0 = 0x1::signer::address_of(user);
    //     masterchef::deposit<swap::LPToken<T0, T1>>(user, 0);
    //     let v1 = helpers::balance<CakeOFT>(v0) - helpers::balance<CakeOFT>(v0);
    //     let v2 = helpers::balance<0x1::aptos_coin::AptosCoin>(v0) - helpers::balance<0x1::aptos_coin::AptosCoin>(v0);
    //     if (v1 > 0) {
    //         dex_events::emit_claim_rewards<T0, T1, CakeOFT>(dex_events::pancakeswap(), v1);
    //     };
    //     if (v2 > 0) {
    //         dex_events::emit_claim_rewards<T0, T1, 0x1::aptos_coin::AptosCoin>(dex_events::pancakeswap(), v2);
    //     };
    // }
    
    // public fun get_liquidity_amounts_pancake<T0, T1>(arg0: u64) : (u64, u64) {
    //     if (!swap_utils::sort_token_type<T0, T1>()) {
    //         let (v0, v1) = get_liquidity_amounts_pancake<T1, T0>(arg0);
    //         return (v1, v0)
    //     };
    //     let (v2, v3) = get_reserves_pancake<T0, T1>();
    //     let v4 = 0x1::coin::supply<swap::LPToken<T0, T1>>();
    //     let v5 = (0x1::option::extract<u128>(&mut v4) as u64);
    //     ((((arg0 as u128) * (v2 as u128) / (v5 as u128)) as u64), (((arg0 as u128) * (v3 as u128) / (v5 as u128)) as u64))
    // }
    
    // public fun get_lp_tokens<T0, T1>(arg0: u64, arg1: u64) : (u64, u64) {
    //     if (!swap_utils::sort_token_type<T0, T1>()) {
    //         return get_lp_tokens<T1, T0>(arg1, arg0)
    //     };
    //     let (v0, v1) = get_reserves_pancake<T0, T1>();
    //     let v2 = 0x1::coin::supply<swap::LPToken<T0, T1>>();
    //     let v3 = (0x1::option::extract<u128>(&mut v2) as u64);
    //     ((((0x1::math64::min(arg0, arg1) as u128) * (v3 as u128) / (0x1::math64::min(v0, v1) as u128)) as u64), v3)
    // }
    
    // public fun get_pending_rewards_pancake<T0, T1>(user: address) : u64 {
    //     abort 0
    // }
    // #[view]
    // public fun get_reserves_pancake<T0, T1>() : (u64, u64) {
    //     if (swap_utils::sort_token_type<T0, T1>()) {
    //         let (v2, v3, _) = swap::token_reserves<T0, T1>();
    //         (v2, v3)
    //     } else {
    //         let (v5, v6, _) = swap::token_reserves<T1, T0>();
    //         (v6, v5)
    //     }
    // }
    
    // public fun get_rewards<T0, T1>(user: address, pool_id: u64) : (u64, u64) {
    //     if (!swap_utils::sort_token_type<T0, T1>()) {
    //         return get_rewards<T1, T0>(user, pool_id)
    //     };
    //     (masterchef::get_pending_apt<swap::LPToken<T0, T1>>(user), masterchef::pending_cake(pool_id, user))
    // }
    
    // public fun get_users_position_pancake<T0, T1>(user: address) : (u64, u64, u64) {
    //     abort 0
    // }
    
    // public(friend) fun remove_liquidity_internal_pancake<T0, T1>(user: &signer, liquidity: u64, amount1: u64, amount2: u64) {
    //     if (!swap_utils::sort_token_type<T0, T1>()) {
    //         remove_liquidity_pancake<T1, T0>(user, liquidity, amount2, amount1);
    //         return
    //     };
    //     masterchef::withdraw<swap::LPToken<T0, T1>>(user, liquidity);
    //     let (v0, v1) = get_liquidity_amounts_pancake<T0, T1>(liquidity);
    //     rrouter::remove_liquidity<T0, T1>(user, liquidity, amount1, amount2);
    //     avex::dex_events::emit_remove_liquidity<T0, T1>(avex::dex_events::pancakeswap(), liquidity, v0, v1);
    // }
    

//     //// LIQUIDSWAP ////


//     // public entry fun add_liquidity<T0, T1>(user: &signer, use_stable_pool: bool, amount1: u64, amount2: u64, slippage: u64) {
//     //     add_liquidity_internal<T0, T1>(user, use_stable_pool, amount1, amount2, slippage);
//     // }
    
//     // public entry fun remove_liquidity<T0, T1>(user: &signer, arg1: bool, arg2: u64, arg3: u64, arg4: u64) {
//     //     remove_liquidity_internal<T0, T1>(user, arg1, arg2, arg3, arg4);
//     // }
    
//     // public(friend) fun add_liquidity_internal<T0, T1>(user: &signer, use_stable_pool: bool, amount1: u64, amount2: u64, slippage: u64) {
//     //     if (!coin_helper::is_sorted<T0, T1>()) {

//     //         add_liquidity_internal<T1, T0>(user, use_stable_pool, amount2, amount1, slippage);
//     //         return
//     //     };
//     //     if (should_use_v05<T0, T1>()) {
//     //         if (use_stable_pool) {
//     //             let (v0, v1, v2) = routerr::add_liquidity<T0, T1, curves::Stable>(0x1::coin::withdraw<T0>(user, amount1), helpers::min_amount_with_slippage(amount1, slippage), 0x1::coin::withdraw<T1>(user, amount2), helpers::min_amount_with_slippage(amount2, slippage));
//     //             deposit_remainders_and_stake_lp<T0, T1, curves::Stable, lp_coin::LP<T0, T1, curves::Stable>>(user, v0, v1, v2);
//     //         } else {
//     //             let (v3, v4, v5) = routerr::add_liquidity<T0, T1, curves::Uncorrelated>(0x1::coin::withdraw<T0>(user, amount1), 
//     //                                                                                     helpers::min_amount_with_slippage(amount1, slippage), 
//     //                                                                                     0x1::coin::withdraw<T1>(user, amount2), 
//     //                                                                                     helpers::min_amount_with_slippage(amount2, slippage));
//     //             deposit_remainders_and_stake_lp<T0, T1, curves::Uncorrelated, lp_coin::LP<T0, T1, curves::Uncorrelated>>(user, v3, v4, v5);
//     //         };
//     //     } else {
//     //         if (use_stable_pool) {
//     //             let (v6, v7, v8) = router0::add_liquidity<T0, T1, curves0::Stable>(0x1::coin::withdraw<T0>(user, amount1), 
//     //                                                                                 helpers::min_amount_with_slippage(amount1, slippage), 
//     //                                                                                 0x1::coin::withdraw<T1>(user, amount2), 
//     //                                                                                 helpers::min_amount_with_slippage(amount2, slippage));
//     //             deposit_remainders_and_stake_lp<T0, T1, curves0::Stable, 0x5A97986A9D031C4567E15B797BE516910CFCB4156312482EFC6A19C0A30C948::lp_coin::LP<T0, T1, curves0::Stable>>(user, v6, v7, v8);
//     //         } else {
//     //             let (v9, v10, v11) = router0::add_liquidity<T0, T1, curves0::Uncorrelated>(0x1::coin::withdraw<T0>(user, amount1), 
//     //                                                                                         helpers::min_amount_with_slippage(amount1, slippage), 
//     //                                                                                         0x1::coin::withdraw<T1>(user, amount2), 
//     //                                                                                         helpers::min_amount_with_slippage(amount2, slippage));
//     //             deposit_remainders_and_stake_lp<T0, T1, curves0::Uncorrelated,0x5A97986A9D031C4567E15B797BE516910CFCB4156312482EFC6A19C0A30C948::lp_coin::LP<T0, T1, curves0::Uncorrelated>>(user, v9, v10, v11);
//     //         };
//     //     };
//     //     // 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::dex_events::emit_add_liquidity<T0, T1>(0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::dex_events::liquidswap(), arg2, arg3);
//     // }
    
//     // public entry fun claim_rewards<T0, T1>(user: &signer, arg1: bool) {
//     //     claim_rewards_internal<T0, T1>(user, arg1);
//     // }
    
//     // public(friend) fun claim_rewards_internal<T0, T1>(user: &signer, use_stable_pool: bool) {
//     //     if (!coin_helper::is_sorted<T0, T1>()) {
//     //         claim_rewards<T1, T0>(user, use_stable_pool);
//     //         return
//     //     };
//     //     if (should_use_v05<T0, T1>()) {
//     //         if (use_stable_pool) {
//     //             deposit_rewards_and_emit_event<T0, T1>(0x1::signer::address_of(user), stake::harvest<lp_coin::LP<T0, T1, curves::Stable>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool));
//     //         } else {
//     //             deposit_rewards_and_emit_event<T0, T1>(0x1::signer::address_of(user), stake::harvest<lp_coin::LP<T0, T1, curves::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool));
//     //         };
//     //     } else {
//     //         if (use_stable_pool) {
//     //             deposit_rewards_and_emit_event<T0, T1>(0x1::signer::address_of(user), stake::harvest<coin0::LP<T0, T1, curves0::Stable>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool));
//     //         } else {
//     //             deposit_rewards_and_emit_event<T0, T1>(0x1::signer::address_of(user), stake::harvest<coin0::LP<T0, T1, curves0::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool));
//     //         };
//     //     };
//     // }
    
//     // fun deposit_coins_and_emit_event<T0, T1>(user: address, coin1: 0x1::coin::Coin<T0>, coin2: 0x1::coin::Coin<T1>, amount_lp: u64) {
//     //     0x1::coin::deposit<T0>(user, coin1);
//     //     0x1::coin::deposit<T1>(user, coin2);
//     //     // 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::dex_events::emit_remove_liquidity<T0, T1>(0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::dex_events::liquidswap(), arg3, 0x1::coin::value<T0>(&arg1), 0x1::coin::value<T1>(&arg2));
//     // }
    
//     // fun deposit_remainders_and_stake_lp<T0, T1, T2, T3>(user: &signer, deposit_1: 0x1::coin::Coin<T0>, deposit_2: 0x1::coin::Coin<T1>, stake: 0x1::coin::Coin<T3>) {
//     //     let v0 = 0x1::signer::address_of(user);
//     //     0x1::coin::deposit<T0>(v0, deposit_1);
//     //     0x1::coin::deposit<T1>(v0, deposit_2);
//     //     stake::stake<T3, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool, stake);
//     // }
    
//     // fun deposit_rewards_and_emit_event<T0, T1>(user: address, deposit_amount: 0x1::coin::Coin<0x1::aptos_coin::AptosCoin>) {
//     //     0x1::aptos_account::deposit_coins<0x1::aptos_coin::AptosCoin>(user, deposit_amount);
//     //     // 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::dex_events::emit_claim_rewards<T0, T1, 0x1::aptos_coin::AptosCoin>(0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::dex_events::liquidswap(), 0x1::coin::value<0x1::aptos_coin::AptosCoin>(&arg1));
//     // }
    
//     // public fun get_liquidity_amounts<T0, T1>(stable_pool: bool, liquiidity_amount: u64) : (u64, u64) {
//     //     if (!coin_helper::is_sorted<T0, T1>()) {
//     //         let (v0, v1) = get_liquidity_amounts<T1, T0>(stable_pool, liquiidity_amount);
//     //         return (v1, v0)
//     //     };
//     //     if (should_use_v05<T0, T1>()) {
//     //         let (v4, v5) = if (stable_pool) {
//     //             let (v6, v7) = get_liquidity_amounts_internal<T0, T1>(stable_pool, 0x1::coin::supply<lp_coin::LP<T0, T1, curves::Stable>>(), liquiidity_amount);
//     //             (v6, v7)
//     //         } else {
//     //             let (v8, v9) = get_liquidity_amounts_internal<T0, T1>(stable_pool, 0x1::coin::supply<lp_coin::LP<T0, T1, curves::Uncorrelated>>(), liquiidity_amount);
//     //             (v8, v9)
//     //         };
//     //         (v4, v5)
//     //     } else {
//     //         let (v10, v11) = if (stable_pool) {
//     //             let (v12, v13) = get_liquidity_amounts_internal<T0, T1>(stable_pool, 0x1::coin::supply<coin0::LP<T0, T1, curves0::Stable>>(), liquiidity_amount);
//     //             (v12, v13)
//     //         } else {
//     //             let (v14, v15) = get_liquidity_amounts_internal<T0, T1>(stable_pool, 0x1::coin::supply<coin0::LP<T0, T1, curves0::Uncorrelated>>(), liquiidity_amount);
//     //             (v14, v15)
//     //         };
//     //         (v10, v11)
//     //     }
//     // }
    
//     // fun get_liquidity_amounts_internal<T0, T1>(is_pool_stable: bool, arg1: 0x1::option::Option<u128>, liquidity_amount: u64) : (u64, u64) {
//     //     let (v0, v1) = get_reserves<T0, T1>(is_pool_stable);
//     //     let v2 = (0x1::option::extract<u128>(&mut arg1) as u64);
//     //     ((((liquidity_amount as u128) * (v0 as u128) / (v2 as u128)) as u64), (((liquidity_amount as u128) * (v1 as u128) / (v2 as u128)) as u64))
//     // }
    
//     // public fun get_pending_rewards<T0, T1>(user: address, is_pool_stable: bool) : u64 {
//     //     if (!coin_helper::is_sorted<T0, T1>()) {
//     //         return get_pending_rewards<T1, T0>(user, is_pool_stable)
//     //     };
//     //     if (should_use_v05<T0, T1>()) {
//     //         let v1 = if (is_pool_stable) {
//     //             stake::get_pending_user_rewards<lp_coin::LP<T0, T1, curves::Stable>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user)
//     //         } else {
//     //             stake::get_pending_user_rewards<lp_coin::LP<T0, T1, curves::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user)
//     //         };
//     //         v1
//     //     } else {
//     //         let v2 = if (is_pool_stable) {
//     //             stake::get_pending_user_rewards<coin0::LP<T0, T1, curves0::Stable>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user)
//     //         } else {
//     //             stake::get_pending_user_rewards<coin0::LP<T0, T1, curves0::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user)
//     //         };
//     //         v2
//     //     }
//     // }
    
//     // public fun get_reserves<T0, T1>(is_pool_stable: bool) : (u64, u64) {
//     //     if (!coin_helper::is_sorted<T0, T1>()) {
//     //         let (v0, v1) = get_reserves<T1, T0>(is_pool_stable);
//     //         return (v1, v0)
//     //     };
//     //     if (should_use_v05<T0, T1>()) {
//     //         let (v4, v5) = if (is_pool_stable) {
//     //             let (v6, v7) = routerr::get_reserves_size<T0, T1, curves::Stable>();
//     //             (v6, v7)
//     //         } else {
//     //             let (v8, v9) = routerr::get_reserves_size<T0, T1, curves::Uncorrelated>();
//     //             (v8, v9)
//     //         };
//     //         (v4, v5)
//     //     } else {
//     //         let (v10, v11) = if (is_pool_stable) {
//     //             let (v12, v13) = router0::get_reserves_size<T0, T1, curves0::Stable>();
//     //             (v12, v13)
//     //         } else {
//     //             let (v14, v15) = router0::get_reserves_size<T0, T1, curves0::Uncorrelated>();
//     //             (v14, v15)
//     //         };
//     //         (v10, v11)
//     //     }
//     // }
    
//     // public fun get_users_position<T0, T1>(user: address, is_pool_stable: bool) : (u64, u64, u64, u64, u64) {
//     //     if (!coin_helper::is_sorted<T0, T1>()) {
//     //         return get_users_position<T1, T0>(user, is_pool_stable)
//     //     };
//     //     let (v0, v1) = if (should_use_v05<T0, T1>()) {
//     //         let (v2, v3) = if (is_pool_stable) {
//     //             (stake::get_user_stake<lp_coin::LP<T0, T1, curves::Stable>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user), stake::get_unlock_time<lp_coin::LP<T0, T1, curves::Stable>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user))
//     //         } else {
//     //             (stake::get_user_stake<lp_coin::LP<T0, T1, curves::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user), stake::get_unlock_time<lp_coin::LP<T0, T1, curves::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user))
//     //         };
//     //         (v2, v3)
//     //     } else {
//     //         let (v4, v5) = if (is_pool_stable) {
//     //             (stake::get_user_stake<coin0::LP<T0, T1, curves0::Stable>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user), stake::get_unlock_time<lp_coin::LP<T0, T1, curves0::Stable>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user))
//     //         } else {
//     //             (stake::get_user_stake<coin0::LP<T0, T1, curves0::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user), stake::get_unlock_time<lp_coin::LP<T0, T1, curves0::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(@harvest_pool, user))
//     //         };
//     //         (v4, v5)
//     //     };
//     //     let (v6, v7) = get_liquidity_amounts<T0, T1>(is_pool_stable, v0);
//     //     (v0, v6, v7, get_pending_rewards<T0, T1>(user, is_pool_stable), v1)
//     // }
    
//     // public(friend) fun remove_liquidity_internal<T0, T1>(user: &signer, is_pool_stable: bool, amount_lp: u64, amount1: u64, amount2: u64) {
//     //     if (!coin_helper::is_sorted<T0, T1>()) {
//     //         remove_liquidity_internal<T1, T0>(user, is_pool_stable, amount_lp, amount2, amount1);
//     //         return
//     //     };
//     //     if (should_use_v05<T0, T1>()) {
//     //         if (is_pool_stable) {
//     //             let (v0, v1) = routerr::remove_liquidity<T0, T1, curves::Stable>(stake::unstake<lp_coin::LP<T0, T1, curves::Stable>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool, amount_lp), amount1, amount2);
//     //             deposit_coins_and_emit_event<T0, T1>(0x1::signer::address_of(user), v0, v1, amount_lp);
//     //         } else {
//     //             let (v2, v3) = routerr::remove_liquidity<T0, T1, curves::Uncorrelated>(stake::unstake<lp_coin::LP<T0, T1, curves::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool, amount_lp), amount1, amount2);
//     //             deposit_coins_and_emit_event<T0, T1>(0x1::signer::address_of(user), v2, v3, amount_lp);
//     //         };
//     //     } else {
//     //         if (is_pool_stable) {
//     //             let (v4, v5) = router0::remove_liquidity<T0, T1, curves0::Stable>(stake::unstake<coin0::LP<T0, T1, curves0::Stable>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool, amount_lp), amount1, amount2);
//     //             deposit_coins_and_emit_event<T0, T1>(0x1::signer::address_of(user), v4, v5, amount_lp);
//     //         } else {
//     //             let (v6, v7) = router0::remove_liquidity<T0, T1, curves0::Uncorrelated>(stake::unstake<coin0::LP<T0, T1, curves0::Uncorrelated>, 0x1::aptos_coin::AptosCoin>(user, @harvest_pool, amount_lp), amount1, amount2);
//     //             deposit_coins_and_emit_event<T0, T1>(0x1::signer::address_of(user), v6, v7, amount_lp);
//     //         };
//     //     };
//     // }
    
//     // fun should_use_v05<T0, T1>() : bool {
//     //     let v0 = 0x1::type_info::type_name<T0>();
//     //     let v1 = 0x1::type_info::type_name<T1>();
//     //     let v2 = vector[b"0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt"];
//     //     if (0x1::vector::contains<vector<u8>>(&v2, 0x1::string::bytes(&v0))) {
//     //         true
//     //     } else {
//     //         let v4 = vector[b"0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt"];
//     //         0x1::vector::contains<vector<u8>>(&v4, 0x1::string::bytes(&v1))
//     //     }
//     // }

// }
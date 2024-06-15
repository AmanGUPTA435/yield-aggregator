// module avex::earn_wrapper{

//     use aptos_framework::coin;
//     use aptos_framework::account;
//     use aptos_framework::aptos_account;
//     use std::option;
//     use std::option::{Option, is_some, borrow};
//     use std::signer;
//     use aptos_std::event::EventHandle;
//     use aptos_framework::timestamp;
//     use aptos_std::event;
//     use aptos_std::type_info::{TypeInfo, type_of};
//     use thalaswap::stable_pool;
//     use thalaswap::weighted_pool;
//     use liquidswap_lp::lp_coin::LP as LP_LIQUID;
//     use ResourceAccountDeployer::LPCoinV1::LPCoin as LP_ANIME;
//     use thalaswap::stable_pool::StablePoolToken;
//     use thalaswap::weighted_pool::WeightedPoolToken;

//     // use std::option::Option;

//     const EPOOL_NOT_FOUND: u64 = 400;
//     const ERR_PAIR_ORDER_ERROR: u64 = 401;
//     const E_UNKNOWN_CURVE: u64 = 402;
//     const E_UNKNOWN_DEX_OR_NOT_IMPLEMENTED: u64 = 403;
//     const E_PAIR_NOT_CREATED: u64 = 404;

//     const DEX_HIPPO: u8 = 1;
//     const DEX_ECONIA: u8 = 2;
//     const DEX_PONTEM: u8 = 3;
//         const DEX_PONTEM_v0: u8 = 31;
//         const DEX_PONTEM_v0_5: u8 = 32;
//     const DEX_BASIQ: u8 = 4;
//     const DEX_DITTO: u8 = 5;
//     const DEX_TORTUGA: u8 = 6;
//     const DEX_APTOSWAP: u8 = 7;
//     const DEX_AUX: u8 = 8;
//     const DEX_ANIMESWAP: u8 = 9;
//     const DEX_CETUS: u8 = 10;
//     const DEX_PANCAKE: u8 = 11;
//     const DEX_OBRIC: u8 = 12;
//     const DEX_OPENOCEAN: u8 = 14;
//     const DEX_THALASWAP: u8 = 15;
//         const DEX_THALASWAP_STABLE: u8 = 151;
//         const DEX_THALASWAP_WEIGHTED: u8 = 152;
//     const DEX_SUSHI: u8 = 16;
//     const DEX_BAPTSWAP_v2: u8 = 17;
//     const DEX_BAPTSWAP_v2_1: u8 = 18;


//     // ############### PUBLIC ENTRY FUNCTIONS #####################

//     /// Wrapped call to `provide_liquidity_direct()`
//     public entry fun lend_coins_entry<W,X,Y,Z, weight1, weight2, weight3, weight4, Curve>(
//         sender: &signer,
//         dex_type : u8,
//         coin_w_desired: u64,
//         coin_x_desired: u64,
//         coin_y_desired: u64,
//         coin_z_desired: u64,
//         coin_w_min: u64,
//         coin_x_min: u64,
//         coin_y_min: u64,
//         coin_z_min: u64
//     ){
//         provide_liquidity_direct<W,X,Y,Z, weight1, weight2, weight3, weight4, Curve>(sender, dex_type, coin_w_desired, coin_x_desired, coin_y_desired, coin_z_desired, coin_w_min, coin_x_min, coin_y_min, coin_z_min);
//     }
  
   

//     public fun provide_liquidity_direct<W,X,Y,Z, weight1, weight2, weight3, weight4, Curve>(
//         sender: &signer,
//         dex_type : u8,
//         coin_w_desired: u64,
//         coin_x_desired: u64,
//         coin_y_desired: u64,
//         coin_z_desired: u64,
//         coin_w_min: u64,
//         coin_x_min: u64,
//         coin_y_min: u64,
//         coin_z_min: u64
//     ){
//         if(dex_type == DEX_PANCAKE){
//             add_liquidity_pancake_internal<W,X>(sender, coin_w_desired, coin_x_desired, coin_w_min, coin_x_min);
//         } else if (dex_type == DEX_SUSHI){
//             add_liquidity_sushiswap_internal<W,X>(sender, coin_w_desired, coin_x_desired, coin_w_min, coin_x_min);
//         } else if(dex_type == DEX_BAPTSWAP_v2){
//             add_liquidity_baptswapV2_internal<W,X>(sender, coin_w_desired, coin_x_desired, coin_w_min, coin_x_min);
//         } else if (dex_type == DEX_BAPTSWAP_v2_1){
//             add_liquidity_baptswapV2dot1_internal<W,X>(sender, coin_w_desired, coin_x_desired, coin_w_min, coin_x_min);
//         } else if (dex_type == DEX_CETUS){
//             add_liquidity_cetus_internal<W,X>(sender, coin_w_desired, coin_x_desired, coin_w_min, coin_x_min);
//         } else if (dex_type == DEX_PONTEM_v0){
//             let coin_w = coin::withdraw<W>(sender, coin_w_desired);
//             let coin_x = coin::withdraw<X>(sender, coin_x_desired);
//             let (coin_x_remain, coin_y_remain, lp_token) = add_liquidity_liquidswapV0_internal<W,X, Curve>(sender, coin_w, coin_w_min, coin_x, coin_x_min);
//             check_and_deposit<W>(sender, coin_x_remain);
//             check_and_deposit<X>(sender, coin_y_remain);
//             check_and_deposit<LP_LIQUID<W, X, Curve>>(sender, lp_token);  
//         } else if (dex_type == DEX_PONTEM_v0_5){
//             let coin_w = coin::withdraw<W>(sender, coin_w_desired);
//             let coin_x = coin::withdraw<X>(sender, coin_x_desired);
//             let (coin_x_remain, coin_y_remain, lp_token) = add_liquidity_liquidswapV0_5_internal<W,X, Curve>(sender, coin_w, coin_w_min, coin_x, coin_x_min);
//             check_and_deposit<W>(sender, coin_x_remain);
//             check_and_deposit<X>(sender, coin_y_remain);
//             check_and_deposit<LP_LIQUID<W, X, Curve>>(sender, lp_token);  
//         } else if (dex_type == DEX_ANIMESWAP){
//             let coin_w = coin::withdraw<W>(sender, coin_w_desired);
//             let coin_x = coin::withdraw<X>(sender, coin_x_desired);
//             let lp_token = add_liquidity_animeswap_internal<W,X>(coin_w, coin_x);
//             check_and_deposit<LP_ANIME<W,X>>(sender, lp_token);
//         } else if (dex_type == DEX_THALASWAP_STABLE){
//             let coin_w = coin::withdraw<W>(sender, coin_w_desired);
//             let coin_x = coin::withdraw<X>(sender, coin_x_desired);
//             let coin_y = coin::withdraw<Y>(sender, coin_y_desired);
//             let coin_z = coin::withdraw<Z>(sender, coin_z_desired);
//             let lp_token = add_liquidity_thala_stable_internal<W,X,Y,Z>(coin_w, coin_x, coin_y, coin_z);
//             check_and_deposit<StablePoolToken<W,X,Y,Z>>(sender, lp_token);
//         } else if (dex_type == DEX_THALASWAP_WEIGHTED){
//             let coin_w = coin::withdraw<W>(sender, coin_w_desired);
//             let coin_x = coin::withdraw<X>(sender, coin_x_desired);
//             let coin_y = coin::withdraw<Y>(sender, coin_y_desired);
//             let coin_z = coin::withdraw<Z>(sender, coin_z_desired);
//             let (lp_token, coin_w_remain, coin_x_remain, coin_y_remain, coin_z_remain) = add_liquidity_thala_weighted_internal<W,X,Y,Z, weight1, weight2, weight3, weight4>(coin_w, coin_x, coin_y, coin_z);
//             check_and_deposit<WeightedPoolToken<W,X,Y,Z, weight1, weight2, weight3, weight4>>(sender, lp_token);
//             check_and_deposit<W>(sender, coin_w_remain);
//             check_and_deposit<X>(sender, coin_x_remain);
//             check_and_deposit<Y>(sender, coin_y_remain);
//             check_and_deposit<Z>(sender, coin_z_remain);
//         } else {
//             abort E_UNKNOWN_DEX_OR_NOT_IMPLEMENTED
//         }
//     }


//     // liquidity pool internal functions : 

//     fun add_liquidity_pancake_internal<X,Y>(
//         sender: &signer,
//         amount_x_desired: u64,
//         amount_y_desired: u64,
//         amount_x_min: u64,
//         amount_y_min: u64,
//     ){
//         use pancake::router;
//         router::add_liquidity<X,Y>(sender, amount_x_desired, amount_y_desired, amount_x_min, amount_y_min)
//     }

//     fun add_liquidity_sushiswap_internal<X,Y>(
//         sender: &signer,
//         amount_x_desired: u64,
//         amount_y_desired: u64,
//         amount_x_min: u64,
//         amount_y_min: u64,
//     ){
//          use sushi::router;
//         router::add_liquidity<X,Y>(sender, amount_x_desired, amount_y_desired, amount_x_min, amount_y_min)
//     }

//     fun add_liquidity_liquidswapV0_internal<X,Y, Curve>(
//         sender: &signer,
//         coin_x : coin::Coin<X>,
//         amount_x_min: u64,
//         coin_y : coin::Coin<Y>,
//         amount_y_min: u64,
//     ): (coin::Coin<X>, coin::Coin<Y>, coin::Coin<LP_LIQUID<X, Y, Curve>>){
//         use liquidswap::router_v2;
//         (router_v2::add_liquidity<X,Y, Curve>(coin_x, amount_x_min, coin_y, amount_y_min))
//     }

//     fun add_liquidity_liquidswapV0_5_internal<X,Y, Curve>(
//         sender: &signer,
//         coin_x : coin::Coin<X>,
//         amount_x_min: u64,
//         coin_y : coin::Coin<Y>,
//         amount_y_min: u64,
//     ): (coin::Coin<X>, coin::Coin<Y>, coin::Coin<LP_LIQUID<X, Y, Curve>>){
//         use liquidswap_v05::router;
//         (router::add_liquidity<X,Y, Curve>(coin_x, amount_x_min, coin_y, amount_y_min))
//     }

//     fun add_liquidity_animeswap_internal<X,Y>(
//         coin_x: coin::Coin<X>,
//         coin_y: coin::Coin<Y>
//     ):(coin::Coin<LP_ANIME<X, Y>>){
//         use SwapDeployer::AnimeSwapPoolV1;
//         (AnimeSwapPoolV1::mint<X,Y>(coin_x, coin_y))
//     }
//     fun add_liquidity_baptswapV2_internal<X,Y>(
//         sender: &signer,
//         amount_x_desired: u64,
//         amount_y_desired: u64,
//         amount_x_min: u64,
//         amount_y_min: u64
//     ){
//         use baptswap_v2::router_v2;
//         (router_v2::add_liquidity<X,Y>(sender, amount_x_desired, amount_y_desired, amount_x_min, amount_y_min))
//     }

//     fun add_liquidity_baptswapV2dot1_internal<X,Y>(
//         sender: &signer,
//         amount_x_desired: u64,
//         amount_y_desired: u64,
//         amount_x_min: u64,
//         amount_y_min: u64
//     ){
//         use baptswap_v2dot1::router_v2dot1;
//         (router_v2dot1::add_liquidity<X,Y>(sender, amount_x_desired, amount_y_desired, amount_x_min, amount_y_min))
//     }

//     fun add_liquidity_cetus_internal<X,Y>(
//         sender: &signer,
//         amount_x_desired: u64,
//         amount_y_desired: u64,
//         amount_x_min: u64,
//         amount_y_min: u64
//     ){
//         use cetus_amm::amm_router;
//         (amm_router::add_liquidity<X,Y>(sender, (amount_x_desired as u128), (amount_y_desired as u128), (amount_x_min as u128), (amount_y_min as u128)))
//     }

//     fun add_liquidity_thala_stable_internal<W,X,Y,Z>(
//         coin_w: coin::Coin<W>,
//         coin_x: coin::Coin<X>,
//         coin_y: coin::Coin<Y>,
//         coin_z: coin::Coin<Z>
//     ):(coin::Coin<StablePoolToken<W, X, Y, Z>>){
//         use thalaswap::stable_pool;
//         (stable_pool::add_liquidity<W, X, Y, Z>(coin_w, coin_x, coin_y, coin_z))
//     }

//     fun add_liquidity_thala_weighted_internal<W,X,Y,Z, weight1, weight2, weight3, weight4>(
//         coin_w: coin::Coin<W>,
//         coin_x: coin::Coin<X>,
//         coin_y: coin::Coin<Y>,
//         coin_z: coin::Coin<Z>
//     ):(coin::Coin<WeightedPoolToken<W, X, Y, Z, weight1, weight2, weight3, weight4>>, coin::Coin<W>, coin::Coin<X>, coin::Coin<Y>, coin::Coin<Z>){
//         use thalaswap::weighted_pool;
//         (weighted_pool::add_liquidity<W, X, Y, Z, weight1, weight2, weight3, weight4>(coin_w, coin_x, coin_y, coin_z))
//     }

//     // stake internal functions :
    
//     fun stake_harvest_pool_liquidswap<S,R>(
//         user: &signer,
//         pool_addr: address,
//         coins: coin::Coin<S>
//     ){
//         use harvest::stake;
//         stake::stake<S,R>(user,pool_addr,coins)
//     }

//     fun unstake_harvest_pool_liquidswap<S,R>(
//         user: &signer,
//         pool_addr: address,
//         amount: u64
//     ):(coin::Coin<S>){
//         use harvest::stake;
//         (stake::unstake<S,R>(user,pool_addr,amount))
//     }

//     fun withdraw_rewards_harvest_pool_liquidswap<S,R>(
//         user: &signer,
//         pool_addr: address
//     ):(coin::Coin<R>){
//         use harvest::stake;
//         (stake::harvest<S,R>(user,pool_addr))
//     }
    

//     fun stake_harvest_pool_pancakeswap<CoinType>(
//         sender: &signer,
//         amount: u64
//     ){
//         use pancake_masterchef::masterchef;
//         masterchef::deposit<CoinType>(sender, amount)
//     }

//     fun unstake_harvest_pool_panckeswap<CoinType>(
//         sender: &signer,
//         amount: u64
//     ){
//         use pancake_masterchef::masterchef;
//         masterchef::withdraw<CoinType>(sender, amount)
//     }
    
//     fun withdraw_rewards_harvest_pool_panckeswap<CoinType>(
//         sender: &signer
//     ){
//         use pancake_masterchef::masterchef;
//         masterchef::deposit<CoinType>(sender, (0 as u64))
//     }

//     // ########### INTERNAL FUNCTIONS : DEPOSIT FUNCTIONS ################

//     fun check_and_deposit<X>(sender: &signer, coin: coin::Coin<X>) {
//         let sender_addr = signer::address_of(sender);
//         if (!coin::is_account_registered<X>(sender_addr)) {
//             coin::register<X>(sender);
//         };
//         coin::deposit(sender_addr, coin);
//     }

//     fun check_and_deposit_opt<X>(sender: &signer, coin_opt: Option<coin::Coin<X>>) {
//         if (option::is_some(&coin_opt)) {
//             let coin = option::extract(&mut coin_opt);
//             let sender_addr = signer::address_of(sender);
//             if (!coin::is_account_registered<X>(sender_addr)) {
//                 coin::register<X>(sender);
//             };
//             coin::deposit(sender_addr, coin);
//         };
//         option::destroy_none(coin_opt)
//     }

//     fun check_and_deposit_to_address<X>(receiver: address, coin: coin::Coin<X>) {
//         aptos_account::deposit_coins<X>(receiver,coin)
//     }

   


// }
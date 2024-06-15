// module avex::cellana{
//     // use aptos_framework::event;
//     use aptos_framework::coin::{Self, Coin};
//     // use amnis::amapt_token::{Self,AmnisApt};
//     // use amnis::stapt_token::{Self,StakedApt};
//     // use std::error;
//     use std::signer;    
//     use cellana::router;
//     use cellana::voting_escrow::{Self,VeCellanaToken};
//     use cellana::vote_manager;
//     use cellana::coin_wrapper;
//     use cellana::gauge;
//     use cellana::rewards_pool_continuous;
//     use cellana::liquidity_pool::{Self,LiquidityPool};
//     use cellana::cellana_token::{Self,CellanaToken};
//     use 0x1::primary_fungible_store;
//     use 0000000000000000000000000000000000000000000000000000000000000001::object::{Self,Object};
//     use 0000000000000000000000000000000000000000000000000000000000000001::fungible_asset::{Metadata};

//     //vote_manager::vote
//     //voting_escrow::create_lock_entry
//     // router::swap_route_entry_both
//     // public entry fun add_liquidity<T0>(user:&signer,amount:u64,)


//     //swap Ty0 for Ty1
//     // public entry fun swap_both_coins<Ty0,Ty1>(user:&signer, amount_swap:u64, amount_gain:u64, metadata:vector<Object<Metadata>>, is_exact_output:vector<bool>, recipient_addr:address){
//     //     router::swap_route_entry_both_coins<Ty0,Ty1>(user,amount_swap,amount_gain,metadata,is_exact_output, recipient_addr);
//     // }

//     public entry fun vote(user:&signer, veCellToken:Object<VeCellanaToken>, chosen_pool:vector<Object<LiquidityPool>>, votes:vector<u64>){
//         vote_manager::vote(user,veCellToken,chosen_pool,votes);
//     }

//     public entry fun create_lock(user:&signer,amount:u64,lock_duration:u64){
//         voting_escrow::create_lock_with(primary_fungible_store::withdraw<CellanaToken>(user,cellana_token::token(),amount),lock_duration,signer::address_of(user));
//     }
//     // swap coin for asset and vice-versa
//     // public entry fun 
//    public entry fun claim_rewards<T0, T1>(user: &signer, arg1: bool) {
//         vote_manager::claim_emissions_entry(user, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg1));
//     }
    
//     public entry fun claim_rewards_single_coin<T0>(user: &signer, arg1: 0x1::object::Object<Metadata>, arg2: bool) {
//         vote_manager::claim_emissions_entry(user, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), arg1, arg2));
//     }
//     public entry fun add_liquidity_and_stake_coin<T0>(user:&signer,asset:Object<Metadata>,isWrapped:bool,amount1:u64,amount2:u64){
//         router::add_liquidity_and_stake_coin_entry<T0>(user,asset,isWrapped,amount1,amount2);
//     }

//     public entry fun add_liquidity_and_stake_both_coins<T0,T1>(user:&signer,isWrapped:bool,amount1:u64,amount2:u64){
//         router::add_liquidity_and_stake_both_coins_entry<T0,T1>(user,isWrapped,amount1,amount2);
//     }

//     //  public fun get_lp_token<T0, T1>(arg0: bool, arg1: u64, arg2: u64) : u64 {
//     //     liquidity_pool::liquidity_out(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg0, arg1, arg2)
//     // }
    
//     fun get_lp_token_amount(arg0: address, arg1: 0x1::object::Object<LiquidityPool>) : (u64, u64) {
//         let v0 = gauge::rewards_pool(vote_manager::get_gauge(arg1));
//         (rewards_pool_continuous::stake_balance(arg0, v0), rewards_pool_continuous::claimable_rewards(arg0, v0))
//     }
    
//     // public fun get_lp_token_single_coin<T0>(arg0: 0x1::object::Object<Metadata>, arg1: bool, arg2: u64, arg3: u64) : u64 {
//     //     liquidity_pool::liquidity_out(coin_wrapper::get_wrapper<T0>(), arg0, arg1, arg2, arg3)
//     // }
    
//     public fun get_pool_reserves<T0, T1>(arg0: bool) : (u64, u64) {
//         liquidity_pool::pool_reserves<LiquidityPool>(liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg0))
//     }
    
//     public fun get_pool_reserves_single_coin<T0>(arg0: 0x1::object::Object<Metadata>, arg1: bool) : (u64, u64) {
//         liquidity_pool::pool_reserves<LiquidityPool>(liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), arg0, arg1))
//     }
    
//     public fun get_token_amount_from_lp(arg0: 0x1::object::Object<LiquidityPool>, arg1: u64) : (u64, u64) {
//         liquidity_pool::liquidity_amounts(arg0, arg1)
//     }
    
//     public fun lp_token_both_coins<T0, T1>(arg0: address, arg1: bool) : (u64, u64) {
//         get_lp_token_amount(arg0, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg1))
//     }
    
//     public fun lp_token_single_coins<T0>(arg0: address, arg1: 0x1::object::Object<Metadata>, arg2: bool) : (u64, u64) {
//         get_lp_token_amount(arg0, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), arg1, arg2))
//     }

//      public entry fun remove_liquid_both_coins<T0, T1>(user: &signer, arg1: bool, arg2: u64, arg3: u64, arg4: u64, arg5: address) {
//         router::unstake_and_remove_liquidity_both_coins_entry<T0, T1>(user, arg1, arg2, arg3, arg4, arg5);
//     }
    
//     public entry fun remove_liquid_single_coins<T0>(user: &signer, arg1: 0x1::object::Object<Metadata>, arg2: bool, arg3: u64, arg4: u64, arg5: u64, arg6: address) {
//         router::unstake_and_remove_liquidity_coin_entry<T0>(user, arg1, arg2, arg3, arg4, arg5, arg6);
//     }

// }

module avex::cellaanaa{
    use cellana::router;
    use cellana::coin_wrapper;
    use cellana::gauge;
    use 0x1::signer;
    use cellana::rewards_pool_continuous;
    use cellana::vote_manager;
    use 0x1::object::{Self,Object};
    use cellana::liquidity_pool::{Self,LiquidityPool};
    use aptos_framework::fungible_asset::Metadata;
    use cellana::voting_escrow::{Self,VeCellanaToken};
    use cellana::cellana_token::{Self,CellanaToken};
    use 0x1::primary_fungible_store;

// collection_address = "0xa552a439fb5e07f9754ec208f44cfe04524426a55ccbb2fd752f54c9c1f21337"

    public entry fun add_liquid_both_coins<T0, T1>(arg0: &signer, arg1: bool, arg2: u64, arg3: u64) {
        router::add_liquidity_and_stake_both_coins_entry<T0, T1>(arg0, arg1, arg2, arg3);
    }

    // public entry fun swap_both_coins<Ty0,Ty1>(user:&signer, amount_swap:u64, amount_gain:u64, metadata:vector<Object<Metadata>>, is_exact_output:vector<bool>, recipient_addr:address){
    //     router::swap_route_entry_both_coins<Ty0,Ty1>(user,amount_swap,amount_gain,metadata,is_exact_output, recipient_addr);
    // }

    public entry fun create_lock(user:&signer,amount:u64,lock_duration:u64){
        voting_escrow::create_lock_with(primary_fungible_store::withdraw<CellanaToken>(user,cellana_token::token(),amount),lock_duration,signer::address_of(user));
    }

    public entry fun vote(user:&signer, veCellToken:address, chosen_pool:vector<Object<LiquidityPool>>, votes:vector<u64>){
        vote_manager::vote(user,object::address_to_object<VeCellanaToken>(veCellToken),chosen_pool,votes);
    }

    public entry fun vote_batch(user:&signer, veCellToken:vector<Object<VeCellanaToken>>,chosen_pools:vector<Object<LiquidityPool>>,votes:vector<u64>){
        vote_manager::vote_batch(user,veCellToken, chosen_pools, votes);
    }
    //object::address_to_object<Metadata>(asset)
    
    public entry fun add_liquid_single_coin<T0>(arg0: &signer, asset: address, arg2: bool, arg3: u64, arg4: u64) {
        router::add_liquidity_and_stake_coin_entry<T0>(arg0, object::address_to_object<Metadata>(asset), arg2, arg3, arg4);
    }
    
    public entry fun claim_rewards<T0, T1>(arg0: &signer, arg1: bool) {
        vote_manager::claim_emissions_entry(arg0, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg1));
    }
    
    public entry fun claim_rewards_single_coin<T0>(arg0: &signer, asset: address, arg2: bool) {
        vote_manager::claim_emissions_entry(arg0, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), object::address_to_object<Metadata>(asset), arg2));
    }
    
    public fun get_lp_token<T0, T1>(arg0: bool, arg1: u64, arg2: u64) : u64 {
        liquidity_pool::liquidity_out(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg0, arg1, arg2)
    }
    
    fun get_lp_token_amount(arg0: address, arg1: 0x1::object::Object<LiquidityPool>) : (u64, u64) {
        let v0 = gauge::rewards_pool(vote_manager::get_gauge(arg1));
        (rewards_pool_continuous::stake_balance(arg0, v0), rewards_pool_continuous::claimable_rewards(arg0, v0))
    }
    
    public fun get_lp_token_single_coin<T0>(arg0: 0x1::object::Object<Metadata>, arg1: bool, arg2: u64, arg3: u64) : u64 {
        liquidity_pool::liquidity_out(coin_wrapper::get_wrapper<T0>(), arg0, arg1, arg2, arg3)
    }
    
    public fun get_pool_reserves<T0, T1>(arg0: bool) : (u64, u64) {
        liquidity_pool::pool_reserves<LiquidityPool>(liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg0))
    }
    
    public fun get_pool_reserves_single_coin<T0>(asset: address, arg1: bool) : (u64, u64) {
        liquidity_pool::pool_reserves<LiquidityPool>(liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), object::address_to_object<Metadata>(asset), arg1))
    }
    
    public fun get_token_amount_from_lp(asset: address, arg1: u64) : (u64, u64) {
        liquidity_pool::liquidity_amounts(object::address_to_object<LiquidityPool>(asset), arg1)
    }
    
    public fun lp_token_both_coins<T0, T1>(arg0: address, arg1: bool) : (u64, u64) {
        get_lp_token_amount(arg0, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), coin_wrapper::get_wrapper<T1>(), arg1))
    }
    
    public fun lp_token_single_coins<T0>(arg0: address, asset: address, arg2: bool) : (u64, u64) {
        get_lp_token_amount(arg0, liquidity_pool::liquidity_pool(coin_wrapper::get_wrapper<T0>(), object::address_to_object<Metadata>(asset), arg2))
    }
    
    public entry fun remove_liquid_both_coins<T0, T1>(arg0: &signer, arg1: bool, arg2: u64, arg3: u64, arg4: u64, arg5: address) {
        router::unstake_and_remove_liquidity_both_coins_entry<T0, T1>(arg0, arg1, arg2, arg3, arg4, arg5);
    }
    
    public entry fun remove_liquid_single_coins<T0>(arg0: &signer, asset: address, arg2: bool, arg3: u64, arg4: u64, arg5: u64, arg6: address) {
        router::unstake_and_remove_liquidity_coin_entry<T0>(arg0, object::address_to_object<Metadata>(asset), arg2, arg3, arg4, arg5, arg6);
    }
    
    // decompiled from Move bytecode v6
}


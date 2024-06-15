// Move bytecode v6
module cellana::router {
use 0000000000000000000000000000000000000000000000000000000000000001::aptos_account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Self,Coin};
use 0000000000000000000000000000000000000000000000000000000000000001::error;
use 0000000000000000000000000000000000000000000000000000000000000001::fungible_asset::{Self,FungibleAsset,Metadata};
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Self,Object};
use 0000000000000000000000000000000000000000000000000000000000000001::primary_fungible_store;
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::vector;
// use cellana::coin_wrapper;
use cellana::gauge;
use cellana::liquidity_pool::{Self,LiquidityPool};
use cellana::vote_manager;




public fun add_liquidity(_arg0: &signer, _arg1: FungibleAsset, _arg2: FungibleAsset, _arg3: bool) {
abort 0
}
entry public fun add_liquidity_and_stake_both_coins_entry<Ty0, Ty1>(_arg0: &signer, _arg1: bool, _arg2: u64, _arg3: u64) {

}
entry public fun add_liquidity_and_stake_coin_entry<Ty0>(_arg0: &signer, _arg1: Object<Metadata>, _arg2: bool, _arg3: u64, _arg4: u64) {

}
entry public fun add_liquidity_and_stake_entry(_arg0: &signer, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool, _arg4: u64, _arg5: u64) {

}
public fun add_liquidity_both_coins<Ty0, Ty1>(_arg0: &signer, _arg1: Coin<Ty0>, _arg2: Coin<Ty1>, _arg3: bool) {
abort 0
}
entry public fun add_liquidity_both_coins_entry<Ty0, Ty1>(_arg0: &signer, _arg1: bool, _arg2: u64, _arg3: u64) {

}
public fun add_liquidity_coin<Ty0>(_arg0: &signer, _arg1: Coin<Ty0>, _arg2: FungibleAsset, _arg3: bool) {
abort 0
}
entry public fun add_liquidity_coin_entry<Ty0>(_arg0: &signer, _arg1: Object<Metadata>, _arg2: bool, _arg3: u64, _arg4: u64) {

}
entry public fun add_liquidity_entry(_arg0: &signer, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool, _arg4: u64, _arg5: u64) {

}
entry public fun create_pool(_arg0: Object<Metadata>, _arg1: Object<Metadata>, _arg2: bool) {

}
entry public fun create_pool_both_coins<Ty0, Ty1>(_arg0: bool) {

}
entry public fun create_pool_coin<Ty0>(_arg0: Object<Metadata>, _arg1: bool) {

}
public fun get_amount_out(_arg0: u64, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool): (u64 , u64) {
abort 0
}
public fun get_amounts_out(_arg0: u64, _arg1: Object<Metadata>, _arg2: vector<address>, _arg3: vector<bool>): u64 {
abort 0
}
public fun get_trade_diff(_arg0: u64, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool): (u64 , u64) {
abort 0
}
public fun quote_liquidity(_arg0: Object<Metadata>, _arg1: Object<Metadata>, _arg2: bool, _arg3: u64): u64 {
abort 0
}
public fun redeemable_liquidity(_arg0: Object<LiquidityPool>, _arg1: u64): (u64 , u64) {
abort 0
}
public fun remove_liquidity(_arg0: &signer, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool, _arg4: u64, _arg5: u64, _arg6: u64): (FungibleAsset , FungibleAsset) {
abort 0
}
public fun remove_liquidity_both_coins<Ty0, Ty1>(_arg0: &signer, _arg1: bool, _arg2: u64, _arg3: u64, _arg4: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
entry public fun remove_liquidity_both_coins_entry<Ty0, Ty1>(_arg0: &signer, _arg1: bool, _arg2: u64, _arg3: u64, _arg4: u64, _arg5: address) {

}
public fun remove_liquidity_coin<Ty0>(_arg0: &signer, _arg1: Object<Metadata>, _arg2: bool, _arg3: u64, _arg4: u64, _arg5: u64): (Coin<Ty0> , FungibleAsset) {
abort 0
}
entry public fun remove_liquidity_coin_entry<Ty0>(_arg0: &signer, _arg1: Object<Metadata>, _arg2: bool, _arg3: u64, _arg4: u64, _arg5: u64, _arg6: address) {

}
entry public fun remove_liquidity_entry(_arg0: &signer, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool, _arg4: u64, _arg5: u64, _arg6: u64, _arg7: address) {

}
public fun swap(_arg0: FungibleAsset, _arg1: u64, _arg2: Object<Metadata>, _arg3: bool): FungibleAsset {
abort 0
}
public fun asset_for_coin<Ty0>(_arg0: FungibleAsset, _arg1: u64, _arg2: bool): Coin<Ty0> {
abort 0
}
entry public fun swap_asset_for_coin_entry<Ty0>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: Object<Metadata>, _arg4: bool, _arg5: address) {

}
public fun swap_coin_for_asset<Ty0>(_arg0: Coin<Ty0>, _arg1: u64, _arg2: Object<Metadata>, _arg3: bool): FungibleAsset {
abort 0
}
entry public fun swap_coin_for_asset_entry<Ty0>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: Object<Metadata>, _arg4: bool, _arg5: address) {

}
public fun swap_coin_for_coin<Ty0, Ty1>(_arg0: Coin<Ty0>, _arg1: u64, _arg2: bool): Coin<Ty1> {
abort 0
}
entry public fun swap_coin_for_coin_entry<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: bool, _arg4: address) {

}
entry public fun swap_entry(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: Object<Metadata>, _arg4: Object<Metadata>, _arg5: bool, _arg6: address) {

}
entry public fun swap_route_entry(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: Object<Metadata>, _arg4: vector<Object<Metadata>>, _arg5: vector<bool>, _arg6: address) {

}
entry public fun swap_route_entry_both_coins<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: vector<Object<Metadata>>, _arg4: vector<bool>, _arg5: address) {

}
entry public fun swap_route_entry_from_coin<Ty0>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: vector<Object<Metadata>>, _arg4: vector<bool>, _arg5: address) {

}
entry public fun swap_route_entry_to_coin<Ty0>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: Object<Metadata>, _arg4: vector<Object<Metadata>>, _arg5: vector<bool>, _arg6: address) {

}
public fun swap_router(_arg0: FungibleAsset, _arg1: u64, _arg2: vector<Object<Metadata>>, _arg3: vector<bool>): FungibleAsset {
abort 0
}
entry public fun unstake_and_remove_liquidity_both_coins_entry<Ty0, Ty1>(_arg0: &signer, _arg1: bool, _arg2: u64, _arg3: u64, _arg4: u64, _arg5: address) {

}
entry public fun unstake_and_remove_liquidity_coin_entry<Ty0>(_arg0: &signer, _arg1: Object<Metadata>, _arg2: bool, _arg3: u64, _arg4: u64, _arg5: u64, _arg6: address) {

}
entry public fun unstake_and_remove_liquidity_entry(_arg0: &signer, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool, _arg4: u64, _arg5: u64, _arg6: u64, _arg7: address) {

}
}
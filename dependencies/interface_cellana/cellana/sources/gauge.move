// Move bytecode v6
module cellana::gauge {
use 0000000000000000000000000000000000000000000000000000000000000001::event;
use 0000000000000000000000000000000000000000000000000000000000000001::fungible_asset::{Self,FungibleAsset,Metadata};
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Self,Object,ExtendRef};
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
// use cellana::cellana_token;
use cellana::liquidity_pool::{Self,LiquidityPool};
// use cellana::package_manager;
use cellana::rewards_pool_continuous::{Self,RewardsPool};


struct Gauge has key {
	rewards_pool: Object<RewardsPool>,
	extend_ref: ExtendRef,
	liquidity_pool: Object<LiquidityPool>
}
struct StakeEvent has drop, store {
	lp: address,
	gauge: Object<Gauge>,
	amount: u64
}
struct UnstakeEvent has drop, store {
	lp: address,
	gauge: Object<Gauge>,
	amount: u64
}

public(friend) fun add_rewards(_arg0: Object<Gauge>, _arg1: FungibleAsset) {
abort 0
}
public(friend) fun claim_fees(_arg0: Object<Gauge>): (FungibleAsset , FungibleAsset) {
abort 0
}
public(friend) fun claim_rewards(_arg0: &signer, _arg1: Object<Gauge>): FungibleAsset {
    abort 0
}
public fun claimable_rewards(_arg0: address, _arg1: Object<Gauge>): u64 {
    abort 0
}
public(friend) fun create(_arg0: Object<LiquidityPool>): Object<Gauge> {
abort 0
}
public fun liquidity_pool(_arg0: Object<Gauge>): Object<LiquidityPool> {
abort 0
}
public fun rewards_duration(): u64 {
abort 0
}
public fun rewards_pool(_arg0: Object<Gauge>): Object<RewardsPool> {
abort 0
}
entry public fun stake(_arg0: &signer, _arg1: Object<Gauge>, _arg2: u64) {
abort 0
}
public fun stake_balance(_arg0: address, _arg1: Object<Gauge>): u64 {
abort 0
}
public fun stake_token(_arg0: Object<Gauge>): Object<Metadata> {
abort 0
}
public fun total_stake(_arg0: Object<Gauge>): u128 {
abort 0
}
entry public fun unstake(_arg0: &signer, _arg1: Object<Gauge>, _arg2: u64) {
abort 0
}
}
// Move bytecode v6
module cellana::rewards_pool {
use 0000000000000000000000000000000000000000000000000000000000000001::fungible_asset::{Self,FungibleAsset,Metadata,FungibleStore};
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Self,Object,ExtendRef};
use 0000000000000000000000000000000000000000000000000000000000000001::pool_u64_unbound::{Self,Pool};
use 0000000000000000000000000000000000000000000000000000000000000001::simple_map::{Self,SimpleMap};
use 0000000000000000000000000000000000000000000000000000000000000001::smart_table::{Self,SmartTable};
// use 0000000000000000000000000000000000000000000000000000000000000001::vector;
// use cellana::epoch;
// use cellana::package_manager;


struct EpochRewards has store {
	total_amounts: SimpleMap<Object<Metadata>, u64>,
	reward_tokens: vector<Object<Metadata>>,
	non_default_reward_tokens_count: u64,
	claimer_pool: Pool
}
struct RewardStore has store {
	store: Object<FungibleStore>,
	store_extend_ref: ExtendRef
}
struct RewardsPool has key {
	epoch_rewards: SmartTable<u64, EpochRewards>,
	reward_stores: SmartTable<Object<Metadata>, RewardStore>,
	default_reward_tokens: vector<Object<Metadata>>
}

public(friend) fun add_rewards(_arg0: Object<RewardsPool>, _arg1: vector<FungibleAsset>, _arg2: u64) {
abort 0
}
public(friend) fun claim_rewards(_arg0: address, _arg1: Object<RewardsPool>, _arg2: u64): vector<FungibleAsset> {
abort 0
}
public fun claimable_rewards(_arg0: address, _arg1: Object<RewardsPool>, _arg2: u64): SimpleMap<Object<Metadata>, u64> {
abort 0
}
public fun claimer_shares(_arg0: address, _arg1: Object<RewardsPool>, _arg2: u64): (u64 , u64) {
abort 0
}
public(friend) fun create(_arg0: vector<Object<Metadata>>): Object<RewardsPool> {
abort 0
}
public(friend) fun decrease_allocation(_arg0: address, _arg1: Object<RewardsPool>, _arg2: u64) {

}
public fun default_reward_tokens(_arg0: Object<RewardsPool>): vector<Object<Metadata>> {
abort 0
}
public(friend) fun increase_allocation(_arg0: address, _arg1: Object<RewardsPool>, _arg2: u64) {

}
public fun reward_tokens(_arg0: Object<RewardsPool>, _arg1: u64): vector<Object<Metadata>> {
abort 0
}
fun rewards(_arg0: address, _arg1: &RewardsPool, _arg2: Object<Metadata>, _arg3: u64): u64 {
abort 0
}
public fun total_rewards(_arg0: Object<RewardsPool>, _arg1: u64): SimpleMap<Object<Metadata>, u64> {
abort 0
}
}
// Move bytecode v6
module cellana::rewards_pool_continuous {
use 0000000000000000000000000000000000000000000000000000000000000001::error;
use 0000000000000000000000000000000000000000000000000000000000000001::fungible_asset::{Self,FungibleAsset,Metadata};
use 0000000000000000000000000000000000000000000000000000000000000001::math64;
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Self,Object,ExtendRef};
use 0000000000000000000000000000000000000000000000000000000000000001::smart_table::{Self,SmartTable};
use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
// use cellana::package_manager;


struct RewardsPool has key {
	extend_ref: ExtendRef,
	reward_per_token_stored: u128,
	user_reward_per_token_paid: SmartTable<address, u128>,
	last_update_time: u64,
	reward_rate: u128,
	reward_duration: u64,
	reward_period_finish: u64,
	rewards: SmartTable<address, u64>,
	total_stake: u128,
	stakes: SmartTable<address, u64>
}

public(friend) fun add_rewards(_arg0: Object<RewardsPool>, _arg1: FungibleAsset) {
abort 0
}
public(friend) fun claim_rewards(_arg0: address, _arg1: Object<RewardsPool>): FungibleAsset {
abort 0
}
fun claimable_internal(_arg0: address, _arg1: &RewardsPool): u64 {
abort 0
}
public fun claimable_rewards(_arg0: address, _arg1: Object<RewardsPool>): u64 {
abort 0
}
public(friend) fun create(_arg0: Object<Metadata>, _arg1: u64): Object<RewardsPool> {
abort 0
}
public fun current_reward_period_finish(_arg0: Object<RewardsPool>): u64 {
abort 0
}
public fun reward_per_token(_arg0: Object<RewardsPool>): u128 {
abort 0
}
fun reward_per_token_internal(_arg0: &RewardsPool): u128 {
abort 0
}
public fun reward_rate(_arg0: Object<RewardsPool>): u128 {
abort 0
}
public(friend) fun stake(_arg0: address, _arg1: Object<RewardsPool>, _arg2: u64) {

}
public fun stake_balance(_arg0: address, _arg1: Object<RewardsPool>): u64 {
abort 0
}
public fun total_stake(_arg0: Object<RewardsPool>): u128 {
abort 0
}
public fun total_unclaimed_rewards(_arg0: Object<RewardsPool>): u64 {
abort 0
}
public(friend) fun unstake(_arg0: address, _arg1: Object<RewardsPool>, _arg2: u64) {

}
fun update_reward(_arg0: address, _arg1: Object<RewardsPool>) {

}
}
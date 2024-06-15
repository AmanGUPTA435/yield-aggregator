// Move bytecode v5
module harvest::stake {
// use 0000000000000000000000000000000000000000000000000000000000000001::account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
// use 0000000000000000000000000000000000000000000000000000000000000001::math128;
// use 0000000000000000000000000000000000000000000000000000000000000001::math64;
use 0000000000000000000000000000000000000000000000000000000000000001::option::{Option};
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
use 0000000000000000000000000000000000000000000000000000000000000001::table::{Table};
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
use 0000000000000000000000000000000000000000000000000000000000000003::token::{Token};
// use harvest::stake_config;


struct BoostEvent has drop, store {
	user_address: address
}
struct DepositRewardEvent has drop, store {
	user_address: address,
	amount: u64,
	new_end_timestamp: u64
}
struct HarvestEvent has drop, store {
	user_address: address,
	amount: u64
}
struct NFTBoostConfig has store {
	boost_percent: u128,
	collection_owner: address,
	collection_name: String
}
struct RemoveBoostEvent has drop, store {
	user_address: address
}
struct StakeEvent has drop, store {
	user_address: address,
	amount: u64
}
struct StakePool<phantom Ty0, phantom Ty1> has key {
	reward_per_sec: u64,
	accum_reward: u128,
	last_updated: u64,
	start_timestamp: u64,
	end_timestamp: u64,
	stakes: Table<address, UserStake>,
	stake_coins: Coin<Ty0>,
	reward_coins: Coin<Ty1>,
	scale: u128,
	total_boosted: u128,
	nft_boost_config: Option<NFTBoostConfig>,
	emergency_locked: bool,
	stake_events: EventHandle<StakeEvent>,
	unstake_events: EventHandle<UnstakeEvent>,
	deposit_events: EventHandle<DepositRewardEvent>,
	harvest_events: EventHandle<HarvestEvent>,
	boost_events: EventHandle<BoostEvent>,
	remove_boost_events: EventHandle<RemoveBoostEvent>
}
struct UnstakeEvent has drop, store {
	user_address: address,
	amount: u64
}
struct UserStake has store {
	amount: u64,
	unobtainable_reward: u128,
	earned_reward: u64,
	unlock_time: u64,
	nft: Option<Token>,
	boosted_amount: u128
}

fun accum_rewards_since_last_updated<Ty0, Ty1>(_arg0: &StakePool<Ty0, Ty1>, _arg1: u64): u128 {
abort 0
}
public fun boost<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: Token) {
abort 0
}
public fun create_boost_config(_arg0: address, _arg1: String, _arg2: u128): NFTBoostConfig {
abort 0
}
public fun deposit_reward_coins<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: Coin<Ty1>) {
abort 0
}
public fun emergency_unstake<Ty0, Ty1>(_arg0: &signer, _arg1: address): (Coin<Ty0> , Option<Token>) {
abort 0
}
public fun enable_emergency<Ty0, Ty1>(_arg0: &signer, _arg1: address) {

}
public fun get_boost_config<Ty0, Ty1>(_arg0: address): (address , String , u128) {
abort 0
}
public fun get_end_timestamp<Ty0, Ty1>(_arg0: address): u64 {
abort 0
}
public fun get_pending_user_rewards<Ty0, Ty1>(_arg0: address, _arg1: address): u64 {
abort 0
}
public fun get_pool_total_boosted<Ty0, Ty1>(_arg0: address): u128 {
abort 0
}
public fun get_pool_total_stake<Ty0, Ty1>(_arg0: address): u64 {
abort 0
}
public fun get_start_timestamp<Ty0, Ty1>(_arg0: address): u64 {
abort 0
}
fun get_time_for_last_update<Ty0, Ty1>(_arg0: &StakePool<Ty0, Ty1>): u64 {
abort 0
}
public fun get_unlock_time<Ty0, Ty1>(_arg0: address, _arg1: address): u64 {
abort 0
}
public fun get_user_boosted<Ty0, Ty1>(_arg0: address, _arg1: address): u128 {
abort 0
}
public fun get_user_stake<Ty0, Ty1>(_arg0: address, _arg1: address): u64 {
abort 0
}
public fun harvest<Ty0, Ty1>(_arg0: &signer, _arg1: address): Coin<Ty1> {
abort 0
}
public fun is_boostable<Ty0, Ty1>(_arg0: address): bool {
abort 0
}
public fun is_boosted<Ty0, Ty1>(_arg0: address, _arg1: address): bool {
abort 0
}
public fun is_emergency<Ty0, Ty1>(_arg0: address): bool {
abort 0
}
fun is_emergency_inner<Ty0, Ty1>(_arg0: &StakePool<Ty0, Ty1>): bool {
abort 0
}
public fun is_finished<Ty0, Ty1>(_arg0: address): bool {
abort 0
}
fun is_finished_inner<Ty0, Ty1>(_arg0: &StakePool<Ty0, Ty1>): bool {
abort 0
}
public fun is_local_emergency<Ty0, Ty1>(_arg0: address): bool {
abort 0
}
public fun is_unlocked<Ty0, Ty1>(_arg0: address, _arg1: address): bool {
abort 0
}
public fun pool_exists<Ty0, Ty1>(_arg0: address): bool {
abort 0
}
fun pool_total_staked_with_boosted<Ty0, Ty1>(_arg0: &StakePool<Ty0, Ty1>): u128 {
abort 0
}
public fun register_pool<Ty0, Ty1>(_arg0: &signer, _arg1: Coin<Ty1>, _arg2: u64, _arg3: Option<NFTBoostConfig>) {
abort 0
}
public fun remove_boost<Ty0, Ty1>(_arg0: &signer, _arg1: address): Token {
abort 0
}
public fun stake<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: Coin<Ty0>) {
abort 0
}
public fun stake_exists<Ty0, Ty1>(_arg0: address, _arg1: address): bool {
abort 0
}
public fun unstake<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: u64): Coin<Ty0> {
abort 0
}
fun update_accum_reward<Ty0, Ty1>(_arg0: &mut StakePool<Ty0, Ty1>) {
abort 0
}
fun update_user_earnings(_arg0: u128, _arg1: u128, _arg2: &mut UserStake) {
abort 0
}
fun user_earned_since_last_update(_arg0: u128, _arg1: u128, _arg2: &UserStake): u128 {
abort 0
}
fun user_stake_amount_with_boosted(_arg0: &UserStake): u128 {
abort 0
}
public fun withdraw_to_treasury<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: u64): Coin<Ty1> {
abort 0
}
}
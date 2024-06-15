// Move bytecode v6
module cellana::vote_manager {
use 0000000000000000000000000000000000000000000000000000000000000001::aptos_account;
use 0000000000000000000000000000000000000000000000000000000000000001::code;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
use 0000000000000000000000000000000000000000000000000000000000000001::event;
use aptos_framework::fungible_asset::{MintRef, TransferRef, BurnRef, Metadata, FungibleAsset};
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Object};
use 0000000000000000000000000000000000000000000000000000000000000001::primary_fungible_store;
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::simple_map::{SimpleMap};
use 0000000000000000000000000000000000000000000000000000000000000001::smart_table::{SmartTable};
use 0000000000000000000000000000000000000000000000000000000000000001::smart_vector::{SmartVector};
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
use 0000000000000000000000000000000000000000000000000000000000000001::vector;
// use cellana::cellana_token;
// use cellana::coin_wrapper;
// use cellana::epoch;
use cellana::gauge::{Gauge};
use cellana::liquidity_pool::{LiquidityPool};
// use cellana::minter;
// use cellana::package_manager;
use cellana::rewards_pool::{RewardsPool};
// use cellana::token_whitelist;
use cellana::voting_escrow::{VeCellanaToken};


struct AbstainEvent has drop, store {
	owner: address,
	ve_token: Object<VeCellanaToken>
}
struct AdministrativeData has key {
	active_gauges: SmartTable<Object<Gauge>, bool>,
	active_gauges_list: SmartVector<Object<Gauge>>,
	pool_to_gauge: SmartTable<Object<LiquidityPool>, Object<Gauge>>,
	gauge_to_fees_pool: SmartTable<Object<Gauge>, Object<RewardsPool>>,
	gauge_to_incentive_pool: SmartTable<Object<Gauge>, Object<RewardsPool>>,
	operator: address,
	governance: address,
	pending_distribution_epoch: u64
}
struct AdvanceEpochEvent has drop, store {
	epoch: u64
}
struct CreateGaugeEvent has drop, store {
	gauge: Object<Gauge>,
	creator: address,
	pool: Object<LiquidityPool>
}
struct GaugeVoteAccounting has key {
	total_votes: u128,
	votes_for_gauges: SimpleMap<Object<Gauge>, u128>
}
struct NullCoin {
	dummy_field: bool
}
struct VeTokenVoteAccounting has key {
	votes_for_pools_by_ve_token: SmartTable<Object<VeCellanaToken>, SimpleMap<Object<LiquidityPool>, u64>>,
	last_voted_epoch: SmartTable<Object<VeCellanaToken>, u64>
}
struct VoteEvent has drop, store {
	owner: address,
	ve_token: Object<VeCellanaToken>,
	pools: vector<Object<LiquidityPool>>,
	weights: vector<u64>
}
struct WhitelistEvent has drop, store {
	tokens: vector<String>
}

fun add_valid_coin<Ty0>(_arg0: &mut vector<String>) {

}
entry public fun advance_epoch() {

}
public fun all_claimable_rewards(_arg0: Object<VeCellanaToken>, _arg1: Object<LiquidityPool>, _arg2: u64): SimpleMap<u64, SimpleMap<String, u64>> {
abort 0
}
public fun all_current_votes(): (SimpleMap<Object<LiquidityPool>, u128> , u128) {
abort 0
}
public fun can_vote(_arg0: Object<VeCellanaToken>): bool {
abort 0
}
public fun claim_emissions(_arg0: &signer, _arg1: Object<LiquidityPool>): FungibleAsset {
abort 0
}
entry public fun claim_emissions_entry(_arg0: &signer, _arg1: Object<LiquidityPool>) {

}
entry public fun claim_emissions_multiple(_arg0: &signer, _arg1: vector<Object<LiquidityPool>>) {

}
entry public fun claim_rebase(_arg0: &signer, _arg1: Object<VeCellanaToken>) {

}
entry public fun claim_rewards<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7, Ty8, Ty9, Ty10, Ty11, Ty12, Ty13, Ty14>(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: Object<LiquidityPool>, _arg3: u64) {

}
entry public fun claim_rewards_all<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7, Ty8, Ty9, Ty10, Ty11, Ty12, Ty13, Ty14>(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: Object<LiquidityPool>, _arg3: u64) {

}
public fun claimable_emissions(_arg0: address, _arg1: Object<LiquidityPool>): u64 {
abort 0
}
public fun claimable_emissions_multiple(_arg0: address, _arg1: vector<Object<LiquidityPool>>): vector<u64> {
abort 0
}
public fun claimable_rebase(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun claimable_rewards(_arg0: Object<VeCellanaToken>, _arg1: Object<LiquidityPool>, _arg2: u64): SimpleMap<String, u64> {
abort 0
}
public fun create_gauge(_arg0: &signer, _arg1: Object<LiquidityPool>): Object<Gauge> {
abort 0
}
entry public fun create_gauge_entry(_arg0: &signer, _arg1: Object<LiquidityPool>) {

}
public fun current_votes(_arg0: Object<LiquidityPool>): (u128 , u128) {
abort 0
}
entry public fun disable_gauge(_arg0: &signer, _arg1: Object<Gauge>) {

}
entry public fun enable_gauge(_arg0: &signer, _arg1: Object<Gauge>) {

}
public fun fees_pool(_arg0: Object<LiquidityPool>): Object<RewardsPool> {
abort 0
}
public fun gauge_exists(_arg0: Object<LiquidityPool>): bool {
abort 0
}
public fun get_gauge(_arg0: Object<LiquidityPool>): Object<Gauge> {
abort 0
}
public fun get_gauges(_arg0: vector<Object<LiquidityPool>>): vector<Object<Gauge>> {
abort 0
}
public fun governance(): address {
abort 0
}
public fun incentive_pool(_arg0: Object<LiquidityPool>): Object<RewardsPool> {
abort 0
}
public fun incentivize(_arg0: Object<LiquidityPool>, _arg1: vector<FungibleAsset>) {
abort 0
}
public fun incentivize_coin<Ty0>(_arg0: Object<LiquidityPool>, _arg1: Coin<Ty0>) {
abort 0
}
entry public fun incentivize_coin_entry<Ty0>(_arg0: &signer, _arg1: Object<LiquidityPool>, _arg2: u64) {

}
entry public fun incentivize_entry(_arg0: &signer, _arg1: Object<LiquidityPool>, _arg2: vector<Object<Metadata>>, _arg3: vector<u64>) {

}
entry public fun initialize() {

}
public fun is_gauge_active(_arg0: Object<Gauge>): bool {
abort 0
}
public fun is_initialized(): bool {
abort 0
}
public fun last_voted_epoch(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun operator(): address {
abort 0
}
public fun pending_distribution_epoch(): u64 {
abort 0
}
entry public fun poke(_arg0: &signer, _arg1: Object<VeCellanaToken>) {

}
fun remove_ve_token_vote_records(_arg0: &mut VeTokenVoteAccounting, _arg1: Object<VeCellanaToken>) {

}
entry public fun reset(_arg0: &signer, _arg1: Object<VeCellanaToken>) {

}
public fun token_votes(_arg0: Object<VeCellanaToken>): (SimpleMap<Object<LiquidityPool>, u64> , u64) {
abort 0
}
fun unwrap_and_deposit<Ty0>(_arg0: address, _arg1: FungibleAsset) {
abort 0
}
entry public fun update_governance(_arg0: &signer, _arg1: address) {

}
entry public fun update_operator(_arg0: &signer, _arg1: address) {

}
entry public fun upgrade(_arg0: &signer, _arg1: vector<u8>, _arg2: vector<vector<u8>>) {

}
entry public fun vote(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: vector<Object<LiquidityPool>>, _arg3: vector<u64>) {

}
public fun vote_manager_address(): address {
abort 0
}
entry public fun whitelist_coin<Ty0>(_arg0: &signer) {

}
entry public fun whitelist_native_fungible_assets(_arg0: &signer, _arg1: vector<Object<Metadata>>) {

}
public entry fun vote_batch(arg0: &signer, arg1: vector<Object<VeCellanaToken>>, arg2: vector<Object<LiquidityPool>>, arg3: vector<u64>) {
        
}
}
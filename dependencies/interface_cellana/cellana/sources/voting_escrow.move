// Move bytecode v6
module cellana::voting_escrow {
// use 0000000000000000000000000000000000000000000000000000000000000001::error;
// use 0000000000000000000000000000000000000000000000000000000000000001::event;    
use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset};
// use 0000000000000000000000000000000000000000000000000000000000000001::math64;
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Object};
// use 0000000000000000000000000000000000000000000000000000000000000001::option;
// use 0000000000000000000000000000000000000000000000000000000000000001::primary_fungible_store;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::smart_table::{SmartTable};
use 0000000000000000000000000000000000000000000000000000000000000001::smart_vector::{SmartVector};
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
// use 0000000000000000000000000000000000000000000000000000000000000001::string_utils;
// use 0000000000000000000000000000000000000000000000000000000000000001::vector;
// use 0000000000000000000000000000000000000000000000000000000000000004::collection;
// use 0000000000000000000000000000000000000000000000000000000000000004::royalty;
// use 0000000000000000000000000000000000000000000000000000000000000004::token;
// use cellana::cellana_token;
// use cellana::epoch;
// use cellana::package_manager;

struct CreateLockEvent has drop, store {
	owner: address,
	amount: u64,
	lockup_end_epoch: u64,
	ve_token: Object<VeCellanaToken>
}
struct ExtendLockupEvent has drop, store {
	owner: address,
	old_lockup_end_epoch: u64,
	new_lockup_end_epoch: u64,
	ve_token: Object<VeCellanaToken>
}
struct IncreaseAmountEvent has drop, store {
	owner: address,
	old_amount: u64,
	new_amount: u64,
	ve_token: Object<VeCellanaToken>
}
struct TokenSnapshot has drop, store {
	epoch: u64,
	locked_amount: u64,
	end_epoch: u64
}
struct VeCellanaCollection has key {
	unscaled_total_voting_power_per_epoch: SmartTable<u64, u128>,
	rebases: SmartTable<u64, u64>
}
struct VeCellanaToken has key {
	locked_amount: u64,
	end_epoch: u64,
	snapshots: SmartVector<TokenSnapshot>,
	next_rebase_epoch: u64
}
struct VeCellanaTokenRefs has key {
	burn_ref: BurnRef,
	transfer_ref: TransferRef
}
struct WithdrawEvent has drop, store {
	owner: address,
	amount: u64,
	ve_token: Object<VeCellanaToken>
}

public(friend) fun add_rebase(_arg0: FungibleAsset, _arg1: u64) {
abort 0
}
entry public fun claim_rebase(_arg0: &signer, _arg1: Object<VeCellanaToken>) {
abort 0
}
public fun claimable_rebase(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
fun claimable_rebase_internal(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun create_lock(_arg0: &signer, _arg1: u64, _arg2: u64): Object<VeCellanaToken> {
abort 0
}
entry public fun create_lock_entry(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
entry public fun create_lock_for(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: address) {

}
public fun create_lock_with(_arg0: FungibleAsset, _arg1: u64, _arg2: address): Object<VeCellanaToken> {
abort 0
}
fun destroy_snapshots(_arg0: SmartVector<TokenSnapshot>) {
abort 0
}
entry public fun extend_lockup(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: u64) {
abort 0
}
public(friend) fun freeze_token(_arg0: Object<VeCellanaToken>) {
abort 0
}
public fun get_lockup_expiration_epoch(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun get_lockup_expiration_time(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun get_voting_power(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun get_voting_power_at_epoch(_arg0: Object<VeCellanaToken>, _arg1: u64): u64 {
abort 0
}
public fun increase_amount(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: FungibleAsset) {
abort 0
}
entry public fun increase_amount_entry(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: u64) {
abort 0
}
fun increase_amount_internal(_arg0: Object<VeCellanaToken>, _arg1: FungibleAsset) {
abort 0
}
entry public fun initialize() {

}
public fun is_initialized(): bool {
abort 0
}
public fun locked_amount(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun max_lockup_epochs(): u64 {
abort 0
}
entry public fun merge(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: Object<VeCellanaToken>) {
abort 0
}
public fun nft_exists(_arg0: address): bool {
abort 0
}
public fun remaining_lockup_epochs(_arg0: Object<VeCellanaToken>): u64 {
abort 0
}
public fun split(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: vector<u64>): vector<Object<VeCellanaToken>> {
abort 0
}
entry public fun split_entry(_arg0: &signer, _arg1: Object<VeCellanaToken>, _arg2: vector<u64>) {
abort 0
}
public fun total_voting_power(): u128 {
abort 0
}
public fun total_voting_power_at(_arg0: u64): u128 {
abort 0
}
public(friend) fun unfreeze_token(_arg0: Object<VeCellanaToken>) {
abort 0
}
fun update_manifested_total_supply(_arg0: u64, _arg1: u64, _arg2: u64, _arg3: u64) {

}
fun update_snapshots(_arg0: &mut VeCellanaToken, _arg1: u64, _arg2: u64) {

}
public fun voting_escrow_collection(): address {
abort 0
}
public fun withdraw(_arg0: &signer, _arg1: Object<VeCellanaToken>): FungibleAsset {
abort 0
}
entry public fun withdraw_entry(_arg0: &signer, _arg1: Object<VeCellanaToken>) {
abort 0
}
}
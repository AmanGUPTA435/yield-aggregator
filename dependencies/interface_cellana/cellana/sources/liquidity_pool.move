// Move bytecode v6
module cellana::liquidity_pool {
use 0000000000000000000000000000000000000000000000000000000000000001::bcs;
use 0000000000000000000000000000000000000000000000000000000000000001::comparator;
use 0000000000000000000000000000000000000000000000000000000000000001::error;
use 0000000000000000000000000000000000000000000000000000000000000001::event;
use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset,FungibleStore};
use 0000000000000000000000000000000000000000000000000000000000000001::math128;
use 0000000000000000000000000000000000000000000000000000000000000001::math64;
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Self,Object};
use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::primary_fungible_store;
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::smart_table::{Self,SmartTable};
use 0000000000000000000000000000000000000000000000000000000000000001::smart_vector::{Self,SmartVector};
use 0000000000000000000000000000000000000000000000000000000000000001::string::{Self,String};
use 0000000000000000000000000000000000000000000000000000000000000001::vector;
// use cellana::coin_wrapper;
// use cellana::package_manager;
// use cellana::token_whitelist;


struct AddLiquidityEvent has drop, store {
	lp: address,
	pool: address,
	amount_1: u64,
	amount_2: u64
}
struct ClaimFeesEvent has drop, store {
	pool: address,
	amount_1: u64,
	amount_2: u64
}
struct CreatePoolEvent has drop, store {
	pool: Object<LiquidityPool>,
	token_1: String,
	token_2: String,
	is_stable: bool
}
struct FeesAccounting has key {
	total_fees_1: u128,
	total_fees_2: u128,
	total_fees_at_last_claim_1: SmartTable<address, u128>,
	total_fees_at_last_claim_2: SmartTable<address, u128>,
	claimable_1: SmartTable<address, u128>,
	claimable_2: SmartTable<address, u128>
}
struct LPTokenRefs has store {
	burn_ref: BurnRef,
	mint_ref: MintRef,
	transfer_ref: TransferRef
}
struct LiquidityPool has key {
	token_store_1: Object<FungibleStore>,
	token_store_2: Object<FungibleStore>,
	fees_store_1: Object<FungibleStore>,
	fees_store_2: Object<FungibleStore>,
	lp_token_refs: LPTokenRefs,
	swap_fee_bps: u64,
	is_stable: bool
}
struct LiquidityPoolConfigs has key {
	all_pools: SmartVector<Object<LiquidityPool>>,
	is_paused: bool,
	fee_manager: address,
	pauser: address,
	pending_fee_manager: address,
	pending_pauser: address,
	stable_fee_bps: u64,
	volatile_fee_bps: u64
}
struct RemoveLiquidityEvent has drop, store {
	lp: address,
	pool: address,
	amount_lp: u64,
	amount_1: u64,
	amount_2: u64
}
struct SwapEvent has drop, store {
	pool: address,
	from_token: String,
	to_token: String,
	amount_in: u64,
	amount_out: u64
}
struct SyncEvent has drop, store {
	pool: address,
	reserves_1: u128,
	reserves_2: u128
}
struct TransferEvent has drop, store {
	pool: address,
	amount: u64,
	from: address,
	to: address
}

entry public fun accept_fee_manager(_arg0: &signer) {

}
entry public fun accept_pauser(_arg0: &signer) {

}
public(friend) fun burn(_arg0: &signer, _arg1: Object<Metadata>, _arg2: Object<Metadata>, _arg3: bool, _arg4: u64): (FungibleAsset , FungibleAsset) {
abort 0
}
fun calculate_constant_k(_arg0: &LiquidityPool): u256 {
abort 0
}
public(friend) fun claim_fees(_arg0: &signer, _arg1: Object<LiquidityPool>): (FungibleAsset , FungibleAsset) {
abort 0
}
public fun claimable_fees(_arg0: address, _arg1: Object<LiquidityPool>): (u128 , u128) {
abort 0
}
public(friend) fun create(_arg0: Object<Metadata>, _arg1: Object<Metadata>, _arg2: bool): Object<LiquidityPool> {
abort 0
}
fun create_token_store(_arg0: &signer, _arg1: Object<Metadata>): Object<FungibleStore> {
abort 0
}
fun ensure_lp_token_store<Ty0: key>(_arg0: address, _arg1: Object<Ty0>): Object<FungibleStore> {
abort 0
}
public fun get_amount_out(_arg0: Object<LiquidityPool>, _arg1: Object<Metadata>, _arg2: u64): (u64 , u64) {
abort 0
}
public fun get_trade_diff(_arg0: Object<LiquidityPool>, _arg1: Object<Metadata>, _arg2: u64): (u64 , u64) {
abort 0
}
fun get_y(_arg0: u256, _arg1: u256, _arg2: u256): u256 {
abort 0
}
entry public fun initialize() {

}
public fun is_initialized(): bool {
abort 0
}
public fun is_sorted(_arg0: Object<Metadata>, _arg1: Object<Metadata>): bool {
abort 0
}
public fun is_stable(_arg0: Object<LiquidityPool>): bool {
abort 0
}
public fun liquidity_amounts(_arg0: Object<LiquidityPool>, _arg1: u64): (u64 , u64) {
abort 0
}
public fun liquidity_out(_arg0: 0x1::object::Object<0x1::fungible_asset::Metadata>, _arg1: 0x1::object::Object<0x1::fungible_asset::Metadata>, _arg2: bool, _arg3: u64, _arg4: u64) : u64 {
       abort 0
    }
public fun liquidity_pool(_arg0: Object<Metadata>, _arg1: Object<Metadata>, _arg2: bool): Object<LiquidityPool> {
abort 0
}
public fun liquidity_pool_address(_arg0: Object<Metadata>, _arg1: Object<Metadata>, _arg2: bool): address {
abort 0
}
fun lp_token_name(_arg0: Object<Metadata>, _arg1: Object<Metadata>): String {
abort 0
}
public fun lp_token_supply<Ty0: key>(_arg0: Object<Ty0>): u128 {
abort 0
}
public fun min_liquidity(): u64 {
abort 0
}
public fun mint(_arg0: &signer, _arg1: FungibleAsset, _arg2: FungibleAsset, _arg3: bool) {
abort 0
}
public fun pool_metadata(_arg0: Object<LiquidityPool>): (Object<Metadata> , Object<Metadata> , u64 , u64 , u8 , u8) {
abort 0
}
public fun pool_reserves<Ty0: key>(_arg0: Object<Ty0>): (u64 , u64) {
abort 0
}
entry public fun set_fee_manager(_arg0: &signer, _arg1: address) {

}
entry public fun set_pause(_arg0: &signer, _arg1: bool) {

}
entry public fun set_pauser(_arg0: &signer, _arg1: address) {

}
entry public fun set_pool_swap_fee(_arg0: &signer, _arg1: Object<LiquidityPool>, _arg2: u64) {
abort 0
}
entry public fun set_stable_fee(_arg0: &signer, _arg1: u64) {

}
entry public fun set_volatile_fee(_arg0: &signer, _arg1: u64) {

}
public fun supported_inner_assets(_arg0: Object<LiquidityPool>): vector<Object<Metadata>> {
abort 0
}
public fun supported_native_fungible_assets(_arg0: Object<LiquidityPool>): vector<Object<Metadata>> {
abort 0
}
public fun supported_token_strings(_arg0: Object<LiquidityPool>): vector<String> {
abort 0
}
public(friend) fun swap(_arg0: Object<LiquidityPool>, _arg1: FungibleAsset): FungibleAsset {
abort 0
}
public fun swap_fee_bps(_arg0: Object<LiquidityPool>): u64 {
abort 0
}
entry public fun transfer(_arg0: &signer, _arg1: Object<LiquidityPool>, _arg2: address, _arg3: u64) {
abort 0
}
entry public fun update_claimable_fees(_arg0: address, _arg1: Object<LiquidityPool>) {
abort 0
}
}
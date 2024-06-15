// Move bytecode v6
module pancake::swap {
use 0000000000000000000000000000000000000000000000000000000000000001::account::{SignerCapability};
// use 0000000000000000000000000000000000000000000000000000000000000001::code;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin,MintCapability,BurnCapability,FreezeCapability};
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
// use 0000000000000000000000000000000000000000000000000000000000000001::option;
// use 0000000000000000000000000000000000000000000000000000000000000001::resource_account;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
// use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use c7efb4076dbe143cbcd98cfaaa929ecfc8f299203dfff63b95ccb6bfe19850fa::math;
// use c7efb4076dbe143cbcd98cfaaa929ecfc8f299203dfff63b95ccb6bfe19850fa::swap_utils;


struct AddLiquidityEvent<phantom Ty0, phantom Ty1> has drop, store {
	user: address,
	amount_x: u64,
	amount_y: u64,
	liquidity: u64,
	fee_amount: u64
}
struct LPToken<phantom Ty0, phantom Ty1> has key {
	dummy_field: bool
}
struct PairCreatedEvent has drop, store {
	user: address,
	token_x: String,
	token_y: String
}
struct PairEventHolder<phantom Ty0, phantom Ty1> has key {
	add_liquidity: EventHandle<AddLiquidityEvent<Ty0, Ty1>>,
	remove_liquidity: EventHandle<RemoveLiquidityEvent<Ty0, Ty1>>,
	swap: EventHandle<SwapEvent<Ty0, Ty1>>
}
struct RemoveLiquidityEvent<phantom Ty0, phantom Ty1> has drop, store {
	user: address,
	liquidity: u64,
	amount_x: u64,
	amount_y: u64,
	fee_amount: u64
}
struct SwapEvent<phantom Ty0, phantom Ty1> has drop, store {
	user: address,
	amount_x_in: u64,
	amount_y_in: u64,
	amount_x_out: u64,
	amount_y_out: u64
}
struct SwapInfo has key {
	signer_cap: SignerCapability,
	fee_to: address,
	admin: address,
	pair_created: EventHandle<PairCreatedEvent>
}
struct TokenPairMetadata<phantom Ty0, phantom Ty1> has key {
	creator: address,
	fee_amount: Coin<LPToken<Ty0, Ty1>>,
	k_last: u128,
	balance_x: Coin<Ty0>,
	balance_y: Coin<Ty1>,
	mint_cap: MintCapability<LPToken<Ty0, Ty1>>,
	burn_cap: BurnCapability<LPToken<Ty0, Ty1>>,
	freeze_cap: FreezeCapability<LPToken<Ty0, Ty1>>
}
struct TokenPairReserve<phantom Ty0, phantom Ty1> has key {
	reserve_x: u64,
	reserve_y: u64,
	block_timestamp_last: u64
}

public(friend) fun add_liquidity<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64): (u64 , u64 , u64) {
abort 0
}
fun add_liquidity_direct<Ty0, Ty1>(_arg0: Coin<Ty0>, _arg1: Coin<Ty1>): (u64 , u64 , Coin<LPToken<Ty0, Ty1>> , u64 , Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public(friend) fun add_swap_event<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64) {

}
public(friend) fun add_swap_event_with_address<Ty0, Ty1>(_arg0: address, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64) {

}
public fun admin(): address {
abort 0
}
fun burn<Ty0, Ty1>(_arg0: Coin<LPToken<Ty0, Ty1>>): (Coin<Ty0> , Coin<Ty1> , u64) {
abort 0
}
public fun check_or_register_coin_store<Ty0>(_arg0: &signer) {

}
public(friend) fun create_pair<Ty0, Ty1>(_arg0: &signer) {

}
fun deposit_x<Ty0, Ty1>(_arg0: Coin<Ty0>) {
abort 0
}
fun deposit_y<Ty0, Ty1>(_arg0: Coin<Ty1>) {
abort 0
}
fun extract_x<Ty0, Ty1>(_arg0: u64, _arg1: &mut TokenPairMetadata<Ty0, Ty1>): Coin<Ty0> {
abort 0
}
fun extract_y<Ty0, Ty1>(_arg0: u64, _arg1: &mut TokenPairMetadata<Ty0, Ty1>): Coin<Ty1> {
abort 0
}
public fun fee_to(): address {
abort 0
}
fun init_module(_arg0: &signer) {

}
public fun is_pair_created<Ty0, Ty1>(): bool {
abort 0
}
public fun lp_balance<Ty0, Ty1>(_arg0: address): u64 {
abort 0
}
fun mint<Ty0, Ty1>(): (Coin<LPToken<Ty0, Ty1>> , u64) {
abort 0
}
fun mint_fee<Ty0, Ty1>(_arg0: u64, _arg1: u64, _arg2: &mut TokenPairMetadata<Ty0, Ty1>): u64 {
abort 0
}
fun mint_lp<Ty0, Ty1>(_arg0: u64, _arg1: &MintCapability<LPToken<Ty0, Ty1>>): Coin<LPToken<Ty0, Ty1>> {
abort 0
}
fun mint_lp_to<Ty0, Ty1>(_arg0: address, _arg1: u64, _arg2: &MintCapability<LPToken<Ty0, Ty1>>) {
abort 0
}
public fun register_lp<Ty0, Ty1>(_arg0: &signer) {

}
public(friend) fun remove_liquidity<Ty0, Ty1>(_arg0: &signer, _arg1: u64): (u64 , u64) {
abort 0
}
fun remove_liquidity_direct<Ty0, Ty1>(_arg0: Coin<LPToken<Ty0, Ty1>>): (Coin<Ty0> , Coin<Ty1> , u64) {
abort 0
}
entry public fun set_admin(_arg0: &signer, _arg1: address) {

}
entry public fun set_fee_to(_arg0: &signer, _arg1: address) {

}
fun swap<Ty0, Ty1>(_arg0: u64, _arg1: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public(friend) fun swap_exact_x_to_y<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: address): u64 {
abort 0
}
public(friend) fun swap_exact_x_to_y_direct<Ty0, Ty1>(_arg0: Coin<Ty0>): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public(friend) fun swap_exact_y_to_x<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: address): u64 {
abort 0
}
public(friend) fun swap_exact_y_to_x_direct<Ty0, Ty1>(_arg0: Coin<Ty1>): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public(friend) fun swap_x_to_exact_y<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: address): u64 {
abort 0
}
public(friend) fun swap_x_to_exact_y_direct<Ty0, Ty1>(_arg0: Coin<Ty0>, _arg1: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public(friend) fun swap_y_to_exact_x<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: address): u64 {
abort 0
}
public(friend) fun swap_y_to_exact_x_direct<Ty0, Ty1>(_arg0: Coin<Ty1>, _arg1: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public fun token_balances<Ty0, Ty1>(): (u64 , u64) {
abort 0
}
public fun token_reserves<Ty0, Ty1>(): (u64 , u64 , u64) {
abort 0
}
public fun total_lp_supply<Ty0, Ty1>(): u128 {
abort 0
}
fun update<Ty0, Ty1>(_arg0: u64, _arg1: u64, _arg2: &mut TokenPairReserve<Ty0, Ty1>) {
abort 0
}
entry public fun upgrade_swap(_arg0: &signer, _arg1: vector<u8>, _arg2: vector<vector<u8>>) {

}
entry public fun withdraw_fee<Ty0, Ty1>(_arg0: &signer) {

}
entry public fun withdraw_fee_noauth<Ty0, Ty1>() {

}
}
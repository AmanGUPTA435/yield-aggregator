// Move bytecode v6
module liquidswap_v05::liquidity_pool {
use 0000000000000000000000000000000000000000000000000000000000000001::account::{SignerCapability};
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin,MintCapability,BurnCapability};
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
// use 0000000000000000000000000000000000000000000000000000000000000001::string::{Self,String};
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
// use liquidswap_v05::coin_helper;
// use liquidswap_v05::curves;
// use liquidswap_v05::dao_storage;
// use liquidswap_v05::emergency;
// use liquidswap_v05::global_config;
// use liquidswap_v05::lp_account;
// use liquidswap_v05::math;
// use liquidswap_v05::stable_curve;
// use 4e9fce03284c0ce0b86c88dd5a46f050cad2f4f33c4cdd29d98f501868558c81::uq64x64;
use liquidswap_lp::lp_coin::{LP};


struct EventsStore<phantom Ty0, phantom Ty1, phantom Ty2> has key {
	pool_created_handle: EventHandle<PoolCreatedEvent<Ty0, Ty1, Ty2>>,
	liquidity_added_handle: EventHandle<LiquidityAddedEvent<Ty0, Ty1, Ty2>>,
	liquidity_removed_handle: EventHandle<LiquidityRemovedEvent<Ty0, Ty1, Ty2>>,
	swap_handle: EventHandle<SwapEvent<Ty0, Ty1, Ty2>>,
	flashloan_handle: EventHandle<FlashloanEvent<Ty0, Ty1, Ty2>>,
	oracle_updated_handle: EventHandle<OracleUpdatedEvent<Ty0, Ty1, Ty2>>,
	update_fee_handle: EventHandle<UpdateFeeEvent<Ty0, Ty1, Ty2>>,
	update_dao_fee_handle: EventHandle<UpdateDAOFeeEvent<Ty0, Ty1, Ty2>>
}
struct Flashloan<phantom Ty0, phantom Ty1, phantom Ty2> {
	x_loan: u64,
	y_loan: u64
}
struct FlashloanEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	x_in: u64,
	x_out: u64,
	y_in: u64,
	y_out: u64
}
struct LiquidityAddedEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	added_x_val: u64,
	added_y_val: u64,
	lp_tokens_received: u64
}
struct LiquidityPool<phantom Ty0, phantom Ty1, phantom Ty2> has key {
	coin_x_reserve: Coin<Ty0>,
	coin_y_reserve: Coin<Ty1>,
	last_block_timestamp: u64,
	last_price_x_cumulative: u128,
	last_price_y_cumulative: u128,
	lp_mint_cap: MintCapability<LP<Ty0, Ty1, Ty2>>,
	lp_burn_cap: BurnCapability<LP<Ty0, Ty1, Ty2>>,
	lp_coins_reserved: Coin<LP<Ty0, Ty1, Ty2>>,
	x_scale: u64,
	y_scale: u64,
	locked: bool,
	fee: u64,
	dao_fee: u64
}
struct LiquidityRemovedEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	returned_x_val: u64,
	returned_y_val: u64,
	lp_tokens_burned: u64
}
struct OracleUpdatedEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	last_price_x_cumulative: u128,
	last_price_y_cumulative: u128
}
struct PoolAccountCapability has key {
	signer_cap: SignerCapability
}
struct PoolCreatedEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	creator: address
}
struct SwapEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	x_in: u64,
	x_out: u64,
	y_in: u64,
	y_out: u64
}
struct UpdateDAOFeeEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	new_fee: u64
}
struct UpdateFeeEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	new_fee: u64
}

fun assert_lp_value_is_increased<Ty0>(_arg0: u64, _arg1: u64, _arg2: u128, _arg3: u128, _arg4: u128, _arg5: u128) {

}
fun assert_pool_unlocked<Ty0, Ty1, Ty2>() {

}
public fun burn<Ty0, Ty1, Ty2>(_arg0: Coin<LP<Ty0, Ty1, Ty2>>): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public fun flashloan<Ty0, Ty1, Ty2>(_arg0: u64, _arg1: u64): (Coin<Ty0> , Coin<Ty1> , Flashloan<Ty0, Ty1, Ty2>) {
abort 0
}
public fun get_cumulative_prices<Ty0, Ty1, Ty2>(): (u128 , u128 , u64) {
abort 0
}
public fun get_dao_fee<Ty0, Ty1, Ty2>(): u64 {
abort 0
}
public fun get_dao_fees_config<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
public fun get_decimals_scales<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
public fun get_fee<Ty0, Ty1, Ty2>(): u64 {
abort 0
}
public fun get_fees_config<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
public fun get_reserves_size<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
entry public fun initialize(_arg0: &signer) {

}
public fun is_pool_exists<Ty0, Ty1, Ty2>(): bool {
abort 0
}
public fun is_pool_locked<Ty0, Ty1, Ty2>(): bool {
abort 0
}
public fun mint<Ty0, Ty1, Ty2>(_arg0: Coin<Ty0>, _arg1: Coin<Ty1>): Coin<LP<Ty0, Ty1, Ty2>> {
abort 0
}
fun new_reserves_after_fees_scaled<Ty0>(_arg0: u64, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64): (u128 , u128) {
abort 0
}
public fun pay_flashloan<Ty0, Ty1, Ty2>(_arg0: Coin<Ty0>, _arg1: Coin<Ty1>, _arg2: Flashloan<Ty0, Ty1, Ty2>) {
abort 0
}
public fun register<Ty0, Ty1, Ty2>(_arg0: &signer) {

}
entry public fun set_dao_fee<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: u64) {

}
entry public fun set_fee<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: u64) {

}
fun split_fee_to_dao<Ty0, Ty1, Ty2>(_arg0: &mut LiquidityPool<Ty0, Ty1, Ty2>, _arg1: u64, _arg2: u64) {
abort 0
}
public fun swap<Ty0, Ty1, Ty2>(_arg0: Coin<Ty0>, _arg1: u64, _arg2: Coin<Ty1>, _arg3: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
fun update_oracle<Ty0, Ty1, Ty2>(_arg0: &mut LiquidityPool<Ty0, Ty1, Ty2>, _arg1: u64, _arg2: u64) {
abort 0
}
}
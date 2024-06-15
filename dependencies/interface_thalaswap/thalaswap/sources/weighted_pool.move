// Move bytecode v6
module thalaswap::weighted_pool {
use 0000000000000000000000000000000000000000000000000000000000000001::account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin,BurnCapability,MintCapability};
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
use 0000000000000000000000000000000000000000000000000000000000000001::table::{Table};
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{TypeInfo};
use 0000000000000000000000000000000000000000000000000000000000000001::vector;
use thalaswap::base_pool;
// use thalaswap::fees;
// use thalaswap::package;
use fixed_point64::fixed_point64::{FixedPoint64};
// use 93aa044a65a27bd89b163f8b3be3777b160b09a25c336643dcc2878dfd8f2a8d::manager;
// use fb6e709add23c710c40e4844d889938f703719f72d2d4439ee682d67f07a15c5::weighted_math;


struct AddLiquidityEvent<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has drop, store {
	amount_0: u64,
	amount_1: u64,
	amount_2: u64,
	amount_3: u64,
	minted_lp_coin_amount: u64
}
struct Flashloan<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> {
	amount_0: u64,
	amount_1: u64,
	amount_2: u64,
	amount_3: u64
}
struct FlashloanEvent<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has drop, store {
	amount_0: u64,
	amount_1: u64,
	amount_2: u64,
	amount_3: u64
}
struct FlashloanHelper<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has key {
	locked: bool,
	flashloan_fee_bps: u64,
	flashloan_events: EventHandle<FlashloanEvent<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>
}
struct RemoveLiquidityEvent<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has drop, store {
	amount_0: u64,
	amount_1: u64,
	amount_2: u64,
	amount_3: u64,
	burned_lp_coin_amount: u64
}
struct SwapEvent<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has drop, store {
	idx_in: u64,
	idx_out: u64,
	amount_in: u64,
	amount_out: u64,
	fee_amount: u64,
	pool_balance_0: u64,
	pool_balance_1: u64,
	pool_balance_2: u64,
	pool_balance_3: u64
}
struct Weight_10 {
	dummy_field: bool
}
struct Weight_15 {
	dummy_field: bool
}
struct Weight_20 {
	dummy_field: bool
}
struct Weight_25 {
	dummy_field: bool
}
struct Weight_30 {
	dummy_field: bool
}
struct Weight_35 {
	dummy_field: bool
}
struct Weight_40 {
	dummy_field: bool
}
struct Weight_45 {
	dummy_field: bool
}
struct Weight_5 {
	dummy_field: bool
}
struct Weight_50 {
	dummy_field: bool
}
struct Weight_55 {
	dummy_field: bool
}
struct Weight_60 {
	dummy_field: bool
}
struct Weight_65 {
	dummy_field: bool
}
struct Weight_70 {
	dummy_field: bool
}
struct Weight_75 {
	dummy_field: bool
}
struct Weight_80 {
	dummy_field: bool
}
struct Weight_85 {
	dummy_field: bool
}
struct Weight_90 {
	dummy_field: bool
}
struct Weight_95 {
	dummy_field: bool
}
struct WeightedPool<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has key {
	asset_0: Coin<Ty0>,
	asset_1: Coin<Ty1>,
	asset_2: Coin<Ty2>,
	asset_3: Coin<Ty3>,
	weight_0: u64,
	weight_1: u64,
	weight_2: u64,
	weight_3: u64,
	swap_fee_ratio: FixedPoint64,
	inverse_negated_swap_fee_ratio: FixedPoint64,
	pool_token_mint_cap: MintCapability<WeightedPoolToken<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>,
	pool_token_burn_cap: BurnCapability<WeightedPoolToken<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>,
	reserved_lp_coin: Coin<WeightedPoolToken<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>,
	events: WeightedPoolEvents<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>
}
struct WeightedPoolCreationEvent<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has drop, store {
	creator: address,
	amount_0: u64,
	amount_1: u64,
	amount_2: u64,
	amount_3: u64,
	minted_lp_coin_amount: u64,
	swap_fee_bps: u64
}
struct WeightedPoolEvents<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> has store {
	pool_creation_events: EventHandle<WeightedPoolCreationEvent<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>,
	add_liquidity_events: EventHandle<AddLiquidityEvent<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>,
	remove_liquidity_events: EventHandle<RemoveLiquidityEvent<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>,
	swap_events: EventHandle<SwapEvent<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>,
	param_change_events: EventHandle<WeightedPoolParamChangeEvent>
}
struct WeightedPoolInfo has copy, drop, store {
	balances: vector<u64>,
	weights: vector<u64>,
	lp_coin_supply: u64
}
struct WeightedPoolLookup has key {
	name_to_pool: Table<String, WeightedPoolInfo>,
	id_to_name: Table<u64, String>,
	next_id: u64
}
struct WeightedPoolParamChangeEvent has drop, store {
	name: String,
	prev_value: u64,
	new_value: u64
}
struct WeightedPoolParams has key {
	default_swap_fee_ratio: FixedPoint64,
	param_change_events: EventHandle<WeightedPoolParamChangeEvent>
}
struct WeightedPoolToken<phantom Ty0, phantom Ty1, phantom Ty2, phantom Ty3, phantom Ty4, phantom Ty5, phantom Ty6, phantom Ty7> {
	dummy_field: bool
}

public fun add_liquidity<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(_arg0: Coin<Ty0>, _arg1: Coin<Ty1>, _arg2: Coin<Ty2>, _arg3: Coin<Ty3>): (Coin<WeightedPoolToken<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>> , Coin<Ty0> , Coin<Ty1> , Coin<Ty2> , Coin<Ty3>) {
abort 0
}
public fun create_weighted_pool<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(_arg0: &signer, _arg1: Coin<Ty0>, _arg2: Coin<Ty1>, _arg3: Coin<Ty2>, _arg4: Coin<Ty3>): Coin<WeightedPoolToken<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>> {
abort 0
}
fun deposit_to_pool<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7, Ty8>(_arg0: address, _arg1: u64, _arg2: Coin<Ty8>) {
abort 0
}
fun extract_from_pool<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7, Ty8>(_arg0: address, _arg1: u64, _arg2: u64): Coin<Ty8> {
abort 0
}
public fun flashloan<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(_arg0: u64, _arg1: u64, _arg2: u64, _arg3: u64): (Coin<Ty0> , Coin<Ty1> , Coin<Ty2> , Coin<Ty3> , Flashloan<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>) {
abort 0
}
public fun flashloan_fee_bps<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(): u64 {
abort 0
}
fun flashloan_helper_initialized<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(): bool {
abort 0
}
public fun get_weight<Ty0>(): u64 {
abort 0
}
public(friend) fun initialize() {

}
public fun initialized(): bool {
abort 0
}
public fun inverse_negated_swap_fee_ratio<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(): FixedPoint64 {
abort 0
}
public fun lp_name_by_id(_arg0: u64): String {
abort 0
}
public fun pay_flashloan<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(_arg0: Coin<Ty0>, _arg1: Coin<Ty1>, _arg2: Coin<Ty2>, _arg3: Coin<Ty3>, _arg4: Flashloan<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>) {
abort 0
}

public fun pool_balances_and_weights<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(): (vector<u64> , vector<u64>) {
abort 0
}
public fun pool_info(_arg0: String): (vector<u64> , vector<u64> , u64) {
abort 0
}

public fun remove_liquidity<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(_arg0: Coin<WeightedPoolToken<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>>): (Coin<Ty0> , Coin<Ty1> , Coin<Ty2> , Coin<Ty3>) {
abort 0
}
entry public fun set_default_pool_swap_fee_bps(_arg0: &signer, _arg1: u64) {

}
entry public fun set_flashloan_fee_bps<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(_arg0: &signer, _arg1: u64) {

}
entry public fun set_pool_swap_fee_bps<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(_arg0: &signer, _arg1: u64) {

}
public fun swap_exact_in<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7, Ty8, Ty9>(_arg0: Coin<Ty8>): Coin<Ty9> {
abort 0
}
public fun swap_exact_out<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7, Ty8, Ty9>(_arg0: Coin<Ty8>, _arg1: u64): (Coin<Ty8> , Coin<Ty9>) {
abort 0
}
public fun swap_fee_ratio<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(): FixedPoint64 {
abort 0
}
public fun weighted_pool_exists<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6, Ty7>(): bool {
abort 0
}
}
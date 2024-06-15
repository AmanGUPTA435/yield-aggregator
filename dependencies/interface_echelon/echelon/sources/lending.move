// Move bytecode v6
module lending::lending {
    // use std::signer;
    use std::string::String;
    // use std::vector;

    // use aptos_std::math64;
    use aptos_std::simple_map::{Self, SimpleMap};
    // use aptos_std::type_info;
    // use aptos_framework::aptos_account;
    use aptos_framework::coin::{Self, Coin};
    // use aptos_framework::event;
    use aptos_framework::fungible_asset::{Self, Metadata, FungibleAsset};
    use aptos_framework::object::{Self, ExtendRef, Object};
    // use aptos_framework::primary_fungible_store;
    // use aptos_framework::timestamp;

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    // use lending_manager::manager;
    // use thala_oracle_interface::oracle;

    // use lending::package;
    // use lending::farming;


struct AccrueMarketInterestEvent has drop, store {
	market_obj: Object<Market>,
	borrow_interest_rate: FixedPoint64,
	second_delta: u64,
	simple_interest_factor: FixedPoint64,
	interest_accumulated: u64,
	interest_fee: u64,
	interest_rate_index: FixedPoint64,
	total_liability: u64,
	total_reserve: u64
}
struct AccrueVaultInterestEvent has drop, store {
	account_addr: address,
	market_obj: Object<Market>,
	prev_user_liability: u64,
	user_liability: u64,
	interest_rate_index: FixedPoint64,
	interest_accumulated: u64
}
struct BorrowEvent has drop, store {
	account_addr: address,
	market_obj: Object<Market>,
	amount: u64,
	user_liability: u64,
	total_cash: u64,
	total_liability: u64
}
struct CoinInfo has key {
	type_name: String
}
struct CreateMarketEvent has drop, store {
	asset_name: String,
	market_obj: Object<Market>
}
struct EfficiencyMode has drop, store {
	id: u8,
	markets: vector<Object<Market>>,
	collateral_factor_bps: u64,
	liquidation_incentive_bps: u64
}
struct FungibleAssetInfo has key {
	metadata: Object<Metadata>
}
struct JumpInterestRateModel has key {
	base_rate_bps: u64,
	multiplier_bps: u64,
	jump_multiplier_bps: u64,
	utilization_kink_bps: u64
}
struct Lending has key {
	liquidation_incentive_bps: u64,
	close_factor_bps: u64,
	interest_fee_bps: u64,
	liquidation_fee_bps: u64,
	next_efficiency_mode_id: u8,
	efficiency_modes: SimpleMap<u8, EfficiencyMode>,
	market_objects: vector<Object<Market>>
}
struct Liability has store {
	principal: u64,
	interest_accumulated: u64,
	last_interest_rate_index: FixedPoint64
}
struct LiquidateEvent has drop, store {
	liquidator_addr: address,
	borrower_addr: address,
	collateral_market_obj: Object<Market>,
	borrow_market_obj: Object<Market>,
	repay_amount: u64,
	seize_shares: u64,
	seize_shares_post_fee: u64,
	borrower_shares: u64,
	liquidator_shares: u64,
	liquidation_fee_coins: u64,
	total_reserve: u64
}
struct Market has key {
	extend_ref: ExtendRef,
	asset_name: String,
	asset_type: u64,
	asset_mantissa: u64,
	initial_liquidity: u64,
	total_shares: u64,
	total_liability: u64,
	total_reserve: u64,
	total_cash: u64,
	interest_rate_model_type: u64,
	interest_rate_index: FixedPoint64,
	interest_rate_last_update_seconds: u64,
	collateral_factor_bps: u64,
	efficiency_mode_id: u8,
	paused: bool,
	supply_cap: u64,
	borrow_cap: u64
}
struct RepayEvent has drop, store {
	borrower_addr: address,
	repayer_addr: address,
	market_obj: Object<Market>,
	amount: u64,
	user_liability: u64,
	total_cash: u64,
	total_liability: u64
}
struct SupplyEvent has drop, store {
	account_addr: address,
	market_obj: Object<Market>,
	amount: u64,
	shares: u64,
	user_shares_increment: u64,
	user_shares: u64,
	total_cash: u64,
	total_shares: u64
}
struct Vault has key {
	efficiency_mode_id: u8,
	collaterals: SimpleMap<Object<Market>, u64>,
	liabilities: SimpleMap<Object<Market>, Liability>
}
struct WithdrawEvent has drop, store {
	account_addr: address,
	market_obj: Object<Market>,
	amount: u64,
	shares: u64,
	user_shares: u64,
	total_cash: u64,
	total_shares: u64
}

public fun account_borrowable_coins(_arg0: address, _arg1: Object<Market>): u64 {
abort 0
}
public fun account_coins(_arg0: address, _arg1: Object<Market>): u64 {
abort 0
}
public fun account_liability(_arg0: address, _arg1: Object<Market>): u64 {
abort 0
}
public fun account_liquidity(_arg0: address): (FixedPoint64 , FixedPoint64) {
abort 0
}
public fun account_shares(_arg0: address, _arg1: Object<Market>): u64 {
abort 0
}
public fun account_withdrawable_coins(_arg0: address, _arg1: Object<Market>): u64 {
abort 0
}
fun accrue_market_interest(_arg0: Object<Market>) {
abort 0
}
fun accrue_vault_interest(_arg0: address, _arg1: Object<Market>) {
abort 0
}
fun accrue_vault_interest_for_all_markets(_arg0: address) {

}
fun assert_market_exists(_arg0: Object<Market>) {

}
public fun asset_price(_arg0: Object<Market>): FixedPoint64 {
abort 0
}
public fun borrow<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: u64): Coin<Ty0> {
abort 0
}
public fun borrow_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: u64): FungibleAsset {
abort 0
}
public fun borrow_interest_rate(_arg0: Object<Market>): FixedPoint64 {
abort 0
}
fun borrow_internal(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
public fun coins_to_shares(_arg0: Object<Market>, _arg1: u64): u64 {
abort 0
}
entry public fun create_efficiency_mode(_arg0: &signer, _arg1: vector<Object<Market>>, _arg2: u64, _arg3: u64) {

}
fun create_market_internal(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: String, _arg5: u64, _arg6: u8): (signer , Object<Market>) {
abort 0
}
public fun create_market_with_jump_model<Ty0>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64, _arg5: u64, _arg6: u64): Object<Market> {
abort 0
}
public fun create_market_with_jump_model_fa(_arg0: &signer, _arg1: Object<Metadata>, _arg2: u64, _arg3: u64, _arg4: u64, _arg5: u64, _arg6: u64, _arg7: u64): Object<Market> {
abort 0
}
fun create_market_with_jump_model_internal(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: String, _arg4: u64, _arg5: u8, _arg6: u64, _arg7: u64, _arg8: u64, _arg9: u64): (signer , Object<Market>) {
abort 0
}
fun dedup_markets(_arg0: vector<Object<Market>>): vector<Object<Market>> {
abort 0
}
fun dummy_e_mode(): (vector<Object<Market>> , u64) {
abort 0
}
public fun efficiency_mode_info(_arg0: u8): (vector<Object<Market>> , u64 , u64) {
abort 0
}
public fun exchange_rate(_arg0: Object<Market>): (u64 , u64) {
abort 0
}
fun init_module(_arg0: &signer) {

}
fun init_vault_if_not_exists(_arg0: &signer) {

}
fun is_shortfall(_arg0: address): bool {
abort 0
}
public fun lending_close_factor_bps(): u64 {
abort 0
}
public fun lending_interest_fee_bps(): u64 {
abort 0
}
public fun lending_liquidation_fee_bps(): u64 {
abort 0
}
public fun lending_liquidation_incentive_bps(): u64 {
abort 0
}
public fun liquidate<Ty0>(_arg0: &signer, _arg1: address, _arg2: Object<Market>, _arg3: Object<Market>, _arg4: Coin<Ty0>, _arg5: u64) {
abort 0
}
public fun liquidate_fa(_arg0: &signer, _arg1: address, _arg2: Object<Market>, _arg3: Object<Market>, _arg4: FungibleAsset, _arg5: u64) {
abort 0
}
fun liquidate_internal(_arg0: &signer, _arg1: address, _arg2: Object<Market>, _arg3: Object<Market>, _arg4: u64, _arg5: u64) {

}
public fun market_asset_metadata(_arg0: Object<Market>): Object<Metadata> {
abort 0
}
public fun market_borrow_cap(_arg0: Object<Market>): u64 {
abort 0
}
public fun market_coin(_arg0: Object<Market>): String {
abort 0
}
public fun market_collateral_factor_bps(_arg0: Object<Market>): u64 {
abort 0
}
public fun market_efficiency_mode_id(_arg0: Object<Market>): u8 {
abort 0
}
entry public fun market_enter_efficiency_mode(_arg0: &signer, _arg1: Object<Market>, _arg2: u8) {

}
public fun market_interest_rate_model_type(_arg0: Object<Market>): u64 {
abort 0
}
public fun market_objects(): vector<Object<Market>> {
abort 0
}
public fun market_paused(_arg0: Object<Market>): bool {
abort 0
}
public fun market_statistics(_arg0: Object<Market>): (u64 , u64 , u64 , u64) {
abort 0
}
public fun market_supply_cap(_arg0: Object<Market>): u64 {
abort 0
}
public fun market_total_cash(_arg0: Object<Market>): u64 {
abort 0
}
public fun market_total_liability(_arg0: Object<Market>): u64 {
abort 0
}
public fun market_total_reserve(_arg0: Object<Market>): u64 {
abort 0
}
public fun market_total_shares(_arg0: Object<Market>): u64 {
abort 0
}
fun new_liability(_arg0: &Market): Liability {
abort 0
}
fun preview_account_liquidity_given_borrow(_arg0: address, _arg1: Object<Market>, _arg2: u64): (FixedPoint64 , FixedPoint64) {
abort 0
}
fun preview_account_liquidity_given_repay(_arg0: address, _arg1: Object<Market>, _arg2: u64): (FixedPoint64 , FixedPoint64) {
abort 0
}
fun preview_account_liquidity_given_supply(_arg0: address, _arg1: Object<Market>, _arg2: u64): (FixedPoint64 , FixedPoint64) {
abort 0
}
fun preview_account_liquidity_given_withdraw(_arg0: address, _arg1: Object<Market>, _arg2: u64): (FixedPoint64 , FixedPoint64) {
abort 0
}
fun remove_old_interest_rate_model(_arg0: address, _arg1: u64) {

}
public fun repay<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: Coin<Ty0>) {
abort 0
}
public fun repay_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: FungibleAsset) {
abort 0
}
fun repay_internal(_arg0: address, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun set_close_factor_bps(_arg0: &signer, _arg1: u64) {

}
entry public fun set_efficiency_mode_collateral_factor_bps(_arg0: &signer, _arg1: u8, _arg2: u64) {

}
entry public fun set_efficiency_mode_liquidation_incentive_bps(_arg0: &signer, _arg1: u8, _arg2: u64) {

}
entry public fun set_interest_fee_bps(_arg0: &signer, _arg1: u64) {

}
entry public fun set_liquidation_fee_bps(_arg0: &signer, _arg1: u64) {

}
entry public fun set_liquidation_incentive_bps(_arg0: &signer, _arg1: u64) {

}
entry public fun set_market_borrow_cap(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun set_market_collateral_factor_bps(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun set_market_jump_interest_rate_model(_arg0: &signer, _arg1: Object<Market>, _arg2: u64, _arg3: u64, _arg4: u64, _arg5: u64) {

}
entry public fun set_market_paused(_arg0: &signer, _arg1: Object<Market>, _arg2: bool) {

}
entry public fun set_market_supply_cap(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
fun share_value(_arg0: Object<Market>): u64 {
abort 0
}
public fun shares_to_coins(_arg0: Object<Market>, _arg1: u64): u64 {
abort 0
}
public fun supply<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: Coin<Ty0>) {
abort 0
}
public fun supply_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: FungibleAsset) {
abort 0
}
public fun supply_interest_rate(_arg0: Object<Market>): FixedPoint64 {
abort 0
}
fun supply_internal(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun user_enter_efficiency_mode(_arg0: &signer, _arg1: u8) {

}
entry public fun user_quit_efficiency_mode(_arg0: &signer) {

}
public fun utilization(_arg0: Object<Market>): FixedPoint64 {
abort 0
}
fun validate_coin_info<Ty0>(_arg0: Object<Market>) {

}
fun validate_fa_info(_arg0: Object<Market>, _arg1: Object<Metadata>) {

}
public fun vault_exists(_arg0: address): bool {
abort 0
}
fun vault_liability_internal(_arg0: &Vault, _arg1: Object<Market>): u64 {
abort 0
}
public fun withdraw<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: u64): Coin<Ty0> {
abort 0
}
public fun withdraw_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: u64): FungibleAsset {
abort 0
}
fun withdraw_internal(_arg0: &signer, _arg1: Object<Market>, _arg2: u64): u64 {
abort 0
}
entry public fun withdraw_reserve<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: address) {

}
entry public fun withdraw_reserve_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: address) {

}
}
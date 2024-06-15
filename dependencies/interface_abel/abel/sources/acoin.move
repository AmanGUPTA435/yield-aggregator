// Move bytecode v5
module abel::acoin {
// use 0000000000000000000000000000000000000000000000000000000000000001::account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
// use 0000000000000000000000000000000000000000000000000000000000000001::error;
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
use 0000000000000000000000000000000000000000000000000000000000000001::table::{Table};
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{TypeInfo};
// use c0188ad3f42e66b5bd3596e642b8f72749b67d84e6349ce325b27117a9406bdf::constants;
// use c0188ad3f42e66b5bd3596e642b8f72749b67d84e6349ce325b27117a9406bdf::interest_rate_module;


struct ACoin<phantom Ty0> has store {
	value: u64
}
struct ACoinGlobalSnapshot has drop, store {
	total_supply: u128,
	total_borrows: u128,
	total_reserves: u128,
	borrow_index: u128,
	accrual_block_number: u64,
	reserve_factor_mantissa: u128,
	initial_exchange_rate_mantissa: u128,
	treasury_balance: u64
}
struct ACoinInfo<phantom Ty0> has key {
	name: String,
	symbol: String,
	decimals: u8,
	total_supply: u128,
	total_borrows: u128,
	total_reserves: u128,
	borrow_index: u128,
	accrual_block_number: u64,
	reserve_factor_mantissa: u128,
	initial_exchange_rate_mantissa: u128,
	treasury: Coin<Ty0>,
	accrue_interest_events: EventHandle<AccrueInterestEvent>,
	new_reserve_factor_events: EventHandle<NewReserveFactorEvent>,
	reserves_added_events: EventHandle<ReservesAddedEvent>,
	reserves_reduced_events: EventHandle<ReservesReducedEvent>
}
struct ACoinStore<phantom Ty0> has key {
	coin: ACoin<Ty0>,
	borrows: BorrowSnapshot,
	deposit_events: EventHandle<DepositEvent>,
	withdraw_events: EventHandle<WithdrawEvent>,
	mint_events: EventHandle<MintEvent>,
	redeem_events: EventHandle<RedeemEvent>,
	borrow_events: EventHandle<BorrowEvent>,
	repay_borrow_events: EventHandle<RepayBorrowEvent>,
	liquidate_borrow_events: EventHandle<LiquidateBorrowEvent>
}
struct ACoinUserSnapshot has drop, store {
	balance: u64,
	borrow_principal: u64,
	interest_index: u128
}
struct AccountSnapshotTable has key {
	account_snapshots: Table<String, ACoinUserSnapshot>
}
struct AccrueInterestEvent has drop, store {
	cash_prior: u64,
	interest_accumulated: u128,
	borrow_index: u128,
	total_borrows: u128
}
struct BorrowEvent has drop, store {
	borrower: address,
	borrow_amount: u64,
	account_borrows: u64,
	total_borrows: u128
}
struct BorrowSnapshot has drop, store {
	principal: u64,
	interest_index: u128
}
struct DepositEvent has drop, store {
	amount: u64
}
struct GlobalSnapshotTable has key {
	snapshots: Table<String, ACoinGlobalSnapshot>
}
struct LiquidateBorrowEvent has drop, store {
	liquidator: address,
	borrower: address,
	repay_amount: u64,
	ctoken_collateral: TypeInfo,
	seize_tokens: u64
}
struct MintEvent has drop, store {
	minter: address,
	mint_amount: u64,
	mint_tokens: u64
}
struct NewReserveFactorEvent has drop, store {
	old_reserve_factor_mantissa: u128,
	new_reserve_factor_mantissa: u128
}
struct RedeemEvent has drop, store {
	redeemer: address,
	redeem_amount: u64,
	redeem_tokens: u64
}
struct RepayBorrowEvent has drop, store {
	payer: address,
	borrower: address,
	repay_amount: u64,
	account_borrows: u64,
	total_borrows: u128
}
struct ReservesAddedEvent has drop, store {
	benefactor: address,
	add_amount: u64,
	new_total_reserves: u128
}
struct ReservesReducedEvent has drop, store {
	admin: address,
	reduce_amount: u64,
	new_total_reserves: u128
}
struct WithdrawEvent has drop, store {
	amount: u64
}

public fun accrual_block_number<Ty0>(): u64 {
abort 0
}
public fun acoin_address(): address {
abort 0
}
public(friend) fun add_reserves<Ty0>(_arg0: u128) {

}
public(friend) fun add_total_borrows<Ty0>(_arg0: u128) {

}
public fun balance<Ty0>(_arg0: address): u64 {
abort 0
}
public fun balance_no_type_args(_arg0: String, _arg1: address): u64 {
abort 0
}
public fun borrow_balance<Ty0>(_arg0: address): u64 {
abort 0
}
public fun borrow_balance_no_type_args(_arg0: String, _arg1: address): u64 {
abort 0
}
public fun borrow_index<Ty0>(): u128 {
abort 0
}
public fun borrow_index_no_type_args(_arg0: String): u128 {
abort 0
}
public fun borrow_interest_index<Ty0>(_arg0: address): u128 {
abort 0
}
public fun borrow_principal<Ty0>(_arg0: address): u64 {
abort 0
}
public fun borrow_rate_per_block_no_type_args(_arg0: String): u128 {
abort 0
}
public(friend) fun burn<Ty0>(_arg0: ACoin<Ty0>): u64 {
abort 0
}
public fun decimals<Ty0>(): u8 {
abort 0
}
public(friend) fun deposit<Ty0>(_arg0: address, _arg1: ACoin<Ty0>) {
abort 0
}
public(friend) fun deposit_to_treasury<Ty0>(_arg0: Coin<Ty0>) {
abort 0
}
public fun destroy_zero<Ty0>(_arg0: ACoin<Ty0>) {
abort 0
}
public(friend) fun emit_accrue_interest_event<Ty0>(_arg0: u64, _arg1: u128, _arg2: u128, _arg3: u128) {

}
public(friend) fun emit_borrow_event<Ty0>(_arg0: address, _arg1: u64, _arg2: u64, _arg3: u128) {

}
public(friend) fun emit_liquidate_borrow_event<Ty0>(_arg0: address, _arg1: address, _arg2: u64, _arg3: TypeInfo, _arg4: u64) {

}
public(friend) fun emit_mint_event<Ty0>(_arg0: address, _arg1: u64, _arg2: u64) {

}
public(friend) fun emit_new_reserve_factor_event<Ty0>(_arg0: u128, _arg1: u128) {

}
public(friend) fun emit_redeem_event<Ty0>(_arg0: address, _arg1: u64, _arg2: u64) {

}
public(friend) fun emit_repay_borrow_event<Ty0>(_arg0: address, _arg1: address, _arg2: u64, _arg3: u64, _arg4: u128) {

}
public(friend) fun emit_reserves_added_event<Ty0>(_arg0: address, _arg1: u64, _arg2: u128) {

}
public(friend) fun emit_reserves_reduced_event<Ty0>(_arg0: address, _arg1: u64, _arg2: u128) {

}
public fun exchange_rate_mantissa<Ty0>(): u128 {
abort 0
}
public fun get_account_snapshot<Ty0>(_arg0: address): (u64 , u64 , u128) {
abort 0
}
public fun get_account_snapshot_no_type_args(_arg0: String, _arg1: address): (u64 , u64 , u128) {
abort 0
}
public fun get_cash<Ty0>(): u64 {
abort 0
}
public fun get_cash_no_type_args(_arg0: String): u64 {
abort 0
}
public fun initial_exchange_rate_mantissa<Ty0>(): u128 {
abort 0
}
public(friend) fun initialize<Ty0>(_arg0: &signer, _arg1: String, _arg2: String, _arg3: u8, _arg4: u128) {

}
public fun is_account_registered<Ty0>(_arg0: address): bool {
abort 0
}
public fun is_account_registered_no_type_args(_arg0: String, _arg1: address): bool {
abort 0
}
public fun is_coin_initialized<Ty0>(): bool {
abort 0
}
public(friend) fun mint<Ty0>(_arg0: u64): ACoin<Ty0> {
abort 0
}
public fun name<Ty0>(): String {
abort 0
}
public fun register<Ty0>(_arg0: &signer) {

}
public fun reserve_factor_mantissa<Ty0>(): u128 {
abort 0
}
public fun reserve_factor_mantissa_no_type_args(_arg0: String): u128 {
abort 0
}
public(friend) fun set_reserve_factor_mantissa<Ty0>(_arg0: u128) {

}
public(friend) fun sub_reserves<Ty0>(_arg0: u128) {

}
public(friend) fun sub_total_borrows<Ty0>(_arg0: u128) {

}
public fun symbol<Ty0>(): String {
abort 0
}
public fun total_borrows<Ty0>(): u128 {
abort 0
}
public fun total_borrows_no_type_args(_arg0: String): u128 {
abort 0
}
public fun total_reserves<Ty0>(): u128 {
abort 0
}
public fun total_reserves_no_type_args(_arg0: String): u128 {
abort 0
}
public fun total_supply<Ty0>(): u128 {
abort 0
}
public fun total_supply_no_type_args(_arg0: String): u128 {
abort 0
}
public(friend) fun update_account_borrows<Ty0>(_arg0: address, _arg1: u64, _arg2: u128) {

}
public(friend) fun update_accrual_block_number<Ty0>() {

}
public(friend) fun update_global_borrow_index<Ty0>(_arg0: u128) {

}
public(friend) fun update_total_borrows<Ty0>(_arg0: u128) {

}
public(friend) fun update_total_reserves<Ty0>(_arg0: u128) {

}
public fun value<Ty0>(_arg0: &ACoin<Ty0>): u64 {
abort 0
}
public(friend) fun withdraw<Ty0>(_arg0: address, _arg1: u64): ACoin<Ty0> {
abort 0
}
public(friend) fun withdraw_from_treasury<Ty0>(_arg0: u64): Coin<Ty0> {
abort 0
}
public fun zero<Ty0>(): ACoin<Ty0> {
abort 0
}
}
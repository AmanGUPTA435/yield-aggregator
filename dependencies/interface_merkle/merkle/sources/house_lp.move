// Move bytecode v6
module merkle::house_lp {
// use 0000000000000000000000000000000000000000000000000000000000000001::account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin,FreezeCapability,BurnCapability,MintCapability};
use 0000000000000000000000000000000000000000000000000000000000000001::event::EventHandle;
// use 0000000000000000000000000000000000000000000000000000000000000001::option;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
// use 0000000000000000000000000000000000000000000000000000000000000001::string::{Self
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::TypeInfo;
// use merkle::fee_distributor;
// use merkle::safe_math_u64;
// use merkle::vault;
// use merkle::vault_type;


struct DepositEvent has drop, store {
	asset_type: TypeInfo,
	user: address,
	deposit_amount: u64,
	mint_amount: u64,
	deposit_fee: u64
}
struct FeeEvent has drop, store {
	fee_type: u64,
	asset_type: TypeInfo,
	amount: u64,
	amount_sign: bool
}
struct HouseLP<phantom Ty0> has key {
	deposit_fee: u64,
	withdraw_fee: u64,
	highest_price: u64
}
struct HouseLPConfig<phantom Ty0> has key {
	mint_capability: MintCapability<MKLP<Ty0>>,
	burn_capability: BurnCapability<MKLP<Ty0>>,
	freeze_capability: FreezeCapability<MKLP<Ty0>>,
	withdraw_division: u64,
	minimum_deposit: u64,
	soft_break: u64,
	hard_break: u64
}
struct HouseLPEvents has key {
	deposit_events: EventHandle<DepositEvent>,
	withdraw_events: EventHandle<WithdrawEvent>,
	fee_events: EventHandle<FeeEvent>
}
struct MKLP<phantom Ty0> {
	dummy_field: bool
}
struct UserWithdrawInfo has key {
	withdraw_limit: u64,
	withdraw_amount: u64,
	last_withdraw_reset_timestamp: u64
}
struct WithdrawEvent has drop, store {
	asset_type: TypeInfo,
	user: address,
	withdraw_amount: u64,
	burn_amount: u64,
	withdraw_fee: u64
}

public fun check_hard_break_exceeded<Ty0>(): bool {
abort 0
}
public fun check_soft_break_exceeded<Ty0>(): bool {
abort 0
}
public fun deposit<Ty0>(_arg0: &signer, _arg1: u64) {

}
fun deposit_trading_fee<Ty0>(_arg0: Coin<Ty0>) {
abort 0
}
public fun deposit_without_mint<Ty0>(_arg0: &signer, _arg1: u64) {

}
fun get_mdd<Ty0>(): u64 {
abort 0
}
public(friend) fun pnl_deposit_to_lp<Ty0>(_arg0: Coin<Ty0>) {
abort 0
}
public(friend) fun pnl_withdraw_from_lp<Ty0>(_arg0: u64): Coin<Ty0> {
abort 0
}
public fun register<Ty0>(_arg0: &signer) {

}
public fun set_house_lp_deposit_fee<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun set_house_lp_hard_break<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun set_house_lp_minimum_deposit<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun set_house_lp_soft_break<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun set_house_lp_withdraw_division<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun set_house_lp_withdraw_fee<Ty0>(_arg0: &signer, _arg1: u64) {

}
fun update_highest_price<Ty0>() {

}
public fun withdraw<Ty0>(_arg0: &signer, _arg1: u64) {

}
}
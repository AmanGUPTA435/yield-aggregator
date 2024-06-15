// Move bytecode v5
module pancake_masterchef::masterchef {
use 0000000000000000000000000000000000000000000000000000000000000001::account::{SignerCapability};
// use 0000000000000000000000000000000000000000000000000000000000000001::code;
// use 0000000000000000000000000000000000000000000000000000000000000001::coin;
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
// use 0000000000000000000000000000000000000000000000000000000000000001::math64;
// use 0000000000000000000000000000000000000000000000000000000000000001::resource_account;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
use 0000000000000000000000000000000000000000000000000000000000000001::table_with_length::{TableWithLength};
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
// use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use 159df6b7689437016108a019fd5bef736bac692b6d4a1f10c941f6fbb9a74ca6::oft;


struct AddPoolEvent has drop, store {
	pid: u64,
	alloc_point: u64,
	lp: String,
	is_regular: bool
}
struct DepositEvent has drop, store {
	user: address,
	pid: u64,
	amount: u64
}
struct EmergencyWithdrawEvent has drop, store {
	user: address,
	pid: u64,
	amount: u128
}
struct Events has key {
	deposit_events: EventHandle<DepositEvent>,
	withdraw_events: EventHandle<WithdrawEvent>,
	emergency_withdraw_events: EventHandle<EmergencyWithdrawEvent>,
	add_pool_events: EventHandle<AddPoolEvent>,
	set_pool_events: EventHandle<SetPoolEvent>,
	update_pool_events: EventHandle<UpdatePoolEvent>,
	update_cake_rate_events: EventHandle<UpdateCakeRateEvent>,
	upkeep_events: EventHandle<UpkeepEvent>
}
struct MasterChef has key {
	signer_cap: SignerCapability,
	admin: address,
	upkeep_admin: address,
	lp_to_pid: TableWithLength<String, u64>,
	lps: vector<String>,
	pool_info: vector<PoolInfo>,
	total_regular_alloc_point: u64,
	total_special_alloc_point: u64,
	cake_per_second: u64,
	cake_rate_to_regular: u64,
	cake_rate_to_special: u64,
	last_upkeep_timestamp: u64,
	end_timestamp: u64
}
struct PoolInfo has store {
	total_amount: u128,
	acc_cake_per_share: u128,
	last_reward_timestamp: u64,
	alloc_point: u64,
	is_regular: bool
}
struct PoolUserInfo has key {
	pid_to_user_info: TableWithLength<u64, UserInfo>,
	pids: vector<u64>
}
struct SetPoolEvent has drop, store {
	pid: u64,
	prev_alloc_point: u64,
	alloc_point: u64
}
struct UpdateCakeRateEvent has drop, store {
	regular_farm_rate: u64,
	special_farm_rate: u64
}
struct UpdatePoolEvent has drop, store {
	pid: u64,
	last_reward_timestamp: u64,
	lp_supply: u128,
	acc_cake_per_share: u128
}
struct UpkeepEvent has drop, store {
	amount: u64,
	elapsed: u64,
	prev_cake_per_second: u64,
	cake_per_second: u64
}
struct UserInfo has store {
	amount: u128,
	reward_debt: u128
}
struct WithdrawEvent has drop, store {
	user: address,
	pid: u64,
	amount: u64
}

entry public fun add_pool<Ty0>(_arg0: &signer, _arg1: u64, _arg2: bool, _arg3: bool) {

}
fun calc_cake_reward(_arg0: u64): (u64 , u128) {
abort 0
}
entry public fun deposit<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun emergency_withdraw<Ty0>(_arg0: &signer) {

}
fun init_module(_arg0: &signer) {

}
public fun get_pending_apt<T0>(_arg0: address) : u64  {
abort 0
}
entry public fun mass_update_pools() {

}
public fun pending_cake(_arg0: u64, _arg1: address): u64 {
abort 0
}
public fun pool_length(): u64 {
abort 0
}
fun safe_transfer_cake(_arg0: &signer, _arg1: address, _arg2: u64) {

}
entry public fun set_admin(_arg0: &signer, _arg1: address) {

}
entry public fun set_pool(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: bool) {

}
entry public fun set_upkeep_admin(_arg0: &signer, _arg1: address) {

}
entry public fun update_cake_rate(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: bool) {

}
entry public fun update_pool(_arg0: u64) {

}
entry public fun upgrade_masterchef(_arg0: &signer, _arg1: vector<u8>, _arg2: vector<vector<u8>>) {

}
entry public fun upkeep(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: bool) {

}
entry public fun withdraw<Ty0>(_arg0: &signer, _arg1: u64) {
abort 0
}
}
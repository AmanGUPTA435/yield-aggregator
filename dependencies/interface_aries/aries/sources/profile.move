// Move bytecode v6
module controller::profile {
use 0000000000000000000000000000000000000000000000000000000000000001::account::SignerCapability;
use 0000000000000000000000000000000000000000000000000000000000000001::event;
use 0000000000000000000000000000000000000000000000000000000000000001::option::{Self,Option};
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::simple_map::{Self,SimpleMap};
use 0000000000000000000000000000000000000000000000000000000000000001::string::{Self,String};
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{Self,TypeInfo};
use 0000000000000000000000000000000000000000000000000000000000000001::vector;
use decimal::decimal::{Self,Decimal};
use utils::iterable_table::{IterableTable};
use utils::map::{Self,Map};
// use aries::oracle;
use utils::pair::{Self,Pair};
use controller::profile_farm::{Self,ProfileFarmRaw,ProfileFarm};
// use aries::reserve;
use config::reserve_config;
use controller::reserve_farm;
// use aries::utils;


struct CheckEquity {
	user_addr: address,
	profile_name: String
}
struct Deposit has drop, store {
	collateral_amount: u64
}
struct Loan has drop, store {
	borrowed_share: Decimal
}
struct Profile has key {
	deposited_reserves: IterableTable<TypeInfo, Deposit>,
	deposit_farms: IterableTable<TypeInfo, ProfileFarm>,
	borrowed_reserves: IterableTable<TypeInfo, Loan>,
	borrow_farms: IterableTable<TypeInfo, ProfileFarm>
}
struct Profiles has key {
	profile_signers: SimpleMap<String, SignerCapability>,
	referrer: Option<address>
}
struct SyncProfileBorrowEvent has drop, store {
	user_addr: address,
	profile_name: String,
	reserve_type: TypeInfo,
	borrowed_share_decimal: u128,
	farm: Option<ProfileFarmRaw>
}
struct SyncProfileDepositEvent has drop, store {
	user_addr: address,
	profile_name: String,
	reserve_type: TypeInfo,
	collateral_amount: u64,
	farm: Option<ProfileFarmRaw>
}

public(friend) fun add_collateral(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: u64) {

}
fun add_collateral_profile(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u64) {

}
public fun available_borrowing_power(_arg0: address, _arg1: &String): Decimal {
abort 0
}
fun borrow_farms(_arg0: &Profile, _arg1: TypeInfo): &IterableTable<TypeInfo, ProfileFarm> {
abort 0
}
fun borrow_farms_mut(_arg0: &mut Profile, _arg1: TypeInfo): &mut IterableTable<TypeInfo, ProfileFarm> {
abort 0
}
fun borrow_profile(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u64, _arg3: u8) {

}
public fun check_enough_collateral(_arg0: CheckEquity) {
abort 0
}
public(friend) fun claim_reward<Ty0>(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: TypeInfo): u64 {
abort 0
}
public(friend) fun claim_reward_ti(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: TypeInfo, _arg4: TypeInfo): u64 {
abort 0
}
public fun claimable_reward_amount_on_farming<Ty0>(_arg0: address, _arg1: String): (vector<TypeInfo> , vector<u64>) {
abort 0
}
public fun claimable_reward_amounts(_arg0: address, _arg1: String): (vector<TypeInfo> , vector<u64>) {
abort 0
}
public(friend) fun deposit(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: u64, _arg4: bool): (u64 , u64) {
abort 0
}
fun deposit_profile(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u64, _arg3: bool): (u64 , u64) {
abort 0
}
fun emit_borrow_event(_arg0: address, _arg1: &String, _arg2: &Profile, _arg3: TypeInfo) {

}
fun emit_deposit_event(_arg0: address, _arg1: &String, _arg2: &Profile, _arg3: TypeInfo) {

}
public fun get_adjusted_borrowed_value(_arg0: address, _arg1: &String): Decimal {
abort 0
}
fun get_adjusted_borrowed_value_fresh_for_profile(_arg0: &Profile): Decimal {
abort 0
}
public fun get_borrowed_amount(_arg0: address, _arg1: &String, _arg2: TypeInfo): Decimal {
abort 0
}
public fun get_deposited_amount(_arg0: address, _arg1: &String, _arg2: TypeInfo): u64 {
abort 0
}
public fun get_liquidation_borrow_value(_arg0: &Profile): Decimal {
abort 0
}
fun get_profile_account(_arg0: address, _arg1: &String): signer {
abort 0
}
public fun get_profile_name_str(_arg0: String): String {
abort 0
}
public fun get_total_borrowing_power(_arg0: address, _arg1: &String): Decimal {
abort 0
}
public fun get_total_borrowing_power_from_profile(_arg0: &Profile): Decimal {
abort 0
}
public fun get_user_referrer(_arg0: address): Option<address> {
abort 0
}
public fun has_enough_collateral(_arg0: address, _arg1: String): bool {
abort 0
}
public fun init(_arg0: &signer) {

}
public fun init_with_referrer(_arg0: &signer, _arg1: address) {

}
public fun is_registered(_arg0: address): bool {
abort 0
}
public(friend) fun liquidate(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: TypeInfo, _arg4: u64): (u64 , u64) {
abort 0
}
fun liquidate_profile(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: TypeInfo, _arg3: u64): (u64 , u64) {
abort 0
}
public fun list_claimable_reward_of_coin<Ty0>(_arg0: address, _arg1: &String): vector<Pair<TypeInfo, TypeInfo>> {
abort 0
}
fun list_farm_reward_keys_of_coin<Ty0, Ty1>(_arg0: &Profile): vector<Pair<TypeInfo, TypeInfo>> {
abort 0
}
public fun max_borrow_amount(_arg0: address, _arg1: &String, _arg2: TypeInfo): u64 {
abort 0
}
fun move_profiles_to(_arg0: &signer, _arg1: Profiles) {
abort 0
}
public fun new(_arg0: &signer, _arg1: String) {

}
public fun profile_deposit<Ty0>(_arg0: address, _arg1: String): (u64 , u64) {
abort 0
}
public fun profile_exists(_arg0: address, _arg1: String): bool {
abort 0
}
public fun profile_farm<Ty0, Ty1>(_arg0: address, _arg1: String): Option<ProfileFarmRaw> {
abort 0
}
public fun profile_farm_coin<Ty0, Ty1, Ty2>(_arg0: address, _arg1: String): (u128 , u128) {
abort 0
}
fun profile_farms_claimable<Ty0>(_arg0: &Profile): Map<TypeInfo, u64> {
abort 0
}
public fun profile_loan<Ty0>(_arg0: address, _arg1: String): (u128 , u128) {
abort 0
}
public(friend) fun read_check_equity_data(_arg0: &CheckEquity): (address , String) {
abort 0
}
public(friend) fun remove_collateral(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: u64): CheckEquity {
abort 0
}
fun remove_collateral_profile(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u64): u128 {
abort 0
}
fun repay_profile(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u64): u64 {
abort 0
}
public fun try_add_or_init_profile_reward_share<Ty0>(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u128) {

}
public fun try_subtract_profile_reward_share<Ty0>(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u128): u128 {
abort 0
}
public(friend) fun withdraw(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: u64, _arg4: bool): (u64 , u64 , CheckEquity) {
abort 0
}
public(friend) fun withdraw_flash_loan(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: u64, _arg4: bool): (u64 , u64 , CheckEquity) {
abort 0
}
fun withdraw_internal(_arg0: address, _arg1: &String, _arg2: TypeInfo, _arg3: u64, _arg4: bool, _arg5: u8): (u64 , u64 , CheckEquity) {
abort 0
}
fun withdraw_profile(_arg0: &mut Profile, _arg1: TypeInfo, _arg2: u64, _arg3: bool, _arg4: u8): (u64 , u64) {
abort 0
}
}
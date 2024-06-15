// Move bytecode v6
module controller::controller {
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Self,Coin};
use 0000000000000000000000000000000000000000000000000000000000000001::event;
use 0000000000000000000000000000000000000000000000000000000000000001::option::{Self,Option};
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::{Self,String};
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{Self,TypeInfo};
// use 890812a6bbe27dd59188ade3bbdbe40a544e6e104319b7ebc6617d3eb947ac07::aggregator;
// use aries::aries_config;
// use aries::decimal;
use config::interest_rate_config::{Self,InterestRateConfig};
// use aries::oracle;
use controller::profile::{Self,CheckEquity};
// use aries::reserve;
use config::reserve_config::{Self,ReserveConfig};
use controller::reserve_farm::{Self,RewardConfig};
// use aries::reward_container;
// use aries::utils;


struct AddLPShareEvent<phantom Ty0> has drop, store {
	user_addr: address,
	profile_name: String,
	lp_amount: u64
}
struct AddReserveEvent<phantom Ty0> has drop, store {
	signer_addr: address,
	initial_exchange_rate_decimal: u128,
	reserve_conf: ReserveConfig,
	interest_rate_conf: InterestRateConfig
}
struct AddRewardEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	signer_addr: address,
	amount: u64
}
struct AddSubaccountEvent has drop, store {
	user_addr: address,
	profile_name: String
}
struct BeginFlashLoanEvent<phantom Ty0> has drop, store {
	user_addr: address,
	profile_name: String,
	amount_in: u64,
	withdraw_amount: u64,
	borrow_amount: u64
}
struct ClaimRewardEvent<phantom Ty0> has drop, store {
	user_addr: address,
	profile_name: String,
	reserve_type: TypeInfo,
	farming_type: TypeInfo,
	reward_amount: u64
}
struct DepositEvent<phantom Ty0> has drop, store {
	sender: address,
	receiver: address,
	profile_name: String,
	amount_in: u64,
	repay_only: bool,
	repay_amount: u64,
	deposit_amount: u64
}
struct DepositRepayForEvent<phantom Ty0> has drop, store {
	receiver: address,
	receiver_profile_name: String,
	deposit_amount: u64,
	repay_amount: u64
}
struct EndFlashLoanEvent<phantom Ty0> has drop, store {
	user_addr: address,
	profile_name: String,
	amount_in: u64,
	repay_amount: u64,
	deposit_amount: u64
}
struct LiquidateEvent<phantom Ty0, phantom Ty1> has drop, store {
	liquidator: address,
	liquidatee: address,
	liquidatee_profile_name: String,
	repay_amount_in: u64,
	redeem_lp: bool,
	repay_amount: u64,
	withdraw_lp_amount: u64,
	liquidation_fee_amount: u64,
	redeem_lp_amount: u64
}
struct MintLPShareEvent<phantom Ty0> has drop, store {
	user_addr: address,
	amount: u64,
	lp_amount: u64
}
struct RedeemLPShareEvent<phantom Ty0> has drop, store {
	user_addr: address,
	amount: u64,
	lp_amount: u64
}
struct RegisterUserEvent has drop, store {
	user_addr: address,
	default_profile_name: String,
	referrer_addr: Option<address>
}
struct RemoveLPShareEvent<phantom Ty0> has drop, store {
	user_addr: address,
	profile_name: String,
	lp_amount: u64
}
struct RemoveRewardEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	signer_addr: address,
	amount: u64
}
struct SwapEvent<phantom Ty0, phantom Ty1> has drop, store {
	sender: address,
	profile_name: String,
	amount_in: u64,
	amount_min_out: u64,
	allow_borrow: bool,
	in_withdraw_amount: u64,
	in_borrow_amount: u64,
	out_deposit_amount: u64,
	out_repay_amount: u64
}
struct UpdateInterestRateConfigEvent<phantom Ty0> has drop, store {
	signer_addr: address,
	config: InterestRateConfig
}
struct UpdateReserveConfigEvent<phantom Ty0> has drop, store {
	signer_addr: address,
	config: ReserveConfig
}
struct UpdateRewardConfigEvent<phantom Ty0, phantom Ty1, phantom Ty2> has drop, store {
	signer_addr: address,
	config: RewardConfig
}
struct UpsertPrivilegedReferrerConfigEvent has drop, store {
	signer_addr: address,
	claimant_addr: address,
	fee_sharing_percentage: u8
}
struct WithdrawEvent<phantom Ty0> has drop, store {
	sender: address,
	profile_name: String,
	amount_in: u64,
	allow_borrow: bool,
	withdraw_amount: u64,
	borrow_amount: u64
}

entry public fun add_collateral<Ty0>(_arg0: &signer, _arg1: vector<u8>, _arg2: u64) {

}
entry public fun add_reserve<Ty0>(_arg0: &signer) {

}
entry public fun add_reward<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: u64) {

}
entry public fun add_subaccount(_arg0: &signer, _arg1: vector<u8>) {

}
public fun begin_flash_loan<Ty0>(_arg0: &signer, _arg1: String, _arg2: u64): (CheckEquity , Coin<Ty0>) {
abort 0
}
entry public fun claim_reward<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: vector<u8>) {

}
entry public fun claim_reward_for_profile<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: String) {

}
public fun claim_reward_ti<Ty0>(_arg0: &signer, _arg1: vector<u8>, _arg2: TypeInfo, _arg3: TypeInfo) {

}
fun consume_coin_dust<Ty0>(_arg0: &signer, _arg1: Option<Coin<Ty0>>) {
abort 0
}
entry public fun deposit<Ty0>(_arg0: &signer, _arg1: vector<u8>, _arg2: u64, _arg3: bool) {

}
public fun deposit_and_repay_for<Ty0>(_arg0: address, _arg1: &String, _arg2: Coin<Ty0>): (u64,u64) {
abort 0
}
public fun deposit_coin_for<Ty0>(_arg0: address, _arg1: &String, _arg2: Coin<Ty0>) {
abort 0
}
fun deposit_coin_to_reserve<Ty0>(_arg0: Coin<Ty0>, _arg1: Coin<Ty0>) {
abort 0
}
public fun deposit_for<Ty0>(_arg0: &signer, _arg1: vector<u8>, _arg2: u64, _arg3: address, _arg4: bool) {

}
public fun end_flash_loan<Ty0>(_arg0: CheckEquity, _arg1: Coin<Ty0>) {
abort 0
}
fun flash_borrow_from_reserve<Ty0>(_arg0: u64, _arg1: u64, _arg2: Option<address>): Coin<Ty0> {
abort 0
}
entry public fun hippo_swap<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6>(_arg0: &signer, _arg1: vector<u8>, _arg2: bool, _arg3: u64, _arg4: u64, _arg5: u8, _arg6: u8, _arg7: u64, _arg8: bool, _arg9: u8, _arg10: u64, _arg11: bool, _arg12: u8, _arg13: u64, _arg14: bool) {

}
entry public fun init(_arg0: &signer, _arg1: address) {

}
entry public fun init_reward_container<Ty0>(_arg0: &signer) {

}
entry public fun liquidate<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: vector<u8>, _arg3: u64) {

}
entry public fun liquidate_and_redeem<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: vector<u8>, _arg3: u64) {

}
fun liquidate_impl<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: vector<u8>, _arg3: u64, _arg4: bool) {

}
entry public fun  mint<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun redeem<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun register_or_update_privileged_referrer(_arg0: &signer, _arg1: address, _arg2: u8) {

}
entry public fun register_user(_arg0: &signer, _arg1: vector<u8>) {

}
entry public fun register_user_with_referrer(_arg0: &signer, _arg1: vector<u8>, _arg2: address) {

}
entry public fun remove_collateral<Ty0>(_arg0: &signer, _arg1: vector<u8>, _arg2: u64) {

}
entry public fun remove_reward<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: u64) {

}
entry public fun update_interest_rate_config<Ty0>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64) {

}
entry public fun update_reserve_config<Ty0>(_arg0: &signer, _arg1: u8, _arg2: u8, _arg3: u64, _arg4: u64, _arg5: u8, _arg6: u8, _arg7: u64, _arg8: u64, _arg9: u64, _arg10: u64, _arg11: bool, _arg12: bool, _arg13: u64) {

}
entry public fun update_reward_rate<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: u128) {

}
entry public fun withdraw<Ty0>(_arg0: &signer, _arg1: vector<u8>, _arg2: u64, _arg3: bool) {

}
fun withdraw_from_reserve<Ty0>(_arg0: u64, _arg1: u64, _arg2: Option<address>): Coin<Ty0> {
abort 0
}
}
// Move bytecode v6
module aries::controller {
use 0000000000000000000000000000000000000000000000000000000000000001::coin;
use 0000000000000000000000000000000000000000000000000000000000000001::event;
use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string;
use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use 890812a6bbe27dd59188ade3bbdbe40a544e6e104319b7ebc6617d3eb947ac07::aggregator;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::controller_config;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::decimal;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::interest_rate_config;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::oracle;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::profile;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::reserve;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::reserve_config;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::reserve_farm;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::reward_container;
// use 9770fa9c725cbd97eb50b2be5f7416efdfd1f1554beb0750d4dae4c64e860da3::utils;


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

entry public add_collateral<Ty0>(Arg0: &signer, Arg1: vector<u8>, Arg2: u64) {

}
entry public add_reserve<Ty0>(Arg0: &signer) {

}
entry public add_reward<Ty0, Ty1, Ty2>(Arg0: &signer, Arg1: u64) {

}
entry public add_subaccount(Arg0: &signer, Arg1: vector<u8>) {

}
public begin_flash_loan<Ty0>(Arg0: &signer, Arg1: String, Arg2: u64): CheckEquity * Coin<Ty0> {
    abort 0
}
entry public claim_reward<Ty0, Ty1, Ty2>(Arg0: &signer, Arg1: vector<u8>) {

}
entry public claim_reward_for_profile<Ty0, Ty1, Ty2>(Arg0: &signer, Arg1: String) {

}
public claim_reward_ti<Ty0>(Arg0: &signer, Arg1: vector<u8>, Arg2: TypeInfo, Arg3: TypeInfo) {

}
consume_coin_dust<Ty0>(Arg0: &signer, Arg1: Option<Coin<Ty0>>) {

}
entry public deposit<Ty0>(Arg0: &signer, Arg1: vector<u8>, Arg2: u64, Arg3: bool) {

}
public deposit_and_repay_for<Ty0>(Arg0: address, Arg1: &String, Arg2: Coin<Ty0>): u64 * u64 {
    abort 0
}
public deposit_coin_for<Ty0>(Arg0: address, Arg1: &String, Arg2: Coin<Ty0>) {

}
deposit_coin_to_reserve<Ty0>(Arg0: Coin<Ty0>, Arg1: Coin<Ty0>) {

}
public deposit_for<Ty0>(Arg0: &signer, Arg1: vector<u8>, Arg2: u64, Arg3: address, Arg4: bool) {

}
public end_flash_loan<Ty0>(Arg0: CheckEquity, Arg1: Coin<Ty0>) {

}
flash_borrow_from_reserve<Ty0>(Arg0: u64, Arg1: u64, Arg2: Option<address>): Coin<Ty0> {
    abort 0
}
entry public hippo_swap<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6>(Arg0: &signer, Arg1: vector<u8>, Arg2: bool, Arg3: u64, Arg4: u64, Arg5: u8, Arg6: u8, Arg7: u64, Arg8: bool, Arg9: u8, Arg10: u64, Arg11: bool, Arg12: u8, Arg13: u64, Arg14: bool) {
	
}
entry public init(Arg0: &signer, Arg1: address) {

}
entry public init_reward_container<Ty0>(Arg0: &signer) {

}
entry public liquidate<Ty0, Ty1>(Arg0: &signer, Arg1: address, Arg2: vector<u8>, Arg3: u64) {

}
entry public liquidate_and_redeem<Ty0, Ty1>(Arg0: &signer, Arg1: address, Arg2: vector<u8>, Arg3: u64) {

}
liquidate_impl<Ty0, Ty1>(Arg0: &signer, Arg1: address, Arg2: vector<u8>, Arg3: u64, Arg4: bool) {
    
}
entry public mint<Ty0>(Arg0: &signer, Arg1: u64) {

}
entry public redeem<Ty0>(Arg0: &signer, Arg1: u64) {

}
entry public register_or_update_privileged_referrer(Arg0: &signer, Arg1: address, Arg2: u8) {

}
entry public register_user(Arg0: &signer, Arg1: vector<u8>) {

}
entry public register_user_with_referrer(Arg0: &signer, Arg1: vector<u8>, Arg2: address) {

}
entry public remove_collateral<Ty0>(Arg0: &signer, Arg1: vector<u8>, Arg2: u64) {

}
entry public remove_reward<Ty0, Ty1, Ty2>(Arg0: &signer, Arg1: u64) {

}
entry public update_interest_rate_config<Ty0>(Arg0: &signer, Arg1: u64, Arg2: u64, Arg3: u64, Arg4: u64) {

}
entry public update_reserve_config<Ty0>(Arg0: &signer, Arg1: u8, Arg2: u8, Arg3: u64, Arg4: u64, Arg5: u8, Arg6: u8, Arg7: u64, Arg8: u64, Arg9: u64, Arg10: u64, Arg11: bool, Arg12: bool, Arg13: u64) {

}
entry public update_reward_rate<Ty0, Ty1, Ty2>(Arg0: &signer, Arg1: u128) {

}
entry public withdraw<Ty0>(Arg0: &signer, Arg1: vector<u8>, Arg2: u64, Arg3: bool) {

}
withdraw_from_reserve<Ty0>(Arg0: u64, Arg1: u64, Arg2: Option<address>): Coin<Ty0> {
    abort 0
}
}
// Move bytecode v5
module abel::market {
// use 0000000000000000000000000000000000000000000000000000000000000001::aptos_coin;
// use 0000000000000000000000000000000000000000000000000000000000000001::coin;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::String;
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
// use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use 7c0322595a73b3fc53bb166f5783470afeb1ed9f46d1176db62139991505dc61::abel_coin;
// use c0188ad3f42e66b5bd3596e642b8f72749b67d84e6349ce325b27117a9406bdf::acoin;
// use c0188ad3f42e66b5bd3596e642b8f72749b67d84e6349ce325b27117a9406bdf::constants;
// use c0188ad3f42e66b5bd3596e642b8f72749b67d84e6349ce325b27117a9406bdf::market_storage;
// use c0188ad3f42e66b5bd3596e642b8f72749b67d84e6349ce325b27117a9406bdf::oracle;




// entry public add_abel_market<Ty0>(_arg0: &signer) {

// }
// entry public approve_market<Ty0>(_arg0: &signer) {

// }
// public borrow_allowed<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// public borrow_verify<Ty0>(_arg0: address, _arg1: u64) {

// }
entry public fun claim_abel(_arg0: address) {

}
// public claimable_abelcoin(_arg0: address): u128 {

// }
// public claimable_abelcoin_each(_arg0: String, _arg1: address): u128 {

// }
// public claimable_borrower_abelcoin(_arg0: String, _arg1: address): u128 {

// }
// public claimable_supplier_abelcoin(_arg0: String, _arg1: address): u128 {

// }
// public deposit_allowed<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// deposit_allowed_internal<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// public deposit_verify<Ty0>(_arg0: address, _arg1: u64) {

// }
// distribute_borrower_abelcoin<Ty0>(_arg0: address, _arg1: u128, _arg2: bool) {

// }
// distribute_borrower_abelcoin_no_type_args(_arg0: String, _arg1: address, _arg2: u128, _arg3: bool) {

// }
// distribute_supplier_abelcoin<Ty0>(_arg0: address, _arg1: bool) {

// }
// distribute_supplier_abelcoin_no_type_args(_arg0: String, _arg1: address, _arg2: bool) {

// }
// entry public drop_abel_market<Ty0>(_arg0: &signer) {

// }
// entry public enter_market<Ty0>(_arg0: &signer) {

// }
// entry public exit_market<Ty0>(_arg0: &signer) {

// }
// entry public fund_abel_treasury(_arg0: &signer, _arg1: u64) {

// }
// get_account_liquidity_internal(_arg0: address): u64 * u64 {

// }
// public get_hypothetical_account_liquidity<Ty0>(_arg0: address, _arg1: u64, _arg2: u64): u64 * u64 {

// }
// get_hypothetical_account_liquidity_internal<Ty0>(_arg0: address, _arg1: u64, _arg2: u64): u64 * u64 {

// }
// public init_allowed<Ty0>(_arg0: address, _arg1: String, _arg2: String, _arg3: u8, _arg4: u128): u64 {

// }
// public init_verify<Ty0>(_arg0: address, _arg1: String, _arg2: String, _arg3: u8, _arg4: u128) {

// }
// public liquidate_borrow_allowed<Ty0, Ty1>(_arg0: address, _arg1: address, _arg2: u64): u64 {

// }
// public liquidate_borrow_verify<Ty0, Ty1>(_arg0: address, _arg1: address, _arg2: u64, _arg3: u64) {

// }
// public liquidate_calculate_seize_tokens<Ty0, Ty1>(_arg0: u64): u64 {

// }
// market_listed<Ty0>() {

// }
// public mint_allowed<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// public mint_verify<Ty0>(_arg0: address, _arg1: u64, _arg2: u64) {

// }
// mulExp(_arg0: u128, _arg1: u128): u128 {

// }
// only_admin(_arg0: &signer) {

// }
// only_admin_or_pause_guardian(_arg0: &signer) {

// }
// public redeem_allowed<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// public redeem_verify<Ty0>(_arg0: address, _arg1: u64, _arg2: u64) {

// }
// public redeem_with_fund_allowed<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// redeem_with_fund_allowed_internal<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// entry public refresh_abel_speeds() {

// }
// public repay_borrow_allowed<Ty0>(_arg0: address, _arg1: address, _arg2: u64): u64 {

// }
// public repay_borrow_verify<Ty0>(_arg0: address, _arg1: address, _arg2: u64, _arg3: u128) {

// }
// public seize_allowed<Ty0, Ty1>(_arg0: address, _arg1: address, _arg2: u64): u64 {

// }
// public seize_verify<Ty0, Ty1>(_arg0: address, _arg1: address, _arg2: u64) {

// }
// entry public set_abel_rate(_arg0: &signer, _arg1: u128) {

// }
// entry public set_borrow_paused<Ty0>(_arg0: &signer, _arg1: bool) {

// }
// entry public set_close_factor(_arg0: &signer, _arg1: u128) {

// }
// entry public set_collateral_factor<Ty0>(_arg0: &signer, _arg1: u128) {

// }
// entry public set_deposit_paused(_arg0: &signer, _arg1: bool) {

// }
// entry public set_liquidation_incentive(_arg0: &signer, _arg1: u128) {

// }
// entry public set_mint_paused<Ty0>(_arg0: &signer, _arg1: bool) {

// }
// entry public set_pause_guardian(_arg0: &signer, _arg1: address) {

// }
// entry public set_seize_paused(_arg0: &signer, _arg1: bool) {

// }
// entry public try_register(_arg0: &signer) {

// }
// update_abelcoin_borrow_index<Ty0>(_arg0: u128) {

// }
// update_abelcoin_borrow_index_no_type_args(_arg0: String, _arg1: u128) {

// }
// update_abelcoin_supply_index<Ty0>() {

// }
// update_abelcoin_supply_index_no_type_args(_arg0: String) {

// }
// public withdraw_allowed<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// withdraw_allowed_internal<Ty0>(_arg0: address, _arg1: u64): u64 {

// }
// public withdraw_verify<Ty0>(_arg0: address, _arg1: u64) {

// }
}
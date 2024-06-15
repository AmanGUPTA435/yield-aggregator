// Move bytecode v6
module lending::scripts {
// use 0000000000000000000000000000000000000000000000000000000000000001::coin;
use aptos_framework::fungible_asset::{Metadata, FungibleAsset};
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Object};
// use 0000000000000000000000000000000000000000000000000000000000000001::primary_fungible_store;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::String;
// use c6bc659f1649553c1a3fa05d9727433dc03843baac29473c817d06d39e7621ba::farming;
use lending::lending::{Market};




entry public fun borrow<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun borrow_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun claim_reward<Ty0>(_arg0: &signer, _arg1: String) {

}
entry public fun claim_reward_fa(_arg0: &signer, _arg1: Object<Metadata>, _arg2: String) {

}
entry public fun create_market_with_jump_model<Ty0>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64, _arg5: u64, _arg6: u64) {

}
entry public fun create_market_with_jump_model_fa(_arg0: &signer, _arg1: Object<Metadata>, _arg2: u64, _arg3: u64, _arg4: u64, _arg5: u64, _arg6: u64, _arg7: u64) {

}
entry public fun liquidate<Ty0>(_arg0: &signer, _arg1: address, _arg2: Object<Market>, _arg3: Object<Market>, _arg4: u64, _arg5: u64) {

}
entry public fun liquidate_fa(_arg0: &signer, _arg1: address, _arg2: Object<Market>, _arg3: Object<Market>, _arg4: u64, _arg5: u64) {

}
entry public fun repay<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun repay_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun supply<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun supply_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun withdraw<Ty0>(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
entry public fun withdraw_fa(_arg0: &signer, _arg1: Object<Market>, _arg2: u64) {

}
}
// Move bytecode v5
module abel::acoin_lend {
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
// use 0000000000000000000000000000000000000000000000000000000000000001::error;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
// use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use abel_coin::abel_coin;
use abel::acoin::{ACoin};
// use abel::constants;
// use abel::interest_rate/_module;
// use abel::market;
// use abel::market_storage;




public fun accrue_interest<Ty0>() {

}
public fun add_reserves<Ty0>(_arg0: &signer, _arg1: Coin<Ty0>) {
abort 0
}
entry public fun add_reserves_entry<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun admin<Ty0>(): address {
abort 0
}
public fun borrow<Ty0>(_arg0: &signer, _arg1: u64): Coin<Ty0> {
abort 0
}
entry public fun borrow_entry<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun deposit<Ty0>(_arg0: &signer, _arg1: ACoin<Ty0>) {
abort 0
}
entry public fun initialize<Ty0>(_arg0: &signer, _arg1: String, _arg2: String, _arg3: u8, _arg4: u128) {

}
public fun liquidate_borrow<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: Coin<Ty0>): ACoin<Ty1> {
abort 0
}
entry public fun liquidate_borrow_entry<Ty0, Ty1>(_arg0: &signer, _arg1: address, _arg2: u64) {

}
public fun mint<Ty0>(_arg0: &signer, _arg1: Coin<Ty0>): ACoin<Ty0> {
abort 0
}
entry public fun mint_entry<Ty0>(_arg0: &signer, _arg1: u64) {

}
fun only_admin<Ty0>(_arg0: &signer) {

}
public fun redeem<Ty0>(_arg0: &signer, _arg1: ACoin<Ty0>): Coin<Ty0> {
abort 0
}
entry public fun redeem_entry<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun redeem_underlying<Ty0>(_arg0: &signer, _arg1: u64) {

}
public fun reduce_reserves<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun reduce_reserves_entry<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun register<Ty0>(_arg0: &signer) {

}
entry public fun repay_all<Ty0>(_arg0: &signer, _arg1: address) {

}
public fun repay_borrow<Ty0>(_arg0: &signer, _arg1: address, _arg2: Coin<Ty0>) {
abort 0
}
entry public fun repay_borrow_entry<Ty0>(_arg0: &signer, _arg1: address, _arg2: u64) {

}
entry public fun set_reserve_factor<Ty0>(_arg0: &signer, _arg1: u128) {

}
entry public fun transfer<Ty0>(_arg0: &signer, _arg1: address, _arg2: u64) {

}
public fun withdraw<Ty0>(_arg0: &signer, _arg1: u64): ACoin<Ty0> {
abort 0
}
}
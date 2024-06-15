// Move bytecode v6
module aptin::lend {
use 0000000000000000000000000000000000000000000000000000000000000001::account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin;
use 0000000000000000000000000000000000000000000000000000000000000001::error;
use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::string;
use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use aptin::constant;
// use aptin::math;
// use aptin::pool;
// use aptin::pool_config;
// use aptin::resource_account;
// use aptin::utils;
// use aptin::vcoins;
// use 890812a6bbe27dd59188ade3bbdbe40a544e6e104319b7ebc6617d3eb947ac07::aggregator;




entry public fun add_config<Ty0>(_arg0: &signer, _arg1: u8, _arg2: u8, _arg3: u8, _arg4: u64, _arg5: u64) {

}
entry public fun add_pool<Ty0>(_arg0: &signer) {

}
public entry fun claim<T0, T1>(_arg0: &signer, _arg1: address) {
        
}
entry public fun borrow<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun disable<Ty0>(_arg0: &signer, _arg1: u8) {

}
entry public fun enable<Ty0>(_arg0: &signer, _arg1: u8) {

}
entry public fun initialize(_arg0: &signer) {

}
entry public fun liquidate<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6>(_arg0: &signer, _arg1: address, _arg2: u64, _arg3: u64, _arg4: u8, _arg5: u8, _arg6: u64, _arg7: bool, _arg8: u8, _arg9: u64, _arg10: bool, _arg11: u8, _arg12: u64, _arg13: bool) {

}
entry public fun register<Ty0>(_arg0: &signer) {

}
entry public fun remove_config<Ty0>(_arg0: &signer) {

}
entry public fun repay<Ty0>(_arg0: &signer, _arg1: u64) {

}
entry public fun reset_collateral<Ty0>(_arg0: &signer) {

}
entry public fun set_weight<Ty0>(_arg0: &signer, _arg1: u8) {

}
entry public fun supply<Ty0>(_arg0: &signer, _arg1: u64, _arg2: bool) {

}
entry public fun traverse_pool(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
entry public fun withdraw<Ty0>(_arg0: &signer, _arg1: u64, _arg2: address) {

}
}
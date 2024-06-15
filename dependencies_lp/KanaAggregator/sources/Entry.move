// Move bytecode v6
module kanalabs_aggregator::Entry {

use aptos_framework::coin::Coin;
use aptos_framework::aptos_coin;
use std::option;
use std::signer;


public fun claim_lz<Ty0>(arg0: &signer) {

}
#[cmd]
public fun impl_three_step<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6>(
    arg0: &signer, 
    arg1: u8, 
    arg2: u8, 
    arg3: u64, 
    arg4: bool, 
    arg5: u8, 
    arg6: u64, 
    arg7: bool, 
    arg8: u8, 
    arg9: u64, 
    arg10: bool, 
    arg11: Coin<Ty0>, 
    arg12: u64, 
    arg13: bool, 
    arg14: address
):(Coin<Ty3>){
    abort 0
}
public fun send_layer_zero<Ty0>(arg0: &signer, arg1: Coin<Ty0>, arg2: u64, arg3: vector<u8>, arg4: u64, arg5: bool, arg6: vector<u8>, arg7: vector<u8>) {
    abort 0
}
public fun set_swap_referral_profile(arg0: &signer, arg1: u64) {
    abort 0
}
public fun swap_send_layer_zero<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6>(arg0: &signer, arg1: u8, arg2: u8, arg3: u64, arg4: bool, arg5: u8, arg6: u64, arg7: bool, arg8: u8, arg9: u64, arg10: bool, arg11: Coin<Ty0>, arg12: u64, arg13: bool, arg14: address, arg15: u64, arg16: vector<u8>, arg17: u64, arg18: bool, arg19: vector<u8>, arg20: vector<u8>) {
    abort 0
}
public fun swap_three_step<Ty0, Ty1, Ty2, Ty3, Ty4, Ty5, Ty6>(arg0: &signer, arg1: u8, arg2: u8, arg3: u64, arg4: bool, arg5: u8, arg6: u64, arg7: bool, arg8: u8, arg9: u64, arg10: bool, arg11: Coin<Ty0>, arg12: u64, arg13: bool, arg14: address) {
    abort 0
}
}
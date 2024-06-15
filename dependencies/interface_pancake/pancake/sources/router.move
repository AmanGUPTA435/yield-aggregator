// Move bytecode v6
module pancake::router {
use 0000000000000000000000000000000000000000000000000000000000000001::coin::Coin;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
// use pancake::swap;
// use pancake::swap_utils;




entry public fun add_liquidity<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64) {

}
fun add_swap_event_internal<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64) {

}
fun add_swap_event_with_address_internal<Ty0, Ty1>(_arg0: address, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64) {

}
entry public fun create_pair<Ty0, Ty1>(_arg0: &signer) {

}
public fun get_amount_in<Ty0, Ty1>(_arg0: u64): u64 {
abort 0
}
fun get_amount_in_internal<Ty0, Ty1>(_arg0: bool, _arg1: u64): u64 {
abort 0
}
fun get_intermediate_output<Ty0, Ty1>(_arg0: bool, _arg1: Coin<Ty0>): Coin<Ty1> {
abort 0
}
fun get_intermediate_output_x_to_exact_y<Ty0, Ty1>(_arg0: bool, _arg1: Coin<Ty0>, _arg2: u64): Coin<Ty1> {
abort 0
}
fun is_pair_created_internal<Ty0, Ty1>() {

}
entry public fun register_lp<Ty0, Ty1>(_arg0: &signer) {

}
entry public fun register_token<Ty0>(_arg0: &signer) {

}
entry public fun remove_liquidity<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64) {

}
entry public fun swap_exact_input<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
fun swap_exact_input_double_internal<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: bool, _arg2: bool, _arg3: u64, _arg4: u64): u64 {
abort 0
}
entry public fun swap_exact_input_doublehop<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
fun swap_exact_input_quadruple_internal<Ty0, Ty1, Ty2, Ty3, Ty4>(_arg0: &signer, _arg1: bool, _arg2: bool, _arg3: bool, _arg4: bool, _arg5: u64, _arg6: u64): u64 {
abort 0
}
entry public fun swap_exact_input_quadruplehop<Ty0, Ty1, Ty2, Ty3, Ty4>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
fun swap_exact_input_triple_internal<Ty0, Ty1, Ty2, Ty3>(_arg0: &signer, _arg1: bool, _arg2: bool, _arg3: bool, _arg4: u64, _arg5: u64): u64 {
abort 0
}
entry public fun swap_exact_input_triplehop<Ty0, Ty1, Ty2, Ty3>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
entry public fun swap_exact_output<Ty0, Ty1>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
fun swap_exact_output_double_internal<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: bool, _arg2: bool, _arg3: u64, _arg4: u64): u64 {
abort 0
}
entry public fun swap_exact_output_doublehop<Ty0, Ty1, Ty2>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
fun swap_exact_output_quadruple_internal<Ty0, Ty1, Ty2, Ty3, Ty4>(_arg0: &signer, _arg1: bool, _arg2: bool, _arg3: bool, _arg4: bool, _arg5: u64, _arg6: u64): u64 {
abort 0
}
entry public fun swap_exact_output_quadruplehop<Ty0, Ty1, Ty2, Ty3, Ty4>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
fun swap_exact_output_triple_internal<Ty0, Ty1, Ty2, Ty3>(_arg0: &signer, _arg1: bool, _arg2: bool, _arg3: bool, _arg4: u64, _arg5: u64): u64 {
abort 0
}
entry public fun swap_exact_output_triplehop<Ty0, Ty1, Ty2, Ty3>(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
public fun swap_exact_x_to_y_direct_external<Ty0, Ty1>(_arg0: Coin<Ty0>): Coin<Ty1> {
abort 0
}
public fun swap_x_to_exact_y_direct_external<Ty0, Ty1>(_arg0: Coin<Ty0>, _arg1: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
}
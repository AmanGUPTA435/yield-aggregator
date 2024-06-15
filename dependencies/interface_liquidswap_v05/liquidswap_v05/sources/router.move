// Move bytecode v6
module liquidswap_v05::router {
use 0000000000000000000000000000000000000000000000000000000000000001::coin::Coin;
// use liquidswap_v05::coin_helper;
// use liquidswap_v05::curves;
// use liquidswap_v05::liquidity_pool;
// use liquidswap_v05::math;
// use liquidswap_v05::stable_curve;
use liquidswap_lp::lp_coin::LP;




public fun add_liquidity<Ty0, Ty1, Ty2>(_arg0: Coin<Ty0>, _arg1: u64, _arg2: Coin<Ty1>, _arg3: u64): (Coin<Ty0> , Coin<Ty1> , Coin<LP<Ty0, Ty1, Ty2>>) {
abort 0
}
public fun calc_optimal_coin_values<Ty0, Ty1, Ty2>(_arg0: u64, _arg1: u64, _arg2: u64, _arg3: u64): (u64, u64) {
abort 0
}
public fun convert_with_current_price(_arg0: u64, _arg1: u64, _arg2: u64): u64 {
abort 0
}
public fun get_amount_in<Ty0, Ty1, Ty2>(_arg0: u64): u64 {
abort 0
}
public fun get_amount_out<Ty0, Ty1, Ty2>(_arg0: u64): u64 {
abort 0
}
fun get_coin_in_with_fees<Ty0, Ty1, Ty2>(_arg0: u64, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64): u64 {
abort 0
}
fun get_coin_out_with_fees<Ty0, Ty1, Ty2>(_arg0: u64, _arg1: u64, _arg2: u64, _arg3: u64, _arg4: u64): u64 {
abort 0
}
public fun get_cumulative_prices<Ty0, Ty1, Ty2>(): (u128 , u128 , u64) {
abort 0
}
public fun get_dao_fee<Ty0, Ty1, Ty2>(): u64 {
abort 0
}
public fun get_dao_fees_config<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
public fun get_decimals_scales<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
public fun get_fee<Ty0, Ty1, Ty2>(): u64 {
abort 0
}
public fun get_fees_config<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
public fun get_reserves_for_lp_coins<Ty0, Ty1, Ty2>(_arg0: u64): (u64 , u64) {
abort 0
}
public fun get_reserves_size<Ty0, Ty1, Ty2>(): (u64 , u64) {
abort 0
}
public fun is_swap_exists<Ty0, Ty1, Ty2>(): bool {
abort 0
}
public fun register_pool<Ty0, Ty1, Ty2>(_arg0: &signer) {

}
public fun remove_liquidity<Ty0, Ty1, Ty2>(_arg0: Coin<LP<Ty0, Ty1, Ty2>>, _arg1: u64, _arg2: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public fun swap_coin_for_coin_unchecked<Ty0, Ty1, Ty2>(_arg0: Coin<Ty0>, _arg1: u64): Coin<Ty1> {
abort 0
}
public fun swap_coin_for_exact_coin<Ty0, Ty1, Ty2>(_arg0: Coin<Ty0>, _arg1: u64): (Coin<Ty0> , Coin<Ty1>) {
abort 0
}
public fun swap_exact_coin_for_coin<Ty0, Ty1, Ty2>(_arg0: Coin<Ty0>, _arg1: u64): Coin<Ty1> {
abort 0
}
}
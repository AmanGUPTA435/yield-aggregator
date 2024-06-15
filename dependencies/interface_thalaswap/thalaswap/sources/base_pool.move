// Move bytecode v6
module thalaswap::base_pool {
// use 0000000000000000000000000000000000000000000000000000000000000001::account;
// use 0000000000000000000000000000000000000000000000000000000000000001::coin;
use 0000000000000000000000000000000000000000000000000000000000000001::event::EventHandle;
// use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::string::String;
// use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use thalaswap::coin_helper;
// use thalaswap::package;
use fixed_point64::fixed_point64::FixedPoint64;
// use 93aa044a65a27bd89b163f8b3be3777b160b09a25c336643dcc2878dfd8f2a8d::manager;


struct BasePoolParamChangeEvent has drop, store {
	name: String,
	prev_value: u64,
	new_value: u64
}
struct BasePoolParams has key {
	swap_fee_protocol_allocation_ratio: FixedPoint64,
	param_change_events: EventHandle<BasePoolParamChangeEvent>
}
struct Null {
	dummy_field: bool
}

public(friend) fun initialize() {

}
public(friend) fun initialized(): bool {
abort 0
}
public fun is_null<Ty0>(): bool {
abort 0
}
public fun max_supported_decimals(): u8 {
abort 0
}
public fun pool_token_supply<Ty0>(): u64 {
abort 0
}
entry public fun set_swap_fee_protocol_allocation_bps(_arg0: &signer, _arg1: u64) {

}
public fun swap_fee_protocol_allocation_ratio(): FixedPoint64 {
abort 0
}
public(friend) fun validate_pool_assets<Ty0, Ty1, Ty2, Ty3>(): bool {
abort 0
}
public(friend) fun validate_swap_fee(_arg0: u64): bool {
abort 0
}
}
// Move bytecode v5
module pancake_oft::oft {
use 0000000000000000000000000000000000000000000000000000000000000001::account::{SignerCapability};
// use 0000000000000000000000000000000000000000000000000000000000000001::code;
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
// use 0000000000000000000000000000000000000000000000000000000000000001::from_bcs;
// use 0000000000000000000000000000000000000000000000000000000000000001::resource_account;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::table::{Table};
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{TypeInfo};
// use 43d8cad89263e6936921a0adb8d5d49f0e236c229460f01b14dca073114df2b9::oft as 1oft;
use layerzero::endpoint::{UaCapability};
// use 54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90::lzapp;
// use 54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90::remote;
// use 54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90::serde;
// use 54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90::utils;


struct CakeOFT {
	dummy_field: bool
}
struct Capabilities has key {
	lz_cap: UaCapability<CakeOFT>
}
struct EventStore has key {
	non_blocking_events: EventHandle<NonBlockingEvent>
}
struct NonBlockingEvent has drop, store {
	src_chain_id: u64,
	src_address: vector<u8>,
	receiver: address,
	amount: u64
}
struct OFT has key {
	admin: address,
	paused: bool,
	signer_cap: SignerCapability,
	white_list: Table<address, bool>
}
struct OFTCap has key {
	hard_cap: Table<u64, u64>,
	used: Table<u64, u64>,
	last_timestamp: Table<u64, u64>
}

fun assert_admin(_arg0: address) {

}
fun decode_send_payload(_arg0: &vector<u8>): (address , u64) {
abort 0
}
entry public fun enable_custom_adapter_params(_arg0: &signer, _arg1: bool) {

}
fun init_module(_arg0: &signer) {

}
entry public fun lz_receive(_arg0: u64, _arg1: vector<u8>, _arg2: vector<u8>) {

}
public fun lz_receive_types(_arg0: u64, _arg1: vector<u8>, _arg2: vector<u8>): vector<TypeInfo> {
abort 0
}
fun non_blocking_lz_receive(_arg0: u64, _arg1: vector<u8>, _arg2: vector<u8>, _arg3: address, _arg4: u64) {

}
fun now_days(): u64 {
abort 0
}
entry public fun pause(_arg0: &signer, _arg1: bool) {

}
entry public fun set_config(_arg0: &signer, _arg1: u64, _arg2: u8, _arg3: u64, _arg4: u8, _arg5: vector<u8>) {

}
entry public fun set_default_fee(_arg0: &signer, _arg1: u64) {

}
entry public fun set_executor(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: address) {

}
entry public fun set_fee(_arg0: &signer, _arg1: u64, _arg2: bool, _arg3: u64) {

}
entry public fun set_fee_owner(_arg0: &signer, _arg1: address) {

}
entry public fun set_hard_cap(_arg0: &signer, _arg1: u64, _arg2: u64) {

}
entry public fun set_min_dst_gas(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u64) {

}
entry public fun set_receive_msglib(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u8) {

}
entry public fun set_send_msglib(_arg0: &signer, _arg1: u64, _arg2: u64, _arg3: u8) {

}
entry public fun set_trust_remote(_arg0: &signer, _arg1: u64, _arg2: vector<u8>) {

}
entry public fun transfer_admin(_arg0: &signer, _arg1: address) {

}
entry public fun upgrade_oft(_arg0: &signer, _arg1: vector<u8>, _arg2: vector<vector<u8>>) {

}
entry public fun whitelist(_arg0: &signer, _arg1: address, _arg2: bool) {

}
}
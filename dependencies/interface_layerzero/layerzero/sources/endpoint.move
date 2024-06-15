// Move bytecode v5
module layerzero::endpoint {
// use 0000000000000000000000000000000000000000000000000000000000000001::account;
use 0000000000000000000000000000000000000000000000000000000000000001::aptos_coin::AptosCoin;
// use 0000000000000000000000000000000000000000000000000000000000000001::bcs;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
// use 0000000000000000000000000000000000000000000000000000000000000001::error;
use 0000000000000000000000000000000000000000000000000000000000000001::event::{EventHandle};
// use 0000000000000000000000000000000000000000000000000000000000000001::hash;
use 0000000000000000000000000000000000000000000000000000000000000001::table::{Table};
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{TypeInfo};
// use layerzero::bulletin;
// use layerzero::channel;
use executor::executor_cap::{ExecutorCapability};
// use layerzero::executor_config;
// use layerzero::executor_router;
use msglib::msglib_cap::{MsgLibSendCapability,MsgLibReceiveCapability};
// use layerzero::msglib_config;
// use layerzero::msglib_router;
use layerzero_common::packet::{Packet};
use layerzero_common::semver::{SemVer};
// use layerzero::utils;
use zro::zro::{ZRO};


struct Capabilities has key {
	send_caps: Table<SemVer, MsgLibSendCapability>,
	executor_caps: Table<u64, ExecutorCapability>
}
struct ChainConfig has key {
	local_chain_id: u64
}
struct UaCapability<phantom Ty0> has copy, store {
	dummy_field: bool
}
struct UaRegistry has key {
	register_events: EventHandle<TypeInfo>,
	ua_infos: Table<address, TypeInfo>
}

public fun bulletin_msglib_read(_arg0: u64, _arg1: u8, _arg2: vector<u8>): vector<u8> {
abort 0
}
public fun bulletin_msglib_write(_arg0: vector<u8>, _arg1: vector<u8>, _arg2: &MsgLibReceiveCapability) {

}
public fun bulletin_ua_read(_arg0: address, _arg1: vector<u8>): vector<u8> {
abort 0
}
public fun bulletin_ua_write<Ty0>(_arg0: vector<u8>, _arg1: vector<u8>, _arg2: &UaCapability<Ty0>) {
abort 0
}
public fun destroy_ua_cap<Ty0>(_arg0: UaCapability<Ty0>) {
abort 0
}
public fun get_config(_arg0: address, _arg1: u64, _arg2: u8, _arg3: u64, _arg4: u8): vector<u8> {
abort 0
}
public fun get_default_executor(_arg0: u64): (u64 , address) {
abort 0
}
public fun get_default_receive_msglib(_arg0: u64): (u64 , u8) {
abort 0
}
public fun get_default_send_msglib(_arg0: u64): (u64 , u8) {
abort 0
}
public fun get_executor(_arg0: address, _arg1: u64): (u64 , address) {
abort 0
}
public fun get_local_chain_id(): u64 {
abort 0
}
public fun get_next_guid(_arg0: address, _arg1: u64, _arg2: vector<u8>): vector<u8> {
abort 0
}
public fun get_receive_msglib(_arg0: address, _arg1: u64): (u64 , u8) {
abort 0
}
public fun get_send_msglib(_arg0: address, _arg1: u64): (u64 , u8) {
abort 0
}
public fun get_ua_type_by_address(_arg0: address): TypeInfo {
abort 0
}
fun handle_executor<Ty0>(_arg0: &Packet, _arg1: vector<u8>, _arg2: Coin<AptosCoin>): Coin<AptosCoin> {
abort 0
}
public fun has_next_receive(_arg0: address, _arg1: u64, _arg2: vector<u8>): bool {
abort 0
}
public fun inbound_nonce(_arg0: address, _arg1: u64, _arg2: vector<u8>): u64 {
abort 0
}
entry public fun init(_arg0: &signer, _arg1: u64) {

}
fun insert_ua<Ty0>(_arg0: &signer) {

}
public fun is_ua_registered<Ty0>(): bool {
abort 0
}
public fun lz_receive<Ty0>(_arg0: u64, _arg1: vector<u8>, _arg2: vector<u8>, _arg3: &UaCapability<Ty0>): u64 {
abort 0
}
public fun outbound_nonce(_arg0: address, _arg1: u64, _arg2: vector<u8>): u64 {
abort 0
}
public fun quote_fee(_arg0: address, _arg1: u64, _arg2: u64, _arg3: bool, _arg4: vector<u8>, _arg5: vector<u8>): (u64 , u64) {
abort 0
}
public fun receive<Ty0>(_arg0: Packet, _arg1: &MsgLibReceiveCapability) {

}
entry public fun register_executor<Ty0>(_arg0: &signer) {

}
public fun register_msglib<Ty0>(_arg0: &signer, _arg1: bool): MsgLibReceiveCapability {
abort 0
}
public fun register_ua<Ty0>(_arg0: &signer): UaCapability<Ty0> {
abort 0
}
public fun send<Ty0>(_arg0: u64, _arg1: vector<u8>, _arg2: vector<u8>, _arg3: Coin<AptosCoin>, _arg4: Coin<ZRO>, _arg5: vector<u8>, _arg6: vector<u8>, _arg7: &UaCapability<Ty0>): (u64 , Coin<AptosCoin> , Coin<ZRO>) {
abort 0
}
public fun set_config<Ty0>(_arg0: u64, _arg1: u8, _arg2: u64, _arg3: u8, _arg4: vector<u8>, _arg5: &UaCapability<Ty0>) {
abort 0
}
public fun set_executor<Ty0>(_arg0: u64, _arg1: u64, _arg2: address, _arg3: &UaCapability<Ty0>) {
abort 0
}
public fun set_receive_msglib<Ty0>(_arg0: u64, _arg1: u64, _arg2: u8, _arg3: &UaCapability<Ty0>) {
abort 0
}
public fun set_send_msglib<Ty0>(_arg0: u64, _arg1: u64, _arg2: u8, _arg3: &UaCapability<Ty0>) {
abort 0
}
}
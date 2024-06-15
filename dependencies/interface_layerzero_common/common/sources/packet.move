// Move bytecode v5
module layerzero_common::packet {
// use 0000000000000000000000000000000000000000000000000000000000000001::hash;
// use layerzero::serde;
// use layerzero::utils;


struct Packet has copy, drop, store, key {
	src_chain_id: u64,
	src_address: vector<u8>,
	dst_chain_id: u64,
	dst_address: vector<u8>,
	nonce: u64,
	payload: vector<u8>
}

public fun compute_guid(_arg0: u64, _arg1: u64, _arg2: vector<u8>, _arg3: u64, _arg4: vector<u8>): vector<u8> {
abort 0
}
public fun decode_dst_address(_arg0: &vector<u8>, _arg1: u64): vector<u8> {
abort 0
}
public fun decode_dst_chain_id(_arg0: &vector<u8>, _arg1: u64): u64 {
abort 0
}
public fun decode_nonce(_arg0: &vector<u8>): u64 {
abort 0
}
public fun decode_packet(_arg0: &vector<u8>, _arg1: u64): Packet {
abort 0
}
public fun decode_payload(_arg0: &vector<u8>, _arg1: u64): vector<u8> {
abort 0
}
public fun decode_src_address(_arg0: &vector<u8>, _arg1: u64): vector<u8> {
abort 0
}
public fun decode_src_chain_id(_arg0: &vector<u8>): u64 {
abort 0
}
public fun dst_address(_arg0: &Packet): vector<u8> {
abort 0
}
public fun dst_chain_id(_arg0: &Packet): u64 {
abort 0
}
public fun encode_packet(_arg0: &Packet): vector<u8> {
abort 0
}
public fun get_guid(_arg0: &Packet): vector<u8> {
abort 0
}
public fun hash_sha3_packet(_arg0: &Packet): vector<u8> {
abort 0
}
public fun hash_sha3_packet_bytes(_arg0: vector<u8>): vector<u8> {
abort 0
}
public fun new_packet(_arg0: u64, _arg1: vector<u8>, _arg2: u64, _arg3: vector<u8>, _arg4: u64, _arg5: vector<u8>): Packet {
abort 0
}
public fun nonce(_arg0: &Packet): u64 {
abort 0
}
public fun payload(_arg0: &Packet): vector<u8> {
abort 0
}
public fun src_address(_arg0: &Packet): vector<u8> {
abort 0
}
public fun src_chain_id(_arg0: &Packet): u64 {
abort 0
}
}
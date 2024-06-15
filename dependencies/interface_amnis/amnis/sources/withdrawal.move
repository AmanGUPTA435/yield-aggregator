module amnis::withdrawal {
// use 0000000000000000000000000000000000000000000000000000000000000001::aptos_account;
use 0000000000000000000000000000000000000000000000000000000000000001::aptos_coin::{AptosCoin};
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
// use 0000000000000000000000000000000000000000000000000000000000000001::option;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
// use 0000000000000000000000000000000000000000000000000000000000000001::string;
// use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
// use 0000000000000000000000000000000000000000000000000000000000000004::collection;
// use 0000000000000000000000000000000000000000000000000000000000000004::royalty;
use 0000000000000000000000000000000000000000000000000000000000000004::token::{BurnRef};
use aptos_framework::object::{Object};
// use aptos_framework::account::SignerCapability;
// use aptos_std::event::{Self};
use amnis::amapt_token::{AmnisApt};
// use amnis::package_manager;
// use amnis::treasury;
// use 0000000000000000000000000000000000000000000000000000000000000001::object;


struct WithdrawalCollection has key {
	apt: Coin<AptosCoin>,
	total_pending_withdrawal: u128,
	lockup_duration: u64
}
struct WithdrawalToken has key {
	burn_ref: BurnRef,
	amapt: Coin<AmnisApt>,
	locked_until_secs: u64
}

public(friend) fun add_apt(_arg0: Coin<AptosCoin>) {
abort 0
}
public fun amount(_arg0: Object<WithdrawalToken>): u64 {
abort 0
}
public fun collection_address(): address {
abort 0
}
public(friend) fun create(_arg0: Coin<AmnisApt>, _arg1: address): Object<WithdrawalToken> {
abort 0	
}
public fun excess_apt(): u128 {
abort 0
}
public(friend) fun initialize() {

}
public fun locked_until(_arg0: Object<WithdrawalToken>): u64 {
abort 0
}
public fun lockup_duration(): u64 {
abort 0
}
public(friend) fun set_lockup_duration(_arg0: u64) {

}
public fun total_apt(): u128 {
abort 0
}
public fun total_pending_withdrawal(): u128 {
abort 0
}
public(friend) fun  withdraw(_arg0: &signer, _arg1: Object<WithdrawalToken>): Coin<AptosCoin> {
abort 0
}
public(friend) fun withdraw_excess_apt(): Coin<AptosCoin> {
abort 0
}
}
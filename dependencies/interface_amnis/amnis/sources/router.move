module amnis::router {
// use 0000000000000000000000000000000000000000000000000000000000000001::aptos_account;
use 0000000000000000000000000000000000000000000000000000000000000001::aptos_coin::{AptosCoin};
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
// use 0000000000000000000000000000000000000000000000000000000000000001::staking_config;
// use 0000000000000000000000000000000000000000000000000000000000000001::string;
// use 0000000000000000000000000000000000000000000000000000000000000001::vector;
use aptos_framework::object::{Object};
use amnis::withdrawal::{WithdrawalToken};
use aptos_std::event::{EventHandle};
use amnis::stapt_token::{StakedApt};
use amnis::amapt_token::{AmnisApt};
// use amnis::package_manager;
// use 0000000000000000000000000000000000000000000000000000000000000001::object;
// use 0000000000000000000000000000000000000000000000000000000000000001::event;
// use amnis::delegation_manager;
// use amnis::treasury;


struct Events has key {
	mint_events: EventHandle<MintEvent>,
	stake_events: EventHandle<StakeEvent>,
	unstake_events: EventHandle<UnstakeEvent>,
	withdrawal_request_event: EventHandle<WithdrawalRequestEvent>,
	withdraw_events: EventHandle<WithdrawEvent>
}
struct MintEvent has drop, store {
	apt: u64,
	amapt: u64
}
struct StakeEvent has drop, store {
	amapt: u64,
	stapt: u64
}
struct UnstakeEvent has drop, store {
	stapt: u64,
	amapt: u64
}
struct WithdrawEvent has drop, store {
	owner: address,
	amount: u64,
	withdrawal_token: Object<WithdrawalToken>
}
struct WithdrawalRequestEvent has drop, store {
	amount: u64,
	receiver: address,
	withdrawal_token: Object<WithdrawalToken>
}

public fun current_reward_rate():(u64,u64) {
abort 0
}
public fun deposit(_arg0: Coin<AptosCoin>): Coin<AmnisApt> {
abort 0
}
public fun deposit_and_stake(_arg0: Coin<AptosCoin>): Coin<StakedApt> {
abort 0
}
entry public fun deposit_and_stake_direct_entry(_arg0: &signer, _arg1: u64, _arg2: address, _arg3: address) {

}
entry public fun deposit_and_stake_entry(_arg0: &signer, _arg1: u64, _arg2: address) {

}
public(friend) fun deposit_direct(_arg0: Coin<AptosCoin>, _arg1: address): Coin<AmnisApt> {
abort 0
	
}
entry public fun deposit_direct_entry(_arg0: &signer, _arg1: u64, _arg2: address, _arg3: address) {

}
entry public fun deposit_entry(_arg0: &signer, _arg1: u64, _arg2: address) {

}
public(friend) fun initialize() {

}
public fun max_fee(): u64 {
abort 0
}
public fun max_fee_for(_arg0: u64): u64 {
abort 0
}
public fun request_withdraw(_arg0: Coin<AmnisApt>, _arg1: address): Object<WithdrawalToken> {
abort 0	
}
public fun router_address(): address {
abort 0
}
public fun stake(_arg0: Coin<AmnisApt>): Coin<StakedApt> {
abort 0
}
entry public fun stake_entry(_arg0: &signer, _arg1: u64, _arg2: address) {

}
public fun unstake(_arg0: Coin<StakedApt>): Coin<AmnisApt> {
abort 0
}
entry public fun unstake_entry(_arg0: &signer, _arg1: u64, _arg2: address) {

}
public fun withdraw(_arg0: &signer, _arg1: Object<WithdrawalToken>): Coin<AptosCoin> {
abort 0
}
entry public fun  withdraw_entry(_arg0: &signer, _arg1: Object<WithdrawalToken>) {

}
public fun withdraw_multi(_arg0: &signer, _arg1: vector<Object<WithdrawalToken>>): Coin<AptosCoin> {
abort 0
	
}
entry public fun withdraw_multi_entry(_arg0: &signer, _arg1: vector<Object<WithdrawalToken>>) {

}
}
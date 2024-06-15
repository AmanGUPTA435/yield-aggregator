module amnis::stapt_token {
// use 0000000000000000000000000000000000000000000000000000000000000001::account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin,BurnCapability,FreezeCapability,MintCapability};
use aptos_std::event::EventHandle;
// use 0000000000000000000000000000000000000000000000000000000000000001::option;
// use 0000000000000000000000000000000000000000000000000000000000000001::string;
// use aptos_framework::object;
use amnis::amapt_token::AmnisApt;
// use 0000000000000000000000000000000000000000000000000000000000000001::event;
// use amnis::package_manager;


struct BurnEvent has drop, store {
	amount: u64
}
struct MintEvent has drop, store {
	amount: u64
}
struct StakedApt has key {
	dummy_field: bool
}
struct StakedAptManagement has key {
	amapt: Coin<AmnisApt>,
	burn_cap: BurnCapability<StakedApt>,
	freeze_cap: FreezeCapability<StakedApt>,
	mint_cap: MintCapability<StakedApt>,
	mint_event: EventHandle<MintEvent>,
	burn_event: EventHandle<BurnEvent>
}

public(friend) fun add(_arg0: Coin<AmnisApt>) {
abort 0
}
public(friend) fun deposit(_arg0: Coin<AmnisApt>): Coin<StakedApt> {
abort 0
}
public(friend) fun initialize() {

}
public fun precision(): u128 {
abort 0
}
public fun precision_u64(): u64 {
abort 0
}
public fun stapt_price(): u64 {
abort 0
}
public fun total_amapt_staked(): u64 {
abort 0
}
public fun total_supply(): u128 {
abort 0
}
public(friend) fun unstake(_arg0: Coin<StakedApt>): Coin<AmnisApt> {
abort 0
}
}
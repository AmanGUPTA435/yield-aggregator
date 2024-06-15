// Move bytecode v6
module cellana::cellana_token {
use 0000000000000000000000000000000000000000000000000000000000000001::fungible_asset::{FungibleAsset,FungibleStore,BurnRef,MintRef,TransferRef};
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Object};
use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::primary_fungible_store;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
// use 0000000000000000000000000000000000000000000000000000000000000001::string;
// use cellana::package_manager;


struct CellanaToken has key {
	burn_ref: BurnRef,
	mint_ref: MintRef,
	transfer_ref: TransferRef
}

public fun balance(_arg0: address): u64 {
abort 0
}
public(friend) fun burn(_arg0: FungibleAsset) {
abort 0
}
public(friend) fun deposit<Ty0: key>(_arg0: Object<Ty0>, _arg1: FungibleAsset) {
abort 0
}
public(friend) fun disable_transfer<Ty0: key>(_arg0: Object<Ty0>) {
abort 0
}
entry public fun initialize() {

}
public fun is_initialized(): bool {
abort 0
}
public(friend) fun mint(_arg0: u64): FungibleAsset {
abort 0
}
public fun token(): Object<CellanaToken> {
abort 0
}
public fun token_address(): address {
abort 0
}
public fun total_supply(): u128 {
abort 0
}
public(friend) fun transfer<Ty0: key>(_arg0: Object<Ty0>, _arg1: Object<FungibleStore>, _arg2: u64) {
abort 0
}
public(friend) fun withdraw<Ty0: key>(_arg0: Object<Ty0>, _arg1: u64): FungibleAsset {
abort 0
}
}
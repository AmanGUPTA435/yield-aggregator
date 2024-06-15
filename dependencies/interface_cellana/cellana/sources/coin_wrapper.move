// Move bytecode v6
module cellana::coin_wrapper {
use 0000000000000000000000000000000000000000000000000000000000000001::account::SignerCapability;
// use 0000000000000000000000000000000000000000000000000000000000000001::aptos_account;
use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin};
use 0000000000000000000000000000000000000000000000000000000000000001::fungible_asset::{FungibleAsset,MintRef,BurnRef,TransferRef,Metadata};
use 0000000000000000000000000000000000000000000000000000000000000001::object::{Object};
// use 0000000000000000000000000000000000000000000000000000000000000001::option;
// use 0000000000000000000000000000000000000000000000000000000000000001::primary_fungible_store;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use 0000000000000000000000000000000000000000000000000000000000000001::smart_table::{SmartTable};
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};
// use 0000000000000000000000000000000000000000000000000000000000000001::string_utils;
// use 0000000000000000000000000000000000000000000000000000000000000001::type_info;
// use 4bf51972879e3b95c4781a5cdcb9e1ee24ef483e7d22f2d903626f126df62bd1::package_manager;


struct FungibleAssetData has store {
	metadata: Object<Metadata>,
	burn_ref: BurnRef,
	mint_ref: MintRef,
	transfer_ref: TransferRef
}
struct WrapperAccount has key {
	signer_cap: SignerCapability,
	coin_to_fungible_asset: SmartTable<String, FungibleAssetData>,
	fungible_asset_to_coin: SmartTable<Object<Metadata>, String>
}

public(friend) fun create_fungible_asset<Ty0>(): Object<Metadata> {
abort 0
}
public fun format_coin<Ty0>(): String {
abort 0
}
public fun format_fungible_asset(_arg0: Object<Metadata>): String {
abort 0
}
public fun get_coin_type(_arg0: Object<Metadata>): String {
abort 0
}
public fun get_original(_arg0: Object<Metadata>): String {
abort 0
}
public fun get_wrapper<Ty0>(): Object<Metadata> {
abort 0
}
entry public fun initialize() {

}
public fun is_initialized(): bool {
abort 0
}
public fun is_supported<Ty0>(): bool {
abort 0
}
public fun is_wrapper(_arg0: Object<Metadata>): bool {
abort 0
}
public(friend) fun unwrap<Ty0>(_arg0: FungibleAsset): Coin<Ty0> {
abort 0
}
public(friend) fun wrap<Ty0>(_arg0: Coin<Ty0>): FungibleAsset {
abort 0
}
public fun wrapper_address(): address {
abort 0
}
}
// Move bytecode v6
module amnis::package_manager {
use 0000000000000000000000000000000000000000000000000000000000000001::account::SignerCapability;
// use 0000000000000000000000000000000000000000000000000000000000000001::code;
// use 0000000000000000000000000000000000000000000000000000000000000001::resource_account;
use 0000000000000000000000000000000000000000000000000000000000000001::smart_table::{SmartTable};
use 0000000000000000000000000000000000000000000000000000000000000001::string::{String};


struct PermissionConfig has key {
	signer_cap: SignerCapability,
	addresses: SmartTable<String, address>
}

public(friend) fun add_address(_arg0: String, _arg1: address) {

}
public fun address_exists(_arg0: String): bool {
abort 0
}
public fun get_address(_arg0: String): address {
abort 0
}
public(friend) fun get_signer(): signer {
abort 0
}
fun init_module(_arg0: &signer) {

}
public(friend) fun upgrade(_arg0: vector<u8>, _arg1: vector<vector<u8>>) {

}
}
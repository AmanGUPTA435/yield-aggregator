// Move bytecode v5
module msglib::msglib_cap {
use 0000000000000000000000000000000000000000000000000000000000000001::acl::ACL;
// use 0000000000000000000000000000000000000000000000000000000000000001::error;
// use 0000000000000000000000000000000000000000000000000000000000000001::signer;
use layerzero_common::semver::{SemVer};

struct GlobalStore has key {
	last_version: SemVer,
	msglib_acl: ACL
}
struct MsgLibReceiveCapability has store {
	version: SemVer
}
struct MsgLibSendCapability has store {
	version: SemVer
}

entry public fun allow(_arg0: &signer, _arg1: address) {

}
public fun assert_receive_version(_arg0: &MsgLibReceiveCapability, _arg1: u64, _arg2: u8) {
abort 0
}
public fun assert_send_version(_arg0: &MsgLibSendCapability, _arg1: u64, _arg2: u8) {
abort 0
}
entry public fun disallow(_arg0: &signer, _arg1: address) {

}
fun init_module(_arg0: &signer) {

}
public fun new_version<Ty0>(_arg0: &signer, _arg1: bool): (SemVer , MsgLibSendCapability , MsgLibReceiveCapability) {
abort 0
}
public fun receive_version(_arg0: &MsgLibReceiveCapability): SemVer {
abort 0
}
public fun send_version(_arg0: &MsgLibSendCapability): SemVer {
abort 0
}
}
// Move bytecode v5
module executor::executor_cap {
// use 0000000000000000000000000000000000000000000000000000000000000001::error;
// use layerzero::utils;


struct ExecutorCapability has store {
	version: u64
}
struct GlobalStore has key {
	last_version: u64
}

public fun assert_version(_arg0: &ExecutorCapability, _arg1: u64) {

}
fun init_module(_arg0: &signer) {

}
public fun new_version(_arg0: &signer): (u64 , ExecutorCapability) {
abort 0
}
public fun version(_arg0: &ExecutorCapability): u64 {
abort 0
}
}
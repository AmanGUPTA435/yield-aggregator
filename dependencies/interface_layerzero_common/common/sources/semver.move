// Move bytecode v5
module layerzero_common::semver {
// use layerzero::utils;


struct SemVer has copy, drop, store {
	major: u64,
	minor: u8
}

public fun blocking_version(): SemVer {
abort 0
}
public fun build_version(_arg0: u64, _arg1: u8): SemVer {
abort 0
}
public fun default_version(): SemVer {
abort 0
}
public fun is_blocking(_arg0: &SemVer): bool {
abort 0
}
public fun is_blocking_or_default(_arg0: &SemVer): bool {
abort 0
}
public fun is_default(_arg0: &SemVer): bool {
abort 0
}
public fun major(_arg0: &SemVer): u64 {
abort 0
}
public fun minor(_arg0: &SemVer): u8 {
abort 0
}
public fun next_major(_arg0: &SemVer): SemVer {
abort 0
}
public fun next_minor(_arg0: &SemVer): SemVer {
abort 0
}
public fun values(_arg0: &SemVer): (u64 , u8) {
abort 0
}
}
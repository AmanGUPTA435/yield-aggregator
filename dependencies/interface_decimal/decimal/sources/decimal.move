// Move bytecode v6
module decimal::decimal {
// use aries::u128_math;


struct Decimal has copy, drop, store {
	val: u128
}

public fun add(_arg0: Decimal, _arg1: Decimal): Decimal {
abort 0
}
public fun as_percentage(_arg0: Decimal): u128 {
abort 0
}
public fun as_u128(_arg0: Decimal): u128 {
abort 0
}
public fun as_u64(_arg0: Decimal): u64 {
abort 0
}
public fun ceil(_arg0: Decimal): Decimal {
abort 0
}
public fun ceil_u64(_arg0: Decimal): u64 {
abort 0
}
public fun div(_arg0: Decimal, _arg1: Decimal): Decimal {
abort 0
}
public fun div_u128(_arg0: Decimal, _arg1: u128): Decimal {
abort 0
}
public fun div_u64(_arg0: Decimal, _arg1: u64): Decimal {
abort 0
}
public fun eq(_arg0: Decimal, _arg1: Decimal): bool {
abort 0
}
public fun floor(_arg0: Decimal): Decimal {
abort 0
}
public fun floor_u64(_arg0: Decimal): u64 {
abort 0
}
public fun from_bips(_arg0: u128): Decimal {
abort 0
}
public fun from_millionth(_arg0: u128): Decimal {
abort 0
}
public fun from_percentage(_arg0: u128): Decimal {
abort 0
}
public fun from_scaled_val(_arg0: u128): Decimal {
abort 0
}
public fun from_u128(_arg0: u128): Decimal {
abort 0
}
public fun from_u64(_arg0: u64): Decimal {
abort 0
}
public fun from_u8(_arg0: u8): Decimal {
abort 0
}
public fun gt(_arg0: Decimal, _arg1: Decimal): bool {
abort 0
}
public fun gte(_arg0: Decimal, _arg1: Decimal): bool {
abort 0
}
public fun half(): Decimal {
abort 0
}
public fun hundredth(): Decimal {
abort 0
}
public fun lt(_arg0: Decimal, _arg1: Decimal): bool {
abort 0
}
public fun lte(_arg0: Decimal, _arg1: Decimal): bool {
abort 0
}
public fun max(_arg0: Decimal, _arg1: Decimal): Decimal {
abort 0
}
public fun min(_arg0: Decimal, _arg1: Decimal): Decimal {
abort 0
}
public fun mul(_arg0: Decimal, _arg1: Decimal): Decimal {
abort 0
}
public fun mul_div(_arg0: Decimal, _arg1: Decimal, _arg2: Decimal): Decimal {
abort 0
}
public fun mul_u128(_arg0: Decimal, _arg1: u128): Decimal {
abort 0
}
public fun mul_u64(_arg0: Decimal, _arg1: u64): Decimal {
abort 0
}
public fun one(): Decimal {
abort 0
}
public fun raw(_arg0: Decimal): u128 {
abort 0
}
public fun round(_arg0: Decimal): Decimal {
abort 0
}
public fun round_u64(_arg0: Decimal): u64 {
abort 0
}
public fun scaling_factor(): u128 {
abort 0
}
public fun sub(_arg0: Decimal, _arg1: Decimal): Decimal {
abort 0
}
public fun tenth(): Decimal {
abort 0
}
public fun zero(): Decimal {
abort 0
}
}
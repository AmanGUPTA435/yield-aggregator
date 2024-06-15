/// Implementation of FixedPoint u64 in Move language.
module fixed_point64::fixed_point64 {
    // Error codes.

    /// When divide by zero attempted.
    const ERR_DIVIDE_BY_ZERO: u64 = 0;

    /// When divisor is too small that will cause overflow
    const ERR_DIVISOR_TOO_SMALL: u64 = 1;
    
    /// When divide result is too large that will cause overflow
    const ERR_DIVIDE_RESULT_TOO_LARGE: u64 = 2;

    /// 2^64 == 1 << 64
    const TWO_POW_64: u128 = 1 << 64;

    /// 2^32 == 1 << 32
    const TWO_POW_32: u128 = 1 << 32;

    /// When a and b are equals.
    const EQUAL: u8 = 0;

    /// When a is less than b equals.
    const LESS_THAN: u8 = 1;

    /// When a is greater than b.
    const GREATER_THAN: u8 = 2;

    /// The resource to store `FixedPoint64`.
    struct FixedPoint64 has copy, store, drop {
        v: u128
    }

    /// Encode `u64` to `FixedPoint64`
    public fun encode(_x: u64): FixedPoint64 {
        abort 0
    }

    /// Decode a `FixedPoint64` into a `u64` by rounding to nearest integer
    /// This should be the default way to convert back to integer
    /// Unless you have a good reason to round up or down
    public fun decode(_fp: FixedPoint64): u64 {
        abort 0
    }
    
    /// Decode a `FixedPoint64` into a `u64` by rounding down
    public fun decode_round_down(_fp: FixedPoint64): u64 {
        abort 0
    }

    /// Decode a `FixedPoint64` into a `u64` by rounding up
    public fun decode_round_up(_fp: FixedPoint64): u64 {
        abort 0
    }

    /// Get `u128` (raw value) from FixedPoint64
    public fun to_u128(_fp: FixedPoint64): u128 {
        abort 0
    }
    
    /// Convert from `u128` (raw value) to FixedPoint64
    public fun from_u128(_v: u128): FixedPoint64 {
        abort 0
    }

    /// Get integer "one" in FixedPoint64
    public fun one(): FixedPoint64 {
        abort 0
    }
    
    /// Get integer "zero" in FixedPoint64
    public fun zero(): FixedPoint64 {
        abort 0
    }

    /// Multiply a `FixedPoint64` by a `u64`, returning a `FixedPoint64`
    public fun mul(_fp: FixedPoint64, _y: u64): FixedPoint64 {
        abort 0
    }

    /// Divide a `FixedPoint64` by a `u64`, returning a `FixedPoint64`.
    public fun div(_fp: FixedPoint64, _y: u64): FixedPoint64 {
        abort 0
    }

    /// Add a `FixedPoint64` and a `u64`, returning a `FixedPoint64`
    public fun add(_fp: FixedPoint64, _y: u64): FixedPoint64 {
        abort 0
    }

    /// Subtract `FixedPoint64` by a `u64`, returning a `FixedPoint64`
    public fun sub(_fp: FixedPoint64, _y: u64): FixedPoint64 {
       abort 0
    }
    spec sub {
        aborts_if _fp.v < (_y << 64);
    }

    /// Add a `FixedPoint64` and a `FixedPoint64`, returning a `FixedPoint64`
    public fun add_fp(_a: FixedPoint64, _b: FixedPoint64): FixedPoint64 {
        abort 0
    }

    /// Subtract `FixedPoint64` by a `FixedPoint64`, returning a `FixedPoint64`
    public fun sub_fp(_a: FixedPoint64, _b: FixedPoint64): FixedPoint64 {
        abort 0
    }
    spec sub_fp {
        aborts_if _a.v < _b.v;
    }

    /// Multiply a `FixedPoint64` by a `FixedPoint64`, returning a `FixedPoint64`
    /// To avoid overflow, the result must be smaller than MAX_U64
    public fun mul_fp(_a: FixedPoint64, _b: FixedPoint64): FixedPoint64 {
        abort 0
    }

    
    /// Divide a `FixedPoint64` by a `FixedPoint64`, returning a `FixedPoint64`.
    /// To avoid overflow, the result must be smaller than MAX_U64
    public fun div_fp(_a: FixedPoint64, _b: FixedPoint64): FixedPoint64 {
        abort 0
    }

    /// Returns a `FixedPoint64` which represents the ratio of the numerator to the denominator.
    public fun fraction(_numerator: u64, _denominator: u64): FixedPoint64 {
        abort 0
    }
    spec fraction {
        aborts_if _denominator == 0 with ERR_DIVIDE_BY_ZERO;
        ensures result.v == (_numerator << 64) / _denominator;
    }

    /// Compare two `FixedPoint64` numbers.
    public fun compare(_left: &FixedPoint64, _right: &FixedPoint64): u8 {
        abort 0
    }
    spec compare {
        ensures _left.v == _right.v ==> result == EQUAL;
        ensures _left.v < _right.v ==> result == LESS_THAN;
        ensures _left.v > _right.v ==> result == GREATER_THAN;
    }

    /// Less than
    public fun lt(_left: &FixedPoint64, _right: &FixedPoint64): bool {
        abort 0
    }

    /// Greater than
    public fun gt(_left: &FixedPoint64, _right: &FixedPoint64): bool {
        abort 0
    }

    /// Less or equal than
    public fun lte(_left: &FixedPoint64, _right: &FixedPoint64): bool {
       abort 0
    }

    /// Greater or equal than
    public fun gte(_left: &FixedPoint64, _right: &FixedPoint64): bool {
        abort 0
    }

    /// Equal than
    public fun eq(_left: &FixedPoint64, _right: &FixedPoint64): bool {
        abort 0
    }

    /// Check if `FixedPoint64` is zero
    public fun is_zero(_fp: &FixedPoint64): bool {
        abort 0
    }
    spec is_zero {
        ensures _fp.v == 0 ==> result == true;
        ensures _fp.v > 0 ==> result == false;
    }

    public fun min(_a: &FixedPoint64, _b: &FixedPoint64): &FixedPoint64 {
        abort 0
    }
    
    public fun max(_a: &FixedPoint64, _b: &FixedPoint64): &FixedPoint64 {
        abort 0
    }
}
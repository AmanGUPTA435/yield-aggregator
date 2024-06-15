module thala_oracle::math {
    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    /// returns 10 to the power of n
    public fun pow10(n: u64): u64 {
        if (n == 0) {
            1
        } else if (n == 1) {
            10
        } else if (n == 2) {
            100
        } else if (n == 3) {
            1000
        } else if (n == 4) {
            10000
        } else if (n == 5) {
            100000
        } else if (n == 6) {
            1000000
        } else if (n == 7) {
            10000000
        } else if (n == 8) {
            100000000
        } else if (n == 9) {
            1000000000
        } else if (n == 10) {
            10000000000
        } else {
            10000000000 * pow10(n - 10)
        }
    }
    spec pow10 {
        // opaque is required for recursive function
        // otherwise move prover will complain even if we don't prove anything here
        pragma opaque;
    }

    // check the relative difference between new_price and old_price is greater or equal than price_deviate_reject_pct
    // If old_price is 0, it means old_price is not available and the function will return false
    public fun deviate_largely_from_old_price(
        price_deviate_reject_pct: u64,
        new_price: FixedPoint64,
        old_price: FixedPoint64
    ): bool {
        fixed_point64::to_u128(old_price) > 0 && get_price_diff_pct(new_price, old_price) >= price_deviate_reject_pct
    }

    // Get the difference between two prices new_price and old_price in percentage. Result is rounded to nearest integer
    fun get_price_diff_pct(new_price: FixedPoint64, old_price: FixedPoint64): u64 {
        if (fixed_point64::gt(&new_price, &old_price)) {
            fixed_point64::decode(fixed_point64::mul(fixed_point64::div_fp(fixed_point64::sub_fp(new_price, old_price), old_price), 100))
        } else if (fixed_point64::lt(&new_price, &old_price)) {
            fixed_point64::decode(fixed_point64::mul(fixed_point64::div_fp(fixed_point64::sub_fp(old_price, new_price), old_price), 100))
        } else {
            0
        }
    }
}

module multihop_swap_router::router {
    use std::signer;
    use std::vector;
    use aptos_std::math64;
    use aptos_std::type_info;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::resource_account;
    use fixed_point64::fixed_point64;
    use thalaswap::base_pool;
    use thalaswap::stable_pool;
    use thalaswap::weighted_pool;
    use thalaswap_math::stable_math;
    use thalaswap_math::weighted_math;

    const STABLE_POOL_MAX_SUPPORTED_DECIMALS: u8 = 8;
    const EXACT_OUT_ERROR_TOLERANCE_BPS: u64 = 1; // 0.01%
    const BPS_BASE: u64 = 10000;

    const ERR_MULTIHOP_POOL_NOT_EXIST: u64 = 1;
    const ERR_MULTIHOP_INSUFFICIENT_OUTPUT: u64 = 2;
    const ERR_MULTIHOP_INSUFFICIENT_INPUT: u64 = 3;
    const ERR_MULTIHOP_WEIGHTED_POOL_INSUFFICIENT_LIQUIDITY: u64 = 4;
    const ERR_MULTIHOP_STABLE_POOL_INSUFFICIENT_LIQUIDITY: u64 = 5;
    const ERR_MULTIHOP_INVALID_ASSET_INDEX: u64 = 6;
    const ERR_MULTIHOP_EXACT_OUT_ERROR_TOLERANCE_EXCEEDED: u64 = 7;

    fun init_module(resource_account: &signer) {
        // retrieve the `signer_cap` and rotate the resource account's authentication key to `0x0`, effectively locking it off
        resource_account::retrieve_resource_account_cap(resource_account, @multihop_swap_router_deployer);
    }

    /// A0, A1, A2, A3, W0, W1, W2, W3 identifies the first pool
    /// B0, B1, B2, B3, X0, X1, X2, X3 identifies the second pool
    /// Stable pool does not have weight types, so if all 4 weight types W0, W1, W2, W3 are zero, then it is a stable pool
    /// I is the input token type
    /// O is the output token type
    /// M is the intermediate token type
    public entry fun swap_exact_in_2<A0, A1, A2, A3, W0, W1, W2, W3, B0, B1, B2, B3, X0, X1, X2, X3, I, M, O>(account: &signer, amount_in: u64, min_amount_out: u64) {
        let coin_in = coin::withdraw<I>(account, amount_in);
        let coin_mid = check_and_swap<A0, A1, A2, A3, W0, W1, W2, W3, I, M>(coin_in);
        let coin_out = check_and_swap<B0, B1, B2, B3, X0, X1, X2, X3, M, O>(coin_mid);
        assert!(coin::value(&coin_out) >= min_amount_out, ERR_MULTIHOP_INSUFFICIENT_OUTPUT);

        coin::register<O>(account);
        coin::deposit<O>(signer::address_of(account), coin_out);
    }
    
    /// A0, A1, A2, A3, W0, W1, W2, W3 identifies the first pool
    /// B0, B1, B2, B3, X0, X1, X2, X3 identifies the second pool
    /// C0, C1, C2, C3, Y0, Y1, Y2, Y3 identifies the third pool
    /// I is the input token type
    /// O is the output token type
    /// M1 is the 1st intermediate token type
    /// M2 is the 2nd intermediate token type
    public entry fun swap_exact_in_3<A0, A1, A2, A3, W0, W1, W2, W3, B0, B1, B2, B3, X0, X1, X2, X3, C0, C1, C2, C3, Y0, Y1, Y2, Y3, I, M1, M2, O>(account: &signer, amount_in: u64, min_amount_out: u64) {
        let coin_in = coin::withdraw<I>(account, amount_in);
        let coin_mid_1 = check_and_swap<A0, A1, A2, A3, W0, W1, W2, W3, I, M1>(coin_in);
        let coin_mid_2 = check_and_swap<B0, B1, B2, B3, X0, X1, X2, X3, M1, M2>(coin_mid_1);
        let coin_out = check_and_swap<C0, C1, C2, C3, Y0, Y1, Y2, Y3, M2, O>(coin_mid_2);
        assert!(coin::value(&coin_out) >= min_amount_out, ERR_MULTIHOP_INSUFFICIENT_OUTPUT);

        coin::register<O>(account);
        coin::deposit<O>(signer::address_of(account), coin_out);
    }

    /// A0, A1, A2, A3, W0, W1, W2, W3 identifies the first pool
    /// B0, B1, B2, B3, X0, X1, X2, X3 identifies the second pool
    /// Stable pool does not have weight types, so if all 4 weight types W0, W1, W2, W3 are zero, then it is a stable pool
    /// I is the input token type
    /// O is the output token type
    /// M is the intermediate token type
    /// This function computes the expected amount of input token needed to get the desired output token amount
    /// And then perform "exact-in" type of swap using the computed amount
    public entry fun swap_exact_out_2<A0, A1, A2, A3, W0, W1, W2, W3, B0, B1, B2, B3, X0, X1, X2, X3, I, M, O>(account: &signer, max_amount_in: u64, amount_out: u64) {
        let first_is_weighted = is_weighted_pool<W0, W1, W2, W3>();
        let second_is_weighted = is_weighted_pool<X0, X1, X2, X3>();

        // First, calculate the amount of input token needed to get the desired output token amount
        let amount_mid = calc_in_given_out<B0, B1, B2, B3, X0, X1, X2, X3, M, O>(amount_out, second_is_weighted);
        let amount_in = calc_in_given_out<A0, A1, A2, A3, W0, W1, W2, W3, I, M>(amount_mid, first_is_weighted);

        assert!(amount_in <= max_amount_in, ERR_MULTIHOP_INSUFFICIENT_INPUT);

        // Then, use "exact in" method to perform the swap. No need to check pool existence again.
        let coin_mid = swap<A0, A1, A2, A3, W0, W1, W2, W3, I, M>(coin::withdraw<I>(account, amount_in), first_is_weighted);
        let coin_out = swap<B0, B1, B2, B3, X0, X1, X2, X3, M, O>(coin_mid, second_is_weighted);

        // Due to numerical errors, the actual output amount may be slightly different from the desired output amount
        // If actual output amount >= (1 - tolerance) * desired output amount, we accept the output amount
        // Otherwise, we abort the transaction
        // This way, users can be sure that they will get at least the desired amount (by a small margin)
        // The excess amount will be limited by user's slippage setting 
        let accept_lower_bound = math64::mul_div(amount_out, BPS_BASE - EXACT_OUT_ERROR_TOLERANCE_BPS, BPS_BASE);
        assert!(coin::value(&coin_out) >= accept_lower_bound, ERR_MULTIHOP_EXACT_OUT_ERROR_TOLERANCE_EXCEEDED);
        
        coin::register<O>(account);
        coin::deposit<O>(signer::address_of(account), coin_out);
    }

    /// A0, A1, A2, A3, W0, W1, W2, W3 identifies the first pool
    /// B0, B1, B2, B3, X0, X1, X2, X3 identifies the second pool
    /// C0, C1, C2, C3, Y0, Y1, Y2, Y3 identifies the third pool
    /// I is the input token type
    /// O is the output token type
    /// M1 is the 1st intermediate token type
    /// M2 is the 2nd intermediate token type
    /// This function computes the expected amount of input token needed to get the desired output token amount
    /// And then perform "exact-in" type of swap using the computed amount
    public entry fun swap_exact_out_3<A0, A1, A2, A3, W0, W1, W2, W3, B0, B1, B2, B3, X0, X1, X2, X3, C0, C1, C2, C3, Y0, Y1, Y2, Y3, I, M1, M2, O>(account: &signer, max_amount_in: u64, amount_out: u64) {
        let first_is_weighted = is_weighted_pool<W0, W1, W2, W3>();
        let second_is_weighted = is_weighted_pool<X0, X1, X2, X3>();
        let third_is_weighted = is_weighted_pool<Y0, Y1, Y2, Y3>();

        // First, calculate the amount of input token needed to get the desired output token amount
        let amount_mid_2 = calc_in_given_out<C0, C1, C2, C3, Y0, Y1, Y2, Y3, M2, O>(amount_out, third_is_weighted);
        let amount_mid_1 = calc_in_given_out<B0, B1, B2, B3, X0, X1, X2, X3, M1, M2>(amount_mid_2, second_is_weighted);
        let amount_in = calc_in_given_out<A0, A1, A2, A3, W0, W1, W2, W3, I, M1>(amount_mid_1, first_is_weighted);

        assert!(amount_in <= max_amount_in, ERR_MULTIHOP_INSUFFICIENT_INPUT);

        // Then, use "exact in" method to perform the swap. No need to check pool existence again.
        let coin_mid_1 = swap<A0, A1, A2, A3, W0, W1, W2, W3, I, M1>(coin::withdraw<I>(account, amount_in), first_is_weighted);
        let coin_mid_2 = swap<B0, B1, B2, B3, X0, X1, X2, X3, M1, M2>(coin_mid_1, second_is_weighted);
        let coin_out = swap<C0, C1, C2, C3, Y0, Y1, Y2, Y3, M2, O>(coin_mid_2, third_is_weighted);

        // Handle numerical errors, same as swap_exact_out_2
        let accept_lower_bound = math64::mul_div(amount_out, BPS_BASE - EXACT_OUT_ERROR_TOLERANCE_BPS, BPS_BASE);
        assert!(coin::value(&coin_out) >= accept_lower_bound, ERR_MULTIHOP_EXACT_OUT_ERROR_TOLERANCE_EXCEEDED);

        coin::register<O>(account);
        coin::deposit<O>(signer::address_of(account), coin_out);
    }

    fun calc_in_given_out_weighted<A0, A1, A2, A3, W0, W1, W2, W3, I, O>(amount_out: u64): u64 {
        let typeof_input = type_info::type_of<I>();
        let typeof_output = type_info::type_of<O>();

        let typeof_0 = type_info::type_of<A0>();
        let typeof_1 = type_info::type_of<A1>();
        let typeof_2 = type_info::type_of<A2>();
        let typeof_3 = type_info::type_of<A3>();
        let (is_in_0, is_in_1, is_in_2, is_in_3) = (typeof_input == typeof_0, typeof_input == typeof_1, typeof_input == typeof_2, typeof_input == typeof_3);
        let (is_out_0, is_out_1, is_out_2, is_out_3) = (typeof_output == typeof_0, typeof_output == typeof_1, typeof_output == typeof_2, typeof_output == typeof_3);

        let idx_in = if (is_in_0) 0 else if (is_in_1) 1 else if (is_in_2) 2 else if (is_in_3) 3 else { abort ERR_MULTIHOP_INVALID_ASSET_INDEX };
        let idx_out = if (is_out_0) 0 else if (is_out_1) 1 else if (is_out_2) 2 else if (is_out_3) 3 else { abort ERR_MULTIHOP_INVALID_ASSET_INDEX };

        let (balances, weights) = weighted_pool::pool_balances_and_weights<A0, A1, A2, A3, W0, W1, W2, W3>();

        assert!(amount_out < *vector::borrow(&balances, idx_out), ERR_MULTIHOP_WEIGHTED_POOL_INSUFFICIENT_LIQUIDITY);

        // Same logic as in weighted_pool::swap_exact_out
        let amount_in_post_fee = weighted_math::calc_in_given_out_weights_u64(idx_in, idx_out, amount_out, &balances, &weights);
        fixed_point64::decode_round_up(fixed_point64::mul(weighted_pool::inverse_negated_swap_fee_ratio<A0, A1, A2, A3, W0, W1, W2, W3>(), amount_in_post_fee))
    }

    fun calc_in_given_out_stable<A0, A1, A2, A3, I, O>(amount_out: u64): u64 {
        let typeof_input = type_info::type_of<I>();
        let typeof_output = type_info::type_of<O>();

        let typeof_0 = type_info::type_of<A0>();
        let typeof_1 = type_info::type_of<A1>();
        let typeof_2 = type_info::type_of<A2>();
        let typeof_3 = type_info::type_of<A3>();
        let (is_in_0, is_in_1, is_in_2, is_in_3) = (typeof_input == typeof_0, typeof_input == typeof_1, typeof_input == typeof_2, typeof_input == typeof_3);
        let (is_out_0, is_out_1, is_out_2, is_out_3) = (typeof_output == typeof_0, typeof_output == typeof_1, typeof_output == typeof_2, typeof_output == typeof_3);

        let idx_in = if (is_in_0) 0 else if (is_in_1) 1 else if (is_in_2) 2 else if (is_in_3) 3 else { abort ERR_MULTIHOP_INVALID_ASSET_INDEX };
        let idx_out = if (is_out_0) 0 else if (is_out_1) 1 else if (is_out_2) 2 else if (is_out_3) 3 else { abort ERR_MULTIHOP_INVALID_ASSET_INDEX };

        let normalized_balances = stable_pool::pool_balances<A0, A1, A2, A3>();
        let normalized_amount_out = amount_out * precision_multiplier<O>();

        assert!(normalized_amount_out < *vector::borrow(&normalized_balances, idx_out), ERR_MULTIHOP_STABLE_POOL_INSUFFICIENT_LIQUIDITY);
        
        // Same logic as in stable_pool::swap_exact_out
        let normalized_amount_in_post_fee = stable_math::calc_in_given_out(stable_pool::pool_amp_factor<A0, A1, A2, A3>(), idx_in, idx_out, normalized_amount_out, &normalized_balances);
        let amount_in_post_fee = normalized_amount_in_post_fee / precision_multiplier<I>();
        fixed_point64::decode(fixed_point64::mul(stable_pool::inverse_negated_swap_fee_ratio<A0, A1, A2, A3>(), amount_in_post_fee))
    }

    inline fun calc_in_given_out<A0, A1, A2, A3, W0, W1, W2, W3, I, O>(amount_out: u64, is_weighted: bool): u64 {
        if (is_weighted && weighted_pool::weighted_pool_exists<A0, A1, A2, A3, W0, W1, W2, W3>()) {
            calc_in_given_out_weighted<A0, A1, A2, A3, W0, W1, W2, W3, I, O>(amount_out)
        } 
        else if (!is_weighted && stable_pool::stable_pool_exists<A0, A1, A2, A3>()) {
            calc_in_given_out_stable<A0, A1, A2, A3, I, O>(amount_out)
        }
        else {
            abort ERR_MULTIHOP_POOL_NOT_EXIST
        }
    }

    /// we only need to check the first type arg to decide if we use weighted pool swap path
    inline fun is_weighted_pool<W0, W1, W2, W3>(): bool {
        !base_pool::is_null<W0>()
    }

    /// check_and_swap checks the pool type and performs one hop swap
    /// A0, A1, A2, A3, W0, W1, W2, W3 identifies pool
    /// I is the input token type
    /// O is the output token type
    inline fun check_and_swap<A0, A1, A2, A3, W0, W1, W2, W3, I, O>(coin_in: Coin<I>): Coin<O> {
        if (is_weighted_pool<W0, W1, W2, W3>()) {
            assert!(weighted_pool::weighted_pool_exists<A0, A1, A2, A3, W0, W1, W2, W3>(), ERR_MULTIHOP_POOL_NOT_EXIST);
            weighted_pool::swap_exact_in<A0, A1, A2, A3, W0, W1, W2, W3, I, O>(coin_in)
        } else {
            assert!(stable_pool::stable_pool_exists<A0, A1, A2, A3>(), ERR_MULTIHOP_POOL_NOT_EXIST);
            stable_pool::swap_exact_in<A0, A1, A2, A3, I, O>(coin_in)
        }
    }

    // swap without checking whether pool exists
    inline fun swap<A0, A1, A2, A3, W0, W1, W2, W3, I, O>(coin_in: Coin<I>, is_weighted: bool): Coin<O> {
        if (is_weighted) {
            weighted_pool::swap_exact_in<A0, A1, A2, A3, W0, W1, W2, W3, I, O>(coin_in)
        } else {
            stable_pool::swap_exact_in<A0, A1, A2, A3, I, O>(coin_in)
        }
    }

    inline fun abs_diff(a: u64, b: u64): u64 {
        if (a > b) {
            a - b
        } else {
            b - a
        }
    }

    inline fun precision_multiplier<CoinType>(): u64 {
        math64::pow(10, (STABLE_POOL_MAX_SUPPORTED_DECIMALS - coin::decimals<CoinType>() as u64))
    }

    #[test_only]
    use test_utils::coin_test;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    struct A {}
    #[test_only]
    struct B {}
    #[test_only]
    struct C {}

    #[test]
    fun precision_multiplier_ok() {
        let account = &account::create_account_for_test(@multihop_swap_router);
        coin_test::initialize_fake_coin_with_decimals<A>(account, 6);
        coin_test::initialize_fake_coin_with_decimals<B>(account, 7);
        coin_test::initialize_fake_coin_with_decimals<C>(account, 8);
        
        assert!(precision_multiplier<A>() == 100, 0);
        assert!(precision_multiplier<B>() == 10, 0);
        assert!(precision_multiplier<C>() == 1, 0);
    }
}

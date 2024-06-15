module thala_launch::lbp_scripts {
    use std::signer;

    use aptos_framework::coin;

    use thala_launch::lbp;
    use thalaswap::weighted_pool;
    use aptos_framework::aptos_coin::AptosCoin;
    use thalaswap::base_pool;
    use thalaswap::weighted_pool::Weight_50;
    use liquidswap::curves;
    use liquidswap::router_v2;
    use pancake::router;
    use pancake::swap;
    use pancake::swap_utils;

    // Error codes
    const ERR_LBP_INSUFFICIENT_OUTPUT: u64 = 0;

    // only whitelisted address for the specific pair can do so
    public entry fun create_lbp<Asset0, Asset1>(
        creator: &signer,
        asset_0_amount: u64,
        asset_1_amount: u64,
        start_weight_0: u64,
        end_weight_0: u64,
        swap_fee_bps: u64,
        start_timestamp_seconds: u64,
        end_timestamp_seconds: u64
    ) {
        let asset_0_coin = coin::withdraw<Asset0>(creator, asset_0_amount);
        let asset_1_coin = coin::withdraw<Asset1>(creator, asset_1_amount);

        // create_lbp inherently checks is creator has permissions to create pool
        lbp::create_lbp<Asset0, Asset1>(
            creator,
            asset_0_coin,
            asset_1_coin,
            start_weight_0,
            end_weight_0,
            swap_fee_bps,
            start_timestamp_seconds,
            end_timestamp_seconds
        );
    }
    
    // only pool owner can do so
    public entry fun close_lbp<Asset0, Asset1>(creator: &signer) {
        let account_addr = signer::address_of(creator);
        let (output_coin_0, output_coin_1) = lbp::close_lbp<Asset0, Asset1>(creator);

        coin::deposit<Asset0>(account_addr, output_coin_0);
        coin::deposit<Asset1>(account_addr, output_coin_1);
    }

    public entry fun swap_exact_in<Asset0, Asset1, In, Out>(account: &signer, creator_addr: address, amount_in: u64, min_amount_out: u64) {
        let coin_in = coin::withdraw<In>(account, amount_in);
        let coin_out = lbp::swap_exact_in<Asset0, Asset1, In, Out>(creator_addr, coin_in);
        assert!(coin::value(&coin_out) >= min_amount_out, ERR_LBP_INSUFFICIENT_OUTPUT);
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<Out>(account_addr)) coin::register<Out>(account);
        coin::deposit(account_addr, coin_out);
    }

    public entry fun swap_exact_out<Asset0, Asset1, In, Out>(account: &signer, creator_addr: address, amount_in: u64, amount_out: u64) {
        let coin_in = coin::withdraw<In>(account, amount_in);
        let (refunded_in, out) = lbp::swap_exact_out<Asset0, Asset1, In, Out>(creator_addr, coin_in, amount_out);
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<Out>(account_addr)) coin::register<Out>(account);
        coin::deposit(account_addr, refunded_in);
        coin::deposit(account_addr, out);
    }

    // A special entry that allows users buy distrited token (Asset0) using APT rather than acquired token (Asset1, such as USDC)
    // Basically a 2-hop swap:
    // (1) swap APT to Asset0 via ThalaSwap APT(50%)-Asset0(50%) pool
    // (2) swap Asset0 to Asset1 via lbp
    public entry fun swap_exact_in_apt_thalaswap<Asset0, Asset1>(account: &signer, creator_addr: address, amount_in: u64, min_amount_out: u64) {
        let apt_in = coin::withdraw<AptosCoin>(account, amount_in);
        let coin_in = weighted_pool::swap_exact_in<AptosCoin, Asset0, base_pool::Null, base_pool::Null, Weight_50, Weight_50, base_pool::Null, base_pool::Null, AptosCoin, Asset0>(apt_in);
        let coin_out = lbp::swap_exact_in<Asset0, Asset1, Asset0, Asset1>(creator_addr, coin_in);
        assert!(coin::value(&coin_out) >= min_amount_out, ERR_LBP_INSUFFICIENT_OUTPUT);
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<Asset1>(account_addr)) coin::register<Asset1>(account);
        coin::deposit(account_addr, coin_out);
    }

    // Similar to swap_exact_in_apt_thalaswap, but through a liquidswap pool
    public entry fun swap_exact_in_apt_liquidswap<Asset0, Asset1>(account: &signer, creator_addr: address, amount_in: u64, min_amount_out: u64) {
        let apt_in = coin::withdraw<AptosCoin>(account, amount_in);
        let coin_in = router_v2::swap_exact_coin_for_coin<AptosCoin, Asset0, curves::Uncorrelated>(apt_in, 0);
        let coin_out = lbp::swap_exact_in<Asset0, Asset1, Asset0, Asset1>(creator_addr, coin_in);
        assert!(coin::value(&coin_out) >= min_amount_out, ERR_LBP_INSUFFICIENT_OUTPUT);
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<Asset1>(account_addr)) coin::register<Asset1>(account);
        coin::deposit(account_addr, coin_out);
    }

    // Similar to swap_exact_in_apt_thalaswap, but through a pancakeswap pool
    // Note that pancakeswap doesn't provide accessible entry function (coin_in: Coin<X>, amount_in: u64) -> (coin_out: Coin<Y>)
    // That's why we have to precompute output amount when swapping from APT
    public entry fun swap_exact_in_apt_pancakeswap<Asset0, Asset1>(account: &signer, creator_addr: address, amount_in: u64, min_amount_out: u64) {
        // precompute output amount
        let (reserve_apt, reserve_asset0) =
            if (swap_utils::sort_token_type<AptosCoin, Asset0>()) {
                let (reserve_apt, reserve_asset0, _) = swap::token_reserves<AptosCoin, Asset0>();
                (reserve_apt, reserve_asset0)
            } else {
                let (reserve_asset0, reserve_apt, _) = swap::token_reserves<Asset0, AptosCoin>();
                (reserve_apt, reserve_asset0)
            };
        let asset0_out = swap_utils::get_amount_out(amount_in, reserve_apt, reserve_asset0);

        // swap APT to asset0
        router::swap_exact_input<AptosCoin, Asset0>(account, amount_in, 0);

        // extract precomputed asset0_out from account
        let coin_in = coin::withdraw<Asset0>(account, asset0_out);

        // lbp swap
        let coin_out = lbp::swap_exact_in<Asset0, Asset1, Asset0, Asset1>(creator_addr, coin_in);
        assert!(coin::value(&coin_out) >= min_amount_out, ERR_LBP_INSUFFICIENT_OUTPUT);
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<Asset1>(account_addr)) coin::register<Asset1>(account);
        coin::deposit(account_addr, coin_out);
    }
}

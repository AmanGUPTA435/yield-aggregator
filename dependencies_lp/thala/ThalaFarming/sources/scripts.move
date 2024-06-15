module thala_farming::scripts {

    use aptos_std::type_info;
    use aptos_framework::coin;
    use thala_farming::farming;
    use std::signer;

    use thl_coin_alias::thl_coin::THL;

    struct Null {}

    public entry fun stake<StakeCoin>(user: &signer, pid: u64, amount: u64) {
        let coin = coin::withdraw<StakeCoin>(user, amount);
        let reward = farming::stake(user, pid, coin);

        try_register<THL>(user);
        coin::deposit(signer::address_of(user), reward);
    }

    public entry fun unstake<StakeCoin>(user: &signer, pid: u64, amount: u64) {
        let (unstaked, reward) = farming::unstake<StakeCoin>(user, pid, amount);
        coin::deposit(signer::address_of(user), unstaked);

        try_register<THL>(user);
        coin::deposit(signer::address_of(user), reward);
    }

    public entry fun claim_all_thl(user: &signer) {
        let reward = farming::claim_all_thl(user);

        try_register<THL>(user);
        coin::deposit(signer::address_of(user), reward);
    }

    public entry fun claim<StakeCoin, ExtraRewardCoin1, ExtraRewardCoin2>(user: &signer, pid: u64) {
        let thl_reward = farming::claim_thl<StakeCoin>(user, pid);
        try_register<THL>(user);
        coin::deposit(signer::address_of(user), thl_reward);

        if (!is_null<ExtraRewardCoin1>()) {
            let extra_reward = farming::claim_extra_reward<StakeCoin, ExtraRewardCoin1>(user, pid);
            try_register<ExtraRewardCoin1>(user);
            coin::deposit(signer::address_of(user), extra_reward);
        };

        if (!is_null<ExtraRewardCoin2>()) {
            let extra_reward = farming::claim_extra_reward<StakeCoin, ExtraRewardCoin2>(user, pid);
            try_register<ExtraRewardCoin2>(user);
            coin::deposit(signer::address_of(user), extra_reward);
        }
    }

    fun try_register<CoinType>(user: &signer) {
        if (!coin::is_account_registered<CoinType>(signer::address_of(user))) {
            coin::register<CoinType>(user);
        };
    }

    fun is_null<CoinType>(): bool {
        type_info::type_name<CoinType>() == type_info::type_name<Null>()
    }
}
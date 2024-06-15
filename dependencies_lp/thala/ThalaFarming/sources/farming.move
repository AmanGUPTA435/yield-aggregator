module thala_farming::farming {
    use std::signer;
    use std::string::String;
    use std::vector;

    use aptos_std::event::{Self, EventHandle};
    use aptos_std::table::{Self, Table};
    use aptos_std::type_info;
    use aptos_framework::account;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::timestamp;

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    use thala_farming::package;

    use thala_manager::manager;
    use thala_oracle::oracle;
    use thala_oracle::thala_lp_oracle;

    use thl_coin_alias::thl_coin::THL;
    use thl_coin_alias::thl_vetoken;

    /// Constants
    const SEC_PER_DAY: u64 = 86400;
    const MAX_U64: u256 = 18446744073709551615; // 2^64 - 1, used as the basis of acc_reward_per_share
    const BPS_BASE: u64 = 10000;
    const MAX_TOTAL_THL_ALLOC_POINT: u64 = 1000000; // to avoid overflow when calculating reward_per_second * thl_alloc_point
    const MANTISSA: u64 = 100000000;
    const THALA_LP_TOKEN_DECIMALS: u8 = 8;

    const FARMING_MANAGER_ROLE: vector<u8> = b"farming_manager";

    /// Error Codes
    const ERR_UNAUTHORIZED: u64 = 0;
    const ERR_FARMING_ALREADY_INITIALIZED: u64 = 1;
    const ERR_FARMING_UNINITIALIZED: u64 = 2;
    const ERR_PACKAGE_UNINITIALIZED: u64 = 3;
    const ERR_MANAGER_UNINITIALIZED: u64 = 4;
    const ERR_COIN_UNINITIALIZED: u64 = 5;
    const ERR_INVALID_TIME: u64 = 6;
    const ERR_INVALID_REWARD_PER_DAY: u64 = 7;
    const ERR_INVALID_STAKE_COIN: u64 = 8;
    const ERR_INVALID_REWARD_COIN: u64 = 9;
    const ERR_INVALID_AMOUNT: u64 = 10;
    const ERR_INVALID_USER: u64 = 11;
    const ERR_INVALID_POOL_ID: u64 = 12;
    const ERR_NO_REWARDS: u64 = 13;
    /// Deprecated. We now allow multiple pools to have the same stake coin
    const ERR_DUPLICATE_POOL: u64 = 14;
    const ERR_THL_ALLOC_POINT_TOO_LARGE: u64 = 15;
    const ERR_DIVIDE_BY_ZERO: u64 = 16;
    const ERR_VETHL_GATED_FARMING_ALREADY_INITIALIZED: u64 = 17;
    const ERR_VETHL_GATED_FARMING_UNINITIALIZED: u64 = 18;
    const ERR_INELIGIBLE_FOR_VETHL_GATED_FARMING: u64 = 19;
    const ERR_COIN_NOT_THALA_LP_TOKEN: u64 = 20;
    const ERR_INVALID_VETHL_GATED_FARMING_THRESHOLD_BPS: u64 = 21;

    // Global variables

    /// Stores farming protocol wide information
    struct Farming has key {
        pool_info: vector<PoolInfo>,
        thl_epoch: EpochInfo,
        total_thl_alloc_point: u64
    }

    /// Stores additional data required for V2 farming
    /// Comparison between v1 and v2:
    /// V1: User can claim rewards directly from farming module, no vesting
    /// V2: User must claim rewards from vesting module, and then vesting module calls claim_thl_for_vesting to send the THL to be vested in 30 days
    struct FarmingV2 has key {
        // if v2_only_mode is false, we allow v1 claim reward methods to continue working while we can test v2 farming in production
        // we should set it to true before official launch
        v2_only_mode: bool,
    }

    struct VeTHLGatedFarming has key {
        threshold_bps: u64,
        /// Pools that are exempt from VeTHL gated farming
        /// - Users can always stake into these pools without veTHL requirement.
        /// - Staking value in these pools are not counted.
        exempt_pools: vector<u64>
    }

    /// Stores user specific information
    struct Staker has key {
        /// Map of pid -> UserPoolInfo
        pool_info: Table<u64, UserPoolInfo>, 
    }

    /// Structs
    struct UserPoolInfo has store {
        /// Amount of tokens the user has staked in the farming pool
        amount: u64,

        /// Map of reward coin name -> value 
        last_acc_rewards_per_share: Table<String, u256>,  

        /// Map of reward coin name -> amount of rewards
        rewards: Table<String, u64>, 
    }

    struct PoolInfo has store {
        stake_coin: String,
        stake_amount: u64,

        /// allocation points for THL rewards
        thl_alloc_point: u64, 

        /// Map of reward coin name -> last timestamp when rewards were calculated
        last_rewards_sec: Table<String, u64>, 

        /// Map of reward coin name -> value
        acc_rewards_per_share: Table<String, u256>, 

        /// Map of reward coin name -> extra reward epoch info
        extra_rewards: Table<String, EpochInfo>,

        /// vector of extra reward coin names
        extra_reward_coins: vector<String>,
    }

    struct EpochInfo has store, drop, copy {
        start_sec: u64,
        end_sec: u64,
        reward_per_sec: u64
    }

    struct FarmingEvents has key {
        reward_epoch_events: EventHandle<RewardEpochEvent>,
        stake_events: EventHandle<StakeEvent>,
        unstake_events: EventHandle<UnstakeEvent>,
        claim_events: EventHandle<ClaimEvent>,
        pool_change_events: EventHandle<PoolChangeEvent>,
    }

    struct RewardEpochEvent has drop, store {
        reward_coin: String,
        start_sec: u64,
        end_sec: u64,
        reward_per_sec: u64
    }

    struct StakeEvent has drop, store {
        pid: u64,
        stake_coin: String,
        amount: u64,
    }

    struct UnstakeEvent has drop, store {
        pid: u64,
        stake_coin: String,
        amount: u64,
    }

    struct ClaimEvent has drop, store {
        stake_coin: String,
        reward_coin: String,
        amount: u64,
    }

    struct PoolChangeEvent has drop, store {
        pid: u64,
        stake_coin: String,
        prev_thl_alloc_point: u64,
        new_thl_alloc_point: u64,
    }

    //
    // Privileged functions
    //

    /// Initialize farming modules. **MUST** be called from the deploying account
    public entry fun init(deployer: &signer) {
        assert!(signer::address_of(deployer) == @thala_farming_deployer, ERR_UNAUTHORIZED);
        
        // Key dependencies
        assert!(package::initialized(), ERR_PACKAGE_UNINITIALIZED);
        assert!(manager::initialized(), ERR_MANAGER_UNINITIALIZED);

        assert!(!initialized(), ERR_FARMING_ALREADY_INITIALIZED);

        let resource_account_signer = package::resource_account_signer();

        move_to(&resource_account_signer, Farming {
            pool_info: vector::empty<PoolInfo>(),
            thl_epoch: EpochInfo {
                start_sec: 0,
                end_sec: 0,
                reward_per_sec: 0
            },
            total_thl_alloc_point: 0
        });

        move_to(&resource_account_signer, FarmingEvents {
            reward_epoch_events: account::new_event_handle<RewardEpochEvent>(&resource_account_signer),
            stake_events: account::new_event_handle<StakeEvent>(&resource_account_signer),
            unstake_events: account::new_event_handle<UnstakeEvent>(&resource_account_signer),
            claim_events: account::new_event_handle<ClaimEvent>(&resource_account_signer),
            pool_change_events: account::new_event_handle<PoolChangeEvent>(&resource_account_signer),
        });
    }

    /// Start a new epoch for THL rewards
    /// manager wallet must have enough THL coins for rewards of next epoch
    /// If start_sec is 0, we will use the current timestamp as the starting time
    public entry fun new_thl_epoch(manager: &signer, start_sec: u64, end_sec: u64, reward_per_day: u64) acquires Farming, FarmingEvents {
        let manager_addr = signer::address_of(manager);
        assert!(manager::is_role_member(manager_addr, FARMING_MANAGER_ROLE), ERR_UNAUTHORIZED);
        assert!(initialized(), ERR_FARMING_UNINITIALIZED);
        assert!(coin::is_coin_initialized<THL>(), ERR_COIN_UNINITIALIZED);
        
        let now = timestamp::now_seconds();

        if (start_sec == 0) {
            start_sec = now;
        };

        assert!(start_sec >= now && end_sec > start_sec, ERR_INVALID_TIME);
        assert!(reward_per_day > 0, ERR_INVALID_REWARD_PER_DAY);

        let resource_account_signer = package::resource_account_signer();
        let resource_account_address = package::resource_account_address();
        
        // resource account signer will hold THL rewards. Register it if it's not registered
        if (!coin::is_account_registered<THL>(resource_account_address)) {
            coin::register<THL>(&resource_account_signer);
        };

        let farming = borrow_global_mut<Farming>(resource_account_address);
        let thl_epoch = &mut farming.thl_epoch;
        mass_update_pools_thl_rewards(&mut farming.pool_info, thl_epoch, farming.total_thl_alloc_point);
        
        let reward_per_sec = reward_per_day / SEC_PER_DAY;

        // if there is an ongoing epoch, move fund between pool and manager
        // to make sure the new epoch has just enough fund for rewards
        let remaining_rewards = thl_epoch.reward_per_sec * (thl_epoch.end_sec - current_epoch_seconds(thl_epoch));
        let new_rewards = reward_per_sec * (end_sec - start_sec);
        if (remaining_rewards > new_rewards) {
            // transfer excess reward coin from pool to manager
            coin::transfer<THL>(&resource_account_signer, manager_addr, remaining_rewards - new_rewards);
        } else if (remaining_rewards < new_rewards) {
            // transfer reward coin from manager to pool
            coin::transfer<THL>(manager, resource_account_address, new_rewards - remaining_rewards);
        };

        thl_epoch.start_sec = start_sec;
        thl_epoch.end_sec = end_sec;
        thl_epoch.reward_per_sec = reward_per_sec;

        let events = borrow_global_mut<FarmingEvents>(resource_account_address);
        event::emit_event(&mut events.reward_epoch_events, RewardEpochEvent {
            reward_coin: thl_name(),
            start_sec: start_sec,
            end_sec: end_sec,
            reward_per_sec: reward_per_sec
        });
    }

    /// Add a new farming pool that accepts deposit of StakeCoin
    public entry fun add_pool<StakeCoin>(manager: &signer, thl_alloc_point: u64) acquires Farming, FarmingEvents {
        assert!(manager::is_role_member(signer::address_of(manager), FARMING_MANAGER_ROLE), ERR_UNAUTHORIZED);
        assert!(initialized(), ERR_FARMING_UNINITIALIZED);
        assert!(coin::is_coin_initialized<StakeCoin>(), ERR_COIN_UNINITIALIZED);
        // Otherwise account_staking_value compute wrong result
        assert!(coin::decimals<StakeCoin>() == THALA_LP_TOKEN_DECIMALS, ERR_COIN_NOT_THALA_LP_TOKEN);

        let resource_account_address = package::resource_account_address();
        let stake_coin_name = type_info::type_name<StakeCoin>();
        let thl_name = thl_name();

        let farming = borrow_global_mut<Farming>(resource_account_address);
        let pid = vector::length(&farming.pool_info);

        mass_update_pools_thl_rewards(&mut farming.pool_info, &farming.thl_epoch, farming.total_thl_alloc_point);

        farming.total_thl_alloc_point = farming.total_thl_alloc_point + thl_alloc_point;
        assert!(farming.total_thl_alloc_point <= MAX_TOTAL_THL_ALLOC_POINT, ERR_THL_ALLOC_POINT_TOO_LARGE);

        let last_rewards_sec = table::new<String, u64>();
        table::add(&mut last_rewards_sec, thl_name, current_epoch_seconds(&farming.thl_epoch));

        let acc_rewards_per_share = table::new<String, u256>();
        table::add(&mut acc_rewards_per_share, thl_name, 0);

        vector::push_back<PoolInfo>(&mut farming.pool_info, PoolInfo {
            stake_coin: stake_coin_name,
            stake_amount: 0,
            thl_alloc_point,
            last_rewards_sec,
            acc_rewards_per_share,
            extra_rewards: table::new<String, EpochInfo>(),
            extra_reward_coins: vector::empty<String>(),
        });
        
        let events = borrow_global_mut<FarmingEvents>(resource_account_address);
        event::emit_event(&mut events.pool_change_events, PoolChangeEvent {
            pid,
            stake_coin: stake_coin_name,
            prev_thl_alloc_point: 0,
            new_thl_alloc_point: thl_alloc_point,
        });
    }

    /// Configure the thl_alloc_point of a farming pool indexed by pid
    public entry fun update_thl_reward(manager: &signer, pid: u64, thl_alloc_point: u64) acquires Farming, FarmingEvents {
        assert!(manager::is_role_member(signer::address_of(manager), FARMING_MANAGER_ROLE), ERR_UNAUTHORIZED);
        assert!(initialized(), ERR_FARMING_UNINITIALIZED);
        
        let resource_account_address = package::resource_account_address();

        let farming = borrow_global_mut<Farming>(resource_account_address);

        mass_update_pools_thl_rewards(&mut farming.pool_info, &farming.thl_epoch, farming.total_thl_alloc_point);

        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);
        let pool = vector::borrow_mut<PoolInfo>(&mut farming.pool_info, pid);
        let prev_alloc_point = pool.thl_alloc_point;
        pool.thl_alloc_point = thl_alloc_point;
        if (prev_alloc_point != thl_alloc_point) {
            farming.total_thl_alloc_point = farming.total_thl_alloc_point - prev_alloc_point + thl_alloc_point;
            assert!(farming.total_thl_alloc_point <= MAX_TOTAL_THL_ALLOC_POINT, ERR_THL_ALLOC_POINT_TOO_LARGE);
        };
        
        let events = borrow_global_mut<FarmingEvents>(resource_account_address);
        event::emit_event(&mut events.pool_change_events, PoolChangeEvent {
            pid,
            stake_coin: pool.stake_coin,
            prev_thl_alloc_point: prev_alloc_point,
            new_thl_alloc_point: thl_alloc_point,
        });
    }

    /// Create or update an epoch for extra reward
    /// manager wallet must have enough ExtraRewardCoin for rewards of next epoch
    /// If start_sec is 0, we will use the current timestamp as the starting time
    public entry fun update_extra_reward<ExtraRewardCoin>(manager: &signer, pid: u64, start_sec: u64, end_sec: u64, reward_per_day: u64) acquires Farming, FarmingEvents {
        let manager_addr = signer::address_of(manager);
        assert!(manager::is_role_member(manager_addr, FARMING_MANAGER_ROLE), ERR_UNAUTHORIZED);
        assert!(initialized(), ERR_FARMING_UNINITIALIZED);
        assert!(coin::is_coin_initialized<ExtraRewardCoin>(), ERR_COIN_UNINITIALIZED);
        
        let resource_account_address = package::resource_account_address();
        let resource_account_signer = package::resource_account_signer();

        if (!coin::is_account_registered<ExtraRewardCoin>(resource_account_address)) {
            coin::register<ExtraRewardCoin>(&resource_account_signer);
        };

        let farming = borrow_global_mut<Farming>(resource_account_address);
        
        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);
        let pool_info = vector::borrow_mut(&mut farming.pool_info, pid);
        let coin_name = type_info::type_name<ExtraRewardCoin>();

        let now = timestamp::now_seconds();

        if (start_sec == 0) {
            start_sec = now;
        };

        assert!(start_sec >= now && end_sec > start_sec, ERR_INVALID_TIME);

        let prev_epoch = if (table::contains(&pool_info.extra_rewards, coin_name)) {
            *table::borrow(&pool_info.extra_rewards, coin_name)
        } else {
            EpochInfo {
                start_sec: 0,
                end_sec: 0,
                reward_per_sec: 0
            }
        };

        // if the reward coin is not initialized before, initialize it by adding it to last_rewards_sec and acc_rewards_per_share
        if (!pool_has_reward_coin(pool_info, coin_name)) {
            table::add(&mut pool_info.acc_rewards_per_share, coin_name, 0);
            table::add(&mut pool_info.last_rewards_sec, coin_name, start_sec);
            table::add(&mut pool_info.extra_rewards, coin_name, prev_epoch);
            vector::push_back(&mut pool_info.extra_reward_coins, coin_name);
        };

        update_pool_extra_reward(pool_info, coin_name);

        let reward_per_sec = reward_per_day / SEC_PER_DAY;

        // update epoch in extra_rewards table
        table::upsert(&mut pool_info.extra_rewards, coin_name, EpochInfo {
            start_sec,
            end_sec,
            reward_per_sec
        });

        // transfer reward coin from manager to pool, or reversely, depending on the amount of remaining rewards
        let remaining_rewards = prev_epoch.reward_per_sec * (prev_epoch.end_sec - current_epoch_seconds(&prev_epoch));

        let new_rewards = reward_per_sec * (end_sec - start_sec);

        if (remaining_rewards > new_rewards) {
            // transfer extra reward coin from pool to manager
            coin::transfer<ExtraRewardCoin>(&resource_account_signer, manager_addr, remaining_rewards - new_rewards);
        }
        else if (remaining_rewards < new_rewards) {
            // transfer extra reward coin from manager to pool
            coin::transfer<ExtraRewardCoin>(manager, resource_account_address, new_rewards - remaining_rewards);
        };
        
        let events = borrow_global_mut<FarmingEvents>(resource_account_address);
        event::emit_event(&mut events.reward_epoch_events, RewardEpochEvent {
            reward_coin: coin_name,
            start_sec: start_sec,
            end_sec: end_sec,
            reward_per_sec: reward_per_sec
        });
    }

    public entry fun initialize_farming_v2(manager: &signer) {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(!initialized_v2(), ERR_FARMING_ALREADY_INITIALIZED);

        move_to(&package::resource_account_signer(), FarmingV2 {
            v2_only_mode: false,
        });
    }

    public entry fun set_v2_only_mode(manager: &signer, new_mode: bool) acquires FarmingV2 {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(initialized_v2(), ERR_FARMING_UNINITIALIZED);

        let farming_v2 = borrow_global_mut<FarmingV2>(package::resource_account_address());
        farming_v2.v2_only_mode = new_mode;
    }

    public entry fun initialize_vethl_gated_farming(manager: &signer, threshold_bps: u64) {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(!initialized_vethl_gated_farming(), ERR_VETHL_GATED_FARMING_ALREADY_INITIALIZED);

        move_to(&package::resource_account_signer(), VeTHLGatedFarming {
            threshold_bps,
            exempt_pools: vector::empty<u64>(),
        });
    }

    public entry fun set_vethl_gated_farming_threshold_bps(manager: &signer, new_threshold_bps: u64) acquires VeTHLGatedFarming {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(initialized_vethl_gated_farming(), ERR_VETHL_GATED_FARMING_UNINITIALIZED);
        assert!(new_threshold_bps <= BPS_BASE, ERR_INVALID_VETHL_GATED_FARMING_THRESHOLD_BPS);

        let vethl_gated_farming = borrow_global_mut<VeTHLGatedFarming>(package::resource_account_address());
        vethl_gated_farming.threshold_bps = new_threshold_bps;
    }

    public entry fun set_vethl_gated_farming_exempt_pools(manager: &signer, exempt_pools: vector<u64>) acquires VeTHLGatedFarming, Farming {
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(initialized_vethl_gated_farming(), ERR_VETHL_GATED_FARMING_UNINITIALIZED);

        let num_pools = vector::length(&borrow_global<Farming>(package::resource_account_address()).pool_info);
        vector::for_each(exempt_pools, |pid| {
            assert!(pid < num_pools, ERR_INVALID_POOL_ID);
        });

        let vethl_gated_farming = borrow_global_mut<VeTHLGatedFarming>(package::resource_account_address());
        vethl_gated_farming.exempt_pools = exempt_pools;
    }

    /// Stake StakeCoin to a certain pool
    /// Return claimable THL (if v2_only_mode is true, return zero coins)
    public fun stake<StakeCoin>(user: &signer, pid: u64, coin: Coin<StakeCoin>): Coin<THL> acquires Farming, FarmingV2, FarmingEvents, Staker, VeTHLGatedFarming {
        let amount = coin::value(&coin);
        assert!(amount > 0, ERR_INVALID_AMOUNT);

        let user_addr = signer::address_of(user);
        
        let resource_account_address = package::resource_account_address();
        let resource_account_signer = package::resource_account_signer();

        let farming = borrow_global<Farming>(resource_account_address);
        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);

        let pool = vector::borrow<PoolInfo>(&farming.pool_info, pid);
        assert!(pool.stake_coin == type_info::type_name<StakeCoin>(), ERR_INVALID_STAKE_COIN);
        let stake_coin = pool.stake_coin;

        if (!exists<Staker>(user_addr)) {
            let pool_info = table::new<u64, UserPoolInfo>();
            move_to(user, Staker { pool_info });
        };

        // Eligibligity check for VeTHL gated farming
        assert!(eligible_given_add(user_addr, pid, amount), ERR_INELIGIBLE_FOR_VETHL_GATED_FARMING);

        let farming = borrow_global_mut<Farming>(resource_account_address);
        let pool = vector::borrow_mut<PoolInfo>(&mut farming.pool_info, pid);
        let staker = borrow_global_mut<Staker>(user_addr);
        let thl_name = thl_name();

        if (!table::contains(&staker.pool_info, pid)) {
            // initialize user pool info for the first time for THL reward
            let last_acc_rewards_per_share = table::new<String, u256>();
            table::add(&mut last_acc_rewards_per_share, thl_name, 0);

            let rewards = table::new<String, u64>();
            table::add(&mut rewards, thl_name, 0);

            table::add(&mut staker.pool_info, pid, UserPoolInfo {
                amount: 0,
                last_acc_rewards_per_share,
                rewards,
            });
        };
        let user_pool_info = table::borrow_mut(&mut staker.pool_info, pid);

        let reward = if (v2_only_mode()) {
            // Only update THL reward info of the pool and the user, but do not claim
            update_pool_thl_reward(pool, &farming.thl_epoch, farming.total_thl_alloc_point);
            accrue_user_reward(pool, user_pool_info, thl_name());
            coin::zero<THL>()
        } else {
            // Claim available THL rewards in V1
            claim_thl_from_pool(&resource_account_signer, pool, user_pool_info, &farming.thl_epoch, farming.total_thl_alloc_point)
        };

        // Update extra rewards info for UserPoolInfo
        let i = 0;
        while (i < vector::length(&pool.extra_reward_coins)) {
            let coin_name = *vector::borrow(&pool.extra_reward_coins, i);
            update_pool_extra_reward(pool, coin_name);
            accrue_user_reward(pool, user_pool_info, coin_name);
            i = i + 1;
        };

        // Stake
        pool.stake_amount = pool.stake_amount + amount;
        user_pool_info.amount = user_pool_info.amount + amount;
        if (!coin::is_account_registered<StakeCoin>(resource_account_address)) {
            coin::register<StakeCoin>(&resource_account_signer);
        };
        coin::deposit(resource_account_address, coin);

        let events = borrow_global_mut<FarmingEvents>(resource_account_address);
        event::emit_event(&mut events.stake_events, StakeEvent {
            pid,
            stake_coin,
            amount,
        });

        // Return reward
        reward
    }

    /// Unstake from a certain pool
    /// Return unstaked coin and claimable THL reward  (if v2_only_mode is true, returned THL is zero)
    public fun unstake<StakeCoin>(user: &signer, pid: u64, amount: u64): (Coin<StakeCoin>, Coin<THL>) acquires Farming, FarmingV2, FarmingEvents, Staker {
        assert!(amount > 0, ERR_INVALID_AMOUNT);

        let user_addr = signer::address_of(user);
        assert!(exists<Staker>(user_addr), ERR_INVALID_USER);

        let resource_account_address = package::resource_account_address();
        let resource_account_signer = package::resource_account_signer();

        let farming = borrow_global_mut<Farming>(resource_account_address);

        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);
        let pool = vector::borrow_mut<PoolInfo>(&mut farming.pool_info, pid);
        assert!(pool.stake_coin == type_info::type_name<StakeCoin>(), ERR_INVALID_STAKE_COIN);

        let staker = borrow_global_mut<Staker>(user_addr);

        assert!(table::contains(&staker.pool_info, pid), ERR_INVALID_POOL_ID);
        let user_pool_info = table::borrow_mut(&mut staker.pool_info, pid);
        assert!(user_pool_info.amount >= amount, ERR_INVALID_AMOUNT);

        let reward = if (v2_only_mode()) {
            // Only update THL reward info of the pool and the user, but do not claim
            update_pool_thl_reward(pool, &farming.thl_epoch, farming.total_thl_alloc_point);
            accrue_user_reward(pool, user_pool_info, thl_name());
            coin::zero<THL>()
        } else {
            // Claim available THL rewards in V1
            claim_thl_from_pool(&resource_account_signer, pool, user_pool_info, &farming.thl_epoch, farming.total_thl_alloc_point)
        };
        
        // Update extra rewards info for UserPoolInfo
        let i = 0;
        while (i < vector::length(&pool.extra_reward_coins)) {
            let coin_name = *vector::borrow(&pool.extra_reward_coins, i);
            update_pool_extra_reward(pool, coin_name);
            accrue_user_reward(pool, user_pool_info, coin_name);
            i = i + 1;
        };

        // Unstake
        pool.stake_amount = pool.stake_amount - amount;
        user_pool_info.amount = user_pool_info.amount - amount;
        
        let events = borrow_global_mut<FarmingEvents>(resource_account_address);
        event::emit_event(&mut events.unstake_events, UnstakeEvent {
            pid,
            stake_coin: pool.stake_coin,
            amount,
        });

        // Return (unstaked, reward)
        (coin::withdraw<StakeCoin>(&resource_account_signer, amount), reward)
    }

    /// Claim rewards from all possible pools
    /// Return claimable THL reward (if v2_only_mode is true, returned THL is zero. `claim_thl_for_vesting` will be the only way to get rewards)
    public fun claim_all_thl(user: &signer): Coin<THL> acquires Farming, FarmingV2, FarmingEvents, Staker {
        if (v2_only_mode()) return coin::zero<THL>();

        claim_all_thl_internal(signer::address_of(user))
    }

    /// Claim rewards from all farming pools to be sent for vesting (in THL Tokenomics V2)
    /// Only vesting account signer can call this function for user
    public fun claim_all_thl_for_vesting(vesting_account: &signer, user: address): Coin<THL> acquires Farming, FarmingEvents, Staker {
        assert!(initialized_v2(), ERR_FARMING_UNINITIALIZED);
        assert!(is_vesting_signer(vesting_account), ERR_UNAUTHORIZED);

        claim_all_thl_internal(user)
    }

    fun claim_all_thl_internal(user: address): Coin<THL> acquires Farming, FarmingEvents, Staker {
        assert!(exists<Staker>(user), ERR_INVALID_USER);

        let farming = borrow_global_mut<Farming>(package::resource_account_address());
        let num_pools = vector::length(&farming.pool_info);
        let staker = borrow_global_mut<Staker>(user);
        let pid = 0;

        // reward to be accumulated through pools
        let reward = coin::zero<THL>();
        while (pid < num_pools) {
            if (table::contains(&staker.pool_info, pid)) {
                let pool = vector::borrow_mut<PoolInfo>(&mut farming.pool_info, pid);
                let user_pool_info = table::borrow_mut(&mut staker.pool_info, pid);
                let pool_reward = claim_thl_from_pool(&package::resource_account_signer(), pool, user_pool_info, &farming.thl_epoch, farming.total_thl_alloc_point);
                coin::merge(&mut reward, pool_reward);
            };
            pid = pid + 1;
        };

        reward
    }

    /// Claim rewards for a certain pool
    /// Return claimable reward (if v2_only_mode is true, returned THL is zero. `claim_thl_for_vesting` will be the only way to get rewards)
    /// Note: <StakeCoin> is not needed, but kept for backward-compatibility
    public fun claim_thl<StakeCoin>(user: &signer, pid: u64): Coin<THL> acquires Farming, FarmingV2, FarmingEvents, Staker {
        if (v2_only_mode()) return coin::zero<THL>();

        claim_thl_internal(signer::address_of(user), pid)
    }

    /// Claim accrued THL rewards to be sent for vesting (in THL Tokenomics V2)
    /// Only vesting account signer can call this function for user
    public fun claim_thl_for_vesting(vesting_account: &signer, user: address, pid: u64): Coin<THL> acquires Farming, FarmingEvents, Staker {
        assert!(initialized_v2(), ERR_FARMING_UNINITIALIZED);
        assert!(is_vesting_signer(vesting_account), ERR_UNAUTHORIZED);

        claim_thl_internal(user, pid)
    }

    fun claim_thl_internal(user: address, pid: u64): Coin<THL> acquires Farming, FarmingEvents, Staker {
        assert!(exists<Staker>(user), ERR_INVALID_USER);

        let farming = borrow_global_mut<Farming>(package::resource_account_address());

        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);
        let pool = vector::borrow_mut<PoolInfo>(&mut farming.pool_info, pid);

        let staker = borrow_global_mut<Staker>(user);
        assert!(table::contains(&staker.pool_info, pid), ERR_INVALID_POOL_ID);
        let user_pool_info = table::borrow_mut(&mut staker.pool_info, pid);

        // Claim reward and return
        claim_thl_from_pool(&package::resource_account_signer(), pool, user_pool_info, &farming.thl_epoch, farming.total_thl_alloc_point)
    }

    /// Claim extra rewards for a certain pool
    /// Return claimable reward
    public fun claim_extra_reward<StakeCoin, ExtraRewardCoin>(user: &signer, pid: u64): Coin<ExtraRewardCoin> acquires Farming, FarmingEvents, Staker {
        let user_addr = signer::address_of(user);
        assert!(exists<Staker>(user_addr), ERR_INVALID_USER);
        
        let resource_account_address = package::resource_account_address();
        let resource_account_signer = package::resource_account_signer();

        let farming = borrow_global_mut<Farming>(resource_account_address);

        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);
        let pool = vector::borrow_mut<PoolInfo>(&mut farming.pool_info, pid);
        assert!(pool.stake_coin == type_info::type_name<StakeCoin>(), ERR_INVALID_STAKE_COIN);

        let reward_coin_name = type_info::type_name<ExtraRewardCoin>();
        assert!(table::contains(&pool.extra_rewards, reward_coin_name), ERR_INVALID_REWARD_COIN);

        let staker = borrow_global_mut<Staker>(user_addr);
        assert!(table::contains(&staker.pool_info, pid), ERR_INVALID_POOL_ID);
        let user_pool_info = table::borrow_mut(&mut staker.pool_info, pid);

        // Claim reward and return
        claim_extra_reward_from_pool<ExtraRewardCoin>(&resource_account_signer, pool, user_pool_info)
    }
    
    //
    // View functions
    //

    #[view] /// Return (stake amount, reward amount) of a user in a pool
    public fun stake_and_reward_amount<RewardCoin>(user: address, pid: u64): (u64, u64) acquires Farming, Staker {
        if (!initialized() || !exists<Staker>(user)) {
            return (0, 0)
        };
        
        let user_info = borrow_global<Staker>(user);
        if(!table::contains(&user_info.pool_info, pid)) {
            return (0, 0)
        };

        let user_pool_info = table::borrow(&user_info.pool_info, pid);

        let reward_coin_name = type_info::type_name<RewardCoin>();
        let stake_amount = user_pool_info.amount;
        let unclaimed_reward = if (table::contains(&user_pool_info.rewards, reward_coin_name)) *table::borrow(&user_pool_info.rewards, reward_coin_name) else 0;
        let last_acc_reward_per_share = if (table::contains(&user_pool_info.last_acc_rewards_per_share, reward_coin_name)) *table::borrow(&user_pool_info.last_acc_rewards_per_share, reward_coin_name) else 0;
        let pool_acc_reward_per_share = if (reward_coin_name == thl_name()) pool_acc_thl_reward_per_share(pid) else pool_acc_extra_reward_per_share<RewardCoin>(pid);
        let pending_reward = (mul_u256_div_u256(
            stake_amount, 
            pool_acc_reward_per_share - last_acc_reward_per_share,
            MAX_U64
        ) as u64);

        (stake_amount, unclaimed_reward + pending_reward)
    }

    #[view]
    /// Get current accumulated THL reward per share of a pool Reward computation method is
    /// same as `update_pool_thl_reward` that distributes rewards based on ratio of allocation points and global emission rate
    public fun pool_acc_thl_reward_per_share(pid: u64): u256 acquires Farming {
        if (!initialized()) {
            return 0
        };

        let farming = borrow_global<Farming>(package::resource_account_address());
        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);

        let pool = vector::borrow(&farming.pool_info, pid);
        let thl_name = thl_name();

        // If pool does not have reward coin, it means pool.acc_rewards_per_share does not contain THL key
        if (!pool_has_reward_coin(pool, thl_name)) {
            return 0
        };
        let last_acc_reward_per_share = *table::borrow(&pool.acc_rewards_per_share, thl_name);

        // If allocation point is 0, no reward is accumulated since last time
        if (pool.thl_alloc_point == 0) {
            return last_acc_reward_per_share
        };

        // Next, calculate the change of accumulated reward per share since last update
        let thl_epoch = &farming.thl_epoch;
        let seconds = current_epoch_seconds(thl_epoch);
        let last_reward_sec = clamp_seconds_in_epoch(*table::borrow(&pool.last_rewards_sec, thl_name), thl_epoch);
        if (seconds <= last_reward_sec || pool.stake_amount == 0) {
            return last_acc_reward_per_share
        };

        // reward = reward duration * total reward rate * (pool.thl_alloc_point / total_thl_alloc_point)
        // where:
        // - reward duration = seconds - last_reward_sec
        // - total reward rate = thl_epoch.reward_per_sec
        let reward = mul_div(
            seconds - last_reward_sec,
            thl_epoch.reward_per_sec * pool.thl_alloc_point,
            farming.total_thl_alloc_point
        );

        last_acc_reward_per_share + mul_u256_div_u256(reward, MAX_U64, (pool.stake_amount as u256))
    }

    #[view]
    /// Get current accumulated reward per share of a pool for Non-THL rewards. Reward computation method
    /// is same as `update_pool_extra_reward` that distributes rewards based per-pool emission rate
    public fun pool_acc_extra_reward_per_share<RewardCoin>(pid: u64): u256 acquires Farming {
        if (!initialized()) {
            return 0
        };

        let farming = borrow_global<Farming>(package::resource_account_address());
        assert!(pid < vector::length(&farming.pool_info), ERR_INVALID_POOL_ID);

        let pool = vector::borrow(&farming.pool_info, pid);
        let reward_coin_name = type_info::type_name<RewardCoin>();

        if (!pool_has_reward_coin(pool, reward_coin_name)) {
            return 0
        };
        let last_acc_reward_per_share = *table::borrow(&pool.acc_rewards_per_share, reward_coin_name);

        let reward_epoch = table::borrow(&pool.extra_rewards, reward_coin_name);
        let seconds = current_epoch_seconds(reward_epoch);
        let last_reward_sec = clamp_seconds_in_epoch(*table::borrow(&pool.last_rewards_sec, reward_coin_name), reward_epoch);
        if (seconds <= last_reward_sec || pool.stake_amount == 0) {
            return last_acc_reward_per_share
        };

        // reward = reward duration * reward rate
        // where:
        // - reward duration = seconds - last_reward_sec
        // - reward rate = epoch.reward_per_sec
        let reward = (seconds - last_reward_sec) * reward_epoch.reward_per_sec;

        last_acc_reward_per_share + mul_u256_div_u256(reward, MAX_U64, (pool.stake_amount as u256))
    }

    #[view]
    public fun is_stake_coin(stake_coin: String): (bool, u64) acquires Farming {
        let farming = borrow_global<Farming>(package::resource_account_address());
        let i = 0;
        while (i < vector::length(&farming.pool_info)) {
            let pool = vector::borrow(&farming.pool_info, i);
            if (pool.stake_coin == stake_coin) {
                return (true, pool.thl_alloc_point)
            };
            i = i + 1;
        };
        (false, 0)
    }

    #[view]
    public fun initialized_vethl_gated_farming(): bool {
        exists<VeTHLGatedFarming>(package::resource_account_address())
    }

    #[view]
    public fun vethl_gated_farming_threshold_bps(): u64 acquires VeTHLGatedFarming {
        if (!initialized_vethl_gated_farming()) 0
        else borrow_global<VeTHLGatedFarming>(package::resource_account_address()).threshold_bps
    }

    #[view]
    public fun vethl_gated_farming_exempt_pools(): vector<u64> acquires VeTHLGatedFarming {
        if (!initialized_vethl_gated_farming()) vector[]
        else borrow_global<VeTHLGatedFarming>(package::resource_account_address()).exempt_pools
    }

    #[view]
    public fun account_staking_value(account_addr: address): FixedPoint64 acquires Farming, Staker, VeTHLGatedFarming {
        account_staking_value_given_add(account_addr, 0, 0)
    }

    #[view]
    public fun account_staking_value_given_add(account_addr: address, stake_pid: u64, add: u64): FixedPoint64 acquires Farming, Staker, VeTHLGatedFarming {
        let exempt_pools = vethl_gated_farming_exempt_pools();
        let farming = borrow_global<Farming>(package::resource_account_address());

        if (!exists<Staker>(account_addr)) {
            if (vector::contains(&exempt_pools, &stake_pid)) return fixed_point64::zero();

            let pool = vector::borrow(&farming.pool_info, stake_pid);
            let stake_lp_coin_price = thala_lp_oracle::get_price(pool.stake_coin);
            return fixed_point64::div(fixed_point64::mul(stake_lp_coin_price, add), MANTISSA)
        };

        let staker = borrow_global<Staker>(account_addr);
        let num_pools = vector::length(&farming.pool_info);
        let staking_value = fixed_point64::zero();
        let pid = 0;
        while (pid < num_pools) {
            if (vector::contains(&exempt_pools, &pid)) {
                pid = pid + 1;
                continue
            };

            let stake_amount = if (table::contains(&staker.pool_info, pid)) table::borrow(&staker.pool_info, pid).amount else 0;
            if (stake_pid == pid) stake_amount = stake_amount + add;
            if (stake_amount > 0) {
                let pool = vector::borrow(&farming.pool_info, pid);
                let stake_lp_coin_price = thala_lp_oracle::get_price(pool.stake_coin);
                let pool_staking_value = fixed_point64::mul(stake_lp_coin_price, stake_amount);
                staking_value = fixed_point64::add_fp(staking_value, pool_staking_value);
            };
            pid = pid + 1;
        };
        fixed_point64::div(staking_value, MANTISSA)
    }

    #[view]
    public fun account_veTHL_value(account_addr: address): FixedPoint64 {
        let thl_price = oracle::get_and_update_price_by_name(thl_name());
        let veTHL_balance = thl_vetoken::balance(account_addr);
        fixed_point64::div(
            fixed_point64::mul(thl_price, (veTHL_balance as u64)),
            MANTISSA
        )
    }

    #[view]
    public fun eligible_given_add(account_addr: address, stake_pid: u64, amount: u64): bool acquires VeTHLGatedFarming, Farming, Staker {
        let (is_shortfall, _, _) = veTHL_shortfall_given_add(account_addr, stake_pid, amount);
        !is_shortfall
    }

    #[view]
    /// Returns (is_shortfall, shortfall_value, shortfall_amount)
    public fun veTHL_shortfall_given_add(account_addr: address, stake_pid: u64, amount: u64): (bool, FixedPoint64, FixedPoint64) acquires VeTHLGatedFarming, Farming, Staker {
        let threshold_bps = vethl_gated_farming_threshold_bps();
        if (threshold_bps == 0) {
            return (false, fixed_point64::zero(), fixed_point64::zero())
        };

        let staking_value = account_staking_value_given_add(account_addr, stake_pid, amount);
        let veTHL_value = account_veTHL_value(account_addr);

        // staking value * (threshold bps / BPS_BASE) <= veTHL value
        if (fixed_point64::lte(
            &fixed_point64::mul(staking_value, threshold_bps),
            &fixed_point64::mul(veTHL_value, BPS_BASE)
        )) {
            return (false, fixed_point64::zero(), fixed_point64::zero())
        };

        // staking_value * (threshold bps / BPS_BASE) = veTHL_value + shortfall_amount * thl_price
        let shortfall_value = fixed_point64::sub_fp(
            fixed_point64::div(fixed_point64::mul(staking_value, threshold_bps), BPS_BASE),
            veTHL_value
        );
        let thl_price = oracle::get_and_update_price_by_name(thl_name());
        let shortfall_amount = fixed_point64::div_fp(shortfall_value, thl_price);
        (true, shortfall_value, shortfall_amount)
    }

    #[view]
    /// How much more can the user stake to a given pool while still being eligible for VeTHL gated farming
    /// Returns (can_stake, max_stake_amount)
    public fun max_eligible_stake(account_addr: address, stake_pid: u64): (bool, u64) acquires Farming, Staker, VeTHLGatedFarming {
        let threshold_bps = vethl_gated_farming_threshold_bps();
        if (threshold_bps == 0) {
            return (true, (MAX_U64 as u64))
        };

        let exempt_pools = vethl_gated_farming_exempt_pools();
        if (vector::contains(&exempt_pools, &stake_pid)) {
            return (true, (MAX_U64 as u64))
        };

        let staking_value = account_staking_value(account_addr);
        let veTHL_value = account_veTHL_value(account_addr);

        if (fixed_point64::gte(
            &fixed_point64::mul(staking_value, threshold_bps),
            &fixed_point64::mul(veTHL_value, BPS_BASE)
        )) {
            return (false, 0)
        };

        // (staking_value + overflow_value) * (threshold_bps / BPS_BASE) = veTHL_value
        let overflow_value = fixed_point64::sub_fp(
            fixed_point64::div(fixed_point64::mul(veTHL_value, BPS_BASE), threshold_bps),
            staking_value
        );

        let farming = borrow_global<Farming>(package::resource_account_address());
        let pool = vector::borrow(&farming.pool_info, stake_pid);
        let stake_lp_coin_price = thala_lp_oracle::get_price(pool.stake_coin);
        (
            true,
            fixed_point64::decode_round_down(fixed_point64::div_fp(overflow_value, stake_lp_coin_price))
        )
    }

    //
    // Internal helper functions
    //

    fun claim_thl_from_pool(resource_account_signer: &signer, pool: &mut PoolInfo, user_pool_info: &mut UserPoolInfo, epoch_info: &EpochInfo, total_thl_alloc_point: u64): Coin<THL> acquires FarmingEvents {
        update_pool_thl_reward(pool, epoch_info, total_thl_alloc_point);

        let thl_name = thl_name();
        accrue_user_reward(pool, user_pool_info, thl_name);

        let reward = *table::borrow(&user_pool_info.rewards, thl_name);
        // set claimable reward to 0
        table::upsert(&mut user_pool_info.rewards, thl_name, 0);

        let events = borrow_global_mut<FarmingEvents>(signer::address_of(resource_account_signer));
        event::emit_event(&mut events.claim_events, ClaimEvent {
            stake_coin: pool.stake_coin,
            reward_coin: thl_name,
            amount: reward,
        });

        coin::withdraw<THL>(resource_account_signer, reward)
    }

    fun claim_extra_reward_from_pool<ExtraRewardCoin>(resource_account_signer: &signer, pool: &mut PoolInfo, user_pool_info: &mut UserPoolInfo): Coin<ExtraRewardCoin> acquires FarmingEvents {
        let reward_coin_name = type_info::type_name<ExtraRewardCoin>();
        update_pool_extra_reward(pool, reward_coin_name);
        accrue_user_reward(pool, user_pool_info, reward_coin_name);

        let reward = *table::borrow(&user_pool_info.rewards, reward_coin_name);
        // set claimable reward to 0
        table::upsert(&mut user_pool_info.rewards, reward_coin_name, 0);
        
        let events = borrow_global_mut<FarmingEvents>(signer::address_of(resource_account_signer));
        event::emit_event(&mut events.claim_events, ClaimEvent {
            stake_coin: pool.stake_coin,
            reward_coin: reward_coin_name,
            amount: reward,
        });

        coin::withdraw<ExtraRewardCoin>(resource_account_signer, reward)
    }

    /// Make sure reward coin exists in `pool` and `user_pool_info` before calling this function
    /// This function calculates user's reward since the last update till now and updates data in `user_pool_info`
    /// Be sure to call this every time before user stake amount is updated (either increase stake or unstake)
    fun accrue_user_reward(pool: &PoolInfo, user_pool_info: &mut UserPoolInfo, reward_coin_name: String) {
        let pool_acc_reward_per_share = *table::borrow(&pool.acc_rewards_per_share, reward_coin_name);

        // extra rewards may be added to pool after the user stakes
        // so we need to add the extra rewards in `last_acc_rewards_per_share` and `rewards` of UserPoolInfo
        if (!user_pool_has_reward_coin(user_pool_info, reward_coin_name)) {
            table::upsert(&mut user_pool_info.last_acc_rewards_per_share, reward_coin_name, 0);
            table::upsert(&mut user_pool_info.rewards, reward_coin_name, 0);
        };

        let pending = (mul_u256_div_u256(
            user_pool_info.amount,
            pool_acc_reward_per_share - *table::borrow(&user_pool_info.last_acc_rewards_per_share, reward_coin_name),
            MAX_U64
        ) as u64);
        if (pending > 0) {
            let prev_reward = *table::borrow(&user_pool_info.rewards, reward_coin_name);
            table::upsert(&mut user_pool_info.rewards, reward_coin_name, prev_reward + pending);
        };

        table::upsert(&mut user_pool_info.last_acc_rewards_per_share, reward_coin_name, pool_acc_reward_per_share);
    }

    fun mass_update_pools_thl_rewards(pool_info: &mut vector<PoolInfo>, thl_epoch: &EpochInfo, total_thl_alloc_point: u64) {
        let length: u64 = vector::length<PoolInfo>(pool_info);
        let i = 0;
        while (i < length) {
            update_pool_thl_reward(vector::borrow_mut<PoolInfo>(pool_info, i), thl_epoch, total_thl_alloc_point);
            i = i + 1;
        };
    }

    /// This function **MUST** be called **BEFORE** user stake amount is updated (either increase stake or unstake)
    fun update_pool_thl_reward(pool: &mut PoolInfo, thl_epoch: &EpochInfo, total_thl_alloc_point: u64) {
        if (pool.thl_alloc_point == 0) {
            return
        };

        let thl_name = thl_name();
        let seconds = current_epoch_seconds(thl_epoch);
        let last_reward_sec = clamp_seconds_in_epoch(*table::borrow(&pool.last_rewards_sec, thl_name), thl_epoch);
        if (seconds <= last_reward_sec) {
            return
        };
        
        table::upsert(&mut pool.last_rewards_sec, thl_name, seconds);

        if (pool.stake_amount == 0) {
            return
        };

        // reward = reward duration * total reward rate * (pool.thl_alloc_point / total_thl_alloc_point)
        // where:
        // - reward duration = seconds - last_reward_sec
        // - total reward rate = thl_epoch.reward_per_sec
        let reward = mul_div(
            seconds - last_reward_sec,
            thl_epoch.reward_per_sec * pool.thl_alloc_point,
            total_thl_alloc_point
        );

        let prev_acc_reward_per_share = *table::borrow(&pool.acc_rewards_per_share, thl_name);
        table::upsert(&mut pool.acc_rewards_per_share, thl_name, prev_acc_reward_per_share + mul_u256_div_u256(reward, MAX_U64, (pool.stake_amount as u256)));
    }

    /// Update reward data for an extra reward coin for pool
    /// Unlike `update_pool_thl_reward`, this function does not use allocation points
    /// Make sure reward coin exists in `pool` before calling this function
    /// This function **MUST** be called **BEFORE** user stake amount is updated (either increase stake or unstake)
    fun update_pool_extra_reward(pool: &mut PoolInfo, reward_coin_name: String) {
        let epoch = table::borrow(&pool.extra_rewards, reward_coin_name);
        let seconds = current_epoch_seconds(epoch);
        let last_reward_sec = clamp_seconds_in_epoch(*table::borrow(&pool.last_rewards_sec, reward_coin_name), epoch);
        if (seconds <= last_reward_sec) {
            return
        };
        
        table::upsert(&mut pool.last_rewards_sec, reward_coin_name, seconds);

        if (pool.stake_amount == 0) {
            return
        };

        // reward = reward duration * reward rate
        // where:
        // - reward duration = seconds - last_reward_sec
        // - reward rate = epoch.reward_per_sec
        let reward = (seconds - last_reward_sec) * epoch.reward_per_sec;

        let prev_acc_reward_per_share = *table::borrow(&pool.acc_rewards_per_share, reward_coin_name);
        table::upsert(&mut pool.acc_rewards_per_share, reward_coin_name, prev_acc_reward_per_share + mul_u256_div_u256(reward, MAX_U64, (pool.stake_amount as u256)));
    }

    fun current_epoch_seconds(epoch: &EpochInfo): u64 {
        clamp_seconds_in_epoch(timestamp::now_seconds(), epoch)
    }

    fun clamp_seconds_in_epoch(seconds: u64, epoch: &EpochInfo): u64 {
        if (seconds < epoch.start_sec) epoch.start_sec
        else if (seconds > epoch.end_sec) epoch.end_sec
        else seconds
    }

    /// Multiply u64 by u256 and divide by u256
    /// Returns u256
    fun mul_u256_div_u256(x: u64, y: u256, z: u256): u256 {
        assert!(z != 0, ERR_DIVIDE_BY_ZERO);
        let r = (x as u256) * y / z;
        r
    }

    /// Calculates x * y / z by casting intermediate values to u256 to avoid overflow
    /// All operands are u64
    /// Returns u64
    fun mul_div(x: u64, y: u64, z: u64): u64 {
        assert!(z != 0, ERR_DIVIDE_BY_ZERO);
        let r = (x as u256) * (y as u256) / (z as u256);
        (r as u64)
    }

    fun thl_name(): String {
        type_info::type_name<THL>()
    }

    fun initialized(): bool {
        exists<Farming>(package::resource_account_address())
    }

    fun initialized_v2(): bool {
        exists<FarmingV2>(package::resource_account_address())
    }

    fun v2_only_mode(): bool acquires FarmingV2 {
        initialized_v2() && borrow_global<FarmingV2>(package::resource_account_address()).v2_only_mode
    }

    fun is_vesting_signer(s: &signer): bool {
        signer::address_of(s) == @thl_vesting
    }

    fun user_pool_has_reward_coin(user_pool_info: &UserPoolInfo, reward_coin_name: String): bool {
        table::contains(&user_pool_info.rewards, reward_coin_name)
    }

    fun pool_has_reward_coin(pool_info: &PoolInfo, reward_coin_name: String): bool {
        table::contains(&pool_info.acc_rewards_per_share, reward_coin_name)
    }

    #[test_only]
    public fun init_for_test() {
        package::init_for_test();

        let deployer = account::create_signer_for_test(@thala_farming_deployer);
        init(&deployer);
    }
}

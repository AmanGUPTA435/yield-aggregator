/// Thala Liquid Staking Derivatives (TLSD)
/// is a liquid staking derivates protocol built on top of Aptos Delegated Staking.
/// It leverages dual-token model (thAPT and sthAPT) inspired by Frax Ether
/// with the focus of getting higher yield for stakers compared to staking directly with delegation pools.
module thala_lsd::staking {
    // use std::option;
    // use std::signer;
    // use std::string;
    // use std::vector;

    use aptos_std::fixed_point64::{FixedPoint64};
    // use aptos_std::math64;
    // use aptos_std::simple_map;
    use aptos_std::smart_table::{SmartTable};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin::{Coin, BurnCapability, FreezeCapability, MintCapability};
    // use aptos_framework::event;
    // use aptos_framework::timestamp;

    // Error Codes

    // Authorization
    const ERR_TLSD_UNAUTHORIZED: u64 = 0;

    // Others
    const ERR_TLSD_INVALID_BPS: u64 = 1;
    const ERR_TLSD_INVALID_COIN_AMOUNT: u64 = 2;
    const ERR_TLSD_USER_UNSTAKE_NOT_EXIST: u64 = 3;
    const ERR_TLSD_INVALID_REQUEST_ID: u64 = 4;
    const ERR_TLSD_UNSTAKE_REQUEST_NOT_COMPLETABLE: u64 = 5;


    // Defaults

    /// 30 days is a reasonable duration given it's the staking lockup cycle
    const DEFAULT_UNSTAKING_DURATION_SECONDS: u64 = 30 * 86400;

    // Constants

    const BPS_BASE: u64 = 10000;
    const FEE_MANAGER_ROLE: vector<u8> = b"fee_manager";

    // Resources

    /// Liquid staking APT that can be exchanged for APT at a 1:1 ratio.
    /// In order to redeem ThalaAPT for APT, user either:
    /// (1) calls request_unstake_APT followed by complete_unstake_APT.
    /// (2) exit through thAPT-APT pool in ThalaSwap.
    struct ThalaAPT {}

    /// Yield bearing coin that accrues Aptos staking rewards.
    /// Over time, 1 sthAPT can be exchanged for increasing amount of thAPT.
    struct StakedThalaAPT {}

    struct TLSD has key {
        // invariant: cumulative_restake + cumulative_deposit + cumulative_rewards = total_stake + cumulative_withdrawn (inflow = outflow).
        // we store cumulative_restake, cumulative_deposit, cumulative_withdrawn in contract, and calculate total_stake
        // through contract call to delegation_pool, then derive cumulative_rewards from the invariant
        // and store in contract as well.
        // NOTE: we use u128 for these counter variables since they're all cumulative and can grow very large.
        cumulative_restake: u128,
        cumulative_deposit: u128,
        cumulative_withdrawn: u128,
        cumulative_rewards: u128,

        /// Charged upon request_unstake_APT to encourage long-term staking
        unstake_APT_fee_bps: u64,

        /// Charged upon stake_thAPT to discourage mev between reward epochs
        stake_thAPT_fee_bps: u64,

        // Reward allocation mechanism
        // ----------------------------
        // Rewards generated from validator will be minted as thAPT and they have 3 destinations:
        // 1) commission_fee: retained by the protocol as fee.
        // 2) sthAPT_stakers: via added to thAPT_staking so that each sthAPT can be exchanged for more thAPT.
        // 3) rewards_kept: the rest are kept in the contract and later on distributed to thAPT-APT LPs.
        //
        // Imagine commission_fee_bps = 10%, extra_rewards_for_sthAPT_holders_bps = 75%,
        // thAPT_staking = 8_000_000, thAPT_supply = 10_000_000.
        // given 100 thAPT rewards:
        // - 10 thAPT goes to commission_fee.
        // - for the remaining 90 thAPT, 90*0.8+(90-90*0.8)*0.75 = 85.5 thAPT goes to thAPT_staking.
        //   note the 90*0.8 is pro rate rewards, and the (90-90*0.8)*0.75 is extra rewards.
        // - the remaining 4.5 thAPT goes to rewards_kept.

        commission_fee_bps: u64,
        commission_fee: Coin<ThalaAPT>,
        extra_rewards_for_sthAPT_holders_bps: u64,
        rewards_kept: Coin<ThalaAPT>,

        /// Staking thAPT comes from three sources:
        /// 1) thAPT staked in exchange for sthAPT.
        /// 2) A portion of thAPT minted upon sync_rewards.
        /// 3) Charged thAPT fees from redemption (request_unstake_APT) and stake (stake_thAPT).
        thAPT_staking: Coin<ThalaAPT>,

        /// When user requests to unstake APT, same amount of thAPT will be locked in the contract,
        /// in order to ensure that the user can't spend the thAPT elsewhere.
        /// After user completes unstake APT, same amount of thAPT will be burned.
        thAPT_unstaking: Coin<ThalaAPT>,

        /// A cache that sits between user and underlying delegation pools.
        /// It stores APT that comes from underlying pools upon `request_unstake_APT` and `complete_unstake_APT`.
        /// Whenever user tries to complete a unstake request, the cache will be used first.
        /// If APT in the cache is not enough to fulfill the request, the cache will be refilled from underlying pools
        /// via `withdraw` call.
        apt_pending_withdrawal: Coin<AptosCoin>,

        /// next unstake_request_id, incremented by 1 for each new request
        next_unstake_request_id: u64,

        /// Duration of unstaking period in seconds.
        /// This should be set the same as staking_config::StakingConfig::recurring_lockup_duration_secs
        /// in order to guarantee that after this period of wait, the user can unstake desired APT
        /// from the underlying pools, despite the fact that different pools have different lockup cycles.
        unstake_duration_seconds: u64,

        // thAPT capabilities
        thAPT_burn_capability: BurnCapability<ThalaAPT>,
        thAPT_freeze_capability: FreezeCapability<ThalaAPT>,
        thAPT_mint_capability: MintCapability<ThalaAPT>,

        // sthAPT capabilities
        sthAPT_burn_capability: BurnCapability<StakedThalaAPT>,
        sthAPT_freeze_capability: FreezeCapability<StakedThalaAPT>,
        sthAPT_mint_capability: MintCapability<StakedThalaAPT>,
    }

    /// User's unstake request
    struct UserUnstake has key {
        // unstake_request_id -> UnstakeRequest struct
        requests: SmartTable<u64, UnstakeRequest>,
    }

    struct UnstakeRequest has store, copy, drop {
        account: address,
        request_id: u64,
        start_sec: u64,
        end_sec: u64,
        /// Amount of APT that will be sent to requester after unstake request is completed.
        amount: u64
    }

    #[event]
    /// Event emitted when user stakes APT with TLSD
    struct StakeAPTEvent has drop, store {
        account: address,
        /// The underlying delegation pool
        pool: address,
        /// Amount of APT staked
        staked_APT: u64,
        /// Amount of thAPT minted
        minted_thAPT: u64,
    }

    #[event]
    /// Event emitted when user requests to unstake APT from TLSD
    struct RequestUnstakeAPTEvent has drop, store {
        /// The unstake request id
        request_id: u64,
        /// The account who requests to unstake APT
        account: address,
        /// Amount of APT requested to unstake
        request_amount: u64,
        /// Amount of APT that will be sent to requester after unstake request is completed.
        actual_amount: u64,
        /// Fee
        fee_amount: u64,
        /// Decrement in active stake due to the unlock operation against underlying pools
        active_decrement: u64,
        /// Increment in pending_inactive stake due to the unlock operation against underlying pools
        pending_inactive_increment: u64,
        /// Amount of APT withdrawn from underlying pools and saved to apt_pending_withdrawal
        withdrawn_amount: u64,
    }

    #[event]
    /// Event emitted when user completes the unstake request.
    struct CompleteUnstakeAPTEvent has drop, store {
        /// The unstake request id
        request_id: u64,
        /// The account who completes the unstake request
        account: address,
        /// Amount of APT unstaked for user, also the amount of thAPT burnt
        unstaked_amount: u64,
        /// Amount of APT withdrawn from underlying pools and saved to apt_pending_withdrawal
        withdrawn_amount: u64,
    }

    #[event]
    /// Event emitted when user restakes pending_inactive rewards
    struct RestakeAPTEvent has drop, store {
        /// The unstake request id
        request_id: u64,
        /// The account who completes the unstake request
        account: address,
        /// The pool that is restaked to
        pool: address,
        /// Amount of APT restaked
        restaked_APT: u64,
        /// Total restake increment
        cumulative_restake_increment: u64,
    }

    #[event]
    /// Event emitted when user stakes thAPT in exchange of sthAPT
    struct StakeThalaAPTEvent has drop, store {
        account: address,
        /// Amount of thAPT staked
        thAPT_staked: u64,
        /// Fee
        thAPT_fee: u64,
        /// Amount of sthAPT minted
        sthAPT_minted: u64,
    }

    #[event]
    /// Event emitted when user returns sthAPT and unstakes thAPT
    struct UnstakeThalaAPTEvent has drop, store {
        account: address,
        /// Amount of thAPT unstaked
        thAPT_unstaked: u64,
        /// Amount of sthAPT burned
        sthAPT_burnt: u64,
    }

    #[event]
    /// Event emitted whenever user interacts with LSD
    struct SyncRewardsEvent has drop, store {
        total_active: u128,
        total_inactive: u128,
        total_pending_inactive: u128,
        cumulative_restake: u128,
        cumulative_deposit: u128,
        cumulative_withdrawn: u128,
        prev_cumulative_rewards: u128,
        cumulative_rewards: u128,
        rewards_amount: u64,
        rewards_commission: u64,
        rewards_for_sthAPT_holders: u64,
        rewards_kept: u64,
    }

    // Initialization

    fun init_module(_resource_account_signer: &signer) {
        // register APT since the resource account needs to store APT for delegation_pool interactions
        
    }

    // Config & Param Management

    public entry fun set_unstake_APT_fee_bps(_manager: &signer, _new_bps: u64)  {
        
    }

    public entry fun set_stake_thAPT_fee_bps(_manager: &signer, _new_bps: u64)  {
        
    }

    public entry fun set_commission_fee_bps(_manager: &signer, _new_bps: u64)  {
        
    }

    public entry fun set_extra_rewards_for_sthAPT_holders_bps(_manager: &signer, _new_bps: u64)  {
        
    }

    public entry fun set_unstake_duration_seconds(_manager: &signer, _new_duration_seconds: u64)  {
       
    }

    public fun extract_commission_fee(_account: &signer): Coin<ThalaAPT>  {
        abort 0
    }

    public fun extract_rewards_kept(_account: &signer): Coin<ThalaAPT>  {
        abort 0
    }

    // User operations

    /// Stake APT. Under the hood:
    /// 1) TLSD mints thAPT at a 1:1 ratio to staker.
    /// 2) TLSD stakes APT to delegation pools right away.
    public fun stake_APT(_account: &signer, _coin: Coin<AptosCoin>): Coin<ThalaAPT>  {
        abort 0
    }

    /// Request to unstake APT.
    /// The unstake request will be queued awaiting for triggered by `complete_unstake_APT`.
    public fun request_unstake_APT(_account: &signer, _coin: Coin<ThalaAPT>)  {
        abort 0
    }

    /// Complete a queuing unstake APT request, following up to request_unstake_APT.
    public fun complete_unstake_APT(_account: &signer, _request_id: u64): Coin<AptosCoin>  {
        abort 0
    }

    /// Stakes thAPT and gets sthAPT given exchange rate.
    public fun stake_thAPT(_account: &signer, _coin: Coin<ThalaAPT>): Coin<StakedThalaAPT>  {
        abort 0
    }

    /// Burn sthAPT and unlocks thAPT given exchange rate.
    public fun unstake_thAPT(_account: &signer, _coin: Coin<StakedThalaAPT>): Coin<ThalaAPT>  {
        abort 0
    }

    // View functions

    #[view]
    /// Returns (thAPT_staking, sthAPT_supply) without syncing rewards.
    public fun thAPT_sthAPT_exchange_rate(): (u64, u64)  {
        abort 0
    }

    #[view]
    /// Returns (thAPT_staking, sthAPT_supply) after syncing rewards.
    public fun thAPT_sthAPT_exchange_rate_synced(): (u64, u64)  {
       abort 0 
    }

    #[view]
    public fun thAPT_supply(): u64 {
abort 0
    }

    #[view]
    public fun sthAPT_supply(): u64 {
abort 0
    }

    #[view]
    public fun next_unstake_request_id(): u64  {
abort 0
    }

    #[view]
    public fun unstake_duration_seconds(): u64  {
abort 0
    }

    #[view]
    public fun user_unstake(_account_addr: address): vector<UnstakeRequest>  {
       abort 0 
    }

    #[view]
    public fun unstake_APT_fee_bps(): u64  {
abort 0
    }

    #[view]
    public fun stake_thAPT_fee_bps(): u64  {
abort 0
    }

    #[view]
    public fun commission_fee_bps(): u64  {
abort 0
    }

    #[view]
    public fun commission_fee(): u64  {
abort 0
    }

    #[view]
    public fun extra_rewards_for_sthAPT_holders_bps(): u64  {
abort 0
    }

    #[view]
    public fun rewards_kept(): u64  {
        abort 0
    }

    #[view]
    public fun thAPT_staking(): u64  {
        abort 0
    }

    #[view]
    public fun thAPT_unstaking(): u64  {
        abort 0
    }

    #[view]
    public fun apt_pending_withdrawal(): u64  {
        abort 0
    }

    #[view]
    public fun cumulative_restake(): u128  {
     abort 0   
    }

    #[view]
    public fun cumulative_deposit(): u128  {
       abort 0
    }

    #[view]
    public fun cumulative_withdrawn(): u128  {
        abort 0
    }

    #[view]
    public fun cumulative_rewards(): u128  {
       abort 0
    }

    #[view]
    public fun total_stake(): u128 {
        abort 0
    }

    #[view]
    /// sthAPT reward rate = staking reward rate * (total_active_stake / thAPT_staking)
    /// staking reward rate = sum_i(node i weight * node i reward rate)
    /// => sthAPT reward rate = sum_i(node i active stake * node i reward rate / thAPT_staking)
    public fun sthAPT_reward_rate(): FixedPoint64  {
        abort 0
    }

    // Internal functions

    /// Mint thAPT rewards and distribute to sthAPT holders and thAPT-APT LPs.
    ///
    /// thAPT rewards are minted based on:
    /// 1) cumulative_rewards = max(cumulative_rewards, total_stake + cumulative_withdrawn - cumulative_deposit - cumulative_restake),
    ///    where total_stake = total_active + total_inactive + total_pending_inactive.
    /// 2) mint_thAPT = current cumulative_rewards - last cumulative_rewards.
    ///
    /// The reason why we use max() is because
    /// total_stake + cumulative_withdrawn - cumulative_deposit - cumulative_restake could be less than cumulative_rewards,
    /// that makes mint_thAPT a negative number.
    /// For example, it is possible that cumulative_deposit=9999980753 while total_stake=9999980752 and cumulative_withdrawn=0
    /// due to rounding errors caused by shares-to-coins conversion in delegation_pool operations.
    /// With max(), we guarantee that cumulative_rewards is increment-only and mint_thAPT is always >=0.
    fun sync_rewards()  {
        
    }

    inline fun get_lsd(): &TLSD  {
        abort 0
    }

}
/// This module is the main user facing module of the Tortuga protocol.
///
/// It handles:
///  * APT -> tAPT transactions,
///  * issuing of `Tickets` and claiming them for tAPT -> APT, and,
///  * permissionless staking/withdrawal from validators according to their
///    scores
///
/// The validators will interface with the protocol through the
/// `validator_router` module.
///
module tortuga::stake_router {
    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use std::signer;
    use std::error;
    use std::option;
    use std::vector;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin::{
        Self,
        BurnCapability,
        MintCapability,
        FreezeCapability
    };
    use aptos_framework::timestamp;
    use aptos_std::event::{Self, EventHandle};

    // use tortuga::validator_router;
    // use oracle::validator_states;
    use tortuga_governance::staked_aptos_coin::{
        register_for_t_apt,
        StakedAptosCoin
    };
    // use helpers::math::{Self, mul_div};
    // use tortuga_governance::tortuga_governance::{TortugaGovernance};
    // use governance::permissions;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // #[test_only]
    // use aptos_framework::stake;
    // #[test_only]
    // use helpers::test_helpers;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // struct StakedAptosCoin {}
    /// Struct which holds the current state of the protocol, including the
    /// storage for the protocol fee.
    struct StakingStatus has key {
        /// Stores the protocol commission collected so far
        protocol_fee: coin::Coin<StakedAptosCoin>,

        /// The rate at which protocol charges commission.
        commission: u64,

        /// When a user calls `unstake`,
        /// this much amount is taken from the user and
        /// distributed among all the current users
        /// of the protocol.
        community_rebate: u64,

        /// Total balance of all the tickets issues since genesis.
        total_claims_balance: u128,

        /// Total balance of all the redeemed tickets since genesis.
        total_claims_balance_cleared: u128,

        /// time that a user must wait between ticket issuance and ticket
        /// redemption, and time that must elapse after contract deployment
        /// before `unstake` is available.
        cooldown_period: u64,

        /// timestamp of the contract deployment.
        deployment_time: u64,

        /// principal over which protocol's commission is calculated.
        commission_exempt_amount: u64,

        /// minimum amount to delegate.
        /// Also, used for clearing tAPT dust.
        min_transaction_amount: u64,

        /// Event handle for increasing stake in a validator.
        increase_stake_in_validator_events:
            EventHandle<IncreaseStakeInValidatorEvent>,

        /// Event handle for unlocking stake in a validator.
        unlock_from_validator_events: EventHandle<UnlockFromValidatorEvent>,
     }

    /// Struct which holds handles for events related to staking, unstaking, and
    /// claiming tickets. It is saved with the delegator's accounts.
    struct EventStore has key {

        /// Stores `StakeEvents` for the delegator
        stake_events: EventHandle<StakeEvent>,

        /// Stores `UnstakeEvents` for the delegator
        unstake_events: EventHandle<UnstakeEvent>,

        /// Stores `ClaimEvents` for the delegator
        claim_events: EventHandle<ClaimEvent>,
    }

    /// Capabilities associated with tAPT coin
    struct StakedAptosCapabilities has key {

        /// Mint capability
        mint_cap: MintCapability<StakedAptosCoin>,

        /// Freeze capability
        freeze_cap: FreezeCapability<StakedAptosCoin>,

        /// Burn capability
        burn_cap: BurnCapability<StakedAptosCoin>,
    }

    /// The `ticket` which is issued when a user unstakes.
    struct Ticket has store {

        /// unique `id`,  used to ensure first-in-first-out for claims
        id: u128,

        /// amount in APT that will be redeemed
        amount: u64,

        /// timestamp when the ticket was issued
        timestamp: u64,
    }

    /// A user can have several tickets which are stored in their ticket store
    struct TicketStore has key {

        /// List of all unclaimed tickets the user has.
        tickets: vector<Ticket>
    }

    /// Event emitted when a user stakes
    struct StakeEvent has drop, store {

        /// account address
        delegator: address,

        /// amount staked in APT
        amount: u64,

        /// tAPT coins received
        t_apt_coins: u64,

        /// timestamp when the event happened
        timestamp: u64,
    }

    /// Event emitted when a user unstakes
    struct UnstakeEvent has drop, store {

        /// account address
        delegator: address,

        /// amount unstaked in APT
        amount: u64,

        /// tAPT coins burned
        t_apt_coins: u64,

        /// timestamp when the event happened
        timestamp: u64,
    }

    /// Event emitted when a user claims a ticket
    struct ClaimEvent has drop, store {

        /// Account address
        delegator: address,

        /// Amount claimed in APT
        amount: u64,

        /// Index of the ticket in the `TicketStore`
        ticket_index: u64,

        /// timestamp when the event happened
        timestamp: u64,
    }

    /// Event emitted when a user increases stake in a validator
    struct IncreaseStakeInValidatorEvent has drop, store {

        /// Address of the validator's `ManagedStakingPool`
        managed_pool_address: address,

        /// The increase in stake in APT
        amount: u64,

        /// timestamp when the event happened
        timestamp: u64,
    }

    /// Event emitted when a user unlocks funds from a validator
    struct UnlockFromValidatorEvent has drop, store {

        /// Address of the validator's `ManagedStakingPool`
        managed_pool_address: address,

        /// The amount of funds unlocked in APT
        amount: u64,

        /// timestamp when the event happened
        timestamp: u64,
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When the calculation of APT from shares fails because of incorrect
    /// arguments
    const ETOO_MANY_SHARES: u64 = 2;

    /// When the cooldown for a ticket has not elapsed.
    const ETICKET_NOT_READY_YET: u64 = 3;

    /// When a user tries to claim a ticket without ever having unstaked.
    const ENO_REMAINING_CLAIMS: u64 = 4;

    /// When a ticket cannot be claimed because the funds are not available.
    const EFUND_NOT_AVAILABLE_YET: u64 = 5;

    /// When a non-protocol user tries to do any permissioned operation.
    const EPERMISSION_DENIED: u64 = 6;

    /// When a user tries to unstake a non-existent ticket.
    const EINVALID_TICKET_INDEX: u64 = 8;

    /// When the amount in APT is too small for the operation.
    const EAMOUNT_TOO_SMALL: u64 = 9;

    /// When a user tries to increase too much stake in a validator or unlock
    /// too much from a validator.
    const EINVALID_AMOUNT: u64 = 10;

    /// When the commission being set is too high.
    const ECOMMISSION_TOO_HIGH: u64 = 11;

    /// When the cooldown period being set is too long.
    const ECOOLDOWN_TOO_LONG: u64 = 12;

    /// When the `unstake` operation is called before the cooldown period since
    /// contract deployment has elapsed.
    const EUNSTAKE_NOT_READY_YET: u64 = 13;

    /// When the new min transaction amount is too high.
    const EMIN_TRANSACTION_AMOUNT_TOO_HIGH: u64 = 14;

    /// When the new withdrawal fee is too high.
    const ECOMMUNITY_REBATE_TOO_HIGH: u64 = 15;

    /// When increase in a validator stake is either too small,
    /// or too frequent.
    const EINVALID_INCREASE_STAKE: u64 = 16;

    /// When unlock amount from a validator is either too small,
    /// or not exactly equal to the minimum of current deficit and the
    /// validator's balance.
    const EINVALID_UNLOCK_AMOUNT: u64 = 17;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// The normalizer for the commission rates.
    const COMMISSION_NORMALIZER: u64 = 1000000;

    /// The maximum cooldown period in seconds.
    const MAX_COOLDOWN_PERIOD: u64 = 1209600; // 2 weeks

    /// The maximum minimum transaction amount
    const MAX_MIN_TRANSACTION_AMOUNT: u64 = 100000000000; // 1000 APT

    /// The maximum withdrawal fee amount
    const MAX_COMMUNITY_REBATE: u64 = 30000; // 3%

    /// Minimum transaction amount while increasing or unlocking stake in a validator
    const MIN_VALIDATOR_TRANSACTION_AMOUNT: u64 = 50000000000; // 500 APT

    /// Rate limit for increasing or decreasing stakes in a validator
    const VALIDATOR_INTERACTION_RATE_LIMIT_SEC: u64 = 5 * 60; // 5 minutes

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /*============================== Getters ============================*/

    /// Returns the total tAPT minted.
    public fun get_t_apt_supply(): u64 {
        // (option::extract(&mut coin::supply<StakedAptosCoin>()) as u64)
        abort 0
    }

    /// Returns the total value locked with the protocol in APT (legacy name).
    public fun get_total_value(): u64  {
        abort 0
    }

    /// Returns how much APT can be staked with validators.
    public fun current_total_stakable_amount(): u64  {
        abort 0
    }

    /// This function calculates how much needs to be unlocked from the
    /// validators, to be able to process unclaimed funds.
    public fun current_deficit(): u64  {
        abort 0
    }

    /// Returns the total number of tickets that `delegator` has.
    public fun get_num_tickets(_delegator: address): u64  {
        abort 0
    }

    /// Returns the ticket at position `index` for `delegator` as a
    /// 3-tuple of:
    ///
    ///  * `id: u128`: unique `id`, used to ensure first-in-first-out for
    ///    claims,
    ///  * `amount: u64`, amount in APT that will be redeemed, and,
    ///  * `timestamp: u64`: timestamp when the ticket was issued.
    ///
    /// # Abort condition
    ///   * If `delegator` does not have a ticket at `index`.
    ///
    public fun get_ticket(
        _delegator: address,
        _index: u64
    ): (u128, u64, u64)  {
        abort 0
    }


    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// This initializes the liquid staking protocol for `tortuga` with the
    /// given `commission`, `cooldown_period` and
    /// `max_number_of_validators`.
    ///
    /// # Restrictions
    ///  * Only `tortuga_governance` **deployer** can call this function.
    ///
    /// # Abort conditions
    ///  * If the `commission` is greater than `COMMISSION_NORMALIZER`,
    ///    i.e. 100%.
    ///
    public entry fun initialize_tortuga_liquid_staking(
        _tortuga_governance_deployer: &signer,
        _commission: u64,
        _cooldown_period: u64,
        _max_number_of_validators: u64
    ) {
        // abort 0
    }

    /*=============================== Setters =============================*/

    /// Set the commission that `tortuga` protocol charges to `value`.
    ///
    /// # Restrictions
    ///  * Only `tortuga_governance` can call this function.
    ///
    /// # Abort conditions
    ///  * If the `value` is greater than `COMMISSION_NORMALIZER`, i.e. 100%.
    ///
    public entry fun set_commission(
        _tortuga_governance: &signer,
        _value: u64
    )  {
        
    }

    /// Set the community rebate that `tortuga` users get to `value`.
    ///
    /// # Restrictions
    ///  * Only `tortuga_governance` can call this function.
    ///
    /// # Abort conditions
    ///  * If the `value` is greater than `MAX_WITHDRAWAL_FEE`, i.e. 0.05%.
    ///
    public entry fun set_community_rebate(
        _tortuga_governance: &signer,
        _value: u64
    )  {
        
    }

    /// Set wait period between ticket issuance and redemption.
    ///
    /// # Restrictions
    ///  * Only `tortuga_governance` can call this function.
    ///
    /// # Abort conditions
    ///  * If the `value` is greater than `MAX_COOLDOWN_PERIOD`.
    ///
    public entry fun set_cooldown_period(
        _tortuga_governance: &signer,
        _value: u64
    )  {
        
    }

    /// Set minimum delegation amount.
    ///
    /// # Restrictions
    ///  * Only `tortuga_governance` can call this function.
    ///  * The `value` must be less than `MAX_MIN_TRANSACTION_AMOUNT`.
    ///
    public entry fun set_min_transaction_amount(
        _tortuga_governance: &signer,
        _value: u64
    )  {
        
    }

    /// This is the endpoint for a user who wants to stake `amount` APT and get
    /// tAPT in return. The coins are directly deposited to the user's account.
    ///
    /// # Abort conditions
    ///  * If the `amount` is less than `min_transaction_amount`.
    ///
    public entry fun stake(
        _delegator: &signer,
        _amount: u64
    ) {
        
    }

    /// Request to redeem APT by burn `t_apt_amount` tAPT.
    ///
    /// # Abort conditions
    ///  * If the `t_apt_amount` is less than `min_transaction_amount`.
    ///  * If the `t_apt_amount` is greater than the delegator's tAPT balance.
    ///  * If `cooldown_period` has not passed since the contract's first
    ///    deployment.
    ///
    public entry fun unstake(
        _delegator: &signer,
        _t_apt_amount: u64
    ) 
    {
        
    }

    /// Users can claim their unstaked APTs using this function,
    /// after their funds have unlocked.
    /// A person who unstakes first will become eligible to claim first.
    ///
    /// *Note*: The tickets in `TicketStore` are not guaranteed to be sorted by
    /// their `timestamp` field.
    ///
    /// # Abort conditions
    ///  * If the `delegator` does not have a `TicketStore`.
    ///  * If the `ticket_index` does not exist (anymore).
    ///  * If the `cooldown_period` has not passed since the ticket's creation.
    ///  * If the funds are still locked and not available to be claimed.
    ///
    public entry fun claim(
        _delegator: &signer,
        _ticket_index: u64
    )  {
        
    }

    /// Increase the stake in the given `managed_pool_address` by `amount` if
    /// there are coins to stake in the coin reserve of the protocol and the
    /// current score and stake in the validator allows for it.
    ///
    /// This allows permissionless staking into validators.
    ///
    /// # Abort conditions
    ///  * If the `amount` is smaller than 1 APT.
    ///  * If the validator balance will become more than the target delegation.
    ///    See `validator_states` module for details.
    ///  * If the amount is greater than the `current_total_stakable_amount()`.
    ///
    public entry fun increase_stake_in_validator(
        _managed_pool_address: address,
        _amount: u64
    ) {
        
    }

    /// This function can be called if the total free balance is not enough to
    /// settle outstanding tickets.
    /// Anyone can call this function to unlock from the earliest unlocking
    /// validator, if current deficit is positive.
    ///
    /// # Abort conditions
    ///  * If the `amount` is smaller than 1 APT.
    ///  * If the `amount` is greater than the `current_deficit()`.
    ///
    public entry fun unlock_from_validator(
        _managed_pool_address: address,
        _amount: u64
    ) {
        
    }

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Stakes the given APT coins and returns tAPT coins.
    fun stake_coins(
        _coins_to_stake: coin::Coin<AptosCoin>
    ): coin::Coin<StakedAptosCoin>
    
    {
        abort 0
    }

    /// Creates an `EventStore` for the given `account` if it does not exist.
    fun ensure_event_store(
        _account: &signer
    ) {
        
    }

    /// Charge the protocol fee based on the rewards earned over the
    /// `commission_exempt_amount` and the current `reward_commission`.
    fun charge_protocol_fee_internal()
    
    {
        
    }

    /// Burn the passed `ticket`.
    fun burn_ticket(ticket: Ticket) {
        // let Ticket { id: _id, amount: _amount, timestamp: _timestamp } = ticket;
        abort 0
    }

    /// Calculate the number of shares to mint based on the `value_being_added`
    /// in APT, the `total_worth` (i.e. the TVL) of the protocol in APT, and the
    /// `t_apt_supply`.
    fun calc_shares_to_mint(
        _value_being_added: u64,
        _total_worth: u64,
        _t_apt_supply: u64
    ): u64 {
        abort 0
    }


    /// Calculate the value of `num_shares` if the `total_worth` (TVL) of the
    /// protocol in APT, and the `t_apt_supply`.
    ///
    /// # Abort conditions
    ///  * If `t_apt_supply < num_shares`.
    ///
    // WARNING: This function is repeated in math as a verify only function in
    // order to prove its specs specified in math.spec.move.  If this function
    // is altered, make sure to alter the verify_only function as well.
    fun calc_shares_to_value(
        _num_shares: u64,
        _total_worth: u64,
        _t_apt_supply: u64
    ): u64 {
        abort 0
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    
}

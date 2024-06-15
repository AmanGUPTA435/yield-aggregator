module thala_launch::lbp {
    use std::signer;
    use std::string::{Self, String};

    use aptos_std::event::{Self, EventHandle};
    use aptos_std::table::{Self, Table};
    use aptos_std::type_info;
    use aptos_framework::account;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::timestamp;

    use thala_launch::fees;
    use thala_launch::package;

    use thala_manager::manager;

    use thalaswap_math::weighted_math;

    use fixed_point64::fixed_point64::{Self, FixedPoint64};

    friend thala_launch::init;

    ///
    /// Error Codes
    ///

    // Authorization
    const ERR_UNAUTHORIZED: u64 = 0;

    // Initialization
    const ERR_UNINITIALIZED: u64 = 1;
    const ERR_INITIALIZED: u64 = 2;

    // Others
    const ERR_LBP_WHITELISTED: u64 = 3;
    const ERR_LBP_NOT_WHITELISTED: u64 = 4;
    const ERR_LBP_INVALID_COIN_TYPE: u64 = 5;
    const ERR_LBP_EXIST: u64 = 6;
    const ERR_LBP_NOT_EXIST: u64 = 7;
    const ERR_LBP_NOT_LIVE: u64 = 8;
    const ERR_LBP_ALREADY_LIVE: u64 = 9;
    const ERR_LBP_INVALID_WEIGHTS: u64 = 10;
    const ERR_LBP_INVALID_TIMES: u64 = 11;
    const ERR_LBP_INVALID_BPS: u64 = 12;
    const ERR_LBP_INSUFFICIENT_BALANCE: u64 = 13;
    const ERR_LBP_INSUFFICIENT_INPUT: u64 = 14;
    const ERR_LBP_INVALID_PCT: u64 = 15;
    const ERR_LBP_INVALID_SWAP_FEE: u64 = 16;
    const ERR_LBP_COIN_NOT_REGISTERED: u64 = 17;
    const ERR_LBP_COIN_PAIR_NOT_REGISTERED: u64 = 18;
    const ERR_LBP_SWAP_INVALID_INPUT_AMOUNT: u64 = 19;

    ///
    /// Defaults
    ///

    // Default max duration is 60 days = 24 * 60 * 60 * 60 seconds
    const DEFAULT_MAX_DURATION_SECONDS: u64 = 5184000;

    // The percentage of swap fee that goes to protocol treasury
    const DEFAULT_PROTOCOL_SWAP_FEE_PCT: u64 = 20;

    // By default swap fee cannot exceed 10%
    const DEFAULT_MAX_SWAP_FEE_BPS: u64 = 1000;

    ///
    /// Constants
    ///

    const ONE_HUNDRED: u64 = 100;
    const BPS_BASE: u64 = 10000;

    ///
    /// Resources
    ///

    /// Define a liquidity boosting pool (LBP)
    /// Platform fee is charged based on % of Asset0 raised from an auction (excluding any liquidity provided by creator)
    struct LBP<phantom Asset0, phantom Asset1> has store {
        creator: address,

        // base coin, such as APT & weight schedule
        asset_0: Coin<Asset0>,

        // start and end weights of the base coin
        // the weight of the other coin is ensured to be 1 - weight_0 at any time
        start_weight_0: FixedPoint64, end_weight_0: FixedPoint64,

        // the coin to be auctioned, such as THL
        asset_1: Coin<Asset1>,

        // We also store `1 / (1 - swap_fee_ratio)` to save on gas on fee calculations in `swap_exact_out`
        inverse_negated_swap_fee_ratio: FixedPoint64,
        swap_fee_ratio: FixedPoint64,

        start_time_seconds: u64,
        end_time_seconds: u64,

        // mainly for UI purposes - it allows tracking amount of token 0 accrued, amount of token 1 sold, etc.
        // start_liquidity are written to the table when the LBP is created
        start_liquidity_0: u64,
        start_liquidity_1: u64,

        // end_liquidity are written to the table when the LBP is closed
        end_liquidity_0: u64,
        end_liquidity_1: u64,

        // if the lbp has been closed before it starts
        canceled: bool,

        events: LBPEvents<Asset0, Asset1>
    }

    struct LBPCollection<phantom Asset0, phantom Asset1> has key {
        lbps: Table<address, LBP<Asset0, Asset1>>,

        // Record whitelisted creator addresses in table keys, while table values can be safely ignored
        creator_whitelist: Table<address, bool>,
        creator_whitelist_events: EventHandle<CreatorWhitelistEvent<Asset0, Asset1>>
    }

    struct LBPParams has key {
        max_duration_seconds: u64,
        max_swap_fee_bps: u64,

        protocol_swap_fee_allocation_ratio: FixedPoint64,

        param_change_events: EventHandle<LBPParamChangeEvent>
    }

    ///
    /// Events
    ///

    struct LBPEvents<phantom Asset0, phantom Asset1> has store {
        lbp_creation_events: EventHandle<LBPCreationEvent<Asset0, Asset1>>,
        lbp_close_events: EventHandle<LBPCloseEvent<Asset0, Asset1>>,
        swap_events: EventHandle<SwapEvent<Asset0, Asset1>>
    }

    /// Event emitted when LBP protocol-wide param is changed
    struct LBPParamChangeEvent has drop, store {
        name: String,

        prev_value: u64,
        new_value: u64
    }

    /// Event emitted when an address is granted or revoked whitelist
    struct CreatorWhitelistEvent<phantom Asset0, phantom Asset1> has drop, store {
        creator_addr: address,
        whitelisted: bool
    }

    /// Event emitted when a LBP is created
    struct LBPCreationEvent<phantom Asset0, phantom Asset1> has drop, store {
        creator_addr: address,

        // amounts
        amount_0: u64,
        amount_1: u64,
        
        // weights (use percentage base for readability)
        start_weight_pct_0: u64,
        end_weight_pct_0: u64,
        
        // duration
        start_time_seconds: u64,
        end_time_seconds: u64,

        swap_fee_bps: u64
    }

    /// Event emitted when a LBP is closed (all liquidity withdrawn)
    struct LBPCloseEvent<phantom Asset0, phantom Asset1> has drop, store {
        creator_addr: address,
        amount_0: u64,
        amount_1: u64,
        commission_fee_amount: u64 // commission fee (tax) charged on asset 0
    }

    /// Event emitted when a swap is made
    struct SwapEvent<phantom Asset0, phantom Asset1> has drop, store {
        creator_addr: address,

        // true if buying Asset1 with Asset0, false if otherwise
        is_buy: bool,

        // actual swap amount
        amount_in: u64,
        amount_out: u64,
        fee_amount: u64,

        // weights used
        weight_0: FixedPoint64,
        weight_1: FixedPoint64,

        // resulting balance after the event
        balance_0: u64,
        balance_1: u64,
    }

    ///
    /// Initialization
    ///

    public(friend) fun initialize() {
        assert!(!initialized(), ERR_INITIALIZED);

        // Dependencies
        assert!(fees::initialized(), ERR_UNINITIALIZED);

        let resource_account_signer = package::resource_account_signer();
        move_to(&resource_account_signer, LBPParams {
            max_duration_seconds: DEFAULT_MAX_DURATION_SECONDS,
            max_swap_fee_bps: DEFAULT_MAX_SWAP_FEE_BPS,
            protocol_swap_fee_allocation_ratio: fixed_point64::fraction(DEFAULT_PROTOCOL_SWAP_FEE_PCT, ONE_HUNDRED),
            param_change_events: account::new_event_handle<LBPParamChangeEvent>(&resource_account_signer)
        })
    }

    // we make this a private function that is called on invocation of `grant_whitelist`.
    fun initialize_coin_pair<Asset0, Asset1>() {
        let resource_account_signer = package::resource_account_signer();
        if (!exists<LBPCollection<Asset0, Asset1>>(signer::address_of(&resource_account_signer))) {
            move_to(&resource_account_signer, LBPCollection<Asset0, Asset1> {
                lbps: table::new(),
                creator_whitelist: table::new(),
                creator_whitelist_events: account::new_event_handle<CreatorWhitelistEvent<Asset0, Asset1>>(&resource_account_signer)
            })
        };
    }

    ///
    /// Config & Param Management
    ///

    /// Grant whitelist for creating LBP with a pair of coins, Whitelist can only be used once
    public entry fun grant_whitelist<Asset0, Asset1>(manager: &signer, creator_addr: address) acquires LBPCollection {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        if (!initialized_coin_pair<Asset0, Asset1>()) {
            initialize_coin_pair<Asset0, Asset1>();
        };

        let resource_account_address = package::resource_account_address();
        let lbp_collection = borrow_global_mut<LBPCollection<Asset0, Asset1>>(resource_account_address);
        assert!(!table::contains(&lbp_collection.creator_whitelist, creator_addr), ERR_LBP_WHITELISTED);
        assert!(!table::contains(&lbp_collection.lbps, creator_addr), ERR_LBP_EXIST);

        table::add(&mut lbp_collection.creator_whitelist, creator_addr, true);
        event::emit_event<CreatorWhitelistEvent<Asset0, Asset1>>(
            &mut lbp_collection.creator_whitelist_events,
            CreatorWhitelistEvent { creator_addr, whitelisted: true }
        );
    }

    /// Revoke whitelist of creator address to disallow it from creating a LBP
    public entry fun revoke_whitelist<Asset0, Asset1>(manager: &signer, creator_addr: address) acquires LBPCollection {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(initialized_coin_pair<Asset0, Asset1>(), ERR_LBP_COIN_PAIR_NOT_REGISTERED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let resource_account_address = package::resource_account_address();
        let lbp_collection = borrow_global_mut<LBPCollection<Asset0, Asset1>>(resource_account_address);

        assert!(table::contains(&lbp_collection.creator_whitelist, creator_addr), ERR_LBP_NOT_WHITELISTED);

        table::remove(&mut lbp_collection.creator_whitelist, creator_addr);
        event::emit_event<CreatorWhitelistEvent<Asset0, Asset1>>(
            &mut lbp_collection.creator_whitelist_events,
            CreatorWhitelistEvent { creator_addr, whitelisted: false }
        );
    }

    public entry fun set_protocol_swap_fee_allocation_pct(manager: &signer, new_pct: u64) acquires LBPParams {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(new_pct <= ONE_HUNDRED, ERR_LBP_INVALID_PCT);

        let params = borrow_global_mut<LBPParams>(package::resource_account_address());
        let prev_pct = fixed_point64::decode(fixed_point64::mul(params.protocol_swap_fee_allocation_ratio, ONE_HUNDRED));
        params.protocol_swap_fee_allocation_ratio = fixed_point64::fraction(new_pct, ONE_HUNDRED);

        event::emit_event<LBPParamChangeEvent>(
            &mut params.param_change_events,
            LBPParamChangeEvent { name: string::utf8(b"protocol_swap_fee_allocation_pct"), prev_value: prev_pct, new_value: new_pct }
        )
    }

    public entry fun set_max_swap_fee_bps(manager: &signer, new_bps: u64) acquires LBPParams {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);
        assert!(new_bps <= BPS_BASE, ERR_LBP_INVALID_BPS);

        let params = borrow_global_mut<LBPParams>(package::resource_account_address());
        let prev_bps = params.max_swap_fee_bps;
        params.max_swap_fee_bps = new_bps;

        event::emit_event<LBPParamChangeEvent>(
            &mut params.param_change_events,
            LBPParamChangeEvent { name: string::utf8(b"max_swap_fee_bps"), prev_value: prev_bps, new_value: new_bps }
        )
    }

    public entry fun set_max_duration_seconds(manager: &signer, new_seconds: u64) acquires LBPParams {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(manager::is_authorized(manager), ERR_UNAUTHORIZED);

        let params = borrow_global_mut<LBPParams>(package::resource_account_address());
        let prev_seconds = params.max_duration_seconds;
        params.max_duration_seconds = new_seconds;

        event::emit_event<LBPParamChangeEvent>(
            &mut params.param_change_events,
            LBPParamChangeEvent { name: string::utf8(b"max_duration_seconds"), prev_value: prev_seconds, new_value: new_seconds }
        )
    }

    ///
    /// Functions
    ///

    /// Create LBP scheduled in the future with initial liquidity. Creator address must be whitelisted
    /// Start weight of Asset0 (base coin) must be smaller than end weight
    /// This ensures the price of Asset1 goes down over time (if no one buys)
    /// `start_weight_pct_0` and `end_weight_pct_0` are integer numbers of percentage
    /// Once created, the liquidity amount, weight and time schedule cannot be changed
    public fun create_lbp<Asset0, Asset1>(
        creator: &signer,
        asset_0: Coin<Asset0>,
        asset_1: Coin<Asset1>,
        start_weight_pct_0: u64,
        end_weight_pct_0: u64,
        swap_fee_bps: u64,
        start_time_seconds: u64,
        end_time_seconds: u64
    ) acquires LBPParams, LBPCollection {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(initialized_coin_pair<Asset0, Asset1>(), ERR_LBP_COIN_PAIR_NOT_REGISTERED);

        // Validate LBP Inputs
        assert!(valid_weights_pct(start_weight_pct_0, end_weight_pct_0), ERR_LBP_INVALID_WEIGHTS);
        assert!(coin::is_coin_initialized<Asset0>() && coin::is_coin_initialized<Asset1>(), ERR_LBP_COIN_NOT_REGISTERED);
        assert!(type_info::type_of<Asset0>() != type_info::type_of<Asset1>(), ERR_LBP_INVALID_COIN_TYPE);
        let now_seconds = timestamp::now_seconds();
        assert!(now_seconds < start_time_seconds && start_time_seconds < end_time_seconds, ERR_LBP_INVALID_TIMES);

        // Assert Liquidity
        let amount_0 = coin::value(&asset_0);
        let amount_1 = coin::value(&asset_1);
        assert!(amount_0 > 0 && amount_1 > 0, ERR_LBP_SWAP_INVALID_INPUT_AMOUNT);

        let resource_account_signer = package::resource_account_signer();
        let resource_account_address = signer::address_of(&resource_account_signer);

        let params = borrow_global<LBPParams>(resource_account_address);
        assert!(end_time_seconds - start_time_seconds <= params.max_duration_seconds, ERR_LBP_INVALID_TIMES);
        assert!(swap_fee_bps <= params.max_swap_fee_bps, ERR_LBP_INVALID_SWAP_FEE);

        let lbp_collection = borrow_global_mut<LBPCollection<Asset0, Asset1>>(resource_account_address);
        let creator_addr = signer::address_of(creator);
        assert!(table::contains(&lbp_collection.creator_whitelist, creator_addr), ERR_LBP_NOT_WHITELISTED);
        assert!(!table::contains(&lbp_collection.lbps, creator_addr), ERR_LBP_EXIST);

        // Update Whilelist
        table::remove(&mut lbp_collection.creator_whitelist, creator_addr);

        // Setup & Assert Swap Fee
        let one_fp = fixed_point64::one();
        let swap_fee_ratio = fixed_point64::fraction(swap_fee_bps, BPS_BASE);
        let inverse_negated_swap_fee_ratio = fixed_point64::div_fp(one_fp, fixed_point64::sub_fp(one_fp, swap_fee_ratio));

        let start_weight_0 = fixed_point64::fraction(start_weight_pct_0, ONE_HUNDRED);
        let end_weight_0 = fixed_point64::fraction(end_weight_pct_0, ONE_HUNDRED);

        let lbp = LBP<Asset0, Asset1> {
            creator: signer::address_of(creator),
            asset_0, 
            asset_1,
            start_weight_0,
            end_weight_0,
            start_time_seconds, 
            end_time_seconds,
            swap_fee_ratio, 
            inverse_negated_swap_fee_ratio,
            start_liquidity_0: amount_0,
            start_liquidity_1: amount_1,
            end_liquidity_0: 0,
            end_liquidity_1: 0,
            canceled: false,
            events: LBPEvents {
                lbp_creation_events: account::new_event_handle<LBPCreationEvent<Asset0, Asset1>>(&resource_account_signer),
                lbp_close_events: account::new_event_handle<LBPCloseEvent<Asset0, Asset1>>(&resource_account_signer),
                swap_events: account::new_event_handle<SwapEvent<Asset0, Asset1>>(&resource_account_signer)
            }
        };

        event::emit_event<LBPCreationEvent<Asset0, Asset1>>(
            &mut lbp.events.lbp_creation_events,
            LBPCreationEvent {
                creator_addr,
                amount_0, amount_1,
                start_weight_pct_0, end_weight_pct_0,
                start_time_seconds, end_time_seconds,
                swap_fee_bps,
            }
        );

        table::add(&mut lbp_collection.lbps, creator_addr, lbp);
    }

    /// Only pool creator can close LBP, either before an auction starts, or after it ends
    /// This method withdraws 100% liquidity from the pool
    /// Returns coin 0 and coin 1 removed from pool
    public fun close_lbp<Asset0, Asset1>(creator: &signer): (Coin<Asset0>, Coin<Asset1>)
    acquires LBPCollection {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(initialized_coin_pair<Asset0, Asset1>(), ERR_LBP_COIN_PAIR_NOT_REGISTERED);

        let resource_account_address = package::resource_account_address();
        let lbp_collection = borrow_global_mut<LBPCollection<Asset0, Asset1>>(resource_account_address);

        let creator_addr = signer::address_of(creator);
        assert!(table::contains(&lbp_collection.lbps, creator_addr), ERR_LBP_NOT_EXIST);

        let lbp = table::borrow_mut(&mut lbp_collection.lbps, creator_addr);
        assert!(!lbp_live(lbp), ERR_LBP_ALREADY_LIVE);

        let coin_out_0 = coin::extract_all(&mut lbp.asset_0);
        let coin_out_1 = coin::extract_all(&mut lbp.asset_1);

        let amount_0 = coin::value(&coin_out_0);
        let amount_1 = coin::value(&coin_out_1);

        // update end liquidity and canceled
        lbp.end_liquidity_0 = amount_0;
        lbp.end_liquidity_1 = amount_1;
        if (timestamp::now_seconds() < lbp.start_time_seconds) {
            lbp.canceled = true;
        };

        // Charge LBP commission if end balance of asset0 is greater than initial liquidity
        // Those balance added by pool creator is tax free
        let commission_fee_amount = 0;
        if (amount_0 > lbp.start_liquidity_0) {
            let asset_0_taxable_amount = amount_0 - lbp.start_liquidity_0;
            let commission_fee_amount = fees::lbp_commission_amount<Asset0>(asset_0_taxable_amount);
            fees::absorb_fee<Asset0>(coin::extract(&mut coin_out_0, commission_fee_amount));
        };
        
        event::emit_event<LBPCloseEvent<Asset0, Asset1>>(
            &mut lbp.events.lbp_close_events,
            LBPCloseEvent {
                creator_addr,
                amount_0, 
                amount_1,
                commission_fee_amount
            }
        );

        (coin_out_0, coin_out_1)
    }

    /// Swap exact coins as input.
    public fun swap_exact_in<Asset0, Asset1, In, Out>(creator_addr: address, coin_in: Coin<In>): Coin<Out>
    acquires LBPParams, LBPCollection {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(initialized_coin_pair<Asset0, Asset1>(), ERR_LBP_COIN_PAIR_NOT_REGISTERED);

        let typeof_0 = type_info::type_of<Asset0>();
        let typeof_1 = type_info::type_of<Asset1>();
        let typeof_in = type_info::type_of<In>();
        let typeof_out = type_info::type_of<Out>();
        assert!(typeof_0 != typeof_1, ERR_LBP_INVALID_COIN_TYPE);

        let is_in_0 = typeof_0 == typeof_in;
        let is_out_0 = typeof_0 == typeof_out;
        assert!((is_in_0 && typeof_1 == typeof_out) || (is_out_0 && typeof_1 == typeof_in), ERR_LBP_INVALID_COIN_TYPE);

        let resource_account_address = package::resource_account_address();

        let params = borrow_global<LBPParams>(resource_account_address);
        let lbp_collection = borrow_global<LBPCollection<Asset0, Asset1>>(resource_account_address);
        assert!(table::contains(&lbp_collection.lbps, creator_addr), ERR_LBP_NOT_EXIST);

        let lbp = table::borrow(&lbp_collection.lbps, creator_addr);
        assert!(lbp_live<Asset0, Asset1>(lbp), ERR_LBP_NOT_LIVE);

        // Ensure Input
        let amount_in = coin::value(&coin_in);
        assert!(amount_in > 0, ERR_LBP_SWAP_INVALID_INPUT_AMOUNT);

        // Fee Calculation & Adjust the input amount that is swapped as a result
        let total_fee_amount = fixed_point64::decode(fixed_point64::mul(lbp.swap_fee_ratio, amount_in));
        let protocol_fee_amount = fixed_point64::decode(fixed_point64::mul(params.protocol_swap_fee_allocation_ratio, total_fee_amount));

        // Compute Swap Output
        let idx_in = if (is_in_0) 0 else 1;
        let idx_out = if (is_out_0) 0 else 1;
        let (weight_0, weight_1) = current_weights(lbp);
        let (balance_0, balance_1) = (coin::value(&lbp.asset_0), coin::value(&lbp.asset_1));
        let amount_out = weighted_math::calc_out_given_in(idx_in, idx_out, amount_in - total_fee_amount, &vector<u64>[balance_0, balance_1], &vector<FixedPoint64>[weight_0, weight_1]);

        let balance_out = if (is_out_0) balance_0 else balance_1;
        assert!(amount_out < balance_out, ERR_LBP_INSUFFICIENT_BALANCE);

        // Absorb Protocol Fees
        fees::absorb_fee(coin::extract(&mut coin_in, protocol_fee_amount));

        // Absorb Swapped In Asset. Yield is provided to LPs by their implicit increased in value with the lp fees included in `coin_in`
        deposit<Asset0, Asset1, In>(resource_account_address, creator_addr, is_in_0, coin_in);

        // Extract Swapped Out Asset
        let coin_out = withdraw<Asset0, Asset1, Out>(resource_account_address, creator_addr, is_out_0, amount_out);

        // Emit event
        let lbp_collection = borrow_global_mut<LBPCollection<Asset0, Asset1>>(resource_account_address);
        let lbp = table::borrow_mut(&mut lbp_collection.lbps, creator_addr);
        event::emit_event<SwapEvent<Asset0, Asset1>>(
            &mut lbp.events.swap_events,
            SwapEvent {
                creator_addr,
                is_buy: is_in_0,
                amount_in, amount_out,
                weight_0, weight_1,
                fee_amount: total_fee_amount,
                balance_0: coin::value(&lbp.asset_0),
                balance_1: coin::value(&lbp.asset_1),
            }
        );

        coin_out
    }

    /// Swap coins for exact output.
    /// Returns (refunded_in, out).
    /// Input coin amount must be positive.
    /// Aborts if input coins are not sufficient to swap out the exact amount.
    public fun swap_exact_out<Asset0, Asset1, In, Out>(creator_addr: address, coin_in: Coin<In>, amount_out: u64): (Coin<In>, Coin<Out>)
    acquires LBPParams, LBPCollection {
        assert!(initialized(), ERR_UNINITIALIZED);
        assert!(initialized_coin_pair<Asset0, Asset1>(), ERR_LBP_COIN_PAIR_NOT_REGISTERED);

        let typeof_0 = type_info::type_of<Asset0>();
        let typeof_1 = type_info::type_of<Asset1>();
        let typeof_in = type_info::type_of<In>();
        let typeof_out = type_info::type_of<Out>();
        assert!(typeof_0 != typeof_1, ERR_LBP_INVALID_COIN_TYPE);

        let is_in_0 = typeof_in == typeof_0;
        let is_out_0 = typeof_out == typeof_0;
        assert!((is_in_0 && typeof_1 == typeof_out) || (is_out_0 && typeof_1 == typeof_in), ERR_LBP_INVALID_COIN_TYPE);

        let resource_account_address = package::resource_account_address();

        let params = borrow_global<LBPParams>(resource_account_address);
        let lbp_collection = borrow_global<LBPCollection<Asset0, Asset1>>(resource_account_address);
        assert!(table::contains(&lbp_collection.lbps, creator_addr), ERR_LBP_NOT_EXIST);

        let lbp = table::borrow(&lbp_collection.lbps, creator_addr);
        assert!(lbp_live<Asset0, Asset1>(lbp), ERR_LBP_NOT_LIVE);

        let idx_in = if (is_in_0) 0 else 1;
        let idx_out = if (is_out_0) 0 else 1;
        let (weight_0, weight_1) = current_weights(lbp);
        let (balance_0, balance_1) = (coin::value(&lbp.asset_0), coin::value(&lbp.asset_1));
        let balance_out = if (is_out_0) balance_0 else balance_1;

        // Ensure Liquidity & Input
        assert!(amount_out < balance_out, ERR_LBP_INSUFFICIENT_BALANCE);
        assert!(amount_out > 0, ERR_LBP_INSUFFICIENT_INPUT);

        let provided_amount_in = coin::value(&coin_in);
        assert!(provided_amount_in > 0, ERR_LBP_SWAP_INVALID_INPUT_AMOUNT);

        // Compute Swap Input
        //  - `amount_in` calculated needs to be increased to also include the swap fee. `amount_in / (1 - swap_fee_ratio)` represents the
        //  the input necessary to generate `amount_out` with an input that also accounts for the necesarry fee.
        let amount_in = weighted_math::calc_in_given_out(idx_in, idx_out, amount_out, &vector<u64>[balance_0, balance_1], &vector<FixedPoint64>[weight_0, weight_1]);
        let total_amount_in = fixed_point64::decode_round_up(fixed_point64::mul(lbp.inverse_negated_swap_fee_ratio, amount_in));
        assert!(total_amount_in <= provided_amount_in, ERR_LBP_INSUFFICIENT_INPUT);

        let total_fee_amount = total_amount_in - amount_in;
        let protocol_fee_amount = fixed_point64::decode(fixed_point64::mul(params.protocol_swap_fee_allocation_ratio, total_fee_amount));

        // Absorb Protocol Fees
        fees::absorb_fee(coin::extract(&mut coin_in, protocol_fee_amount));

        // Absorb Swapped In Asset. Yield is provided to LPs by their implicit increased in value with lp fees included in `coin_in_swapped`.
        //   - Since the caller can provide arbitrary input, we extract the exact amount and refund the rest
        let coin_in_swapped = coin::extract(&mut coin_in, total_amount_in - protocol_fee_amount);
        deposit<Asset0, Asset1, In>(resource_account_address, creator_addr, is_in_0, coin_in_swapped);

        // Extract Swapped Out Asset
        let coin_out = withdraw<Asset0, Asset1, Out>(resource_account_address, creator_addr, is_out_0, amount_out);

        // Emit event
        let lbp_collection = borrow_global_mut<LBPCollection<Asset0, Asset1>>(resource_account_address);
        let lbp = table::borrow_mut(&mut lbp_collection.lbps, creator_addr);
        event::emit_event<SwapEvent<Asset0, Asset1>>(
            &mut lbp.events.swap_events,
            SwapEvent {
                creator_addr,
                is_buy: is_in_0,
                amount_in: total_amount_in, amount_out,
                fee_amount: total_fee_amount,
                weight_0, weight_1,
                balance_0: coin::value(&lbp.asset_0),
                balance_1: coin::value(&lbp.asset_1),
            }
        );

        (coin_in, coin_out)
    }

    fun deposit<Asset0, Asset1, In>(lbp_resource_address: address, creator_addr: address, is_in_0: bool, coin: Coin<In>) acquires LBPCollection {
        if (is_in_0) {
            let lbp_collection = borrow_global_mut<LBPCollection<In, Asset1>>(lbp_resource_address);
            let lbp = table::borrow_mut(&mut lbp_collection.lbps, creator_addr);
            coin::merge(&mut lbp.asset_0, coin);
        } else {
            let lbp_collection = borrow_global_mut<LBPCollection<Asset0, In>>(lbp_resource_address);
            let lbp = table::borrow_mut(&mut lbp_collection.lbps, creator_addr);
            coin::merge(&mut lbp.asset_1, coin);
        }
    }

    fun withdraw<Asset0, Asset1, Out>(lbp_resource_address: address, creator_addr: address, is_out_0: bool, amount: u64): Coin<Out> acquires LBPCollection {
        if (is_out_0) {
            let lbp_collection = borrow_global_mut<LBPCollection<Out, Asset1>>(lbp_resource_address);
            let lbp = table::borrow_mut(&mut lbp_collection.lbps, creator_addr);
            coin::extract(&mut lbp.asset_0, amount)
        } else {
            let lbp_collection = borrow_global_mut<LBPCollection<Asset0, Out>>(lbp_resource_address);
            let lbp = table::borrow_mut(&mut lbp_collection.lbps, creator_addr);
            coin::extract(&mut lbp.asset_1, amount)
        }
    }


    // Public Getters
    
    public fun initialized(): bool {
        exists<LBPParams>(package::resource_account_address())
    }

    public fun initialized_coin_pair<Asset0, Asset1>(): bool {
        exists<LBPCollection<Asset0, Asset1>>(package::resource_account_address())
    }

    public fun live<Asset0, Asset1>(creator_addr: address): bool acquires LBPCollection {
        let lbp_collection = borrow_global<LBPCollection<Asset0, Asset1>>(package::resource_account_address());
        let lbp = table::borrow(&lbp_collection.lbps, creator_addr);
        lbp_live(lbp)
    }

    public fun weights<Asset0, Asset1>(creator_addr: address): (FixedPoint64, FixedPoint64) acquires LBPCollection {
        let lbp_collection = borrow_global<LBPCollection<Asset0, Asset1>>(package::resource_account_address());
        let lbp = table::borrow(&lbp_collection.lbps, creator_addr);
        current_weights(lbp)
    }

    public fun balances<Asset0, Asset1>(creator_addr: address): (u64, u64) acquires LBPCollection {
        let lbp_collection = borrow_global<LBPCollection<Asset0, Asset1>>(package::resource_account_address());
        let lbp = table::borrow(&lbp_collection.lbps, creator_addr);
        (coin::value(&lbp.asset_0), coin::value(&lbp.asset_1))
    }

    // Internal Helpers

    fun lbp_live<Asset0, Asset1>(lbp: &LBP<Asset0, Asset1>): bool {
        let now_seconds = timestamp::now_seconds();
        !lbp.canceled && lbp.start_time_seconds <= now_seconds && now_seconds <= lbp.end_time_seconds
    }

    fun valid_weights_pct(start_weight: u64, end_weight: u64): bool {
        start_weight > 0 && start_weight < end_weight && end_weight < ONE_HUNDRED
    }

    // Given the current time, calculate the current weights (in FP64) of the LBP.
    fun current_weights<Asset0, Asset1>(lbp: &LBP<Asset0, Asset1>): (FixedPoint64, FixedPoint64) {
        let now_seconds = timestamp::now_seconds();

        // The first asset's weights are always increasing. Since the sum of weights must always equal 1.0, we can simply
        // negate the interpolated value for weight 0.
        let weight_0 = interpolate_weight(lbp.start_weight_0, lbp.end_weight_0, lbp.start_time_seconds, lbp.end_time_seconds, now_seconds);
        let weight_1 = fixed_point64::sub_fp(fixed_point64::one(), weight_0);
        (weight_0, weight_1)
    }

    // calculate the current weight between [start_weight, end_weight] given the (start_times_seonds, end_time_seconds) time bounds.
    // CONTRACT: start_weight <= end_weight (this should be ensured at LBP creation / configuration time)
    fun interpolate_weight(start_weight: FixedPoint64, end_weight: FixedPoint64, start_time_seconds: u64, end_time_seconds: u64, now_seconds: u64): FixedPoint64 {
        if (fixed_point64::eq(&start_weight, &end_weight) || now_seconds <= start_time_seconds) start_weight
        else if (now_seconds >= end_time_seconds) end_weight
        else {
            let elapsed = now_seconds - start_time_seconds;
            let duration = end_time_seconds - start_time_seconds;
            let progress_ratio = fixed_point64::fraction(elapsed, duration);

            // Since `start_weight < end_weight`, we're always adding to `start_weight`.
            let weight_diff = fixed_point64::sub_fp(end_weight, start_weight);
            fixed_point64::add_fp(fixed_point64::mul_fp(progress_ratio, weight_diff), start_weight)
        }
    }

    #[test]
    fun interpolate_weight_ok() {
        let x = fixed_point64::fraction(1, 2); // 0.5
        let y = fixed_point64::fraction(3, 2); // 1.5
        let a: u64 = 0;
        let b: u64 = 10;

        let t = 0;
        let result = interpolate_weight(x, y, a, b, t);
        assert!(fixed_point64::eq(&result, &x), 0);

        t = 20;
        result = interpolate_weight(x, y, a, b, t);
        assert!(fixed_point64::eq(&result, &y), 0);

        t = 5;
        result = interpolate_weight(x, y, a, b, t);
        assert!(fixed_point64::decode(result) == 1, 0);

        t = 3;
        result = interpolate_weight(x, y, a, b, t); // 0.5 + 1 * 0.3 = 0.8
        assert!(fixed_point64::decode(fixed_point64::mul(result, 100)) == 80, 0);

        // Fractional values
        t = 1;
        b = 8;
        result = interpolate_weight(x, y, a, b, t); // 0.5 + 1 * 1/8 = 0.625
        assert!(fixed_point64::eq(&result, &fixed_point64::fraction(625, 1000)), 0);
    }
}

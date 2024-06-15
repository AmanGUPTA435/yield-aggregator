module bridge::asset {
    struct USDC {}
    struct USDT {}
    struct BUSD {}
    struct USDD {}

    struct WETH {}
    struct WBTC {}
}

module bridge::coin_bridge {
    // use std::error;
    use std::string;
    // use std::vector;
    // use std::signer::address_of;

    use aptos_std::table::Table;
    use aptos_std::event::EventHandle;
    use aptos_std::type_info::TypeInfo;
    // use aptos_std::from_bcs::to_address;
    // use aptos_std::math64;

    use aptos_framework::coin::{BurnCapability, MintCapability, FreezeCapability, Coin};
    use aptos_framework::aptos_coin::AptosCoin;
    // use aptos_framework::account;
    // use aptos_framework::aptos_account;

    // use layerzero_common::utils::{vector_slice, assert_u16, assert_signer, assert_length};
    use layerzero::endpoint::{UaCapability};
    use zro::zro::{ZRO};
    

    const EBRIDGE_UNREGISTERED_COIN: u64 = 0x00;
    const EBRIDGE_COIN_ALREADY_EXISTS: u64 = 0x01;
    const EBRIDGE_REMOTE_COIN_NOT_FOUND: u64 = 0x02;
    const EBRIDGE_INVALID_COIN_TYPE: u64 = 0x03;
    const EBRIDGE_CLAIMABLE_COIN_NOT_FOUND: u64 = 0x04;
    const EBRIDGE_INVALID_COIN_DECIMALS: u64 = 0x05;
    const EBRIDGE_COIN_NOT_UNWRAPPABLE: u64 = 0x06;
    const EBRIDGE_INSUFFICIENT_LIQUIDITY: u64 = 0x07;
    const EBRIDGE_INVALID_ADDRESS: u64 = 0x08;
    const EBRIDGE_INVALID_SIGNER: u64 = 0x09;
    const EBRIDGE_INVALID_PACKET_TYPE: u64 = 0x0a;
    const EBRIDGE_PAUSED: u64 = 0x0b;
    const EBRIDGE_SENDING_AMOUNT_TOO_FEW: u64 = 0x0c;
    const EBRIDGE_INVALID_ADAPTER_PARAMS: u64 = 0x0d;

    // paceket type, in line with EVM
    const PRECEIVE: u8 = 0;
    const PSEND: u8 = 1;

    const SHARED_DECIMALS: u8 = 6;

    const SEND_PAYLOAD_SIZE: u64 = 74;

    // layerzero user application generic type for this app
    struct BridgeUA {}

    struct Path has copy, drop {
        remote_chain_id: u64,
        remote_coin_addr: vector<u8>,
    }

    struct CoinTypeStore has key {
        type_lookup: Table<Path, TypeInfo>,
        types: vector<TypeInfo>,
    }

    struct LzCapability has key {
        cap: UaCapability<BridgeUA>
    }

    struct Config has key {
        paused_global: bool,
        paused_coins: Table<TypeInfo, bool>, // coin type -> paused
        custom_adapter_params: bool,
    }

    struct RemoteCoin has store, drop {
        remote_address: vector<u8>,
        // in shared decimals
        tvl_sd: u64,
        // whether the coin can be unwrapped into native coin on remote chain, like WETH -> ETH on ethereum, WBNB -> BNB on BSC
        unwrappable: bool,
    }

    struct CoinStore<phantom CoinType> has key {
        ld2sd_rate: u64,
        // chainId -> remote coin
        remote_coins: Table<u64, RemoteCoin>,
        // chain id of remote coins
        remote_chains: vector<u64>,
        claimable_amt_ld: Table<address, u64>,
        // coin caps
        mint_cap: MintCapability<CoinType>,
        burn_cap: BurnCapability<CoinType>,
        freeze_cap: FreezeCapability<CoinType>,
    }

    struct EventStore has key {
        send_events: EventHandle<SendEvent>,
        receive_events: EventHandle<ReceiveEvent>,
        claim_events: EventHandle<ClaimEvent>,
    }

    struct SendEvent has drop, store {
        coin_type: TypeInfo,
        dst_chain_id: u64,
        dst_receiver: vector<u8>,
        amount_ld: u64,
        unwrap: bool,
    }

    struct ReceiveEvent has drop, store {
        coin_type: TypeInfo,
        src_chain_id: u64,
        receiver: address,
        amount_ld: u64,
        stashed: bool,
    }

    struct ClaimEvent has drop, store {
        coin_type: TypeInfo,
        receiver: address,
        amount_ld: u64,
    }

    fun init_module(_account: &signer) {
        
    }

    //
    // layerzero admin interface
    //
    // admin function to add coin to the bridge
    public entry fun register_coin<CoinType>(
        _account: &signer,
        _name: string::String,
        _symbol: string::String,
        _decimals: u8,
        _limiter_cap_sd: u64
    ) {
        
    }

    // admin function to configure TWA cap
    public entry fun set_limiter_cap<CoinType>(_account: &signer, _enabled: bool, _cap_sd: u64, _window_sec: u64) {
        
    }

    // one registered CoinType can have multiple remote coins, e.g. ETH-USDC and AVAX-USDC
    public entry fun set_remote_coin<CoinType>(
        _account: &signer,
        _remote_chain_id: u64,
        _remote_coin_addr: vector<u8>,
        _unwrappable: bool,
    )  {
        
    }

    public entry fun set_global_pause(_account: &signer, _paused: bool)  {
        
    }

    public entry fun set_pause<CoinType>(_account: &signer, _paused: bool)  {
        
    }

    public entry fun enable_custom_adapter_params(_account: &signer, _enabled: bool)  {
        
    }

    public fun get_coin_capabilities<CoinType>(_account: &signer): (MintCapability<CoinType>, BurnCapability<CoinType>, FreezeCapability<CoinType>) {
        abort 0
    }

    //
    // coin transfer functions
    //
    public fun send_coin<CoinType>(
        _coin: Coin<CoinType>,
        _dst_chain_id: u64,
        _dst_receiver: vector<u8>,
        _fee: Coin<AptosCoin>,
        _unwrap: bool,
        _adapter_params: vector<u8>,
        _msglib_params: vector<u8>,
    ): Coin<AptosCoin>  {
        abort 0
    }

    public fun send_coin_with_zro<CoinType>(
        _coin: Coin<CoinType>,
        _dst_chain_id: u64,
        _dst_receiver: vector<u8>,
        _native_fee: Coin<AptosCoin>,
        _zro_fee: Coin<ZRO>,
        _unwrap: bool,
        _adapter_params: vector<u8>,
        _msglib_params: vector<u8>,
    ): (Coin<AptosCoin>, Coin<ZRO>)  {
       abort 0
    }

    public entry fun send_coin_from<CoinType>(
        _sender: &signer,
        _dst_chain_id: u64,
        _dst_receiver: vector<u8>,
        _amount_ld: u64,
        _native_fee: u64,
        _zro_fee: u64,
        _unwrap: bool,
        _adapter_params: vector<u8>,
        _msglib_params: vector<u8>,
    )  {
        
    }

    fun send_coin_internal<CoinType>(
        _coin: Coin<CoinType>,
        _dst_chain_id: u64,
        _dst_receiver: vector<u8>,
        _native_fee: Coin<AptosCoin>,
        _zro_fee: Coin<ZRO>,
        _unwrap: bool,
        _adapter_params: vector<u8>,
        _msglib_params: vector<u8>,
    ): (Coin<AptosCoin>, Coin<ZRO>)  {
        abort 0
    }

    public entry fun lz_receive<CoinType>(_src_chain_id: u64, _src_address: vector<u8>, _payload: vector<u8>) {
        
    }

    public entry fun claim_coin<CoinType>(_receiver: &signer) {
        
    }

    //
    // public view functions
    //
    #[view]
    public fun lz_receive_types(_src_chain_id: u64, _src_address: vector<u8>, _payload: vector<u8>): vector<TypeInfo>  {
       abort 0
    }

    #[view]
    public fun has_coin_registered<CoinType>(): bool {
        abort 0    
    }

    #[view]
    public fun quote_fee(_dst_chain_id: u64, _pay_in_zro: bool, _adapter_params: vector<u8>, _msglib_params: vector<u8>): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_tvls_sd<CoinType>(): (vector<u64>, vector<u64>) {
        abort 0
    }

    public fun remove_dust_ld<CoinType>(_amount_ld: u64): u64 {
        abort 0
    }

    public fun is_valid_remote_coin<CoinType>(_remote_chain_id: u64, _remote_coin_addr: vector<u8>): bool  {
        abort 0
    }

    //
    // internal functions
    //
    fun withdraw_coin_if_needed<CoinType>(_account: &signer, _amount_ld: u64): Coin<CoinType> {
        abort 0
    }

    fun deposit_coin_if_needed<CoinType>(_account: address, _coin: Coin<CoinType>) {
       abort 0
    }

    // ld = local decimal. sd = shared decimal among all chains
    fun ld2sd(_amount_ld: u64, _ld2sd_rate: u64): u64 {
        abort 0    
    }

    fun sd2ld(_amount_sd: u64, _ld2sd_rate: u64): u64 {
    abort 0
    }

    // encode payload: packet type(1) + remote token(32) + receiver(32) + amount(8) + unwarp flag(1)
    fun encode_send_payload(_dst_coin_addr: vector<u8>, _dst_receiver: vector<u8>, _amount_sd: u64, _unwrap: bool): vector<u8> {
        abort 0
    }

    // decode payload: packet type(1) + remote token(32) + receiver(32) + amount(8)
    fun decode_receive_payload(_payload: &vector<u8>): (vector<u8>, vector<u8>, u64) {
        abort 0
    }

    fun check_adapter_params(_dst_chain_id: u64, _adapter_params: &vector<u8>) {
        
    }

    fun assert_registered_coin<CoinType>() {

    }

    fun assert_unpaused<CoinType>() {
        
    }

}
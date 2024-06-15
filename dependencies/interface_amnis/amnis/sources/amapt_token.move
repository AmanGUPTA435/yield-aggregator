module amnis::amapt_token {
    use 0000000000000000000000000000000000000000000000000000000000000001::coin::{Coin,BurnCapability,FreezeCapability,MintCapability};
    // use 0000000000000000000000000000000000000000000000000000000000000001::option;
    // use 0000000000000000000000000000000000000000000000000000000000000001::string;
    // use aptos_framework::object::{Object};
    // use amnis::package_manager;


    struct AmnisApt has key {
        dummy_field: bool
    }
    struct StakedAptCapabilities has key {
        burn_cap: BurnCapability<AmnisApt>,
        freeze_cap: FreezeCapability<AmnisApt>,
        mint_cap: MintCapability<AmnisApt>
    }

    public(friend) fun burn(_arg0: Coin<AmnisApt>) {
        abort 0
    }
    public(friend) fun initialize() {

    }
    public(friend) fun mint(_arg0: u64): Coin<AmnisApt> {
        abort 0
    }
    public fun total_supply(): u128 {
        abort 0
    }
}
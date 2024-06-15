module avex::resource_account {

    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::timestamp;
    use std::bcs;
    // friend avex::lending_events;
    // friend avex::lsd_events;

    struct SignerCapabilityStore has key {
        signer_capability: SignerCapability
    }


    #[view]
    public(friend) fun get_address():
    address
    acquires SignerCapabilityStore {
        let signer_capability_ref =
            &borrow_global<SignerCapabilityStore>(@avex).signer_capability;
        account::get_signer_capability_address(signer_capability_ref)
    }

    public(friend) fun get_signer():
    signer
    acquires SignerCapabilityStore {
        let signer_capability_ref =
            &borrow_global<SignerCapabilityStore>(@avex).signer_capability;
        account::create_signer_with_capability(signer_capability_ref)
    }

   
    fun init_module(
        volt: &signer
    ) {
        let time_seed = bcs::to_bytes(&timestamp::now_microseconds());
        let (_, signer_capability) =
            account::create_resource_account(volt, time_seed);
        move_to(volt, SignerCapabilityStore{signer_capability});
    }


}
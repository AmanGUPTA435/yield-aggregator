/// This module handles the managment & control over the resource account.
///
/// This module also contains the entry point to publish upgrades or new modules
/// to the resource itself via `package::publish_package`, gated by the ThalaManager.
///
/// NOTE: When copying over this module definitely to other modules which require similar
/// behavior, ensure to also update expected deployer address and the hardcoded seed to which
/// the resource account was derived from. See the comment block below
module thala_oracle::package {

    // *************************************************************************
    // IMPORTANT                                                              //
    //                                                                        //
    // The resource address is derived from a combination of these two        //
    // constants. The combination must be unique and CANNOT be shared         //
    // across different projects. At least the seed must be changed           //
    //                                                                        //
    const DEPLOYER_ADDRESS: address = @thala_oracle_deployer;
    const RESOURCE_ACCOUNT_SEED: vector<u8> = b"thala_oracle";
    const RESOURCE_ACCOUNT_ADDRESS: address = @thala_oracle;
    //                                                                        //
    // Modules that can interface with the resource signer                    //
    friend thala_oracle::params;
    friend thala_oracle::pyth_oracle;
    friend thala_oracle::simple_oracle;
    friend thala_oracle::oracle;
    friend thala_oracle::switchboard_oracle;
    friend thala_oracle::tiered_oracle;
    friend thala_oracle::thala_lp_oracle;
    friend thala_oracle::stable_pool_twap_oracle;
    //                                                                        //
    //                                                                        //
    // *************************************************************************

    use std::signer;

    use aptos_framework::account;
    use aptos_framework::code;
    use aptos_framework::resource_account;

    struct ResourceSignerCapability has key {
        signer_cap: account::SignerCapability,
    }

    ///
    /// Error Codes
    ///

    // Authorization
    const ERR_PACKAGE_UNAUTHORIZED: u64 = 0;

    // Initialization
    const ERR_PACKAGE_INITIALIZED: u64 = 1;
    const ERR_PACKAGE_UNINITIALIZED: u64 = 2;

    const ERR_PACKAGE_ADDRESS_MISMATCH: u64 = 3;

    ///
    /// Initialization
    ///

    // Invoked when package is published. We bootstrap the signer packer and claim ownership
    // of the SignerCapability right away
    fun init_module(resource_signer: &signer) {
        let resource_account_address = signer::address_of(resource_signer);
        assert!(!exists<ResourceSignerCapability>(resource_account_address), ERR_PACKAGE_INITIALIZED);

        // ensure the right templated variables are used. This also implicity ensures that `RESOURCE_ACCOUNT_ADDRESS != DEPLOYER_ADDRESS`
        // since there's no seed where `dervied_resource_account_address() == DEPLOYER_ADDRESS`.
        assert!(resource_account_address == derived_resource_account_address(), ERR_PACKAGE_ADDRESS_MISMATCH);
        assert!(resource_account_address == resource_account_address(), ERR_PACKAGE_ADDRESS_MISMATCH);

        let signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, DEPLOYER_ADDRESS);
        move_to(resource_signer, ResourceSignerCapability { signer_cap });
    }

    ///
    /// Functions
    ///

    public(friend) fun resource_account_signer(): signer acquires ResourceSignerCapability {
        assert!(initialized(), ERR_PACKAGE_UNINITIALIZED);

        let resource_account_address = resource_account_address();
        let ResourceSignerCapability { signer_cap } = borrow_global<ResourceSignerCapability>(resource_account_address);
        account::create_signer_with_capability(signer_cap)
    }

    /// Entry point to publishing new or upgrading modules AFTER initialization, gated by the ThalaManager
    public entry fun publish_package(account: &signer, metadata_serialized: vector<u8>, code: vector<vector<u8>>) acquires ResourceSignerCapability {
        assert!(thala_manager::manager::is_authorized(account), ERR_PACKAGE_UNAUTHORIZED);

        let resource_account_signer = resource_account_signer();
        code::publish_package_txn(&resource_account_signer, metadata_serialized, code);
    }

    // Public Getters

    public fun initialized(): bool {
        exists<ResourceSignerCapability>(resource_account_address())
    }

    public fun resource_account_deployer_address(): address {
        DEPLOYER_ADDRESS 
    }

    public fun resource_account_address(): address {
        // We don't call `derived_resource_account_address` to save on the sha3 call. `init_module` that's called on deployment
        // already ensures that `RESOURCE_ACCOUNT_ADDRESS == derived_resource_account_address()`.
        RESOURCE_ACCOUNT_ADDRESS
    }

    // Internal Helpers

    fun derived_resource_account_address(): address {
        account::create_resource_address(&DEPLOYER_ADDRESS, RESOURCE_ACCOUNT_SEED)
    }

    #[test_only]
    public fun init_for_test() {
        // Zero auth key
        let auth_key = x"0000000000000000000000000000000000000000000000000000000000000000";

        // `account::create_signer_for_test` on the next release to simplify account generation below

        // Setup the generated resource account with the SignerCapability ready to be claimed
        let deployer_account = account::create_signer_with_capability(&account::create_test_signer_cap(DEPLOYER_ADDRESS));
        resource_account::create_resource_account(&deployer_account, RESOURCE_ACCOUNT_SEED, auth_key);

        // Init the module with the expected resource address
        let resource_account = account::create_signer_with_capability(&account::create_test_signer_cap(RESOURCE_ACCOUNT_ADDRESS));
        init_module(&resource_account);
    }
}

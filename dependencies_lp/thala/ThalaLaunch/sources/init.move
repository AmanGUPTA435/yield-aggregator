module thala_launch::init {
    use std::signer;

    use thala_launch::fees;
    use thala_launch::lbp;
    use thala_launch::package;

    use thala_manager::manager;

    ///
    /// Error Codes
    ///

    // Authorization
    const ERR_UNAUTHORIZED: u64 = 0;

    // Initialization
    const ERR_INITIALIZED: u64 = 1;
    const ERR_UNINITIALIZED: u64 = 2;

    // Core Dependencies
    const ERR_PACKAGE_UNINITIALIZED: u64 = 3;
    const ERR_MANAGER_UNINITIALIZED: u64 = 4;

    /// Initialize the LBP modules. **MUST** be called from the deploying account
    public entry fun initialize(deployer: &signer) {
        assert!(signer::address_of(deployer) == @thala_launch_deployer, ERR_UNAUTHORIZED);

        // Key dependencies
        assert!(package::initialized(), ERR_PACKAGE_UNINITIALIZED);
        assert!(manager::initialized(), ERR_MANAGER_UNINITIALIZED);

        // In order of dependencies
        fees::initialize();
        lbp::initialize();
    }
}

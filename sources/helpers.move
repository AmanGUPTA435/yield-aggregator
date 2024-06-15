module avex::helpers {
    use controller::profile;
    use controller::controller;
    use abel::acoin;
    use abel::acoin_lend;
    public fun balance<T0>(user: address) : u64 {
        if (0x1::coin::is_account_registered<T0>(user)) {
            0x1::coin::balance<T0>(user)
        } else {
            0
        }
    }
    
    public fun aries_profile_exists(user: address, seed: vector<u8>) : bool {
        profile::is_registered(user) && profile::profile_exists(user, 0x1::string::utf8(seed))
    }
    
    public fun ensure_aries_profile_exists(user: &signer, seed: vector<u8>) {
        let user_addr = 0x1::signer::address_of(user);
        if (!profile::is_registered(user_addr)) {
            controller::register_user(user, seed);
        } else {
            if (!profile::profile_exists(user_addr, 0x1::string::utf8(seed))) {
                profile::new(user, 0x1::string::utf8(seed));
            };
        };
    }

    public fun ensure_abel_profile_exists<T0>(user:&signer) {
        let user_addr = 0x1::signer::address_of(user);
        if (!acoin::is_account_registered<T0>(user_addr)) {
            acoin_lend::register<T0>(user);
        }
    }
    
    public fun min_amount_with_slippage(amount: u64, slippage: u64) : u64 {
        let v0 = ((amount as u128) * ((10000 - slippage) as u128) / (10000 as u128) as u64);
        v0
    }
    
    // decompiled from Move bytecode v6
}


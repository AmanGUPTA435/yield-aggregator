module avex::echel {
    // use avex::helpers;
    // use controller::controller;
    // use controller::profile;
    // use controller::reserve_config::{DepositFarming};
    // use avex::lending_events;
    use aptos_framework::fungible_asset::{Metadata};
    use std::string::{String};
    use lending::scripts;
    use 0000000000000000000000000000000000000000000000000000000000000001::object::{Object};
    use lending::lending::{Market};
    use std::type_info;
    use 0x1::object;

    // use aptos_framework::aptos_coin::{AptosCoin};

    // #[event]
    // struct EchelonCoinBorrow has drop,store{
    //     amount:u64,
    //     token:String
    // }
    // #[event]
    // struct EchelonCoinLiquidity has drop,store{
    //     amount:u64,
    //     token:String
    // }
    // #[event]
    // struct EchelonCoinRewards has drop,store{
    //     amount:u64,
    //     token:String
    // }
    // #[event]
    // struct EchelonCoinRepay has drop,store{
    //     amount:u64,
    //     token:String
    // }
    // #[event]
    // struct EchelonCoinWithdraw has drop,store{
    //     amount:u64,
    //     token:String
    // }
    // #[event]
    // struct EchelonCoinSupply has drop,store{
    //     amount:u64,
    //     token:String
    // }

    public entry fun borrow<T0>(user:&signer,asset:address,amount:u64){
        scripts::borrow<T0>(user,object::address_to_object<Market>(asset),amount);
        // let v0 = EchelonCoinBorrow{
        //     amount : amount,
        //     token  : type_info::type_name<T0>(), 
        // };
        // 0x1::event::emit<EchelonCoinBorrow>(v0);
    }

    public entry fun borrow_fa(user:&signer,asset:Object<Market>,amount:u64){
        scripts::borrow_fa(user,asset,amount);
    }

    public entry fun add_liquidity<T0>(user: &signer, pool: address, asset1: Object<Market>, asset2: Object<Market>, amount1: u64, amount2: u64){
        scripts::liquidate<T0>(user,pool,asset1,asset2,amount1,amount2);
        // let v0 = EchelonCoinLiquidity{
        //     amount : amount,
        //     token  : type_info::type_name<T0>(), 
        // };
        // 0x1::event::emit<EchelonCoinLiquidity>(v0);
    }

    public entry fun add_liquidity_fa(user: &signer, pool: address, asset1: Object<Market>, asset2: Object<Market>, amount1: u64, amount2: u64){
        scripts::liquidate_fa(user,pool,asset1,asset2,amount1,amount2);
    }

    public entry fun repay<T0>(user: &signer, asset: address, amount: u64){
        scripts::repay<T0>(user,object::address_to_object<Market>(asset),amount);
        // scripts::liquidate<T0>(user,pool,asset1,asset2,amount1,amount2);
        // let v0 = EchelonCoinLiquidity{
        //     amount : amount,
        //     token  : type_info::type_name<T0>(), 
        // };
        // 0x1::event::emit<EchelonCoinLiquidity>(v0);
    }

    public entry fun repay_fa(user: &signer, asset: Object<Market>, amount: u64){
        scripts::repay_fa(user,asset,amount);
    }

    public entry fun withdraw<T0>(user: &signer, asset: address, amount: u64){
        scripts::withdraw<T0>(user,object::address_to_object<Market>(asset),amount);
        // scripts::liquidate<T0>(user,pool,asset1,asset2,amount1,amount2);
        // let v0 = EchelonCoinLiquidity{
        //     amount : amount,
        //     token  : type_info::type_name<T0>(), 
        // };
        // 0x1::event::emit<EchelonCoinLiquidity>(v0);
    }

    public entry fun withdraw_fa(user: &signer, asset: Object<Market>, amount: u64){
        scripts::withdraw_fa(user,asset,amount);
    }

    public entry fun supply<T0>(user: &signer, asset: Object<Market>, amount: u64){
        scripts::supply<T0>(user,asset,amount);
        // scripts::liquidate<T0>(user,pool,asset1,asset2,amount1,amount2);
        // let v0 = EchelonCoinLiquidity{
        //     amount : amount,
        //     token  : type_info::type_name<T0>(), 
        // };
        // 0x1::event::emit<EchelonCoinLiquidity>(v0);
    }
    public entry fun supply_fa(user: &signer, asset: Object<Market>, amount: u64){
        scripts::supply_fa(user,asset,amount);
    }

    public entry fun claim_reward<T0>(user:&signer,name:String){
        scripts::claim_reward<T0>(user,name);
        // scripts::liquidate<T0>(user,pool,asset1,asset2,amount1,amount2);
        // let v0 = EchelonCoinRewards{
        //     amount : amount,
        //     token  : type_info::type_name<T0>(), 
        // };
        // 0x1::event::emit<EchelonCoinRewards>(v0);
    }

    public entry fun claim_reward_fa(user:&signer,asset: Object<Metadata>,name:String){
        scripts::claim_reward_fa(user,asset,name);
    }

}
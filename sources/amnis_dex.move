// module avex::amnis_dex {
    
//     struct MultiClaimRewards has drop, store {
//         app: u64,
//         token: 0x1::string::String,
//         amount: u64,
//     }
    
//     struct MultiStakeAndLP has drop, store {
//         app: u64,
//         amount: u64,
//         amount_apt: u64,
//         amount_amapt: u64,
//     }
    
//     struct MultiWithdraw has drop, store {
//         app: u64,
//         amount: u64,
//     }
    
//     public fun get_pending_rewards<T0, T1>(arg0: address, arg1: bool) : u64 {
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::liquidswap::get_pending_rewards<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0, arg1)
//     }
    
//     public fun get_users_position(arg0: address, arg1: bool) : (u64, u64, u64, u64, u64) {
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::liquidswap::get_users_position<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0, arg1)
//     }
    
//     fun calculate_apt_amount(arg0: u64, arg1: u64, arg2: u64) : u64 {
//         let v0 = arg1 as u256;
//         let v1 = 100000000 as u256;
//         let v2 = v1 - (0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::delegation_manager::current_add_stake_fee(100000000) as u256);
//         (v0 * (arg0 as u256) * v2 / ((arg2 as u256) * v1 + v0 * v2)) as u64
//     }
    
//     entry fun liquidswap_claim_rewards(arg0: &signer) {
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::liquidswap::claim_rewards_internal<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0, true);
//         let v0 = MultiClaimRewards{
//             app    : 2, 
//             token  : 0x1::type_info::type_name<0x1::aptos_coin::AptosCoin>(), 
//             amount : 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x1::aptos_coin::AptosCoin>(0x1::signer::address_of(arg0)),
//         };
//         0x1::event::emit<MultiClaimRewards>(v0);
//     }
    
//     entry fun liquidswap_stake_and_lp(arg0: &signer, arg1: u64, arg2: u64) {
//         let (v0, v1) = 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::liquidswap::get_reserves<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(true);
//         let v2 = ((v1 as u128) * ((100000000 + 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::delegation_manager::current_add_stake_fee(100000000)) as u128) / (100000000 as u128)) as u64;
//         let v3 = v0 + v2;
//         let v4 = ((v0 as u128) * (arg1 as u128) / (v3 as u128)) as u64;
//         let v5 = 0x1::signer::address_of(arg0);
//         0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::router::deposit_entry(arg0, ((v2 as u128) * (arg1 as u128) / (v3 as u128)) as u64, 0x1::signer::address_of(arg0));
//         let v6 = 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(v5) - 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(v5);
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::liquidswap::add_liquidity_internal<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0, true, v4, v6, arg2);
//         let v7 = MultiStakeAndLP{
//             app          : 2, 
//             amount       : arg1, 
//             amount_apt   : v4, 
//             amount_amapt : v6,
//         };
//         0x1::event::emit<MultiStakeAndLP>(v7);
//     }
    
//     entry fun liquidswap_withdraw(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) {
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::liquidswap::remove_liquidity_internal<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0, true, arg1, arg2, arg3);
//         let v0 = MultiWithdraw{
//             app    : 2, 
//             amount : arg1,
//         };
//         0x1::event::emit<MultiWithdraw>(v0);
//     }
    
//     public fun pancake_apt_amount(arg0: u64) : u64 {
//         let (v0, v1) = 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::pancakeswap::get_reserves<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>();
//         calculate_apt_amount(arg0, v0, v1)
//     }
    
//     entry fun pancakeswap_claim_rewards(arg0: &signer) {
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::pancakeswap::claim_rewards_internal<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0);
//         let v0 = MultiClaimRewards{
//             app    : 3, 
//             token  : 0x1::type_info::type_name<0x1::aptos_coin::AptosCoin>(), 
//             amount : 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x1::aptos_coin::AptosCoin>(0x1::signer::address_of(arg0)),
//         };
//         0x1::event::emit<MultiClaimRewards>(v0);
//     }
    
//     entry fun pancakeswap_stake_and_lp(arg0: &signer, arg1: u64, arg2: u64) {
//         let (v0, v1) = 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::pancakeswap::get_reserves<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>();
//         let v2 = calculate_apt_amount(arg1, v0, v1);
//         let v3 = 0x1::signer::address_of(arg0);
//         0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::router::deposit_entry(arg0, arg1 - v2, 0x1::signer::address_of(arg0));
//         let v4 = 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(v3) - 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(v3);
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::pancakeswap::add_liquidity_internal<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0, v2, v4, arg2);
//         let v5 = MultiStakeAndLP{
//             app          : 3, 
//             amount       : arg1, 
//             amount_apt   : v2, 
//             amount_amapt : v4,
//         };
//         0x1::event::emit<MultiStakeAndLP>(v5);
//     }
    
//     entry fun pancakeswap_withdraw(arg0: &signer, arg1: u64, arg2: u64, arg3: u64, arg4: u64) {
//         let v0 = 0x1::signer::address_of(arg0);
//         0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::pancakeswap::remove_liquidity_internal<0x1::aptos_coin::AptosCoin, 0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(arg0, arg1, arg2, arg3);
//         let v1 = 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(v0) - 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::balance<0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt>(v0);
//         0xc7efb4076dbe143cbcd98cfaaa929ecfc8f299203dfff63b95ccb6bfe19850fa::router::swap_exact_input<0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt, 0x1::aptos_coin::AptosCoin>(arg0, v1, 0x17f1e926a81639e9557f4e4934df93452945ec30bc962e11351db59eb0d78c33::helpers::min_amount_with_slippage(v1, arg4));
//         let v2 = MultiWithdraw{
//             app    : 3, 
//             amount : arg1,
//         };
//         0x1::event::emit<MultiWithdraw>(v2);
//     }
    
//     // decompiled from Move bytecode v6
// }



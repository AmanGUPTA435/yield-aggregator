// module avex::events {
//     use aptos_framework::event;
//     use std::string::{String};
//     use std::type_info;

//     friend avex::entry_router;
//     friend avex::stake_route;
//     // friend avex::entry_router;
//     #[event]
//     struct LsdStake has drop, store {
//         app: u64,
//         amount: u64,
//     }
//     #[event]
//     struct LsdUnstake has drop, store {
//         app: u64,
//         amount: u64,
//     }
//     #[event]
//     struct LsdUnstakeAndSwap has drop, store {
//         app: u64,
//         amount: u64,
//         amount_apt: u64,
//     }
//     #[event]
//     struct LsdClaimReward has drop, store {
//         app: u64
//     }

//     #[event]
//     struct LendingAddLiquidity has drop, store {
//         app: u64,
//         token: String,
//         amount: u64,
//     }
//     #[event]
//     struct LendingClaimRewards has drop, store {
//         app: u64,
//         token: String,
//         reward_token: String,
//         amount: u64,
//     }
//     #[event]
//     struct LendingRemoveLiquidity has drop, store {
//         app: u64,
//         token: String,
//         amount: u64,
//     }
//     #[event]
//     struct LendingBorrow has drop, store {
//         app: u64,
//         token: String,
//         amount: u64,
//     }
//     #[event]
//     struct LendingRepay has drop, store {
//         app: u64,
//         token: String,
//         amount: u64,
//     }
    
//     public fun abel() : u64 {
//         1
//     }
//     public fun aries() : u64 {
//         2
//     }
//     public fun aptin() : u64 {
//         3
//     }
    
//     public(friend) fun emit_claim_rewards<T0, T1>(arg0: u64, arg1: u64) {
//         let v0 = LendingClaimRewards{
//             app          : arg0, 
//             token        : type_info::type_name<T0>(), 
//             reward_token : type_info::type_name<T1>(), 
//             amount       : arg1,
//         };
//         0x1::event::emit<LendingClaimRewards>(v0);
//     }
    
//     public(friend) fun emit_lend<T0>(arg0: u64, arg1: u64) {
//         let v0 = LendingAddLiquidity{
//             app    : arg0, 
//             token  : 0x1::type_info::type_name<T0>(), 
//             amount : arg1,
//         };
//         0x1::event::emit<LendingAddLiquidity>(v0);
//     }
    
//     public(friend) fun emit_withdraw<T0>(arg0: u64, arg1: u64) {
//         let v0 = LendingRemoveLiquidity{
//             app    : arg0, 
//             token  : 0x1::type_info::type_name<T0>(), 
//             amount : arg1,
//         };
//         0x1::event::emit<LendingRemoveLiquidity>(v0);
//     }

//     public(friend) fun emit_borrow<T0>(arg0: u64, arg1: u64) {
//         let v0 = LendingBorrow{
//             app    : arg0,
//             token  : 0x1::type_info::type_name<T0>(),
//             amount : arg1
//         };
//         0x1::event::emit<LendingBorrow>(v0);
//     }
    
//     public(friend) fun emit_repay<T0>(arg0: u64, arg1: u64) {
//         let v0 = LendingRepay{
//             app    : arg0,
//             token  : 0x1::type_info::type_name<T0>(),
//             amount : arg1
//         };
//         0x1::event::emit<LendingRepay>(v0);
//     }
    
//     // decompiled from Move bytecode v6
    
//     public fun amnis() : u64 {
//         1
//     }
//     public fun thala() : u64 {
//         2
//     }

//     public fun tortuga() : u64 {
//         3
//     }

//     public fun merkle() : u64 {
//         4
//     }
    
//     public(friend) fun emit_stake(id: u64, amount: u64) {
//         let v0 = LsdStake{
//             app    : id, 
//             amount : amount,
//         };
//         0x1::event::emit<LsdStake>(v0);
//     }
    
//     public(friend) fun emit_unstake(id: u64, unstake_amount: u64) {
//         let v0 = LsdUnstake{
//             app    : id, 
//             amount : unstake_amount,
//         };
//         0x1::event::emit<LsdUnstake>(v0);
//     }
    
//     public(friend) fun emit_unstake_and_swap(id: u64, unstake_amount: u64, swap_apt_amount: u64) {
//         let v0 = LsdUnstakeAndSwap{
//             app        : id, 
//             amount     : unstake_amount, 
//             amount_apt : swap_apt_amount,
//         };
//         0x1::event::emit<LsdUnstakeAndSwap>(v0);
//     }

//     public(friend) fun emit_claim_reward(id: u64) {
//         let v0 = LsdClaimReward{
//             app         : id
//         };
//         0x1::event::emit<LsdClaimReward>(v0);
//     }
    
    
//     // decompiled from Move bytecode v6

// }


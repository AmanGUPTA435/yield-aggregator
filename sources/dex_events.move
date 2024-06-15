// module avex::dex_events {
//     friend avex::stake_route;
//     #[event]
//     struct DexAddLiquidity has drop, store {
//         app: u64,
//         tokens: vector<0x1::string::String>,
//         amount_1: u64,
//         amount_2: u64,
//     }
//     #[event]
//     struct DexClaimRewards has drop, store {
//         app: u64,
//         tokens: vector<0x1::string::String>,
//         reward_token: 0x1::string::String,
//         amount: u64,
//     }
//     #[event]
//     struct DexRemoveLiquidity has drop, store {
//         app: u64,
//         tokens: vector<0x1::string::String>,
//         amount_lp: u64,
//         amount_1: u64,
//         amount_2: u64,
//     }
    
//     public(friend) fun emit_add_liquidity<T0, T1>(arg0: u64, arg1: u64, arg2: u64) {
//         let v0 = 0x1::vector::empty<0x1::string::String>();
//         let v1 = &mut v0;
//         0x1::vector::push_back<0x1::string::String>(v1, 0x1::type_info::type_name<T0>());
//         0x1::vector::push_back<0x1::string::String>(v1, 0x1::type_info::type_name<T1>());
//         let v2 = DexAddLiquidity{
//             app      : arg0, 
//             tokens   : v0, 
//             amount_1 : arg1, 
//             amount_2 : arg2,
//         };
//         0x1::event::emit<DexAddLiquidity>(v2);
//     }
    
//     public(friend) fun emit_claim_rewards<T0, T1, T2>(arg0: u64, arg1: u64) {
//         let v0 = 0x1::vector::empty<0x1::string::String>();
//         let v1 = &mut v0;
//         0x1::vector::push_back<0x1::string::String>(v1, 0x1::type_info::type_name<T0>());
//         0x1::vector::push_back<0x1::string::String>(v1, 0x1::type_info::type_name<T1>());
//         let v2 = DexClaimRewards{
//             app          : arg0, 
//             tokens       : v0, 
//             reward_token : 0x1::type_info::type_name<T2>(), 
//             amount       : arg1,
//         };
//         0x1::event::emit<DexClaimRewards>(v2);
//     }
    
//     public(friend) fun emit_remove_liquidity<T0, T1>(arg0: u64, arg1: u64, arg2: u64, arg3: u64) {
//         let v0 = 0x1::vector::empty<0x1::string::String>();
//         let v1 = &mut v0;
//         0x1::vector::push_back<0x1::string::String>(v1, 0x1::type_info::type_name<T0>());
//         0x1::vector::push_back<0x1::string::String>(v1, 0x1::type_info::type_name<T1>());
//         let v2 = DexRemoveLiquidity{
//             app       : arg0, 
//             tokens    : v0, 
//             amount_lp : arg1, 
//             amount_1  : arg2, 
//             amount_2  : arg3,
//         };
//         0x1::event::emit<DexRemoveLiquidity>(v2);
//     }
    
//     public fun liquidswap() : u64 {
//         2
//     }
    
//     public fun pancakeswap() : u64 {
//         3
//     }
    
//     public fun sushiswap() : u64 {
//         4
//     }
    
//     public fun thalaswap() : u64 {
//         1
//     }
    
//     // decompiled from Move bytecode v6
// }


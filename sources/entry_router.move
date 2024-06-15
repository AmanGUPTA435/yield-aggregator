// module avex::entry_router{
//     use avex::stake_route;
//     use std::signer;
//     // use avex::events;
//     // use avex::events;
//     use avex::events;

//     const THALA : u64 = 1;
//     const AMNIS : u64 = 2;
//     const TORTUGA : u64 = 3;
//     const MERKLE : u64 = 4;
//     const ABEL : u64 = 5;
//     const ARIES : u64 = 6;
//     const APTIN : u64 = 7;

//     public entry fun stake_entry(user:&signer,amount:u64,id:u64){
//         stake_route::stake(user,amount,id);
//     }

//     public entry fun unstake_entry(user:&signer,amount:u64,id:u64){
//         stake_route::unstake(user,amount,id);
//     }

//     public entry fun claim_rewards_entry<T0,T1>(user:&signer,id:u64){
//         stake_route::claim_rewards_uni<T0,T1>(user,id);
//     }

//     public entry fun lend_entry<T0>(user:&signer,amount:u64,id:u64){
//         stake_route::lend<T0>(user,amount,id);
//     }

//     public entry fun withdraw_entry<T0>(user:&signer,amount:u64,id:u64){
//         stake_route::withdraw<T0>(user,amount,id);
//     }

//     public entry fun repay_entry<T0>(user:&signer,amount:u64,id:u64){
//         stake_route::repay<T0>(user,amount,id);
//     }

//     public entry fun borrow_entry<T0>(user:&signer,amount:u64,id:u64){
//         stake_route::borrow<T0>(user,amount,id);
//     }
// }
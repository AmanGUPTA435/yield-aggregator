// Move bytecode v6
module controller::profile_farm {
use 0000000000000000000000000000000000000000000000000000000000000001::math128;
use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{Self,TypeInfo};
use decimal::decimal::{Self,Decimal};
use utils::iterable_table::{Self,IterableTable};
use utils::map::{Self,Map};
use controller::reserve_farm;


struct ProfileFarm has store {
	share: u128,
	rewards: IterableTable<TypeInfo, Reward>
}
struct ProfileFarmRaw has copy, drop, store {
	share: u128,
	reward_type: vector<TypeInfo>,
	rewards: vector<RewardRaw>
}
struct Reward has drop, store {
	unclaimed_amount: Decimal,
	last_reward_per_share: Decimal
}
struct RewardRaw has copy, drop, store {
	unclaimed_amount_decimal: u128,
	last_reward_per_share_decimal: u128
}

public(friend) fun accumulate_profile_farm_raw(_arg0: &mut ProfileFarmRaw, _arg1: &Map<TypeInfo, Reward>) {

}
public(friend) fun accumulate_profile_reward_raw(_arg0: &mut RewardRaw, _arg1: u128, _arg2: Decimal) {

}
public fun add_share(_arg0: &mut ProfileFarm, _arg1: &Map<TypeInfo, Reward>, _arg2: u128) {

}
public fun aggregate_all_claimable_rewards(_arg0: &ProfileFarm, _arg1: &mut Map<TypeInfo, u64>) {

}
public fun claim_reward(_arg0: &mut ProfileFarm, _arg1: &Map<TypeInfo, Reward>, _arg2: TypeInfo): u64 {
abort 0
}
public fun get_all_claimable_rewards(_arg0: &ProfileFarm): Map<TypeInfo, u64> {
abort 0
}
public fun get_claimable_amount(_arg0: &ProfileFarm, _arg1: TypeInfo): u64 {
abort 0
}
public fun get_reward_balance(_arg0: &ProfileFarm, _arg1: TypeInfo): Decimal {
abort 0
}
public fun get_reward_detail(_arg0: &ProfileFarm, _arg1: TypeInfo): (Decimal , Decimal) {
abort 0
}
public fun get_share(_arg0: &ProfileFarm): u128 {
abort 0
}
public fun has_reward(_arg0: &ProfileFarm, _arg1: TypeInfo): bool {
abort 0
}
public fun new(_arg0: &Map<TypeInfo, Reward>): ProfileFarm {
abort 0
}
public fun new_reward(_arg0: Decimal): Reward {
abort 0
}
public fun profile_farm_raw(_arg0: &ProfileFarm): ProfileFarmRaw {
abort 0
}
public fun profile_farm_reward_raw(_arg0: &ProfileFarm, _arg1: TypeInfo): RewardRaw {
abort 0
}
public fun try_remove_share(_arg0: &mut ProfileFarm, _arg1: &Map<TypeInfo, Reward>, _arg2: u128): u128 {
abort 0
}
public fun unwrap_profile_farm_raw(_arg0: ProfileFarmRaw): (u128 , vector<TypeInfo> , vector<RewardRaw>) {
abort 0
}
public fun unwrap_profile_reward_raw(_arg0: RewardRaw): (u128 , u128) {
abort 0
}
public fun update(_arg0: &mut ProfileFarm, _arg1: &Map<TypeInfo, Reward>) {

}
}
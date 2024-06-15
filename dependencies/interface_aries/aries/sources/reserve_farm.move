// Move bytecode v6
module controller::reserve_farm {
use 0000000000000000000000000000000000000000000000000000000000000001::math128;
use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::timestamp;
use 0000000000000000000000000000000000000000000000000000000000000001::type_info::{Self,TypeInfo};
use 0000000000000000000000000000000000000000000000000000000000000001::vector;
use decimal::decimal::{Self,Decimal};
use utils::iterable_table::{Self,IterableTable};
use utils::map::{Self,Map};


struct ReserveFarm has store {
	timestamp: u64,
	share: u128,
	rewards: IterableTable<TypeInfo, Reward>
}
struct ReserveFarmRaw has copy, drop, store {
	timestamp: u64,
	share: u128,
	reward_types: vector<TypeInfo>,
	rewards: vector<RewardRaw>
}
struct Reward has copy, drop, store {
	reward_config: RewardConfig,
	remaining_reward: u128,
	reward_per_share: Decimal
}
struct RewardConfig has copy, drop, store {
	reward_per_day: u128
}
struct RewardRaw has copy, drop, store {
	reward_per_day: u128,
	remaining_reward: u128,
	reward_per_share_decimal: u128
}

public fun add_reward(_arg0: &mut ReserveFarm, _arg1: TypeInfo, _arg2: u128) {

}
public fun add_share(_arg0: &mut ReserveFarm, _arg1: u128) {

}
public fun borrow_reward(_arg0: &ReserveFarm, _arg1: TypeInfo): &Reward {
abort 0
}
fun borrow_reward_mut(_arg0: &mut ReserveFarm, _arg1: TypeInfo): &mut Reward {
abort 0
}
public(friend) fun get_latest_reserve_farm_view(_arg0: &ReserveFarm): Map<TypeInfo, Reward> {
abort 0
}
public(friend) fun get_latest_reserve_reward_view(_arg0: &ReserveFarm, _arg1: TypeInfo): Reward {
abort 0
}
public fun get_reward_per_day(_arg0: &ReserveFarm, _arg1: TypeInfo): u128 {
abort 0
}
public fun get_reward_per_share(_arg0: &ReserveFarm, _arg1: TypeInfo): Decimal {
abort 0
}
public fun get_reward_remaining(_arg0: &ReserveFarm, _arg1: TypeInfo): u128 {
abort 0
}
public fun get_rewards(_arg0: &mut ReserveFarm): Map<TypeInfo, Reward> {
abort 0
}
public fun get_share(_arg0: &ReserveFarm): u128 {
abort 0
}
fun get_time_diff(_arg0: &ReserveFarm): u64 {
abort 0
}
public fun get_timestamp(_arg0: &ReserveFarm): u64 {
abort 0
}
public fun has_reward(_arg0: &ReserveFarm, _arg1: TypeInfo): bool {
abort 0
}
public fun new(): ReserveFarm {
abort 0
}
public fun new_reward(): Reward {
abort 0
}
public fun new_reward_config(_arg0: u128): RewardConfig {
abort 0
}
public fun remaining_reward(_arg0: &Reward): u128 {
abort 0
}
public fun remove_reward(_arg0: &mut ReserveFarm, _arg1: TypeInfo, _arg2: u128) {

}
public fun remove_share(_arg0: &mut ReserveFarm, _arg1: u128) {

}
public fun reserve_farm_raw(_arg0: &ReserveFarm): ReserveFarmRaw {
abort 0
}
public fun reward_per_day(_arg0: &Reward): u128 {
abort 0
}
public fun reward_per_share(_arg0: &Reward): Decimal {
abort 0
}
public fun self_update(_arg0: &mut ReserveFarm) {

}
public fun unwrap_reserve_farm_raw(_arg0: ReserveFarmRaw): (u64 , u128 , vector<TypeInfo> , vector<RewardRaw>) {
abort 0
}
public fun unwrap_reserve_reward_raw(_arg0: RewardRaw): (u128 , u128 , u128) {
abort 0
}
fun update_reward(_arg0: &mut Reward, _arg1: u64, _arg2: u128) {

}
public fun update_reward_config(_arg0: &mut ReserveFarm, _arg1: TypeInfo, _arg2: RewardConfig) {

}
}
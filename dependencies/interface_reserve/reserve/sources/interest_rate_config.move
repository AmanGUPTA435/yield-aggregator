// Move bytecode v6
module config::interest_rate_config {
use decimal::decimal::{Self,Decimal};


struct InterestRateConfig has copy, drop, store {
	min_borrow_rate: u64,
	optimal_borrow_rate: u64,
	max_borrow_rate: u64,
	optimal_utilization: u64
}

public fun default_config(): InterestRateConfig {
abort 0
}
public fun get_borrow_rate(_arg0: &InterestRateConfig, _arg1: Decimal, _arg2: u128, _arg3: Decimal): Decimal {
abort 0
}
public fun get_borrow_rate_for_seconds(_arg0: u64, _arg1: &InterestRateConfig, _arg2: Decimal, _arg3: u128, _arg4: Decimal): Decimal {
abort 0
}
public fun max_borrow_rate(_arg0: &InterestRateConfig): u64 {
abort 0
}
public fun min_borrow_rate(_arg0: &InterestRateConfig): u64 {
abort 0
}
public fun new_interest_rate_config(_arg0: u64, _arg1: u64, _arg2: u64, _arg3: u64): InterestRateConfig {
abort 0
}
public fun optimal_borrow_rate(_arg0: &InterestRateConfig): u64 {
abort 0
}
public fun optimal_utilization(_arg0: &InterestRateConfig): u64 {
abort 0
}
public fun update_max_borrow_rate(_arg0: &InterestRateConfig, _arg1: u64): InterestRateConfig {
abort 0
}
public fun update_min_borrow_rate(_arg0: &InterestRateConfig, _arg1: u64): InterestRateConfig {
abort 0
}
public fun update_optimal_borrow_rate(_arg0: &InterestRateConfig, _arg1: u64): InterestRateConfig {
abort 0
}
public fun update_optimal_utilization(_arg0: &InterestRateConfig, _arg1: u64): InterestRateConfig {
abort 0
}
}
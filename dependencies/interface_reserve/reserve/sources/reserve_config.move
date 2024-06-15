// Move bytecode v6
module config::reserve_config {
struct BorrowFarming {
	dummy_field: bool
}
struct DepositFarming {
	dummy_field: bool
}
struct ReserveConfig has copy, drop, store {
	loan_to_value: u8,
	liquidation_threshold: u8,
	liquidation_bonus_bips: u64,
	liquidation_fee_hundredth_bips: u64,
	borrow_factor: u8,
	reserve_ratio: u8,
	borrow_fee_hundredth_bips: u64,
	withdraw_fee_hundredth_bips: u64,
	deposit_limit: u64,
	borrow_limit: u64,
	allow_collateral: bool,
	allow_redeem: bool,
	flash_loan_fee_hundredth_bips: u64
}

public fun allow_collateral(_arg0: &ReserveConfig): bool {
abort 0
}
public fun allow_redeem(_arg0: &ReserveConfig): bool {
abort 0
}
public fun borrow_factor(_arg0: &ReserveConfig): u8 {
abort 0
}
public fun borrow_fee_hundredth_bips(_arg0: &ReserveConfig): u64 {
abort 0
}
public fun borrow_limit(_arg0: &ReserveConfig): u64 {
abort 0
}
public fun default_config(): ReserveConfig {
abort 0
}
public fun deposit_limit(_arg0: &ReserveConfig): u64 {
abort 0
}
public fun flash_loan_fee_hundredth_bips(_arg0: &ReserveConfig): u64 {
abort 0
}
public fun liquidation_bonus_bips(_arg0: &ReserveConfig): u64 {
abort 0
}
public fun liquidation_fee_hundredth_bips(_arg0: &ReserveConfig): u64 {
abort 0
}
public fun liquidation_threshold(_arg0: &ReserveConfig): u8 {
abort 0
}
public fun loan_to_value(_arg0: &ReserveConfig): u8 {
abort 0
}
public fun new_reserve_config(_arg0: u8, _arg1: u8, _arg2: u64, _arg3: u64, _arg4: u8, _arg5: u8, _arg6: u64, _arg7: u64, _arg8: u64, _arg9: u64, _arg10: bool, _arg11: bool, _arg12: u64): ReserveConfig {
abort 0
}
public fun reserve_ratio(_arg0: &ReserveConfig): u8 {
abort 0
}
public fun update_allow_collateral(_arg0: &ReserveConfig, _arg1: bool): ReserveConfig {
abort 0
}
public fun update_allow_redeem(_arg0: &ReserveConfig, _arg1: bool): ReserveConfig {
abort 0
}
public fun update_borrow_factor(_arg0: &ReserveConfig, _arg1: u8): ReserveConfig {
abort 0
}
public fun update_borrow_fee_hundredth_bips(_arg0: &ReserveConfig, _arg1: u64): ReserveConfig {
abort 0
}
public fun update_borrow_limit(_arg0: &ReserveConfig, _arg1: u64): ReserveConfig {
abort 0
}
public fun update_deposit_limit(_arg0: &ReserveConfig, _arg1: u64): ReserveConfig {
abort 0
}
public fun update_flash_loan_fee_hundredth_bips(_arg0: &ReserveConfig, _arg1: u64): ReserveConfig {
abort 0
}
public fun update_liquidation_bonus_bips(_arg0: &ReserveConfig, _arg1: u64): ReserveConfig {
abort 0
}
public fun update_liquidation_fee_hundredth_bips(_arg0: &ReserveConfig, _arg1: u64): ReserveConfig {
abort 0
}
public fun update_liquidation_threshold(_arg0: &ReserveConfig, _arg1: u8): ReserveConfig {
abort 0
}
public fun update_loan_to_value(_arg0: &ReserveConfig, _arg1: u8): ReserveConfig {
abort 0
}
public fun update_reserve_ratio(_arg0: &ReserveConfig, _arg1: u8): ReserveConfig {
abort 0
}
public fun update_withdraw_fee_hundredth_bips(_arg0: &ReserveConfig, _arg1: u64): ReserveConfig {
abort 0
}
fun validate_reserve_config(_arg0: &ReserveConfig) {
abort 0
}
public fun withdraw_fee_hundredth_bips(_arg0: &ReserveConfig): u64 {
abort 0
}
}
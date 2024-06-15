// Move bytecode v6
module utils::map {
use 0000000000000000000000000000000000000000000000000000000000000001::comparator;
use 0000000000000000000000000000000000000000000000000000000000000001::error;
use 0000000000000000000000000000000000000000000000000000000000000001::option::{Self,Option};
use 0000000000000000000000000000000000000000000000000000000000000001::vector;
use utils::iterable_table::{Self,IterableTable};


struct Element<Ty0, Ty1> has copy, drop, store {
	key: Ty0,
	value: Ty1
}
struct Map<Ty0, Ty1> has copy, drop, store {
	data: vector<Element<Ty0, Ty1>>
}

public fun add<Ty0: copy + drop, Ty1>(_arg0: &mut Map<Ty0, Ty1>, _arg1: Ty0, _arg2: Ty1) {
abort 0
}
public fun borrow<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>, _arg1: Ty0): &Ty1 {
abort 0
}
fun borrow_index<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>, _arg1: u64): &Element<Ty0, Ty1> {
abort 0
}
public fun borrow_inner<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>, _arg1: Ty0): (&Ty1 , u64) {
abort 0
}
public fun borrow_iter<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>, _arg1: Ty0): (&Ty1 , Option<Ty0> , Option<Ty0>) {
abort 0
}
public fun borrow_iter_mut<Ty0: copy + drop, Ty1>(_arg0: &mut Map<Ty0, Ty1>, _arg1: Ty0): (&mut Ty1 , Option<Ty0> , Option<Ty0>) {
abort 0
}
public fun borrow_mut<Ty0: copy + drop, Ty1>(_arg0: &mut Map<Ty0, Ty1>, _arg1: Ty0): &mut Ty1 {
abort 0
}
public fun borrow_mut_with_default<Ty0: copy + drop, Ty1: drop>(_arg0: &mut Map<Ty0, Ty1>, _arg1: Ty0, _arg2: Ty1): &mut Ty1 {
abort 0
}
public fun contains<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>, _arg1: Ty0): bool {
abort 0
}
public fun destroy_empty<Ty0: copy + drop, Ty1>(_arg0: Map<Ty0, Ty1>) {
abort 0
}
public fun empty<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>): bool {
abort 0
}
fun find<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>, _arg1: Ty0): (Option<u64> , Option<u64>) {
abort 0
}
public fun from_iterable_table<Ty0: copy + drop + store, Ty1: copy + store>(_arg0: &IterableTable<Ty0, Ty1>): Map<Ty0, Ty1> {
abort 0
}
public fun keys<Ty0: copy, Ty1>(_arg0: &Map<Ty0, Ty1>): vector<Ty0> {
abort 0
}
public fun length<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>): u64 {
abort 0
}
public fun new<Ty0: copy + drop, Ty1>(): Map<Ty0, Ty1> {
abort 0
}
public fun remove<Ty0: copy + drop, Ty1>(_arg0: &mut Map<Ty0, Ty1>, _arg1: Ty0): (Ty0 , Ty1) {
abort 0
}
public fun tail_key<Ty0: copy + drop, Ty1>(_arg0: &Map<Ty0, Ty1>): Option<Ty0> {
abort 0
}
public fun to_vec_pair<Ty0: store, Ty1: store>(_arg0: Map<Ty0, Ty1>): (vector<Ty0> , vector<Ty1>) {
abort 0
}
public fun upsert<Ty0: copy + drop, Ty1>(_arg0: &mut Map<Ty0, Ty1>, _arg1: Ty0, _arg2: Ty1): (Option<Ty0> , Option<Ty1>) {
abort 0
}
public fun values<Ty0, Ty1: copy>(_arg0: &Map<Ty0, Ty1>): vector<Ty1> {
abort 0
}
}
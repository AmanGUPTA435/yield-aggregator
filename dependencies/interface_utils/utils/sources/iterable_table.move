// Move bytecode v6
module utils::iterable_table {
use 0000000000000000000000000000000000000000000000000000000000000001::option::{Self,Option};
use 0000000000000000000000000000000000000000000000000000000000000001::table_with_length::{Self,TableWithLength};


struct IterableTable<Ty0: copy + drop + store, Ty1: store> has store {
	inner: TableWithLength<Ty0, IterableValue<Ty0, Ty1>>,
	head: Option<Ty0>,
	tail: Option<Ty0>
}
struct IterableValue<Ty0: copy + drop + store, Ty1: store> has store {
	val: Ty1,
	prev: Option<Ty0>,
	next: Option<Ty0>
}

public fun add<Ty0: copy + drop + store, Ty1: store>(_arg0: &mut IterableTable<Ty0, Ty1>, _arg1: Ty0, _arg2: Ty1) {
abort 0
}
public fun append<Ty0: copy + drop + store, Ty1: store>(_arg0: &mut IterableTable<Ty0, Ty1>, _arg1: &mut IterableTable<Ty0, Ty1>) {

}
public fun borrow<Ty0: copy + drop + store, Ty1: store>(_arg0: &IterableTable<Ty0, Ty1>, _arg1: Ty0): &Ty1 {
abort 0
}
public fun borrow_iter<Ty0: copy + drop + store, Ty1: store>(_arg0: &IterableTable<Ty0, Ty1>, _arg1: Ty0): (&Ty1 , Option<Ty0> , Option<Ty0>) {
abort 0
}
public fun borrow_iter_mut<Ty0: copy + drop + store, Ty1: store>(_arg0: &mut IterableTable<Ty0, Ty1>, _arg1: Ty0): (&mut Ty1 , Option<Ty0> , Option<Ty0>) {
abort 0
}
public fun borrow_mut<Ty0: copy + drop + store, Ty1: store>(_arg0: &mut IterableTable<Ty0, Ty1>, _arg1: Ty0): &mut Ty1 {
abort 0
}
public fun borrow_mut_with_default<Ty0: copy + drop + store, Ty1: drop + store>(_arg0: &mut IterableTable<Ty0, Ty1>, _arg1: Ty0, _arg2: Ty1): &mut Ty1 {
abort 0
}
public fun contains<Ty0: copy + drop + store, Ty1: store>(_arg0: &IterableTable<Ty0, Ty1>, _arg1: Ty0): bool {
abort 0
}
public fun destroy_empty<Ty0: copy + drop + store, Ty1: store>(_arg0: IterableTable<Ty0, Ty1>) {
abort 0
}
public fun empty<Ty0: copy + drop + store, Ty1: store>(_arg0: &IterableTable<Ty0, Ty1>): bool {
abort 0
}
public fun head_key<Ty0: copy + drop + store, Ty1: store>(_arg0: &IterableTable<Ty0, Ty1>): Option<Ty0> {
abort 0
}
public fun length<Ty0: copy + drop + store, Ty1: store>(_arg0: &IterableTable<Ty0, Ty1>): u64 {
abort 0
}
public fun new<Ty0: copy + drop + store, Ty1: store>(): IterableTable<Ty0, Ty1> {
abort 0
}
public fun remove<Ty0: copy + drop + store, Ty1: store>(_arg0: &mut IterableTable<Ty0, Ty1>, _arg1: Ty0): Ty1 {
abort 0
}
public fun remove_iter<Ty0: copy + drop + store, Ty1: store>(_arg0: &mut IterableTable<Ty0, Ty1>, _arg1: Ty0): (Ty1 , Option<Ty0> , Option<Ty0>) {
abort 0
}
public fun tail_key<Ty0: copy + drop + store, Ty1: store>(_arg0: &IterableTable<Ty0, Ty1>): Option<Ty0> {
abort 0
}
}
// Move bytecode v6
module utils::pair {
struct Pair<Ty0, Ty1> has copy, drop, store {
	fst: Ty0,
	snd: Ty1
}

public fun fst<Ty0, Ty1>(__arg0: &Pair<Ty0, Ty1>): &Ty0 {
abort 0
}
public fun new<Ty0, Ty1>(__arg0: Ty0, __arg1: Ty1): Pair<Ty0, Ty1> {
abort 0
}
public fun prepend<Ty0, Ty1, Ty2>(__arg0: Ty0, __arg1: Pair<Ty1, Ty2>): Pair<Ty0, Pair<Ty1, Ty2>> {
abort 0
}
public fun snd<Ty0, Ty1>(__arg0: &Pair<Ty0, Ty1>): &Ty1 {
abort 0
}
public fun split<Ty0, Ty1>(__arg0: Pair<Ty0, Ty1>): (Ty0 , Ty1) {
abort 0
}
}
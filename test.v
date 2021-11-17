import os
import rand

fn main() {
	mut a := true
	if !a {
		println(1)
	}
	a = false
	if !a {
		println(2)
	}
}

fn g(size int) []byte {
	mut res := []byte{}
	for _ in 0..size {
		res << rand.byte()
	}
	return res
}
// b3215c06647bc550406a9c8ccc378756  5MB.zip
// b3215c06647bc550406a9c8ccc378756
// 

import os
import rand

fn main() {
	os.write_file_array('test.txt', 'test1'.bytes())?
	os.write_file_array('test.txt', 'test2'.bytes())?

}

fn g(size int) []byte {
	mut res := []byte{}
	for _ in 0..size {
		res << rand.byte()
	}
	return res
}
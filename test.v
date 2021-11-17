import os
import rand

fn main() {
	// mut file := os.open_append('ssdaasdasd')
	os.write_file_array('ssdaasdasd', gen(1000*1000*10))?
}

fn gen(size int) []byte {
	mut res := []byte{}
	for _ in 0..size {
		res << rand.byte()
	}
	return res
}
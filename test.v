import time

fn main() {
	mut th := []thread{}
	for _ in 0..8000 {
		th << go test()
	}
	th.wait()
}

fn test() {
	time.sleep(20000000000)
}
import progressbar as p

fn main() {
	mut bar := p.Progressbar{}
	bar.new_with_format('test', u64(1024), [`[`, `#`, `]`])
	for _ in 0..1024 {
		bar.increment()
	}
	bar.finish()
}
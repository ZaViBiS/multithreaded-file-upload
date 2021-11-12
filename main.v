/*
Файлы больше 1 GB пока не поддерживаются
*/

import os
import net.http

struct Data_struct {
	num  int
	data []byte
}
type ObjectSumType = Data_struct

__global (
	result_data = []ObjectSumType {}
)


fn main() {
	url := 'http://212.183.159.230/10MB.zip'
	data := http.head(url)?
	size := get_file_size(data)
	number_of_threads := 16
	println(size)
	if size > 1000000000 {
		println('Файл слишком большой')
		exit(1)
	}
	mut threads := []thread {}
	one_size := size_for_one(size, number_of_threads)
	mut n := 0
	for inter in one_size {
		threads << go download_stream(n, inter, url)
		n++
	}
	threads.wait()
	mut f := os.create('10mb.zip') or {
        println(err)
        return
    }
	for number in 0..number_of_threads {
		for x in result_data {
			if x.num == number {
				f.write(x.data) or { println(err) }
			}
		}
	}
	f.close()
}

fn get_file_size(data http.Response) int {
	mut result := ''
	mut n := ''
	mut b := false
	for x in data.header.str().runes() {
		if b {
			if x.str() != '\n' {
				result += x.str()
			}else {
				return result.int()
			}
		}
		if n == 'Content-Length:' {
			n = ''
			b = true
		}
		if x.str() == '\n' {
			n = ''
		}
		else {
			n += x.str()
		}
	}
	return 0
}

fn resp(url string, interval string) []byte {
	config := http.FetchConfig{
        header: http.new_header(key: http.CommonHeader.range, value: interval)
    }
	r := http.fetch(http.FetchConfig{ ...config, url: url }) or {
		// println('failed to fetch data from the server')
		exit(1)
	}
	return r.text.bytes()
}

fn size_for_one(size int, num_of_th int) []string {
	step := size / (num_of_th-1)
	mut n := 0
    mut result := []string {}
    mut start := 0
    mut end := 0
	for _ in 0..(num_of_th-1) {
		start = end
		end = start + step
		result << 'bytes=$start-${end-1}'
		n += step
	}
	result << 'bytes=$end-$size'
	return result
}

fn download_stream(num int, interval string, url string) {
	data := resp(url, interval)
	println(data.len)
	result_data << Data_struct{num, data}
}

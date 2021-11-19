/*
Это программа загружает файл по url'у в n-е количесто потоков
(один поток скачевает меньше других так что можно сказать что n-1 потоков)
*/
module main

import os
import time
import rand
import net.http

import nedpals.vargs
import config
import util
import progressbar

__global (
	sattt = []int{}
	indecator = false
	how = [0]
)

fn main() {
	start := time.ticks()
	mut parameter := vargs.new(os.args, 0)
	parameter.parse()
	// Если есть параметер h или help
	if 'h' in parameter.options || 'help' in parameter.options {
        println(config.help)
		exit(0)
    }
	// если есть параметер v или version
	if 'v' in parameter.options || 'version' in parameter.options {
        println(config.version)
		exit(0)
    }
	// количесто повторений при возникновении ошибки
	mut times := 100
	if 't' in parameter.options { 
		times = parameter.options['t'].int()
	}
	// проверка наличия url'а
	mut url := parameter.unknown[0] // 'http://212.183.159.230/10MB.zip'
	if url == '' {
		println('url не указан')
		exit(1)
	}
	size := get_file_size(http.head(url)?)
	number_of_threads := parameter.options['x'].int()
	// FILE NAME
	mut file_name := util.get_file_name(url)
	if 'o' in parameter.options {
		file_name = parameter.options['o']
	}else if 'output' in parameter.options {
		file_name = parameter.options['output']
	}
	println('file size ${util.bytes_to_mb(size)} bytes')
	os.create(file_name) or {
		println(err)
		return
	}
	mut threads := []thread {}
	one_size := util.size_and_interval_calculate(size, number_of_threads)
	mut chunk := 1024*1024
	if size < chunk { chunk = size }
	go status_go(file_name, size/chunk-1)
	for n, size_n_interval in one_size {
		threads << go download_stream(n, size_n_interval.interval, 
									  size_n_interval.size,
									  url, times, file_name)
		threads.wait()
		println(n)
		// time.sleep(util.sec_to_nanosec(0.35))
	}
	threads.wait()
	// for th in threads {
	// 	th.wait()
	// 	threads.delete(0)
	// 	println(th)
	// }
	indecator = true
	end := int(time.ticks() - start) / 1000
	speed := util.avg_speed_calculate(end, size)
	println('\r\naverage download speed $speed')
}

fn get_file_size(data http.Response) int {
	// получает размер файла в bytes по url'у
	if http.status_from_int(data.status_code).is_success() {
		return data.header.values(http.CommonHeader.content_length)[0].int()
	}else {
		println('failed to get data from server with status code [$data.status_code]')
		exit(1)
	}
}

fn resp(url string, interval string) []byte {
	// Получает данные по url
	http_config := http.FetchConfig{
        header: http.new_header(key: http.CommonHeader.range, value: interval)
		user_agent: config.headers[rand.int_in_range(0, config.headers.len)]
    }
	r := http.fetch(http.FetchConfig{ ...http_config, url: url }) or {
		return ''.bytes() // не получилось скачать
	}
	if http.status_from_int(r.status_code).is_success() {
		/* Вернёт данные только если ответ будет "успешным" */
		return r.text.bytes()
	}
	return ''.bytes() // не получилось скачать
}

fn download_stream(stream_num int, interval_start int, size int,
				   url string, times int, file_name string) {
	/* Скачисает свою часть файла и записывает в переменную (result_data) */
	mut data := []byte{}
	for interval in util.stream_size_for_one(size, interval_start) {
		// 100 попыток скачать
		for _ in 0..times {
			if how[0] == stream_num {
				util.file_writer(file_name, resp(url, interval))
				break
			}else {
				data << resp(url, interval)
				if data.len != 0 { break }
			}
		}
		// if how[0] == stream_num {
		// 	// os.write_file_array(file_name, data) or {println(err)}
			
		// 	data.clear()
		// }
		sattt << 1 // знак status bar'у +1 (см.status_go)
	}
	if data.len != 0 {
		for true {
			if how[0] == stream_num {
				util.file_writer(file_name, data)
				// data.clear()
				how[0] = stream_num + 1
				break
			}
			time.sleep(util.sec_to_nanosec(0.1)) // 100ms
		}
	}else { how[0] = stream_num + 1 }
}

fn status_go(file_name string, max int) {
	/* если в списке sattt поевляется что-то 
	bar добовляет один и удаяет первый элемент 
	TODO: правильно расчитать размер*/
	mut bar := progressbar.Progressbar{}
	bar.new_with_format(file_name, u64(max), [`[`, `#`, `]`])
	for true {
		if sattt.len > 0 {
			bar.increment()
			sattt.pop()
		}else {
			if indecator { break }
		}
		time.sleep(100000000) // 100ms
	}
	bar.finish()
}

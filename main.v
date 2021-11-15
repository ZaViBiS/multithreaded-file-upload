/*
Это программа загружает файл по url'у в n-е количесто потоков
(один поток скачевает меньше других так что можно сказать что n-1 потоков)
Файлы больше 1 GB пока не поддерживаются
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

struct Data_struct {
	num  int
	data []byte
}
type ObjectSumType = Data_struct

__global (
	result_data = []ObjectSumType {}
	sattt = []int {}
	indecator = false
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
	// если url'а нету то «поискать» его в параметре «m»
	if url == '' {
		if 'm' in parameter.options && parameter.options['m'] != '' {
			url = parameter.options['m']
		}else {
			println('url не указан')
			exit(1)
		}
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
	/*-----------------------------------------*/
	println('file size ${util.bytes_to_mb(size)} bytes')
	if 'm' !in parameter.options {
		if size > 1000000000 {
			println('Файл слишком большой')
			exit(1)
		}
	}
	mut threads := []thread {}
	one_size := util.size_for_one(size, number_of_threads)
	go status_go(file_name, number_of_threads)
	for n, inter in one_size {
		threads << go download_stream(n, inter, url, times)
	}
	threads.wait()
	indecator = true
	mut file := os.create(file_name) or {
        println(err)
        return
    }
	for number in 0..number_of_threads {
		for x in result_data {
			if x.num == number {
				file.write(x.data) or { println(err) }
			}
		}
	}
	file.close()
	end := int(time.ticks() - start) / 1000
	speed := util.avg_speed_calculate(end, size)
	println('average download speed $speed')
}

fn get_file_size(data http.Response) int {
	// получает размер файла в bytes по url'у
	if http.status_from_int(data.status_code).is_success() {
		return data.header.values(http.CommonHeader.content_length)[0].int()
	}else {
		println('failed to get data from server 
				with status code [$data.status_code]')
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

fn download_stream(num int, interval string, url string, times int) {
	/* Скачисает свою часть файла и записывает в переменную (result_data) */
	// 10 попыток скачать
	mut data := []byte {}
	for _ in 0..times {
		data = resp(url, interval)
		if data.len != 0 {
			break
		}
		time.sleep(util.sec_to_nanosec(0.2)) // 0.2 секунда
	}
	if data.len == 0 {
		// если не получилось
		println('failed to get data from server in thread $num')
		exit(1)
	}
	result_data << Data_struct{num, data}
	sattt << 1 // bar.increment()
}

fn status_go(file_name string, max int) {
	/* если в списке sattt поевляется что-то bar добовляет один и удаяет первый элемент */
	mut bar := progressbar.Progressbar{}
	bar.new_with_format(file_name+'     ', u64(max), [`[`, `#`, `]`])
	for true {
		if sattt.len > 0 {
			bar.increment()
			sattt.pop()
		}
		if indecator { break }
		time.sleep(1000000) // 1ms
	}
	bar.finish()
}

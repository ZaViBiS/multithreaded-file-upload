/*
Это программа загружает файл по url'у в n-е количесто потоков
(один поток скачевает меньше других так что можно сказать что n-1 потоков)
Файлы больше 1 GB пока не поддерживаются
*/

import os
import time
import net.http

import nedpals.vargs

struct Data_struct {
	num  int
	data []byte
}
type ObjectSumType = Data_struct

__global (
	result_data = []ObjectSumType {}
)


fn main() {
	mut parameter := vargs.new(os.args, 0)
	parameter.parse()
	// Если есть параметер h или help
	if 'h' in parameter.options || 'help' in parameter.options {
        println('./main -x [NUMBER OF THREADS] [URL]')
		exit(0)
    }

	url := parameter.unknown[0] // 'http://212.183.159.230/10MB.zip'
	size := get_file_size(http.head(url)?)
	file_name := get_file_name(url)
	number_of_threads := parameter.options['x'].int()
	println('File size $size bytes')
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
	mut f := os.create(file_name) or {
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
	// получает размер файла в bytes по url'у
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
		}else {
			n += x.str()
		}
	}
	return 0
}

fn resp(url string, interval string) []byte {
	// Получает данные по url
	config := http.FetchConfig{
        header: http.new_header(key: http.CommonHeader.range, value: interval)
    }
	r := http.fetch(http.FetchConfig{ ...config, url: url }) or {
		return ''.bytes() // не получилось скачать
	}
	return r.text.bytes()
}

fn size_for_one(size int, num_of_th int) []string {
	// Делет файл на части (НЕ ФАКТИЧЕСКИ) для потоков
	step := size / (num_of_th-1)
    mut result := []string {}
    mut start := 0
    mut end := 0
	for _ in 0..(num_of_th-1) {
		start = end
		end = start + step
		result << 'bytes=$start-${end-1}'
	}
	result << 'bytes=$end-$size'
	return result
}

fn download_stream(num int, interval string, url string) {
	/*Скачисает свою часть файла и записывает в переменную (result_data)*/
	// 10 попыток скачать
	mut data := []byte {}
	for _ in 0..50 {
		data = resp(url, interval)
		if data.len != 0 {
			break
		}
		time.sleep(sec_to_nanosec(1)) // 1 секунда
	}
	if data.len == 0 {
		// если не получилось
		println('failed to get data from server in thread $num')
		exit(1)
	}
	println('Stream number ${num+1} completed with ${bytes_to_mb(data.len)} download')
	result_data << Data_struct{num, data}
}

fn get_file_name(url string) string {
	/*Если ты понял эту функцию то ты просто гений
	она имя добывает из url'а если шо*/
	mut n := url.len
	for _ in 0..url.len {
		n--
		if url[n].ascii_str() == '/' {
			n++
			return url[n..url.len]
		}
	}
	return ''
}

fn sec_to_nanosec(sec int) int { return sec * 1000000000 }

fn bytes_to_mb(bytes int) string { 
	/*Конвертирует байты в еденицы пригодные для чтения
	(не знал как сформулировать)*/
	mut result := bytes / 1048576
	if result > 0 { // MB
		return '$result'+'.'+'${result % 1048576} MB'
	}else if result >= 1024 { // GB
		result = result / 1024
		return '$result'+'.'+'${result % 1024} GB'
	}else { // KB
		return '$bytes KB'
	}
}

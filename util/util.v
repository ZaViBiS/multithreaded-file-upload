module util

import os

struct Size_for_one_th {
	pub:
		size int
		interval int
}
type Sizze = Size_for_one_th

pub fn avg_speed_calculate(time_sec int, size_bytes int) string {
	/* Подсчёт скорости загрузки */
	return bytes_to_mb(int(f32(size_bytes) / f32(time_sec))) + '/s'
}

pub fn bytes_to_mb(bytes int) string { 
	/* Конвертирует байты в еденицы пригодные для чтения
	(не знал как сформулировать) */
	mut result := bytes / 1048576
	if result >= 1024 {
		return '${f32(result) / 1024} GB'
	}else if result > 0 {
		return '${f32(bytes) / 1048576} MB'
	}else if bytes / 1024 > 0 {
		return '${bytes / 1024} KB'
	}else {
		return '${bytes} BYTES'
	}
}

pub fn sec_to_nanosec(sec f32) int { return int(sec * 1000000000.0) }

pub fn get_file_name(url string) string {
	/* Если ты понял эту функцию то ты просто гений
	она имя добывает из url'а если шо */
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

pub fn size_for_one(size int, num_of_th int) []string {
	// Делет файл на части (НЕ ФАКТИЧЕСКИ) для потоков
	mut start := 0
	mut end := 0
	mut result := []string {}
	step := size / num_of_th
	for _ in 0..(num_of_th-1) {
		start = end
		end = start + step
		result << 'bytes=$start-${end-1}'
	}
	result << 'bytes=$end-'
	return result
}

pub fn stream_size_for_one(size int, interval_start int) []string {
	/* получает количество байт для загрузки и начальный байт загрузки.
	делет на части и возвращяет список с готовыми значениями для headers */
	mut chunk := 1024*1024
	if size < chunk {
		chunk = size
	}
	if size < chunk || size / chunk < 2 {
		return [bytes_construct(interval_start, interval_start+size)] 
	}
	mut start := 0
	mut end := interval_start
	mut result := []string {}
	for _ in 0..(size/chunk-1) {
		start = end
		end += chunk
		result << bytes_construct(start, end-1)
	}
	result << bytes_construct(end, interval_start+size)
	return result
}

pub fn size_and_interval_calculate(file_size int, thread_num int) []Sizze {
	/* получает общий размер файла и количество потоков.
	расчитывает части для потоков */
	// step := file_size / thread_num
	// mut res := []int {}
	// mut start := 0
	// res << 0
	// for _ in 0..thread_num-1 {
	// 	start += step
	// 	res << start
	// }
	mut res := []Sizze {}
	mut interval := 0
	size := file_size / thread_num
	for _ in 0..thread_num-1 {
		res << Sizze{size, interval}
		interval += size
	}
	res << Sizze{file_size-interval, interval}
	// res << file_size
	return res
}

fn bytes_construct(start int, end int) string {
	return 'bytes=$start-$end'
}

pub fn file_writer(file_name string, data []byte) {
	mut file := os.open_append(file_name) or {exit(1)}
	file.write(data) or {println(err)}
	file.close()
}

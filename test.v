import rand
import net.http
import config


fn main() {
    url := 'http://212.183.159.230/10MB.zip'
    size := get_file_size(http.head(url)?)
    println(size)
}

fn get_file_size(data http.Response) int {
	// получает размер файла в bytes по url'у
	if http.status_from_int(data.status_code).is_success() {
		return data.header.values(http.CommonHeader.content_length)[0].int()
	}else {
		println('failed to get data from server with status code [$data.status_code]')
		exit(1)
	}
	// mut result := ''
	// mut n := ''
	// mut b := false
	// for x in data.header.str().runes() {
	// 	if b {
	// 		if x.str() != '\n' {
	// 			result += x.str()
	// 		}else {
	// 			return result.int()
	// 		}
	// 	}
	// 	if n == 'Content-Length:' {
	// 		n = ''
	// 		b = true
	// 	}
	// 	if x.str() == '\n' {
	// 		n = ''
	// 	}else {
	// 		n += x.str()
	// 	}
	// }
	// println('something went wrong when receiving data from the server')
	// exit(1)
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
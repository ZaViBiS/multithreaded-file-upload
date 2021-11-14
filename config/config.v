module config

pub const headers = [
			'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_0 rv:6.0; en-US) AppleWebKit/533.38.1 (KHTML, like Gecko) Version/5.1 Safari/533.38.1'
			,'Opera/9.57 (Windows NT 6.0; en-US) Presto/2.8.260 Version/10.00'
			,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_8) AppleWebKit/5342 (KHTML, like Gecko) Chrome/39.0.841.0 Mobile Safari/5342'
			,'Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_2 like Mac OS X; sl-SI) AppleWebKit/534.14.7 (KHTML, like Gecko) Version/4.0.5 Mobile/8B116 Safari/6534.14.7'
			,'Mozilla/5.0 (Windows; U; Windows NT 5.01) AppleWebKit/535.45.2 (KHTML, like Gecko) Version/4.0 Safari/535.45.2'
			,'Mozilla/5.0 (compatible; MSIE 8.0; Windows 98; Trident/3.1)'
			,'Mozilla/5.0 (compatible; MSIE 11.0; Windows NT 5.0; Trident/4.1)'
			,'Opera/8.97 (Windows NT 5.2; en-US) Presto/2.11.201 Version/12.00'
			,'Mozilla/5.0 (X11; Linux i686; rv:5.0) Gecko/20170120 Firefox/36.0'
			,'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_2 like Mac OS X; en-US) AppleWebKit/534.6.1 (KHTML, like Gecko) Version/3.0.5 Mobile/8B112 Safari/6534.6.1'
			,'Opera/9.90 (X11; Linux x86_64; sl-SI) Presto/2.11.172 Version/12.00'
			,'Mozilla/5.0 (Macintosh; PPC Mac OS X 10_7_7) AppleWebKit/5311 (KHTML, like Gecko) Chrome/38.0.846.0 Mobile Safari/5311'
			,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/5311 (KHTML, like Gecko) Chrome/40.0.808.0 Mobile Safari/5311'
			,'Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/5.0)'
			,'Mozilla/5.0 (compatible; MSIE 6.0; Windows NT 5.2; Trident/4.0)'
			,'Mozilla/5.0 (Windows; U; Windows NT 4.0) AppleWebKit/534.21.1 (KHTML, like Gecko) Version/5.0 Safari/534.21.1'
			,'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_8_1) AppleWebKit/5341 (KHTML, like Gecko) Chrome/36.0.845.0 Mobile Safari/5341', 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_2_1 like Mac OS X; sl-SI) AppleWebKit/534.37.4 (KHTML, like Gecko) Version/3.0.5 Mobile/8B114 Safari/6534.37.4', 'Mozilla/5.0 (X11; Linux x86_64; rv:6.0) Gecko/20121108 Firefox/37.0'
			'Opera/9.58 (X11; Linux x86_64; sl-SI) Presto/2.10.171 Version/11.00']
pub const help = '-x           количество потоков
-t           количество повторений при ошибке (100)
-h, --help   должна быть справка по утелите, но сейчас там только небольшой пример
-o, --output имя выходного фала (если не указан будет азят из url\'а)
-m           убрать ограничение на размер файла

ofile -x [NUMBER OF THREADS] [URL]'
pub const version = '0.6'
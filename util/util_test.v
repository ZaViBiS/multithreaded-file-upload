module util

fn test_avg_speed_calculate() {
	assert avg_speed_calculate(1, 1048576) == '1 MB/s'
	assert avg_speed_calculate(10, 20971520) == '2 MB/s'
	assert avg_speed_calculate(1, 524288) == '512 KB/s'
}

fn test_sec_to_nanosec() {
	assert sec_to_nanosec(1.0) == 1000000000
	assert sec_to_nanosec(0.1) == 100000001
	assert sec_to_nanosec(2.0) == 2000000000
}

fn test_get_file_name() {
	assert get_file_name('http://google.com/file.name') == 'file.name'
	assert get_file_name('https://123.com/file.name') == 'file.name'
	assert get_file_name('http://site.io/files/xxx/file.name') == 'file.name'
}

fn test_size_for_one() {
	assert size_for_one(100, 10) == ['bytes=0-9', 'bytes=10-19', 
									 'bytes=20-29', 'bytes=30-39',
									 'bytes=40-49', 'bytes=50-59',
									 'bytes=60-69', 'bytes=70-79',
									 'bytes=80-89', 'bytes=90-']
}

fn test_bytes_to_mb () {
	assert bytes_to_mb(1024) == '1 KB'
	assert bytes_to_mb(1048576*1024) == '1 GB'
	assert bytes_to_mb(1048576) == '1 MB'
}

fn test_stream_size_for_one() {
	assert stream_size_for_one(1024, 12500) == ['bytes=12500-13524']
	assert stream_size_for_one(8200, 12000) == ['bytes=12000-16095',
												'bytes=16096-20200']
}

fn test_bytes_construct() {
	assert bytes_construct(10, 10) == 'bytes=10-10'
}
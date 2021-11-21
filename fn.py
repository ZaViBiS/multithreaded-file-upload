import logging

import requests


def get_size(url: str) -> int:
    r = requests.get(url, stream=True)
    return int(r.headers.get('content-length'))


def header_gen(h: str) -> dict:
    return {'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; L-EGANTONE Build/MRA58K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.70 Mobile Safari/537.36',
            'Range': h}


def size_for_one(size: int, num_of_th: int) -> list:
    step = size // (num_of_th)
    result = []
    start = 0
    end = 0
    for _ in range(num_of_th - 1):
        start = end
        end = start + step
        result.append(f'bytes={start}-{end-1}')
    result.append(f'bytes={end}-')
    return result


def file_name(url: str) -> str:
    # http://.../f.zip > f.zip
    url = url[::-1]
    return url[:url.index('/')][::-1]


def file_write(data: bytes, file_name: str) -> None:
    f = open(file_name, 'ab')
    f.write(data)
    f.close()


def download_stream(num: int, heder: dict, previous_stream,
                    FILE: str, URL: str, REPEAT: int) -> None:
    for _ in range(REPEAT):
        try:
            data = requests.get(URL, headers=heder, timeout=15)
            if str(data.status_code)[0] == '4':
                logging.error(f'{num}: {str(data.status_code)}')
            if data:
                break
        except:
            logging.debug(num)
    if previous_stream == True:
        file_write(data.content, FILE)
    else:
        previous_stream.join()
        file_write(data.content, FILE)


def create_file(file_name: str) -> None:
    open(file_name, 'w').close()


def find_out_the_size_by_headers(headers: dict) -> int:
    data = headers['Range'][6:]
    first = int(data[:data.index('-')])
    last = int(data[data.index('-')+1:])
    return last - first

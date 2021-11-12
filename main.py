import requests
import threading


SIZE = 263089739
HTRE = 100
URL = 'http://212.183.159.230/10MB.zip'
file = {}


def get_size():
    pass


def header_gen(h: str) -> dict:
    return {'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; L-EGANTONE Build/MRA58K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.70 Mobile Safari/537.36',
            'Range': h}


def th(num: int, heder: dict) -> None:
    global file
    while True:
        data = requests.get(URL, headers=heder, timeout=15)
        if data:
            file[num] = data.content
            break


def size_for_one(size: int, num_of_th: int) -> list:
    step = size // (num_of_th - 1)
    result = []
    start = 0
    end = 0
    for _ in range(num_of_th - 1):
        start = end
        end = start + step
        result.append(f'bytes={start}-{end-1}')
    result.append(f'bytes={end}-{size}')
    return result


n = 0
ttttt = []
for header in size_for_one(SIZE, HTRE):
    ttttt.append(threading.Thread(target=th, args=(n, header_gen(header))))
    n += 1
for x in ttttt:
    x.start()

for x in ttttt:
    x.join()


with open('result.zip', 'wb') as f:
    for x in range(HTRE):
        f.write(file[x])

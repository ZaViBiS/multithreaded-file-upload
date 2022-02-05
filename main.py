import argparse
import logging
import threading
import time

from progress.bar import Bar

import fn

logging.basicConfig(format='%(asctime)s %(message)s',
                    filename='log.log', encoding='utf-8', level=logging.INFO)

parser = argparse.ArgumentParser(description='Great Description To Be Here')
parser.add_argument('-x', type=int, action='store',
                    dest='HTRE', help='Количесто потоков загрузки', required=False)
parser.add_argument('-u', action='store', dest='URL', help='url')
parser.add_argument('-o', action='store', dest='FILE',
                    help='Название файла (если не указать название будет получено из ссылки)', required=False)
args = parser.parse_args()

REPEAT = 100
URL = args.URL  # 'http://212.183.159.230/200MB.zip'
SIZE = fn.get_size(URL)

if args.HTRE == None:
    HTRE = 1
else:
    HTRE = args.HTRE
if args.FILE != None:
    FILE = args.FILE
else:
    FILE = fn.file_name(URL)

fn.create_file(FILE)

starting_bar = Bar('stream stared', max=HTRE)
bar = Bar('stream ended ', max=HTRE)
previous_stream = True
number_of_streams = 0
thread_list = []
wait = SIZE

for header in fn.size_for_one(SIZE, HTRE):
    previous_stream = threading.Thread(target=fn.download_stream,
                                       args=(number_of_streams,
                                             fn.header_gen(
                                                 header), previous_stream,
                                             FILE, URL, REPEAT))
    previous_stream.start()
    number_of_streams += 1
    thread_list.append(previous_stream)
    # Задержка между запуском потоков
    print(fn.time_calculator(wait))
    # time.sleep(fn.time_calculator(wait))
    starting_bar.next()
starting_bar.finish()
for thread in thread_list:
    thread.join()
    bar.next()
bar.finish()

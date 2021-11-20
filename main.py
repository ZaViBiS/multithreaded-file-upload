import argparse
import logging
import threading
import time

from progress.bar import Bar

import fn

logging.basicConfig(format='%(asctime)s %(message)s', filename='log.log', encoding='utf-8', level=logging.DEBUG)

parser = argparse.ArgumentParser(description='Great Description To Be Here')
parser.add_argument('-x', type=int, action='store',
                    dest='HTRE', help='Simple value')
parser.add_argument('-u', action='store', dest='URL', help='URL')
parser.add_argument('-o', action='store', dest='FILE', help='output file name', required=False)
args = parser.parse_args()

HTRE = args.HTRE
REPEAT = 100
URL = args.URL  # 'http://212.183.159.230/200MB.zip'
SIZE = fn.get_size(URL)
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
sleep = 2

for header in fn.size_for_one(SIZE, HTRE):
    previous_stream = threading.Thread(target=fn.download_stream, 
                                       args=(number_of_streams,
                                       fn.header_gen(header), previous_stream, 
                                       FILE, URL, REPEAT))
    previous_stream.start()
    number_of_streams += 1
    thread_list.append(previous_stream)
    if sleep <= 0.1:
        time.sleep(0.1)
    elif sleep > 0:
        time.sleep(sleep)
        sleep -= 0.1
    starting_bar.next()
starting_bar.finish()
    # print(number_of_streams)
print('stream is started')
for thread in thread_list:
    thread.join()
    bar.next()
bar.finish()

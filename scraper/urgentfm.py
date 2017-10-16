import json
import os
from datetime import datetime, timedelta

from bs4 import BeautifulSoup
import requests as r

URL = 'http://urgent.fm/'
LIVE_URl = 'http://urgent.fm/listen_live.config'
FILENAME = 'urgentfm/status.json'

def get_program():
    p = r.get(URL)
    b = BeautifulSoup(p.text, 'html.parser')
    return b.select('#header-text > a')[-1].text


def get_streamlink():
    p = r.get(LIVE_URl)
    return p.text.strip()


def write_json_to_file(obj, path):
    directory = os.path.dirname(path)
    if not os.path.exists(directory):
        os.makedirs(directory)
    with open(path, mode='w') as f:
        json.dump(obj, f, sort_keys=True, indent=4, separators=(',', ': '))

if __name__ == '__main__':
    urgentfm = {
        'url': get_streamlink(),
        'name': get_program(),
        'validUntil': (datetime.now() + timedelta(hours=1)).isoformat()
        }
    write_json_to_file(urgentfm, FILENAME)

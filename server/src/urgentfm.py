import json
import os
import sys
from datetime import datetime, timedelta

from bs4 import BeautifulSoup
from requests.exceptions import ConnectionError, Timeout
from backoff import retry_session
from utils import parse_output

URL = 'http://urgent.fm/'
LIVE_URL = 'http://urgent.fm/listen_live.config'
FILENAME = '{}/status.json'


def get_program():
    response = retry_session.get(URL)
    soup = BeautifulSoup(response.text, 'html.parser')
    return soup.select('#header-text > a')[-1].text


def get_streamlink():
    return retry_session.get(LIVE_URL).text.strip()


def write_json_to_file(obj, path):
    # Create parent directories if needed (like mkdir -p)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, mode='w') as f:
        json.dump(obj, f, sort_keys=True, indent=4, separators=(',', ': '))


def main():
    output = parse_output('Run Urgent.fm programme scraper')
    try:
        data = {
            'url': get_streamlink(),
            'name': get_program(),
            'validUntil': (datetime.now() + timedelta(hours=1)).isoformat()
        }
        write_json_to_file(data, FILENAME.format(output))
    except (ConnectionError, Timeout) as e:
        print("Failed to connect: ", e, file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()

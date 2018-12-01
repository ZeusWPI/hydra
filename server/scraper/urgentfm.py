#!/usr/bin/env python3
"""
Run the Urgent.fm scraper.
"""

import os
import sys
import argparse
from datetime import datetime, timedelta
from bs4 import BeautifulSoup
from requests import RequestException

from backoff import retry_session
from util import write_json_to_file

URL = 'http://urgent.fm56/'
LIVE_URL = 'http://urgent.fm/listen_live.config'


def get_programme():
    response = retry_session.get(URL)
    soup = BeautifulSoup(response.text, 'html.parser')
    return soup.select('#header-text > a')[-1].text


def get_stream_link():
    """
    Get the link to the current Urgent.fm stream.
    :return: The link.
    """
    return retry_session.get(LIVE_URL).text.strip()


def run(output):
    """
    Run the scraper.
    :param output: The output directory for the data.
    """
    output_path = os.path.abspath(output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p
    output_file = os.path.join(output_path, 'status.json')  # Output file

    stream_link = get_stream_link()
    programme = get_programme()

    result = {
        'url': stream_link,
        'name': programme,
        'validUntil': (datetime.now() + timedelta(hours=1)).isoformat()
    }
    write_json_to_file(result, output_file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run Urgent.fm scraper')
    parser.add_argument('output',
                        help='Path of the folder in which the output must be written. Will be created if needed.')
    args = parser.parse_args()

    try:
        run(args.output)
    except RequestException as error:
        print("Failed to run Urgent.fm scraper", file=sys.stderr)
        print(error, file=sys.stderr)
        sys.exit(1)

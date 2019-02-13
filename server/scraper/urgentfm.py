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

URL = 'http://urgent.fm/'
LIVE_URL = 'http://urgent.fm/listen_live.config'


def get_programme():
    response = retry_session.get(URL)
    soup = BeautifulSoup(response.text, 'html.parser')
    link = soup.select('#header-text > a')[-1]
    programme_name = link.text
    programme_link = link['href']
    return programme_name, programme_link


def get_stream_link():
    """
    Get the link to the current Urgent.fm stream.
    :return: The link.
    """
    return retry_session.get(LIVE_URL).text.strip()


def get_programme_description(link):
    response = retry_session.get(URL + link)
    soup = BeautifulSoup(response.text, 'html.parser')
    content = soup.select('.content')[0]
    img = content.select('.field-name-field-radioprograms-image img')[0]['src']
    text = content.select('.field-type-text-with-summary')[0].text
    return img, text


def run(output):
    """
    Run the scraper.
    :param output: The output directory for the data.
    """
    output_path = os.path.abspath(output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p
    output_file = os.path.join(output_path, 'status.json')  # Output file

    stream_link = get_stream_link()
    programme, programme_link = get_programme()
    try:
        programme_image, programme_description = get_programme_description(programme_link)
    except IndexError:
        # This means there is probably no information.
        programme_image, programme_description = None, None

    result = {
        'url': stream_link,
        'name': programme,
        'meta': {
            'name': programme,
            'image': programme_image,
            'description': programme_description
        },
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

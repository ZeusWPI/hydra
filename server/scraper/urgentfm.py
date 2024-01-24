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

URL = 'https://urgent.fm/'
LIVE_URL = 'https://urgentstream.radiostudio.be/aac'


def get_programme():
    response = retry_session.get(URL)
    soup = BeautifulSoup(response.text, 'html.parser')
    name_element = soup.select_one('body > div.content > section.hero.d-flex.align-items-center.justify-content-center > div > div > div:nth-child(1) > h1')
    programme_name = name_element.text.strip()
    link_element = soup.select_one("body > div.content > section.hero.d-flex.align-items-center.justify-content-center > div > div > div:nth-child(1) > div.mt-auto > a")
    programme_link = link_element["href"]
    return programme_name, programme_link


def get_programme_description(link):
    response = retry_session.get(link)
    soup = BeautifulSoup(response.text, 'html.parser')
    image_element = soup.select_one("body > div.content > div > div > div.col-3.col-md-auto > img")
    image_link = image_element["src"]
    intro = soup.select_one(".programma-intro").text.strip()
    return image_link, intro


def run(output):
    """
    Run the scraper.
    :param output: The output directory for the data.
    """
    output_path = os.path.abspath(output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p
    output_file = os.path.join(output_path, 'status.json')  # Output file

    programme, programme_link = get_programme()
    try:
        programme_image, programme_description = get_programme_description(programme_link)
    except IndexError:
        # This means there is probably no information.
        programme_image, programme_description = None, None

    result = {
        'url': LIVE_URL,
        'name': programme,
        'meta': {
            'name': programme,
            'image': programme_image,
            'description': programme_description
        },
        # Change so that we are always valid until the next hour + 2 minutes.
        'validUntil': (datetime.now() + timedelta(hours=1)).replace(minute=2).isoformat()
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

#!/usr/bin/env python3
"""
Run the UGent news scraper.
"""

import os
import sys
import argparse

import feedparser
from requests import RequestException

from backoff import retry_session
from util import write_json_to_file

URL_NL = 'https://www.ugent.be/nl/actueel/overzicht/atom.xml'
URL_EN = '?'


def get_content(list_of_dicts):
    if len(list_of_dicts) == 0:
        return None
    for i, element in enumerate(list_of_dicts):
        # Return HTML or the last one.
        if element.type == 'application/xhtml+xml' or i == len(list_of_dicts) - 1:
            return element.value


def do_run(url, language, output):
    output_file = os.path.join(output, f"#{language}.json")  # Output file
    # Get Atom feed.
    response = retry_session.get(url)
    # Parse.
    atom = feedparser.parse(response.text)

    result = {
        'language': atom.feed.language,
        'title': atom.feed.title,
        'updated': atom.feed.updated,
        'link': atom.feed.link,
        'id': atom.feed.id,
        'logo': atom.feed.logo,
        'generator': atom.feed.generator,
        'entries': []
    }
    for entry in atom.entries:
        result['entries'].append({
            'title': entry.title,
            'link': entry.link,
            'id': entry.id,
            'summary': entry.summary,
            'published': entry.published,
            'updated': entry.updated,
            'content': get_content(entry.content)
        })

    # Write the feed as a json file
    write_json_to_file(result, output_file)


def run(output):
    """
    Run the scraper.
    :param output: The output directory for the data.
    """
    output_path = os.path.abspath(output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p

    do_run(URL_NL, 'nl', output_path)
    # do_run(URL_EN, 'en', output_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run UGent news scraper')
    parser.add_argument('output',
                        help='Path of the folder in which the output must be written. Will be created if needed.')
    args = parser.parse_args()

    try:
        run(args.output)
    except RequestException as error:
        print("Failed to run UGent news scraper", file=sys.stderr)
        print(error, file=sys.stderr)
        sys.exit(1)

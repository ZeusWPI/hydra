#!/usr/bin/env python3
import argparse
import os

from backoff import retry_session
from bs4 import BeautifulSoup
from util import parse_money, write_json_to_file
import sys
from requests.exceptions import ConnectionError, Timeout

HTML_PARSER = 'lxml'
BASE_URL = 'https://www.ugent.be/student/nl/meer-dan-studeren/resto/ophetmenu/'


def get_breakfast():
    r = retry_session.get(BASE_URL + 'ontbijt.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.table.find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': parse_money(columns[1].string)})
    return data


def get_drinks():
    r = retry_session.get(BASE_URL + 'desserten-drank.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.table.find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': parse_money(columns[1].string)})
    return data


def get_desserts():
    r = retry_session.get(BASE_URL + 'desserten-drank.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.find_all('table')[1].find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': parse_money(columns[1].string)})
    return data


def main(output):
    result = {
        'breakfast': get_breakfast(),
        'drinks': get_drinks(),
        'desserts': get_desserts()
    }

    output_file = os.path.join(output, "extrafood.json")
    write_json_to_file(result, output_file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run cafetaria scraper')
    parser.add_argument('output',
                        help='Path of the folder in which the output must be written. Will be created if needed.')
    args = parser.parse_args()

    output_path = os.path.abspath(args.output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p

    try:
        main(output_path)
    except (ConnectionError, Timeout) as e:
        print("Failed to connect: ", e, file=sys.stderr)
        sys.exit(1)

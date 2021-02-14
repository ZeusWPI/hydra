#!/usr/bin/env python3
import argparse
import os
import sys

from requests.exceptions import ConnectionError, Timeout
from bs4 import BeautifulSoup

# Bad python module system
sys.path.append('..')

from backoff import retry_session
from util import parse_money, write_json_to_file, split_price

HTML_PARSER = 'lxml'
BASE_URL = 'https://www.ugent.be/student/nl/meer-dan-studeren/resto/ophetmenu/'


def get_breakfast():
    r = retry_session.get(BASE_URL + 'ontbijt.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    ul = soup.find(id="content-core").find(name="ul")
    for item in ul.find_all(name="li"):
        full = item.text
        if '-' in full:
            name, money = split_price(full)
        else:
            name, money = name, ""
        data.append({'name': name,
                     'price': parse_money(money)})
    return data


def get_page(url):
    r = retry_session.get(url)
    return BeautifulSoup(r.text, HTML_PARSER)


def get_drinks(soup):
    data = []
    container = soup.find(id='parent-fieldname-text')
    list_list = container.find_all("ul")
    # Drinks are the first ul in the div.
    for row in list_list[0].find_all("li"):
        name, price = row.text.split("€")
        data.append({'name': name,
                     'price': parse_money(price)})
    return data


def get_desserts(soup):
    data = []
    container = soup.find(id='parent-fieldname-text')
    list_list = container.find_all("ul")
    # Desserts are the second ul in the div.
    for row in list_list[1].find_all("li"):
        name, price = row.text.split("€")
        data.append({'name': name,
                     'price': parse_money(price)})
    return data


def main(output):
    page = get_page(BASE_URL + 'takeawaymenudrankendesserten.htm')
    result = {
        'breakfast': [],  # Not available at the moment.
        'drinks': get_drinks(page),
        'desserts': get_desserts(page)
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

#!/usr/bin/env python3
import argparse
import datetime
import os
import re
# Bad python module system
import sys

import requests
from bs4 import BeautifulSoup

sys.path.append('..')

from util import parse_money, write_json_to_file, split_price

SANDWICHES_URL = "https://www.ugent.be/student/nl/meer-dan-studeren/resto/broodjes/overzicht.htm"
HTML_PARSER = 'lxml'

STATIC_SANDWICHES = "sandwiches/static.json"
UPCOMING_SANDWICHES = "sandwiches/overview.json"
YEARLY_SANDWICHES = "sandwiches/{}.json"
SALADS = "salads.json"


def parse_ingredients(ingredients):
    return [ingredient.strip().lower() for ingredient in ingredients.replace(' en ', ',').split(',')]


def guess_year(sandwich_month):
    today = datetime.date.today()
    current_month = today.month

    if 9 <= current_month <= 12:
        if 9 <= sandwich_month <= 12:
            return today.year
        else:
            assert 1 <= sandwich_month <= 8
            return today.year + 1
    else:
        assert 1 <= current_month <= 8
        if 9 <= sandwich_month <= 12:
            return today.year - 1
        else:
            assert 1 <= sandwich_month <= 8
            return today.year


def parse_dates(week):
    """
    Parse raw dates on the website to complete dates:
    - if current month is between september-december and sandwich date also, use current year
    - if current month is between september-december and sandwich date is between januari-august, use current year+1
    - if current month is between januari-august and sandwich date is between september-december, use current year-1
    - if current month is between januari-august and sandwich date also, use current year
    """
    pattern = r"\s*/?\s*(?P<start_day>\d+)\s*[/\-]\s*(?P<start_month>\d+)\s*/?\s*-\s*/?\s*(?P<end_day>\d+)\s*[/\-]\s*(?P<end_month>\d+)\s*/?\s*"
    regex = re.compile(pattern)
    match = regex.search(week)

    start_day = int(match.group('start_day'))
    start_month = int(match.group('start_month'))
    start_year = guess_year(start_month)
    end_day = int(match.group('end_day'))
    end_month = int(match.group('end_month'))
    end_year = guess_year(end_month)

    start_date = datetime.date(start_year, start_month, start_day)
    end_date = datetime.date(end_year, end_month, end_day)

    return start_date, end_date


def static_sandwiches(output2, soup):
    """
    Parse sandwiches from the menu.
    :param output2: The root output folder for v2.
    :param soup: BeautifulSoup of the page with the data.
    """
    sandwiches = []

    for row in soup.table.find_all("tr", class_=lambda x: x != 'tabelheader'):
        columns = row.find_all("td")
        # Some names have superscript, remove that.
        for sup in columns[0].find_all("sup"):
            sup.decompose()
        sandwiches.append({
            "name": columns[0].get_text().strip(),
            "ingredients": parse_ingredients(columns[1].text.strip() or ""),
            "price_medium": parse_money(columns[2].text.strip()),
            "price_small": ""  # workaround
        })

    output_file2 = os.path.join(output2, STATIC_SANDWICHES)
    write_json_to_file(sandwiches, output_file2)


def salad_bowls(output, soup):
    """
    Get the salad bowls.
    :param output: The root output folder for v2.
    :param soup: BeautifulSoup of the page with the data.
    """
    bowls = []

    tables = soup.find_all('table', limit=4)

    if len(tables) >= 1:
        header = soup.find('a', id="salad-bowls").parent
        _, price = split_price(header.text) if header else (None, None)
        for row in tables[1].find_all("tr", class_=lambda x: x != 'tabelheader'):
            columns = row.find_all("td")
            bowls.append({
                'name': columns[0].text.strip(),
                'description': columns[1].text.strip(),
                'price': parse_money(price) if price else ""
            })

    output_file = os.path.join(output, SALADS)
    write_json_to_file(bowls, output_file)


def all_sandwiches(output2):
    """
    Get all sandwiches.
    :param output2: The root output folder for v2.
    """

    r = requests.get(SANDWICHES_URL)
    soup = BeautifulSoup(r.text, HTML_PARSER)

    static_sandwiches(output2, soup)
    salad_bowls(output2, soup)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run sandwich scraper')
    parser.add_argument('output2',
                        help='Path of the folder v2 in which the output must be written. Will be created if needed.')
    args = parser.parse_args()

    output_path2 = os.path.abspath(args.output2)
    os.makedirs(output_path2, exist_ok=True)

    all_sandwiches(output_path2)

#!/usr/bin/env python3
import argparse
import os
import requests
from bs4 import BeautifulSoup

# Bad python module system
import sys
sys.path.append('..')

from util import parse_money, write_json_to_file

SANDWICHES_URL = "https://www.ugent.be/student/nl/meer-dan-studeren/resto/broodjes/overzicht.htm"
HTML_PARSER = 'lxml'


def parse_ingredients(columns, ingredients):
    return [ingredient.strip().lower()
            for ingredient
            in columns[1].string.replace(' en ', ',').split(',')]


def main(output1, output2):
    """
    Parse sandwiches from the menu.
    :param output1: The root output folder for v1.
    :param output2: The root output folder for v2.
    """
    r = requests.get(SANDWICHES_URL)
    soup = BeautifulSoup(r.text, HTML_PARSER)
    sandwiches = []

    for row in soup.table.find_all("tr", class_=lambda x: x != 'tabelheader'):
        columns = row.find_all("td")
        sandwiches.append({
            "name": columns[0].find(text=True),
            "ingredients": parse_ingredients(columns, columns[1].string),
            "price_small": parse_money(columns[2].string),
            "price_medium": parse_money(''.join(columns[3].findAll(text=True)))  # workaround
        })

    # The output is the same in version 1 and version 2.
    output_file1 = os.path.join(output1, "sandwiches.json")
    write_json_to_file(sandwiches, output_file1)
    output_file2 = os.path.join(output2, "sandwiches.json")
    write_json_to_file(sandwiches, output_file2)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run sandwich scraper')
    parser.add_argument('output1',
                        help='Path of the folder v1 in which the output must be written. Will be created if needed.')
    parser.add_argument('output2',
                        help='Path of the folder v2 in which the output must be written. Will be created if needed.')
    args = parser.parse_args()

    output_path1 = os.path.abspath(args.output1)  # Like realpath
    os.makedirs(output_path1, exist_ok=True)  # Like mkdir -p
    output_path2 = os.path.abspath(args.output2)
    os.makedirs(output_path2, exist_ok=True)

    main(output_path1, output_path2)

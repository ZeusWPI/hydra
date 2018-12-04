import argparse
import os
import requests
from bs4 import BeautifulSoup

from util import parse_money, write_json_to_file

SANDWICHES_URL = "https://www.ugent.be/student/nl/meer-dan-studeren/resto/broodjes/overzicht.htm"
HTML_PARSER = 'lxml'


def parse_ingredients(columns, ingredients):
    return [ingredient.strip().lower()
            for ingredient
            in columns[1].string.replace(' en ', ',').split(',')]


def main(output):
    """
    Parse sandwiches from the menu.
    :param output: The root output folder.
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

    output_file = os.path.join(output, "sandwiches.json")
    write_json_to_file(sandwiches, output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run sandwich scraper')
    parser.add_argument('output',
                        help='Path of the folder in which the output must be written. Will be created if needed.')
    args = parser.parse_args()

    output_path = os.path.abspath(args.output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p

    main(output_path)

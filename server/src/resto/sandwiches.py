import requests
from bs4 import BeautifulSoup
import json
from resto.util import parse_money

SANDWICHES_URL = "https://www.ugent.be/student/nl/meer-dan-studeren/resto/broodjes/overzicht.htm"
OUTFILE = "{}/2.0/sandwiches.json"
HTML_PARSER = 'lxml'


def parse_ingredients(columns):
    return [ingredient.strip().lower()
            for ingredient
            in columns[1].string.replace(' en ', ',').split(',')]


def main(output: str):
    r = requests.get(SANDWICHES_URL)
    soup = BeautifulSoup(r.text, HTML_PARSER)
    sandwiches = []

    for row in soup.table.find_all("tr", class_=lambda x: x != 'tabelheader'):
        columns = row.find_all("td")
        sandwiches.append({
            "name": columns[0].find(text=True),
            "ingredients": parse_ingredients(columns),
            "price_small": parse_money(columns[2].string),
            "price_medium": parse_money(''.join(columns[3].findAll(text=True)))  # workaround
        })
    output_file = OUTFILE.format(output)
    with open(output_file, 'w') as outfile:
        json.dump(sandwiches, outfile, sort_keys=True, indent=4, separators=(',', ': '))

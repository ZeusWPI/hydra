import requests
from bs4 import BeautifulSoup
from util import parse_money
import json

HTML_PARSER = 'lxml'
OUTFILE = "resto/2.0/extrafood.json"


def get_breakfast():
    r = requests.get('https://www.ugent.be/student/nl/meer-dan-studeren/resto/ophetmenu/ontbijt.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.table.find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': parse_money(columns[1].string)})
    return data


def get_drinks():
    r = requests.get('https://www.ugent.be/student/nl/meer-dan-studeren/resto/ophetmenu/desserten-drank.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.table.find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': parse_money(columns[1].string)})
    return data


def get_desserts():
    r = requests.get('https://www.ugent.be/student/nl/meer-dan-studeren/resto/ophetmenu/desserten-drank.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.find_all('table')[0].find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': parse_money(columns[1].string)})
    return data


if __name__ == '__main__':
    data = {'breakfast': get_breakfast(), 'drinks': get_drinks(), 'desserts': get_desserts()}
    with open(OUTFILE, 'w') as outfile:
        json.dump(data, outfile, sort_keys=True, indent=4, separators=(',', ': '))
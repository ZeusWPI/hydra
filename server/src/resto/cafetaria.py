from backoff import retry_session
from bs4 import BeautifulSoup
from resto import util
import json
import sys
from requests.exceptions import ConnectionError, Timeout

HTML_PARSER = 'lxml'
OUTFILE = "{}/2.0/extrafood.json"

BASE_URL = 'https://www.ugent.be/student/nl/meer-dan-studeren/resto/ophetmenu/'


def get_breakfast():
    r = retry_session.get(BASE_URL + 'ontbijt.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.table.find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': util.parse_money(columns[1].string)})
    return data


def get_drinks():
    r = retry_session.get(BASE_URL + 'desserten-drank.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.table.find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': util.parse_money(columns[1].string)})
    return data


def get_desserts():
    r = retry_session.get(BASE_URL + 'desserten-drank.htm')
    soup = BeautifulSoup(r.text, HTML_PARSER)
    data = []
    for row in soup.find_all('table')[1].find_all('tr'):
        columns = row.find_all('td')
        data.append({'name': columns[0].string,
                     'price': util.parse_money(columns[1].string)})
    return data


def main(output_directory: str):
    try:
        data = {'breakfast': get_breakfast(), 'drinks': get_drinks(), 'desserts': get_desserts()}
    except (ConnectionError, Timeout) as e:
        print("Failed to connect: ", e, file=sys.stderr)
        sys.exit(1)
    output_file = OUTFILE.format(output_directory)
    with open(output_file, 'w') as outfile:
        json.dump(data, outfile, sort_keys=True, indent=4, separators=(',', ': '))

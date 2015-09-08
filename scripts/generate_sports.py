from argparse import ArgumentParser

from jinja2 import FileSystemLoader, Environment
from bs4 import BeautifulSoup as bs
import requests

parser = ArgumentParser(description='Create hydra sports page')
parser.add_argument('--file',
                    dest='filename',
                    required=True,
                    help='file location, for example: --file ../iOS/Resources/info-sport-aanbod.html')

args = parser.parse_args()

sports = []
r = requests.get("http://www.ugent.be/nl/voorzieningen/sport/aanbod/overzicht-sporttakken")
soup = bs(r.text, 'html.parser')
table = soup.find('table').find('tbody')
rows = table.find_all('tr')
for row in rows:
    a_tag = row.find_all('a')[-1]
    sport = {
        'url': a_tag.get('href'),
        'name': a_tag.text,
        'text': row.find_all('td')[-1].text
    }
    sports.append(sport)

template = Environment(
    loader=FileSystemLoader('')
).get_template('sports_template.html')

with open(args.filename, 'w') as f:
    html = bs(template.render(sports=sports), 'html.parser').prettify()
    f.write(html)

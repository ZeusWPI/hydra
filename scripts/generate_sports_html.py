from bs4 import BeautifulSoup
import requests
from jinja2 import Template

sports = []
r = requests.get("http://www.ugent.be/nl/voorzieningen/sport/aanbod/overzicht-sporttakken")
soup = BeautifulSoup(r.text, 'html.parser')
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

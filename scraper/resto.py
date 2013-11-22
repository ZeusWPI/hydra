# coding=utf-8
"""
Parse the weekly menu from a webpage and export it as JSON in the different
API version formats.
"""

from __future__ import with_statement
import json, libxml2, os, os.path, datetime, locale, re, requests
from datetime import datetime, timedelta

SOURCES = {
    'nl': 'http://www.ugent.be/student/nl/meer-dan-studeren/resto/menu/weekmenu/week%02d.htm',
    'nl-omg': 'http://www.ugent.be/student/nl/meer-dan-studeren/resto/menu/weekmenu-sintjansvest/week%02d.htm',
    'en': 'http://www.ugent.be/en/facilities/food/weekly-menu/menu%02d.htm'
}

LOCALES = {
    'nl': 'nl_BE.utf-8',
    'en': 'en_US.utf-8'
}

# Only contains word which need a translation, e.g. not 'snack'
LABELS = {
    'nl': { 'groenten': 'vegetables', 'soep': 'soup', 'vlees': 'meat',
            'vis': 'fish', 'vegetarisch': 'vegetarian', "niet-veggie": "meat" },
    'en': { 'vegi': 'vegetarian' }
}
OPTIONS = {
    'nl': { 'recommended': 'aanbevolen' },
    'en': { 'recommended': 'recommended' }
}

API_PATH = 'resto/%s/menu'

class Week(object):
    def __init__(self, year, week):
        self.year = year
        self.week = week
        self.days = []

    def parse(self, rows, friday, lang):
        day_of_week = 4
        for row in rows:
            menu = Menu(friday - timedelta(day_of_week))
	    menu.parse(row, lang)
            day_of_week -=  1
            self.days.append(menu)

class Menu(object):
    def __init__(self, date):
        self.date = date
        self.items = []
        self.vegetables = []

    def parse(self, row, lang):
        items = row.xpathEval('./td')[1].xpathEval('.//li')
        for item in items:
            text = unicode(item.content.strip(), encoding='utf8')
            if len(text) == 0:
                continue

            if text.startswith(u'€'):
                menu_item = MenuItem(text, lang)
                self.items.append(menu_item)
            else:
                match = re.search('^([a-z ]+):(.*)$', text, re.I)
                if match:
                    keyword = match.group(1).lower()
                    if keyword in LABELS[lang]:
                        keyword = LABELS[lang][keyword]

                    if keyword == 'vegetables':
                        self.parse_vegetables(match.group(2).strip())

                else:
                    print('Unknown line format: ' + text)

    def open(self):
        # Consider the resto to be open when there's some items
        return len(self.items) > 0

    def parse_vegetables(self, line):
        r = re.compile(' (?:of|or) ', re.I)
        for vegetable in r.split(line, 0):
            # drop remark
            vegetable = re.sub('\(.*\)$', '', vegetable).strip()
            self.vegetables.append(vegetable.capitalize())

class MenuItem(object):
    def __init__(self, description, lang):
        self.name = ''
        self.type = ''
        self.price = 0
        self.recommended = False
        self.availability = None
        self.process_description(description, lang)

    def process_description(self, description, lang):
        match = re.match(u'^€([0-9,. ]+)-([a-z -]+):([^(]+)(\(.+\))?$', description, re.I)
        self.price = float(match.group(1).replace(',', '.'))
	self.name = match.group(3).strip()

        self.type = match.group(2).strip().lower()
        if self.type in LABELS[lang]:
            self.type = LABELS[lang][self.type]

        # TODO: parse availability
        if match.group(4):
            remark = match.group(4).strip()
            if re.search(OPTIONS[lang]['recommended'], remark):
                self.recommended = True

def download_menu(year, week, lang):
    parsed_lang = re.match(u'^([a-z]+)', lang, re.I).group(0)
    locale.setlocale(locale.LC_ALL, LOCALES[parsed_lang])
    page = get_menu_page(SOURCES[lang], week)
    if not page:
        print('ERROR: failed to retrieve menu for week %02d' % week)
    else:
        week_menu = parse_week_menu(page, year, week, parsed_lang)
        if not week_menu:
            print('ERROR: failed to parse menu for week %02d' % week)
        else:
	    json = None
            if lang == 'nl':
                json = create_api_10_representation(week_menu)
                dump_representation('1.0', year, week, json)
	    elif lang == 'nl-omg':
		json = create_api_10_representation(week_menu)
	    return json

def get_menu_page(url, week):
    print('Fetching week %02d menu webpage' % week)
    r = requests.get(url % week, allow_redirects=False)
    if r.status_code == 200:
        return r.text
    else:
        return None

def parse_week_menu(page, year, week, lang):
    print('Parsing menu webpage')
    # replace those pesky non-breakable spaces
    page = page.replace('&nbsp;', ' ')

    doc = libxml2.htmlReadDoc(page.encode('utf-8'), None, 'utf-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)

    dateComponents = doc.xpathEval("//*[@id='parent-fieldname-title']")[0].content.strip().split()
    # Date description is not consistent, sometimes misses year
    if not dateComponents[-1].isdigit():
        dateComponents.append(str(year))

    # always start from the last day of the week, since it will be in the correct year and month
    friday = datetime.strptime("%s %s %s" % tuple(dateComponents[-3:]), "%d %B %Y").date()

    # verify that this is the week we are searching for
    isocalendar = friday.isocalendar()

    if isocalendar[0] != year or isocalendar[1] != week:
        print('Incorrect information retrieved: expected %s-%s, got %s-%s' %
            (year, week, isocalendar[0], isocalendar[1]))
        return None
    menuElement = doc.xpathEval("//*[starts-with(@id, 'parent-fieldname-text')]")
    rows = menuElement[0].xpathEval('.//tr')[1:]

    week_menu = Week(year, week)
    week_menu.parse(rows, friday, lang)
    return week_menu

def create_api_10_representation(week):
    root = {}
    for day in week.days:
        root[str(day.date)] = menu = { 'open': day.open() }
        if not day.open():
            continue

        menu['meat'] = []
        for item in day.items:
            price = (u'€ %0.2f' % item.price).replace('.', ',')
            if item.type == 'soup':
                menu['soup'] = { 'name': item.name, 'price': price }
            else:
                prefix = 'Veg. ' if item.type == 'vegetarian' else ''
                menu['meat'].append({
                    'recommended': item.recommended,
                    'price': price,
                    'name': prefix + item.name
                })

        if len(day.vegetables) > 0:
            menu['vegetables'] = day.vegetables

    return root

def dump_representation(identifier, year, week, menu):
    path = os.path.join(API_PATH % identifier, str(year))
    print('Writing object tree to %s' % path);
    if not os.path.isdir(path):
        os.makedirs(path)
    with open('%s/%s.json' % (path, week), 'w') as f:
        json.dump(menu, f, sort_keys=True)

def download_wrapper(year, week, langs):
    dict = {}
    for l in langs:
	dict[l] = download_menu(isocalendar[0], isocalendar[1], l)
    dump_representation('2.0', year, week, dict)

if __name__ == "__main__":
    # Fetch the menu for the next three weeks
    weeks = [datetime.today() + timedelta(weeks = n) for n in range(3)]
    for week in weeks:
        isocalendar = week.isocalendar()
	langs = ['nl', 'nl-omg']
        download_wrapper(isocalendar[0], isocalendar[1], langs)

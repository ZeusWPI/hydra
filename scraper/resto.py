# coding=utf-8
"""
Parse the weekly menu from a webpage and export it as JSON in the different
API version formats.
"""

from __future__ import with_statement, print_function
import json, libxml2, os, os.path, sys, datetime, locale, re, requests
from datetime import datetime, timedelta

SOURCES = {
    'nl': 'http://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu/week%02d',
    'nl-sintjansvest': 'http://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu-sintjansvest/week%02d',
    'en': 'http://www.ugent.be/en/facilities/restaurants/weekly-menu/week%02d'
}

LOCALES = {
    'nl': 'nl_BE.utf-8',
    'en': 'en_US.utf-8'
}

# Only contains word which need a translation, e.g. not 'snack'
LABELS = {
    'nl': { 'groenten': 'vegetables', 'soep': 'soup', 'vlees': 'meat',
            'vis': 'fish', 'vegetarisch': 'vegetarian', 'niet-veggie': 'meat',
            'maaltijdsoep': 'meal soup' },
    'en': { 'vegi': 'vegetarian' }
}

class IdentityDict(dict):
    def __missing__(self, key):
        return key

DICTIONARY = {
    'en': IdentityDict(),
    'nl': {
            'recommended': 'aanbevolen',
            'main course': 'hoofdgerecht',
            'vegetables': 'groenten',
            'closed': 'gesloten',
          }
}

API_PATH = 'resto/%s/menu'

class Week(object):
    def __init__(self, year, week):
        self.year = year
        self.week = week
        self.days = []

    def parse(self, menus_txt, friday, lang):
        day_of_week = 4
        for menu_txt in menus_txt:
            menu = Menu(friday - timedelta(day_of_week))
            menu.parse(menu_txt, lang)
            day_of_week -=  1
            self.days.append(menu)

class Menu(object):
    def __init__(self, date):
        self.date = date
        self.items = []
        self.vegetables = []

    def parse(self, menu_div, lang):
        titles = [x.content.lower() for x in menu_div.xpathEval('./h3')]
        lists = menu_div.xpathEval('./ul[*]')

        if len(titles) == 1 and titles[0] == DICTIONARY[lang]['closed']:
            return;

        if len(titles) != len(lists):
            print('ERROR: Inconsistent format for', self.date, file=sys.stderr)
            # TODO: this will fail december 20th, since we sometimes have <li>'s
            # split over multiple <ul>'s. Somebody needs to learn HTML.
            # Better parser would split li's by surrounding <h3> tag.
            return -1

        for title, list_ in zip(titles, lists):
            list_items = [unicode(x.content, encoding='utf8')
                          for x in list_.xpathEval('./li')]
            if title == DICTIONARY[lang]['main course']:
                for item in list_items:
                    self.items.append(MenuItem(item, lang))
            elif title == DICTIONARY[lang]['vegetables']:
                self.vegetables = [x.capitalize() for x in list_items]
            else:
                for item in list_items:
                    description = '%s: %s' % (title.capitalize(), item.capitalize())
                    self.items.append(MenuItem(description, lang))

    def open(self):
        # Consider the resto to be open when there's some items
        return len(self.items) > 0

class MenuItem(object):
    def __init__(self, description, lang):
        self.name = ''
        self.type = ''
        self.price = 0
        self.recommended = False
        self.availability = None
        self.process_description(description, lang)

    def process_description(self, description, lang):
        match = re.match(u'^([^:]+): *([^€]+) - € *([0-9,. ]+)(\s*\([A-Za-z ]+\))?$', description, re.I)

        if match is None:
            print('ERROR: (%s) contains no eurosign' % (description), file=sys.stderr)
            match = re.match(u'^([^:]+): *([^€]+) - €? *([0-9,. ]+)(\s*\([A-Za-z ]+\))?$', description, re.I)

        self.name = match.group(2).strip()
        self.type = match.group(1).strip().lower()
        self.price = float(match.group(3).replace(',', '.'))

        if self.type in LABELS[lang]:
            self.type = LABELS[lang][self.type]

        # TODO: parse availability
        # if match.group(4):
        #     remark = match.group(4).strip()
        #     if re.search(DICTIONARY[lang]['recommended'], remark):
        #         self.recommended = True

def get_menu(year, week, lang):
    parsed_lang = re.match(u'^([a-z]+)', lang, re.I).group(0)
    locale.setlocale(locale.LC_ALL, LOCALES[parsed_lang])
    page = download_menu(SOURCES[lang], week, lang)
    if not page:
        print('ERROR: Failed to retrieve menu for week %02d in %s' % (week, lang), file=sys.stderr)
    else:
        week_menu = parse_week_menu(page, year, week, parsed_lang)
        if not week_menu:
            print('ERROR: Failed to parse menu for week %02d in %s' % (week,lang), file=sys.stderr)
        else:
            return week_menu

def download_menu(url, week, lang):
    print('Fetching week %02d menu webpage for %s' % (week, lang))
    r = requests.get(url % week)
    if r.status_code == 200 and not 'login.ugent.be' in r.url: 
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
    menus = doc.xpathEval("//*[starts-with(@id, 'parent-fieldname-text')]")

    week_menu = Week(year, week)
    week_menu.parse(menus, friday, lang)
    return week_menu

def create_api_10_representation(week):
    root = {}

    if week == None or len(week.days) == 0:
        # invalid menu
        return None

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

def dump_api_10_representation(year, week, menu):
    path = os.path.join(API_PATH % '1.0', str(year))
    print('Writing object tree to %s' % path);

    if not os.path.isdir(path):
        os.makedirs(path)

    menu = create_api_10_representation(menu)
    if menu is None:
        # don't write if invalid format
        print ('ERROR: Invalid menu for week %02d' % week,file=sys.stderr)
        return None

    with open('%s/%s.json' % (path, week), 'w') as f:
        json.dump(menu, f, sort_keys=True)

def process_sources(year, week, lang, sources):
    parsed_menus = {}
    for source in sources:
        if source.find('-') != -1:
            key = source.split('-')[-1]
        else:
            key = 'default'
        parsed_menus[key] = get_menu(year, week, source)

    if lang == 'nl' and parsed_menus['default']:
        dump_api_10_representation(year, week, parsed_menus['default'])

if __name__ == '__main__':
    # Fetch the menu for the next three weeks
    language_sources = {'nl': ['nl', 'nl-sintjansvest'], 'en': ['en']}
    weeks = [datetime.today() + timedelta(weeks = n) for n in range(3)]
    for week in weeks:
        isocalendar = week.isocalendar()
        for lang in language_sources:
            process_sources(isocalendar[0], isocalendar[1], lang, language_sources[lang])

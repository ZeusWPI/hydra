# coding=utf-8
""" Parse the weekly menu from a webpage into a JSON struct and write it to a file. """
from __future__ import with_statement
import json, urllib, libxml2, os, os.path, datetime, locale, re
from datetime import datetime, timedelta

SOURCE = 'http://www.ugent.be/nl/voorzieningen/resto/studenten/menu/weekmenu/week%02d.htm'
API_PATH = './resto/menu/'
TRANSLATE = {'fish':'meat','vegi':'meat', 'meat':'meat', 'snack': 'meat','soup': 'soup',
    'soep':'soup','vlees':'meat','vis':'meat','vegetarisch':'meat'}
VEGETABLES = 'Groenten'
OR = 'OF'
RECOMMEND = u'aanbevolen'
YEAR = '2013'
def download_menu(year, week):
	page = get_menu_page(SOURCE, week)
	menu = parse_menu_from_html(page, year, week)
	if menu:
		dump_menu_to_file(API_PATH, year, week, menu)

def get_menu_page(url, week):
	print('Fetching week %02d menu webpage' %  week)
	f = urllib.urlopen(url % week)
	return f.read()

def get_meat_and_price(meat):
	meals = re.findall(u'€[0-9,. ]+-', unicode(meat.content, encoding='utf8'))
	price = meals[0][2:-2]
	recommendedLen = len(re.findall(RECOMMEND, unicode(meat.content, encoding='utf8')))
	recommended = False
	if recommendedLen == 1:
		recommended = True
	name = meat.content.split(':')[1].strip()
	name = name.split('(')[0].strip()
	return {
		'recommended': recommended,
		'price': u'€ ' + price,
		'name': name
	}

def get_vegetables(vegies):
	vegies = vegies.content[len(VEGETABLES):]
	veg = vegies.split(OR)
	veg[1].split('(')[0]
	vegetables = [veg[0][2:].strip(),veg[1].split('(')[0]]
	return vegetables

def parse_menu_from_html(page, year, week):
	print('Parsing weekmenu webpage to an object tree')
	# replace those pesky non-breakable spaces
	page = page.replace('&nbsp;', ' ')

	doc = libxml2.htmlReadDoc(page, None, 'utf-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)

	dateComponents = doc.xpathEval("//*[@id='parent-fieldname-title']")[0].content.strip().split()
	locale.setlocale(locale.LC_ALL, 'nl_BE.UTF-8')
	if dateComponents[-1] != YEAR:
		dateComponents.append(YEAR)
	
	friday = datetime.strptime("%s %s %s" % tuple(dateComponents[-3:]), "%d %B %Y").date()
	
	# verify that this is the week we are searching for
	isocalendar = friday.isocalendar()

	if isocalendar[0] != year or isocalendar[1] != week:
		print('Incorrect information retrieved: expected %s-%s, got %s-%s' %
			(year, week, isocalendar[0], isocalendar[1]))
		return None
	menuElement = doc.xpathEval("//*[starts-with(@id, 'parent-fieldname-text')]")
	rows = menuElement[0].xpathEval('.//tr')[1:]

	menu = {}
	dayOfWeek = 4
	for row in rows:
		day = str(friday - timedelta(dayOfWeek))
		dayOfWeek-=1
		cellz = row.xpathEval('.//td')
		cells = cellz[1].xpathEval('.//li')
		menu[day] = {'open': True}
		for cell in cells:
			keyword = re.findall('- .*:', unicode(cell.content, encoding='utf8'))
			if len(keyword) != 0:
				keyword = keyword[0][2:-1].lower()
				meat = get_meat_and_price(cell)
				if menu[day].get(TRANSLATE[keyword]) != None:
					menu[day][TRANSLATE[keyword]].append(meat)
				else:
					menu[day][TRANSLATE[keyword]] = [meat]
			else:
				vegies = len(re.findall(VEGETABLES, unicode(cell.content, encoding='utf8')))
				if vegies == 1:
					menu[day]['vegetables'] = get_vegetables(cell)
		# TODO: open

	return menu

def dump_menu_to_file(path, year, week, menu):
	print('Writing object tree to file in JSON format')
	path += str(year)
	if not os.path.isdir(path):
		os.makedirs(path)
	with open('%s/%s.json' % (path, week), 'w') as f:
		json.dump(menu, f, sort_keys=True)

if __name__ == "__main__":
	# Fetch the menu for the next three weeks
	weeks = [datetime.today() + timedelta(weeks = n) for n in range(3)]
	for week in weeks:
		isocalendar = week.isocalendar()
		download_menu(isocalendar[0], isocalendar[1])

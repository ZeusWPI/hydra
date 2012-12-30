""" Parse the weekly menu from a webpage into a JSON struct and write it to a file. """
from __future__ import with_statement
import json, urllib, libxml2, os, os.path, datetime, locale
from datetime import datetime, timedelta

SOURCE = 'http://www.ugent.be/nl/voorzieningen/resto/studenten/menu/weekmenu/week%02d.htm'
API_PATH = './resto/menu/'

def download_menu(year, week):
	page = get_menu_page(SOURCE, week)
	menu = parse_menu_from_html(page)
	dump_menu_to_file(API_PATH, year, week, menu)

def get_menu_page(url, week):
	print('Fetching week %02d menu webpage' %  week)
	f = urllib.urlopen(url % week)
	return f.read()

def parse_single_meat_and_price(meat):
	content = meat.content.strip().split(' - ', 1)
	return {
		'recommended': len(meat.xpathEval('.//u')) > 0,
		'price': content[0],
		'name': content[1]
	}

def get_meat_and_price(meat):
	meals = meat.xpathEval(".//p")
	if len(meals) == 0:
		return [parse_single_meat_and_price(meat)]
	else:
		return [parse_single_meat_and_price(meal) for meal in meals]

def parse_menu_from_html(page):
	print('Parsing weekmenu webpage to an object tree')
	# replace those pesky non-breakable spaces
	page = page.replace('&nbsp;', ' ')

	doc = libxml2.htmlReadDoc(page, None, 'utf-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)

	week = doc.xpathEval("//*[@id='parent-fieldname-title']")[0].content.strip().split()
	locale.setlocale(locale.LC_ALL, ('nl_BE.UTF-8'))
	friday = datetime.strptime("%s %s %s" % tuple(week[-3:]), "%d %B %Y").date()

	menuElement = doc.xpathEval("//*[starts-with(@id, 'parent-fieldname-text')]")
	rows = menuElement[0].xpathEval('.//tr')[1:-2]

	menu = {}
	dayOfWeek = 4
	for row in rows:
		cells = row.xpathEval('.//td')

		if len(cells[0].content.strip()) != 0:
			# first row of a day
			day = str(friday - timedelta(dayOfWeek))
			dayOfWeek -= 1
			menu[day] = {}
			if cells[2].content.strip() == 'Gesloten':
				menu[day]['open'] = False
			else:
				menu[day]['open'] = True
				menu[day]['soup'] = {'name' : cells[1].content.strip()}
				menu[day]['meat'] = get_meat_and_price(cells[2])
				menu[day]['vegetables'] = [cells[3].content.strip()]

		elif len(cells[1].content.strip()) != 0 and menu[day]['open']:
			# second row of a day
			menu[day]['soup']['price'] = cells[1].content.strip()
			menu[day]['meat'].extend(get_meat_and_price(cells[2]))
			menu[day]['vegetables'].append(cells[3].content.strip())

		elif len(cells[2].content.strip()) != 0 and menu[day]['open']:
			# the third and forth row of a day (sometimes it's empty)
			menu[day]['meat'].extend(get_meat_and_price(cells[2]))

	return menu

def dump_menu_to_file(path, year, week, menu):
	print('Writing object tree to file in JSON format')
	path += str(year)
	if not os.path.isdir(path):
		os.makedirs(path)
	with open('%s/%s.json' % (path, week), 'w') as f:
		json.dump(menu, f, sort_keys=True, indent=4)

if __name__ == "__main__":
	# Fetch the menu for the next three weeks
	weeks = [today + timedelta(weeks = n) for n in range(3)]
	for week in weeks:
		isocalendar = week.isocalendar()
		download_menu(isocalendar[0], isocalendar[1])

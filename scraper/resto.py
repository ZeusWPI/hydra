# coding=utf-8
""" Parse the weekly menu from a webpage into a JSON struct and write it to a file. """
from __future__ import with_statement
import json, urllib, libxml2, os, os.path, datetime, locale, re
from datetime import datetime, timedelta

SOURCE = 'http://www.ugent.be/nl/voorzieningen/resto/studenten/menu/weekmenu/week%02d.htm'
API_PATH = './resto/menu/'

def download_menu(year, week):
	page = get_menu_page(SOURCE, week)
	menu = parse_menu_from_html(page, year, week)
	if menu:
		dump_menu_to_file(API_PATH, year, week, menu)

def get_menu_page(url, week):
	print('Fetching week %02d menu webpage' %  week)
	f = urllib.urlopen(url % week)
	return f.read()

def parse_single_meat_and_price(ctx, meat):
	# there are some inconsistencies in the item descriptions
	m = re.search('([0-9.,]+)[ -]+(.*)', meat.strip())
	if not m:
		print('Unable to parse item "%s"' % meat.strip())
		return None
	else:
		# fnd node containing this info
		query = '\'' + m.group(2).encode('utf8') + '\''
		parents = ctx.xpathEval('.//*[contains(.,' + query + ')]')
		# sometimes the description is split up over multiple nodes, so we try
		# to find the item by matching the price (e.g. http://i.imgur.com/kkhqiqm.png)
		if len(parents) == 0:
			query = '\'€ ' + m.group(1).encode('utf8') + '\''
			parents = ctx.xpathEval('.//*[contains(.,' + query + ')]')

		# check its parents to see if this item is recommend
		recommended = False
		for parent in parents:
			if parent.name == 'b' or parent.name == 'u':
				recommended = True
			elif parent.prop('style') and 'underline' in parent.prop('style'):
				recommended = True

		return {
			'recommended': recommended,
			'price': u'€ ' + m.group(1),
			'name': m.group(2)
		}

def get_meat_and_price(meat):
	# the text can be in multiple paragraphs, or with multiple <br />
	meals = re.findall(u'€[^€]+', unicode(meat.content, encoding='utf8'))
	return filter(None, [parse_single_meat_and_price(meat, meal) for meal in meals])

def parse_menu_from_html(page, year, week):
	print('Parsing weekmenu webpage to an object tree')
	# replace those pesky non-breakable spaces
	page = page.replace('&nbsp;', ' ')

	doc = libxml2.htmlReadDoc(page, None, 'utf-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)

	dateComponents = doc.xpathEval("//*[@id='parent-fieldname-title']")[0].content.strip().split()
	locale.setlocale(locale.LC_ALL, 'nl_BE.UTF-8')
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
		cells = row.xpathEval('.//td')
		if len(cells) <= 3:
			continue

		# first row of a day
		if cells[0].content.strip() != '':
			day = str(friday - timedelta(dayOfWeek))
			dayOfWeek -= 1
			menu[day] = {}

			# check if resto is closed
			if cells[2].content.lower().strip() == 'gesloten':
				menu[day]['open'] = False
			else:
				menu[day]['open'] = True
				menu[day]['soup'] = { 'name': cells[1].content.strip() }
				menu[day]['meat'] = get_meat_and_price(cells[2])
				menu[day]['vegetables'] = [cells[3].content.strip()]

		# second row of a day
		elif cells[1].content.strip() != '' and menu[day]['open']:
			menu[day]['soup']['price'] = cells[1].content.strip()
			menu[day]['meat'].extend(get_meat_and_price(cells[2]))
			menu[day]['vegetables'].append(cells[3].content.strip())

		# the third and fourth row of a day (sometimes it's empty)
		elif cells[2].content.strip() != '' and menu[day]['open']:
			menu[day]['meat'].extend(get_meat_and_price(cells[2]))

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

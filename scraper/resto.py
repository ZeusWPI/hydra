# coding=utf-8
""" Parse the weekly menu from a webpage into a JSON struct and write it to a file. """
from __future__ import with_statement
import json, urllib, libxml2, os, os.path, datetime, locale, re
from datetime import datetime, timedelta

SOURCE = 'http://www.ugent.be/nl/voorzieningen/resto/studenten/menu/weekmenu/week%02d.htm'
#API_PATH = './resto/%d.%d/menu/%04d'
API_PATH = './resto/menu'
TRANSLATE = {'fish':'fish','vegi':'vegi', 'meat':'meat', 'snack': 'snack','soup': 'soup',
    'soep':'soup','vlees':'meat','vis':'fish','vegetarisch':'vegi'}
VEGETABLES = 'Groenten'
OR = 'OF'
VEGETARIAN = 'vegetarisch' 
RECOMMEND = u'aanbevolen'
RESTOS = {'Boudewijn':'Resto Boudewijn', 'Brug':'Resto De Brug', 'Kantienberg':'Resto Kantienberg'}
NOTINRESTOS = u'niet in'
ONLYINRESTOS = u'enkel in'

def download_menu(year, week):
	page = get_menu_page(SOURCE, week)
	parse_menu_for_version(page, year, week, 10)
	#parse_menu_for_version(page, year, week, 20) # 2.0 beta version

def parse_menu_for_version(page, year, week, version):
	menu = parse_menu_from_html(page, year, week, version)
	if menu:
		dump_menu_to_file(API_PATH, year, week, menu, version)	

def get_menu_page(url, week):
	print('Fetching week %02d menu webpage' %  week)
	f = urllib.urlopen(url % week)
	return f.read()

def get_restos_from_option(content, option):
	present = len(re.findall(option, unicode(content, encoding='utf8')))
	if present <= 0:
		return []
	restos = []
	content = content.split('(')[1].strip()
	content = content[:-1].split(' ')
	for w in content:
		w = w.strip()
		r = RESTOS.get(w)
		if r != None:
			restos.append(r)
	return restos

def get_meat_and_price(meat, version, keyword):
	meals = re.findall(u'€[0-9,. ]+-', unicode(meat.content, encoding='utf8'))
	price = meals[0][2:-2]
	recommendedLen = len(re.findall(RECOMMEND, unicode(meat.content, encoding='utf8')))
	recommended = False
	if recommendedLen == 1:
		recommended = True
	notInRestos = get_restos_from_option(meat.content, NOTINRESTOS)
	onlyInRestos = get_restos_from_option(meat.content, ONLYINRESTOS)

	name = meat.content.split(':')[1].strip()
	name = name.split('(')[0].strip()
	if version <= 10:
		if len(notInRestos) >= 1:
			name+='#'
		if len(onlyInRestos) >= 1:
			name+='*'
		if TRANSLATE[keyword] == 'vegi':
			name = 'Veg. ' + name

	meal = {
		'recommended': recommended,
		'price': u'€ ' + price,
		'name': name
	}

	if TRANSLATE[keyword] == 'soup':
		meal.pop('recommended')
	else:
		if version > 10:
			meal['notInRestos'] = notInRestos
			meal['onlyInRestos'] = onlyInRestos
			meal['type'] = keyword
	return meal

def get_vegetables(vegies):
	vegies = vegies.content[len(VEGETABLES):]
	veg = vegies.split(OR)
	veg[1].split('(')[0]
	vegetables = [veg[0][2:].strip().capitalize(),veg[1].split('(')[0].strip().capitalize()]
	return vegetables

def parse_menu_from_html(page, year, week, version):
	print('Parsing weekmenu webpage to an object tree')
	# replace those pesky non-breakable spaces
	page = page.replace('&nbsp;', ' ')

	doc = libxml2.htmlReadDoc(page, None, 'utf-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)

	dateComponents = doc.xpathEval("//*[@id='parent-fieldname-title']")[0].content.strip().split()
	locale.setlocale(locale.LC_ALL, 'nl_BE.UTF-8')
	if dateComponents[-1] != str(year):
		dateComponents.append(str(year))
	
	friday = datetime.strptime("%s %s %s" % tuple(dateComponents[-3:]), "%d %B %Y").date()
	
	# verify that this is the week we are searching for
	isocalendar = friday.isocalendar()

	if isocalendar[0] != year or isocalendar[1] != week:
		print('Incorrect information retrieved: expected %s-%s, got %s-%s' %
			(year, week, isocalendar[0], isocalendar[1]))
		return None
	menuElement = doc.xpathEval("//*[starts-with(@id, 'parent-fieldname-text')]")
	rows = menuElement[0].xpathEval('.//tr')[1:]

	meal = 'meal'
	if version < 11:
		meal = 'meat'
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
				if TRANSLATE[keyword] == 'soup':
					soup = get_meat_and_price(cell, version, keyword)
					menu[day]['soup'] = soup
				else:
					meat = get_meat_and_price(cell, version, keyword)
					if menu[day].get(meal) != None:
						menu[day][meal].append(meat)
					else:
						menu[day][meal] = [meat]
			else:
				vegies = len(re.findall(VEGETABLES, unicode(cell.content, encoding='utf8')))
				if vegies == 1:
					menu[day]['vegetables'] = get_vegetables(cell)
		# TODO: open

	return menu

def dump_menu_to_file(path, year, week, menu, version):
	print('Writing object tree to file in JSON format')
	#path = path % (version//10, version%10, year) #beta version
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

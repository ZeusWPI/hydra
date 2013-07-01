# coding=utf-8
""" Parse the weekly menu from a webpage into a JSON struct and write it to a file. """
from __future__ import with_statement
import json, urllib, libxml2, os, os.path, datetime, locale, re
from datetime import datetime, timedelta

SOURCE = 'http://www.ugent.be/nl/voorzieningen/resto/studenten/menu/weekmenu/week%02d.htm'
#API_PATH = './resto/%d.%d/menu/%04d'
API_PATH = './resto/menu/'
TRANSLATE = {'fish':'fish','vegi':'vegi', 'meat':'meat', 'snack': 'snack','soup': 'soup',
    'soep':'soup','vlees':'meat','vis':'fish','vegetarisch':'vegi'}
VEGETABLES = 'Groenten'
OR = 'OF'
RECOMMEND = u'aanbevolen'
RESTOS = {'Boudewijn':'Resto Boudewijn', 'Brug':'Resto De Brug', 'Kantienberg':'Resto Kantienberg'}
NOTINRESTOS = u'niet in'
ONLYINRESTOS = u'enkel in'

class Week(object):
	"""docstring for Week"""
	def __init__(self, year, week):
		super(Week, self).__init__()
		self.year = year
		self.week = week
		self.days = []

	def addDay(self, day):
		self.days.append(day)
		

class Day(object):
	"""docstring for Day"""
	def __init__(self, date):
		super(Day, self).__init__()
		self.date = date
		self.meals = []
		self.vegetables = []
		self.soup = None

	def addMeal(self, meal):
		self.meals.append(meal)

	def open(self):
		return not (len(self.meals) <= 0)

class Meal(object):
	"""docstring for Meal"""
	def __init__(self, content, keyword):
		super(Meal, self).__init__()
		self.name = ''
		self.recommended = False
		self.price = 0
		self.notIn = []
		self.onlyIn = []
		self.type = TRANSLATE[keyword]
		self.process_meal(content)

	def process_meal(self,content):
		meals = re.findall(u'€[0-9,. ]+-', unicode(content, encoding='utf8'))
		self.price = meals[0][2:-2]
		recommendedLen = len(re.findall(RECOMMEND, unicode(content, encoding='utf8')))
		self.recommended = False
		if recommendedLen == 1:
			self.recommended = True
		self.parse_restos_options(self.notIn, content, NOTINRESTOS)
		self.parse_restos_options(self.onlyIn, content, ONLYINRESTOS)

		self.name = content.split(':')[1].split('(')[0].strip()

	def parse_restos_options(self, arr, content, option):
		present = len(re.findall(option, unicode(content, encoding='utf8')))
		if present <= 0:
			arr = []
			return
		arr = []
		words = content.split('(')[1].strip()
		words = words[:-1].split(' ')
		for w in words:
			w = w.strip()
			r = RESTOS.get(w)
			if r != None:
				arr.append(r)

	def get_name_for_api_v10(self):
		name = self.name
		if len(self.notIn) >= 1:
			name+='#'
		if len(self.onlyIn) >= 1:
			name+='*'
		if self.type == 'vegi':
			name = 'Veg. ' + name

		return name

class Soup(object):
	"""docstring for Soup"""
	def __init__(self, content):
		super(Soup, self).__init__()
		meals = re.findall(u'€[0-9,. ]+-', unicode(content, encoding='utf8'))
		self.price = meals[0][2:-2]
		self.name = content.split(':')[1].split('(')[0].strip()
		
		
def download_menu(year, week):
	page = get_menu_page(SOURCE, week)
	menu = parse_menu_from_html(page, year, week)
	parse_menu_for_version(menu, year, week, 10)
	#parse_menu_for_version(menu, year, week, 20) # 2.0 beta version

def parse_menu_for_version(menu, year, week, version):
	if menu:
		if version == 10:
			menu = create_api_1_0_dict(menu)
		dump_menu_to_file(API_PATH, year, week, menu, version)	

def get_menu_page(url, week):
	print('Fetching week %02d menu webpage' %  week)
	f = urllib.urlopen(url % week)
	return f.read()

def get_vegetables(vegies):
	vegies = vegies.content[len(VEGETABLES):]
	veg = vegies.split(OR)
	veg[1].split('(')[0]
	vegetables = [veg[0][2:].strip().capitalize(),veg[1].split('(')[0].strip().capitalize()]
	return vegetables

def parse_menu_from_html(page, year, week):
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

	menu = Week(year, week)
	dayOfWeek = 4
	for row in rows:
		dayDate = str(friday - timedelta(dayOfWeek))
		day = Day(dayDate)
		dayOfWeek-=1
		cellz = row.xpathEval('.//td')
		cells = cellz[1].xpathEval('.//li')
		for cell in cells:
			keyword = re.findall('- .*:', unicode(cell.content, encoding='utf8'))
			if len(keyword) != 0:
				keyword = keyword[0][2:-1].lower()
				if TRANSLATE[keyword] == 'soup':
					soup = Soup(cell.content)
					day.soup = soup
				else:
					meal = Meal(cell.content, keyword)
					day.addMeal(meal)
			else:
				vegies = len(re.findall(VEGETABLES, unicode(cell.content, encoding='utf8')))
				if vegies == 1:
					day.vegetables = get_vegetables(cell)
		menu.addDay(day)
	return menu

def create_api_1_0_dict(week):
	menu = {}
	for day in week.days:
		menu[day.date] = {'open':day.open()}
		if day.open():
			menu[day.date]['meat'] = []
			for meal in day.meals:
				meat = {
					'recommended': meal.recommended,
					'price': u'€ ' + meal.price,
					'name': meal.get_name_for_api_v10()
				}
				menu[day.date]['meat'].append(meat)
			if len(day.vegetables) > 0:
				menu[day.date]['vegetables'] = day.vegetables
			if day.soup != None:
				menu[day.date]['soup'] = {'name':day.soup.name, 'price': u'€ ' + day.soup.price}
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

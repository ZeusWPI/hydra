""" Parse the weekly menu from a webpage into a json struct and write it to a file. """

import json, urllib, libxml2, os, os.path, datetime, locale
from datetime import datetime, timedelta

API_VERSION = '0.1'
API_PATH = './resto/api/%s/week/'

def get_menu_page (week):
	print "Fetching week %02d menu webpage" %  week
	f = urllib.urlopen("http://www.ugent.be/nl/voorzieningen/resto/studenten/menu/weekmenu/week%02d.htm" % week)
	return f.read()

def get_meat_and_price (meat):
	# splitting on '-' doesn't work, FAIL!
	name = meat.content[8:]
	try:
		name = name[name.index('-')+1:]
	except:
		pass
	
	result = {}
	result['recommended'] = len(meat.xpathEval('.//u')) > 0
	result['price'] = meat.content[:8]
	result['name'] = name.strip()
	return result

def parse_menu_from_html (page):
	print "Parsing weekmenu webpage to an object tree"
	# replace those pesky non-breakable spaces
	page = page.replace('&nbsp;', ' ')
	
	doc = libxml2.htmlParseDoc(page, 'utf-8')
	menuElement = doc.xpathEval("//div[@id='parent-fieldname-text']")
	rows = menuElement[0].xpathEval('.//tr')[1:-2]
	
	week = doc.xpathEval("//span[@id='parent-fieldname-title']")[0].content.strip().split()
	if len(week) == 7:
		# start and end of week are in the same month
		monday = datetime.strptime("%s %s %s" % (week[2], week[5], week[6]), "%d %B %Y")
	else:
		# start and end of week are in different months
		monday = datetime.strptime("%s %s %s" % (week[2], week[3], week[7]), "%d %B %Y")
	
	menu = {}
	dayOfWeek = 0
	for row in rows:
		fields = row.xpathEval('.//td')
		if len(fields[0].content) != 0:
			# first row of a day
			day = str(monday.date() + timedelta(dayOfWeek))
			dayOfWeek += 1
			menu[day] = {}
			if fields[2].content == 'Gesloten':
				menu[day]['open'] = False
			else:
				menu[day]['open'] = True
				menu[day]['soup'] = {'name' : fields[1].content}
				menu[day]['meat'] = []
				menu[day]['meat'].append(get_meat_and_price(fields[2]))
				menu[day]['vegetables'] = []
				menu[day]['vegetables'].append(fields[3].content.strip())
		elif len(fields[1].content) != 0 and menu[day]['open']:
			# second row of a day
			menu[day]['soup']['price'] = fields[1].content
			menu[day]['meat'].append(get_meat_and_price(fields[2]))
			menu[day]['vegetables'].append(fields[3].content.strip())
		elif menu[day]['open']:
			# the third and forth row of a day
			menu[day]['meat'].append(get_meat_and_price(fields[2]))
	return menu

def dump_menu_to_file (week, menu):
	print "Writing object tree to file in json format"
	path = './resto/api/%s/week/' % API_VERSION
	if not os.path.isdir(path):
		os.makedirs(path)
	f = open ('%s/%s.json' % (path, week), 'w')
	json.dump(menu, f, sort_keys=True, indent=4)
	f.close()

def menu_already_downloaded(week):
	return os.path.exists(API_PATH % API_VERSION + '/%s.json' % week)

def download_menu(week):
	page = get_menu_page(week)
	menu = parse_menu_from_html(page)
	dump_menu_to_file(week, menu)

if __name__ == "__main__":
	locale.setlocale(locale.LC_ALL, ('nl_BE.UTF-8'))
	week = datetime.today().isocalendar()[1]
	# fetch the menu for the next to weeks, if not already downloaded
	if not menu_already_downloaded(week+1):
		download_menu(week+1)
	if not menu_already_downloaded(week+2):
		download_menu(week+2)


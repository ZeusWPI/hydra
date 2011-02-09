""" Parse the weekly menu from a webpage into a json struct and write it to a file. """

import json, urllib, libxml2, os, os.path

API_VERSION = "0.1"

def get_menu_page (week):
	f = urllib.urlopen("http://www.ugent.be/nl/voorzieningen/resto/studenten/menu/weekmenu/week%02d.htm" % week)
	return f.read()

def get_meat_and_price (meat):
	content = meat.content.split(' - ')
	result = {}
	result['recommended'] = len(meat.xpathEval('.//u')) > 0
	result['price'] = content[0]
	result['name'] = content[1]
	return result

def parse_menu_from_html (page):
	# replace those pesky non-breakable spaces
	page = page.replace('&nbsp;', '')
	
	doc = libxml2.htmlParseDoc(page, 'utf-8')
	menuElement = doc.xpathEval("//div[@id='parent-fieldname-text']")
	rows = menuElement[0].xpathEval('.//tr')[1:-2]
	
	week = doc.xpathEval("//span[@id='parent-fieldname-title']")[0].content.strip().split()
	#monday = datetime.datetime.strptime("%s %s %s" % (week[2], week[3], week[7]), "%d %B %Y")
	
	menu = {}
	day = None
	for row in rows:
		fields = row.xpathEval('.//td')
		if len(fields[0].content) != 0:
			# first row of a day
			day = fields[0].content
			menu[day] = {}
			if fields[2].content == 'Gesloten':
				menu[day]['open'] = False
			else:
				menu[day]['open'] = True
				menu[day]['soup'] = {'name' : fields[1].content}
				menu[day]['meat'] = []
				menu[day]['meat'].append(get_meat_and_price(fields[2]))
				menu[day]['vegetables'] = []
				menu[day]['vegetables'].append(fields[3].content)
		elif len(fields[1].content) != 0:
			# second row of a day
			menu[day]['soup']['price'] = fields[1].content
			menu[day]['meat'].append(get_meat_and_price(fields[2]))
			menu[day]['vegetables'].append(fields[3].content)
		else:
			# the third and forth row of a day
			menu[day]['meat'].append(get_meat_and_price(fields[2]))
	return menu

def dump_menu_to_file (week, menu):
	path = './resto/api/%s/week/' % API_VERSION
	if not os.path.isdir(path):
		os.makedirs(path)
	f = open ('%s/%s.json' % (path, week), 'w')
	json.dump(menu, f, sort_keys=True, indent=4)
	f.close()

if __name__ == "__main__":
	week = 6
	page = get_menu_page(week)
	menu = parse_menu_from_html(page)
	dump_menu_to_file(week, menu)


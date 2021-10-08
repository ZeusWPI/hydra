#!/usr/bin/env python3
import argparse
import collections
import datetime
import os
import sys
import traceback
from pprint import pprint

from pyquery import PyQuery as pq

# Bad python module system
sys.path.append('..')

# Relative import, since Python cannot handle being a script
from util import write_json_to_file, split_price

# Where to write to.
OUTFILE_1_0 = "menu/{}/{}.json"
OUTFILE_2_0 = "menu/{}/{}/{}/{}.json"
OVERVIEW_2_0 = "menu/{}/overview.json"

LINK_FORMAT = "http://www.ugent.be/student/nl/meer-dan-studeren/resto/{}"

# The url containing the list of week menus.
WEEK_MENU_URL = {
    "en": "https://www.ugent.be/en/facilities/restaurants/weekly-menu",
    "nl-debrug": LINK_FORMAT.format("weekmenurestodebrug"),
    "nl-heymans": LINK_FORMAT.format("weekmenurestocampusheymans"),
    "nl-dunant": LINK_FORMAT.format("weekmenurestocampusdunant"),
    "nl-coupure": LINK_FORMAT.format("weekmenurestocampuscoupure"),
    "nl-sterre": LINK_FORMAT.format("weekmenurestocampussterre"),
    "nl-ardoyen": LINK_FORMAT.format("weekmenurestoardoyen"),
    "nl-merelbeke": LINK_FORMAT.format("weekmenurestocampusmerelbeke")
}

# Day names to day of the week.
# The keys are the keys from WEEK_MENU_URL.
# For english:
# noinspection PyTypeChecker
DAY_OF_THE_WEEK = collections.defaultdict(
    lambda: {
        "Maandag": 1,
        "Dinsdag": 2,
        "Woensdag": 3,
        "Donderdag": 4,
        "Vrijdag": 5
    }, {
        "en": {
            "Monday": 1,
            "Tuesday": 2,
            "Wednesday": 3,
            "Thursday": 4,
            "Friday": 5
        }
    })

# Define the page type for the resto.
# See also WEEK_MENU_PARSERS
WEEK_MENU_PAGE_TYPE = collections.defaultdict(lambda: "html")

# Languages
TYPES = list(WEEK_MENU_URL.keys())

# The jQuery selector for the meals on the menu page.
CONTENT_SELECTOR = "#content-core"
MEAL_AND_HEADING_SELECTOR = "#content-core li, #content-core h3"

WEEK_MENU_HTML_SELECTOR_LINKS = "#content-core a"

# The string indicating a closed day.
CLOSED = collections.defaultdict(lambda: "GESLOTEN", en="CLOSED")

# Dictionary to translate the kinds on the website to the internal kind.
TRANSLATE_KIND = collections.defaultdict(lambda: 'meat', {
    # Dutch -> internal
    'vegetarisch': 'vegetarian',
    'veggie': 'vegetarian',
    'vegi': 'vegetarian',
    'vis': 'fish',
    'vlees': 'meat',
    'vis/vlees': 'fish',
    'vegetarische wrap': 'vegetarian',
    'veganistisch': 'vegan',
    # English -> internal (except meat, since it is the default)
    'vegan': 'vegan',
    'vegetarian': 'vegetarian',
    'fish': 'fish'
})

KIND_ORDER = {
    'soup': 1,
    'vegan': 2,
    'vegetarian': 3,
    'fish': 4,
    'meat': 5
}

POSSIBLE_VEGETARIAN = ['vegetarische', 'vegetarisch', 'veggie', 'vegi', 'vegetarian']
POSSIBLE_VEGAN = ['veganistische', 'veganistisch', 'vegan']
# Not all fish dishes have these. Also included are some wrong spellings.
POSSIBLE_FISH = ['asc', 'msc', 'gap', 'hoki', 'kabeljauw', 'zalm', 'pollack', 'koolvis', 'pangasius', 'vispannetje',
                 'heek', 'pollak', 'schol', 'hocki', 'salmon', 'tilapia', 'coley', 'loin']

# Map headings to internal types.
HEADING_TO_TYPE = {
    'soep': 'soup',
    'maaltijdsoep': 'meal soup',
    'hoofdgerecht': 'meat',
    'groenten': 'vegetables',
    'groente': 'vegetables',
    'steeds op het menu': 'meat',
    'warme gerechten': 'meat',
    'koude gerechten (zelf op te warmen)': 'meat',
    # English
    'soup': 'soup',
    'meal soup': 'meal soup',
    'main dish': 'meat',
    'vegetables': 'vegetables',
    'warm take away dishes': 'meat',
    'cold take away dishes (to heat up)': 'meat',
    'warm meals': 'meat',
    'cold meals (to heat up)': 'meat',
    'cold meals <em>(to heat up)</em>': 'meat',
    'cold meals <em>(to heat up)</em>': 'meat'
}

HOT_COLD_MAPPING = collections.defaultdict(lambda: 'hot', {
    'koude gerechten (zelf op te warmen)': 'cold',
    'cold meals (to heat up)': 'cold',
    'cold take away dishes (to heat up)': 'cold',
    'cold meals <em>(to heat up)</em>': 'cold',
    'cold meals <em>(to heat up)</em>': 'cold'
})


def get_weeks_html(url):
    """
    Get the URLs to the weekly menus from the Dutch-style HTML page.
    """
    page = pq(url=url)
    return [link.attrib['href'] for link in page(WEEK_MENU_HTML_SELECTOR_LINKS)]


# Map of the various parsers for the week menu.
WEEK_MENU_PARSERS = {
    "html": get_weeks_html
}


def get_weeks(which):
    """
    Retrieves a dictionary of week numbers to the url of the menu for that
    week from the given week menu overview.
    """
    page_type = WEEK_MENU_PAGE_TYPE[which]
    week_parser = WEEK_MENU_PARSERS[page_type]
    week_urls = week_parser(WEEK_MENU_URL[which])
    r = {}
    for url in week_urls:
        try:
            week_part = url.rsplit("/")[-1].replace("week", "")
            # Strip cyclus part
            iso_week = int(week_part.split("-")[0])
        except Exception:
            print(f"Failure parsing week page for {which}, with url {url}.", file=sys.stderr)
            print(f"Week number {url.split('week')[-1]} is not an int, ignoring it.", file=sys.stderr)
            traceback.print_exc()
            continue
        iso_year, iso_week, _ = DateStuff.from_iso_week(iso_week).isocalendar()
        r[(iso_year, iso_week)] = url
    return r


def get_days(which, iso_week, url):
    """Retrieves a dictionary from iso weeks on which the resto is open."""
    # All days are closed by default.
    r = {
        DateStuff.from_iso_week_day(which, iso_week, day): None
        for day in DAY_OF_THE_WEEK[which]
    }

    # Get content core, containing the links to the days.
    page = pq(url=url)
    links = []
    for anchor in page("#content-core a"):
        links.append(anchor.attrib["href"].lower())

    # For each possible day (and corresponding ISO day), try if the link exists.
    for day in DAY_OF_THE_WEEK[which]:
        potential = f"{url}/{day.lower()}.htm"
        if potential in links:
            r[DateStuff.from_iso_week_day(which, iso_week, day)] = potential

    return r


def get_day_menu(which, url):
    """Parses the day menu from the given url."""
    # Assumptions:
    # - The #content-core contains only <li> items belonging to the menu and <h3> elements that indicate a type.
    # - All menu items have a price, except vegetables.
    # - Priced items are of the form "NAME - € X,XX".
    # - Vegan and vegetarian is indicated by either the old system (KIND: name - price)
    #   or the new system (name - KIND - price). The kind is optional; if not present, meat is assumed (in the new
    #   system)
    day_menu = pq(url=url)
    vegetables = []
    meats = []
    soups = []

    if CLOSED[which] in day_menu(CONTENT_SELECTOR).html():
        return dict(open=False)

    # We iterate through the html: the h3 headings are used to reliably (?) determine the kind of the meal.
    meals_and_headings = day_menu(MEAL_AND_HEADING_SELECTOR).items()

    last_heading = None
    for current in meals_and_headings:
        if current.is_('h3'):
            if current.html() is not None:
                last_heading = current.html().lower().strip()
            continue
        # We have a meal type.
        meal = current.html()
        if meal is None:
            continue  # Ignore empty

        meal = meal.strip()

        if last_heading is None:
            print(f'Ignoring {meal}, no header.')
            continue

        if last_heading not in HEADING_TO_TYPE:
            raise ValueError(f"Unknown header type {last_heading}, not mapped.")

        if HEADING_TO_TYPE[last_heading] == 'soup':
            name, price = split_price(meal)
            soups.append(dict(price=price, name=name, type='side'))
        elif HEADING_TO_TYPE[last_heading] == 'meal soup':
            name, price = split_price(meal)
            soups.append(dict(price=price, name=name, type='main'))
        elif HEADING_TO_TYPE[last_heading] == 'meat':
            hot_cold = HOT_COLD_MAPPING[last_heading]
            name, price = split_price(meal)
            if ':' in meal:  # Meat in the old way
                kind, name = [s.strip() for s in name.split(':')]
                kind = kind.lower()
                kind = TRANSLATE_KIND[kind]
                meats.append(dict(price=price, name=name, kind=kind, hot=hot_cold))
            else:  # Meat in the new way
                # If the name contains '-', it might be an indication of vegan/vegi
                if '-' in name:
                    kind = name.split('-')[-1].strip()
                    stripped_name = '-'.join(name.split('-')[:-1]).strip()  # Re-join other splits
                    if kind in TRANSLATE_KIND:
                        meats.append(dict(price=price, name=stripped_name, kind=TRANSLATE_KIND[kind], hot=hot_cold))
                    else:
                        meats.append(dict(price=price, name=name, kind='meat', hot=hot_cold))
                else:
                    # Sometimes there is vegan/vegetarian in the name, in which case they don't repeat the type.
                    if any(possible in name.lower() for possible in POSSIBLE_VEGETARIAN):
                        meats.append(dict(price=price, name=name, kind='vegetarian', hot=hot_cold))
                    elif any(possible in name.lower() for possible in POSSIBLE_VEGAN):
                        meats.append(dict(price=price, name=name, kind='vegan', hot=hot_cold))
                    elif any(possible in name.lower() for possible in POSSIBLE_FISH):
                        meats.append(dict(price=price, name=name, kind='fish', hot=hot_cold))
                    else:
                        meats.append(dict(price=price, name=name, kind='meat', hot=hot_cold))
        elif HEADING_TO_TYPE[last_heading] == 'vegetables':
            vegetables.append(meal)
        else:
            raise ValueError(f"Oops, HEADING_TO_TYPE contains unknown value for {last_heading}.")

    # sometimes the closed indicator has a different layout.
    if not vegetables and not soups and not meats:
        return dict(open=False)

    r = dict(open=True, vegetables=vegetables, soup=soups, meat=meats)
    return r


class DateStuff(object):

    @staticmethod
    def iso_year_start(iso_year):
        """The gregorian calendar date of the first day of the given ISO year"""
        fourth_jan = datetime.date(iso_year, 1, 4)
        delta = datetime.timedelta(fourth_jan.isoweekday() - 1)
        return fourth_jan - delta

    @staticmethod
    def iso_to_gregorian(iso_year, iso_week, iso_day):
        """Gregorian calendar date for the given ISO year, week and day"""
        year_start = DateStuff.iso_year_start(iso_year)
        return year_start + datetime.timedelta(days=iso_day - 1,
                                               weeks=iso_week - 1)

    @staticmethod
    def from_iso_week(iso_week):
        return DateStuff._from_iso_week_day(iso_week, 1)

    @staticmethod
    def from_iso_week_day(which, iso_week, iso_day_name):
        iso_day = DAY_OF_THE_WEEK[which][iso_day_name]
        return DateStuff._from_iso_week_day(iso_week, iso_day)

    @staticmethod
    def _from_iso_week_day(iso_week, iso_day):
        today_iso_calendar = datetime.date.today().isocalendar()
        iso_current_year, iso_current_week, _ = today_iso_calendar
        if iso_current_week > 40 and iso_week < 10:
            iso_year = iso_current_year + 1
        elif iso_current_week < 10 and iso_week > 40:
            iso_year = iso_current_year - 1
        else:
            iso_year = iso_current_year
        return DateStuff.iso_to_gregorian(iso_year, iso_week, iso_day)


def write_2_0(root_path, menus):
    """
    Write the menus for version 2.0 of the API.
    :param root_path: The output path for version 2.0. This is the root path. The subfolder menu will be created.
    :param menus: The menus to write.
    :return:
    """

    for resto, resto_menu in menus.items():
        overview = []
        for week_year, week_menu in resto_menu.items():
            for day, day_menu in week_menu.items():
                menu = dict(
                    open=day_menu['open'],
                    date=day.strftime('%Y-%m-%d'),
                    meals=[],
                    vegetables=[],
                )
                if day_menu['open']:
                    for i, meal in enumerate(day_menu['soup']):
                        menu['meals'].append(dict(
                            kind='soup',
                            name=meal['name'],
                            price=meal['price'],
                            type=meal['type'],
                        ))
                    for meal in day_menu['meat']:
                        menu['meals'].append(dict(
                            kind=meal['kind'],
                            name=meal['name'],
                            price=meal['price'],
                            type='main' if meal['hot'] == 'hot' else 'cold',
                        ))
                    menu['vegetables'] = day_menu['vegetables']

                if day >= datetime.date.today():
                    overview.append(menu)

                menu['meals'] = sorted(menu['meals'], key=lambda x: KIND_ORDER[x['kind']])
                output_file_menu = os.path.join(root_path, OUTFILE_2_0.format(resto, day.year, day.month, day.day))
                write_json_to_file(menu, output_file_menu)

        overview_file = os.path.join(root_path, OVERVIEW_2_0.format(resto))
        write_json_to_file(
            sorted(overview, key=lambda x: datetime.datetime.strptime(x['date'], '%Y-%m-%d'))[:10],
            overview_file
        )


def main(output_v2):
    """The main method."""

    all_problems = {}
    menus = {}
    for which in TYPES:
        problems = []
        menus[which] = {}

        weeks = {}
        try:
            # Get weeks. Expect at least this week (if <= friday) and the
            # following.
            weeks = get_weeks(which)
        except Exception as error:
            problems.append(f"Failed to parse the weekmenu on {WEEK_MENU_URL[which]}.")
            traceback.print_exc()

        for week, week_url in weeks.items():

            year, week = week
            days = {}
            try:
                # Get days. Expect every day to be there.
                days = get_days(which, week, week_url)
                problems.extend([
                    f"{day} is not available in week {week}."
                    for day in days
                    if days[day] is None and day >= datetime.date.today()
                ])
            except Exception as error:
                problem = f"Failed to parse days from {week_url}."
                problems.append(problem)
                traceback.print_exc()

            week_dict = {}
            for day, day_url in days.items():
                if day_url is None:
                    continue  # Skip unavailable days.

                try:
                    menu = get_day_menu(which, day_url)
                    week_dict[day] = menu
                except Exception as error:
                    problems.append(f"Failed parsing daymenu from {day_url}.")
                    traceback.print_exc()

            menus[which][(year, week)] = week_dict

        if problems:
            all_problems[which] = problems

    # Print the parsing problems.
    if all_problems:
        pprint(all_problems, stream=sys.stderr)

    write_2_0(output_v2, menus)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run main resto scraper')
    parser.add_argument('v2', help='Folder for v2 output. Will be created if needed.')
    args = parser.parse_args()

    output_path_v2 = os.path.abspath(args.v2)  # Like realpath

    main(output_path_v2)

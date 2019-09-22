#!/usr/bin/env python3
import argparse
from pprint import pprint

import json
import collections
import datetime
import os
import sys

from requests.exceptions import ConnectionError, Timeout
from pyquery import PyQuery as pq

# Bad python module system
sys.path.append('..')

# Relative import, since Python cannot handle being a script
from backoff import retry_session
from util import write_json_to_file

# Where to write to.
OUTFILE_1_0 = "menu/{}/{}.json"
OUTFILE_2_0 = "menu/{}/{}/{}/{}.json"
OVERVIEW_2_0 = "menu/{}/overview.json"

LINK_FORMAT = "http://www.ugent.be/student/nl/meer-dan-studeren/resto/{}/overzicht/@@rss2json"

# The url containing the list of week menus.
WEEK_MENU_URL = {
    "nl": (LINK_FORMAT.format("weekmenu")),
    "en": "https://www.ugent.be/en/facilities/restaurants/weekly-menu/overzicht/@@rss2json",
    "nl-sintjansvest": "https://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu-sintjansvest/",
    "nl-debrug": LINK_FORMAT.format("weekmenurestodebrug"),
    "nl-heymans": LINK_FORMAT.format("weekmenurestocampusheymans"),
    "nl-kantienberg": LINK_FORMAT.format("weekmenurestokantienberg")
}

# Define the page type for the resto.
# See also WEEK_MENU_PARSERS
WEEK_MENU_PAGE_TYPE = collections.defaultdict(lambda: "rss-json", {
    "nl-sintjansvest": "html"
})

# Languages
TYPES = list(WEEK_MENU_URL.keys())

# The jQuery selector for each day title <a> element on each week menu.
DAY_SELECTOR = ".summary.url"

# The jQuery selector for the meals on the menu page.
CLOSED_SELECTOR = "#content-core"
MEAL_AND_HEADING_SELECTOR = "#content-core li, #content-core h3"

WEEK_MENU_HTML_SELECTOR_LINKS = "#content-core .linklist li a"

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
POSSIBLE_FISH = ['asc', 'msc']

# Map headings to internal types.
# TODO: both soups are mapped to same type and then later split again.
#   Maybe directly split it?
HEADING_TO_TYPE = {
    'soep': 'soup',
    'maaltijdsoep': 'soup',
    'hoofdgerecht': 'meat',
    'groenten': 'vegetables',
    'steeds op het menu': 'meat',
    # English
    'soup': 'soup',
    'meal soup': 'soup',
    'main dish': 'meat',
    'vegetables': 'vegetables'
}


def get_weeks_rss_json(url):
    """
    Get the URL for the weekly menus from the rss page.
    """
    try:
        page = retry_session.get(url)
    except (ConnectionError, Timeout) as e:
        print("Failed to connect: ", e, file=sys.stderr)
        raise e
    week_menu = json.loads(page.text)
    return [x["identifier"] for x in week_menu]


def get_weeks_html(url):
    """
    Get the URL fro the weekly menus from the HTML page.
    """
    page = pq(url=url)
    return [link.attrib['href'] for link in page(WEEK_MENU_HTML_SELECTOR_LINKS)]


# Map of the various parsers for the week menu.
WEEK_MENU_PARSERS = {
    "rss-json": get_weeks_rss_json,
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
            iso_week = int(url.split("week")[-1])
        except Exception as e:
            print(f"Failure parsing week page for {which}, with url {url}.", file=sys.stderr)
            print(f"Week number {url.split('week')[-1]} is not an int, ignoring it.", file=sys.stderr)
            print(e, file=sys.stderr)
            continue
        iso_year, iso_week, _ = DateStuff.from_iso_week(iso_week).isocalendar()
        r[(iso_year, iso_week)] = url
    return r


def get_days(which, iso_week, url):
    """Retrieves a dictionary from iso weeks on which the resto is open."""
    # close all days by default.
    r = {
        DateStuff.from_iso_week_day(which, iso_week, day): None
        for day in DateStuff.DAY_OF_THE_WEEK[which]
    }

    # open on the available days
    week_menu = pq(url=url)
    r.update({
        DateStuff.from_iso_week_day(which, iso_week, pq(e).html()):
            str(pq(e).attr("href"))
        for e in week_menu(DAY_SELECTOR)
    })

    return r


def split_price(meal):
    price = meal.split('-')[-1].strip()
    name = '-'.join(meal.split('-')[:-1]).strip()
    return name, price


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

    if CLOSED[which] in day_menu(CLOSED_SELECTOR).html():
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

        if HEADING_TO_TYPE[last_heading] == 'soup':
            name, price = split_price(meal)
            soups.append(dict(price=price, name=name))
        elif HEADING_TO_TYPE[last_heading] == 'meat':
            name, price = split_price(meal)
            if ':' in meal:  # Meat in the old way
                kind, name = [s.strip() for s in name.split(':')]
                kind = kind.lower()
                kind = TRANSLATE_KIND[kind]
                meats.append(dict(price=price, name=name, kind=kind))
            else:  # Meat in the new way
                # If the name contains '-', it might be an indication of vegan/vegi
                if '-' in name:
                    kind = name.split('-')[-1].strip()
                    stripped_name = '-'.join(name.split('-')[:-1]).strip()  # Re-join other splits
                    if kind in TRANSLATE_KIND:
                        meats.append(dict(price=price, name=stripped_name, kind=TRANSLATE_KIND[kind]))
                    else:
                        meats.append(dict(price=price, name=name, kind='meat'))
                else:
                    # Sometimes there is vegan/vegetarian in the name, in which case they don't repeat the type.
                    if any(possible in name.lower() for possible in POSSIBLE_VEGETARIAN):
                        meats.append(dict(price=price, name=name, kind='vegetarian'))
                    elif any(possible in name.lower() for possible in POSSIBLE_VEGAN):
                        meats.append(dict(price=price, name=name, kind='vegan'))
                    elif any(possible in name.lower() for possible in POSSIBLE_FISH):
                        meats.append(dict(price=price, name=name, kind='fish'))
                    else:
                        meats.append(dict(price=price, name=name, kind='meat'))
        elif HEADING_TO_TYPE[last_heading] == 'vegetables':
            vegetables.append(meal)
        else:
            raise ValueError(f"Unknown header {last_heading} encountered")

    # sometimes the closed indicator has a different layout.
    if not vegetables and not soups and not meats:
        return dict(open=False)

    r = dict(open=True, vegetables=vegetables, soup=soups, meat=meats)
    return r


class DateStuff(object):
    # Day names to day of the week.
    DAY_OF_THE_WEEK = collections.defaultdict(lambda: {
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
        iso_day = DateStuff.DAY_OF_THE_WEEK[which][iso_day_name]
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


def write_1_0(root_path, menus, use_existing=True):
    """
    Write the menus for version 1.0 of the API. This is Dutch only.
    :param use_existing: If existing data should be deleted or not. Set to true if re-writing all data.
    :param root_path: The output path for version 1.0. This is the root path. The subfolder menu will be created.
    :param menus: The menus to write.
    """
    for week_year, week_menu in menus['nl'].items():
        year, week = week_year
        # Read existing data
        output_file = os.path.join(root_path, OUTFILE_1_0.format(year, week))
        if use_existing:
            try:
                with open(output_file, 'r') as f:
                    menu = json.load(f)
            except FileNotFoundError:
                menu = {}
        else:
            menu = {}
        for day, day_menu in week_menu.items():
            if not day_menu["open"]:
                day_menu1_0 = {"open": False}
            else:
                day_menu1_0 = {
                    "open": True,
                    "soup": day_menu["soup"][0],
                    "meat": [day_menu["soup"][1]],
                    "vegetables": day_menu["vegetables"]
                }
                day_menu1_0["meat"][0]["recommended"] = False
                for meat in day_menu["meat"]:
                    name = meat["name"]
                    price = meat["price"]
                    if "vegetarian" in meat["kind"]:
                        name = "Veg. " + name
                    day_menu1_0["meat"].append({
                        'name': name,
                        'price': price,
                        'recommended': False
                    })
            menu[str(day)] = day_menu1_0

        write_json_to_file(menu, output_file)


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
                            # side comes first, FIXME
                            type='side' if i == 0 or i == 1 else 'main',
                        ))
                    for meal in day_menu['meat']:
                        menu['meals'].append(dict(
                            kind=meal['kind'],
                            name=meal['name'],
                            price=meal['price'],
                            type='main',
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


def main(output_v1, output_v2):
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
            problems.append("Failed to parse the weekmenu on {}.".format(
                WEEK_MENU_URL[which]))
            print(error, file=sys.stderr)

        for week, week_url in weeks.items():

            year, week = week
            days = {}
            try:
                # Get days. Expect every day to be there.
                days = get_days(which, week, week_url)
                problems.extend([
                    "{} is not available in week {}.".format(day, week)
                    for day in days
                    if days[day] is None and day >= datetime.date.today()
                ])
            except Exception as error:
                problem = "Failed to parse days from {}.".format(week_url)
                problems.append(problem)
                print(error, file=sys.stderr)

            week_dict = {}
            for day, day_url in days.items():
                if day_url is None:
                    continue  # Skip unavailable days.

                try:
                    menu = get_day_menu(which, day_url)
                    week_dict[day] = menu
                except Exception as error:
                    problems.append("Failed parsing daymenu from {}.".format(
                        day_url))
                    print(error, file=sys.stderr)

            menus[which][(year, week)] = week_dict

        if problems:
            all_problems[which] = problems

    # Print the parsing problems.
    if all_problems:
        pprint(all_problems, stream=sys.stderr)

    write_1_0(output_v1, menus)
    write_2_0(output_v2, menus)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run main resto scraper')
    parser.add_argument('v1', help='Folder for v1 output. Will be created if needed.')
    parser.add_argument('v2', help='Folder for v2 output. Will be created if needed.')
    args = parser.parse_args()

    output_path_v1 = os.path.abspath(args.v1)  # Like realpath
    output_path_v2 = os.path.abspath(args.v2)  # Like realpath

    main(output_path_v1, output_path_v2)

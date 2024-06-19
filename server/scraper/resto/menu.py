#!/usr/bin/env python3
import argparse
import collections
import datetime
import json
import os
import re
import warnings

from bs4 import BeautifulSoup, MarkupResemblesLocatorWarning
import string
import sys
import traceback
from pprint import pprint
from typing import Dict

from pyquery import PyQuery as pq

warnings.filterwarnings("ignore", category=MarkupResemblesLocatorWarning)

# Bad python module system
sys.path.append('..')

# Relative import, since Python cannot handle being a script
from util import write_json_to_file, split_price

# Where to write to.
OUTFILE_2_0 = "menu/{}/{}/{}/{}.json"
OVERVIEW_2_0 = "menu/{}/overview.json"

# The url containing the list of week menus.
WEEK_MENU_URL = {
    "en": "https://www.ugent.be/en/facilities/restaurants/weekly-menu",
    "nl": "https://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu",
    "nl-sterre": "https://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu",
    "nl-debrug": "https://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu",
    "nl-coupure": "https://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu",
    "nl-ardoyen": "https://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu"
}

NORMAL_WEEK = re.compile(r"week(\d+)$")
INDIVIDUAL_DAY_URL_OVERRIDE = {
    "nl-coupure": r"week(\d+)-?(ardoyen-)?coupure$",
    "nl-debrug": r"week(\d+)-?(brugsterre|brug)|week(27)duurzaam|week(28)duurzaam",
    "nl-sterre": r"week(\d+)-?(brugsterre|sterre)|week(27)duurzaam",
    "nl-ardoyen": r"week(\d+)-?ardoyen(-coupure)?"
}

# These endpoints are copies of another endpoint.
# While this seems useless, it allows messages per endpoint,
# which is very useful.
# TODO: there is currently no "nl" endpoint, so this is pointless.
COPIED_ENDPOINTS = {
    "nl-debrug": "nl",
    "nl-coupure": "nl",
    "nl-sterre": "nl",
    "nl-ardoyen": "nl",
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
    'warm dishes': 'meat',
    'hot meals': 'meat',
    'cold meals (to heat up)': 'meat',
    'cold dishes (to heat up)': 'meat',
    'cold dishes (to be heated up)': 'meat',
    'cold meals <em>(to heat up)</em>': 'meat',
    'cold meals <em>(to heat up)</em>': 'meat'
}

HOT_COLD_MAPPING = collections.defaultdict(lambda: 'hot', {
    'koude gerechten (zelf op te warmen)': 'cold',
    'cold meals (to heat up)': 'cold',
    'cold take away dishes (to heat up)': 'cold',
    'cold meals <em>(to heat up)</em>': 'cold',
    'cold meals <em>(to heat up)</em>': 'cold',
    'cold dishes (to heat up)': 'cold',
    'cold dishes (to be heated up)': 'cold',
})

# Relevant sections from https://www.ugent.be/student/nl/meer-dan-studeren/resto/allergenen
RELEVANT_ALLERGEN_SECTIONS = [
    "warme maaltijden: vegetarisch",
    "warme maaltijden: vegan",
    "warme maaltijden: vis",
    "warme maaltijden: vlees",
    "groenten bij warme maaltijden",
    "zetmeel",
    "soep",
    "groenten bij warme maaltijden"
]


def get_weeks_html(url, endpoint):
    """
    Get the URLs to the weekly menus from the Dutch-style HTML page.
    """
    page = pq(url=url)
    # The page gives us the "cycli", which we open and parse to get the weeks.
    cycli = [link.attrib['href'] for link in page(WEEK_MENU_HTML_SELECTOR_LINKS)]

    week_urls = []
    for cyclus in cycli:
        if cyclus.endswith("c"):
            # Skip the cafetaria cyclus in the summer.
            # See https://github.com/ZeusWPI/hydra/issues/412
            continue
        if cyclus.endswith("overzicht"):
            # Skip the "overzicht" page, as we don't use it at all.
            continue
        if cyclus.endswith("y") or cyclus.endswith("z"):
            # When working with cycli URLs, there is another level of indirection, which
            # is not present in the regular week menus.
            cyclus_page = pq(url=cyclus)
            week_urls.extend(link.attrib['href'] for link in cyclus_page(WEEK_MENU_HTML_SELECTOR_LINKS))
        else:
            # Just append it...
            week_urls.append(cyclus)

    filtered_urls = []
    if last_part_regex := INDIVIDUAL_DAY_URL_OVERRIDE.get(endpoint):
        last_part_regex = re.compile(last_part_regex)
        filtered_weeks = []
        for url in week_urls:
            if match := last_part_regex.search(url):
                filtered_urls.append(url)
                filtered_weeks.append(match[1])
        # Determine which weeks have an override and which not.
        # Weeks without override are still added.
        for url in week_urls:
            if match := NORMAL_WEEK.search(url):
                week_number = match[1]
                if week_number not in filtered_weeks:
                    filtered_urls.append(url)
    else:
        # In this case, we want all non-special URLs, so all URLs that don't match any override.
        for potential_url in week_urls:
            if NORMAL_WEEK.search(potential_url):
                filtered_urls.append(potential_url)

    # Diagnostics: check if there are URLs that don't match any pattern.
    non_matching = []
    for original_url in week_urls:
        if not any(re.search(pattern, original_url) for pattern in INDIVIDUAL_DAY_URL_OVERRIDE.values()) and not NORMAL_WEEK.search(original_url):
            non_matching.append(original_url)

    if non_matching:
        pprint(f"WARNING: Some week URLs from {endpoint} where not recognized:", stream=sys.stderr)
        pprint(str(non_matching), stream=sys.stderr)

    return filtered_urls


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
    week_urls = week_parser(WEEK_MENU_URL[which], which)
    # If there are no week urls for "nl", which is our fallback,
    # use those from "nl-debrug".
    if not week_urls:
        # This is an ugly hack :(
        week_urls = week_parser(WEEK_MENU_URL["nl-debrug"], "nl-debrug")
    r = {}
    for url in week_urls:
        try:
            week_part = url.rsplit("/")[-1].replace("week", "")
            split = week_part.split("-")
            # Handle "week-17" format
            if not split[0]:
                split.pop(0)
            # Strip cyclus part
            supposedly_int = split[0].rstrip(string.ascii_letters)
            iso_week = int(supposedly_int)
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


def find_allergens_for_food(allergens: Dict[str, str], food: str) -> list[str]:
    """Attempt to find the allergens for the given food."""
    food = food.lower()
    food_parts = [x.strip() for x in food.split("/")]
    found = []
    for part in food_parts:
        found += allergens.get(part, [])
    # Also do the reverse search if we didn't find any allergens.
    if not found:
        for allergen_food, allergens in allergens.items():
            if allergen_food in food:
                found += allergens
    return found


def get_day_menu(which, url, allergens: Dict[str, str]):
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
    vegetables2 = []
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
        meal = BeautifulSoup(meal, "html.parser").get_text()

        if last_heading is None:
            print(f'Ignoring {meal}, no header.')
            continue

        if last_heading not in HEADING_TO_TYPE:
            raise ValueError(f"Unknown header type {last_heading}, not mapped.")

        if HEADING_TO_TYPE[last_heading] == 'soup':
            name, price = split_price(meal)
            if "€" in name:
                name, price_large = split_price(name)
            else:
                price_large = None
            food_allergens = find_allergens_for_food(allergens, name)
            if price_large:
                small = "klein" if "nl" in which else "small"
                big = "groot" if "nl" in which else "big"
                name_small = f"{name} {small}"
                name_big = f"{name} {big}"
                soups.append(dict(price=price, name=name_small, type='side', allergens=food_allergens))
                soups.append(dict(price=price_large, name=name_big, type='side', allergens=food_allergens))
            else:
                soups.append(dict(price=price, name=name, type='side', allergens=food_allergens))
        elif HEADING_TO_TYPE[last_heading] == 'meal soup':
            name, price = split_price(meal)
            food_allergens = find_allergens_for_food(allergens, name)
            soups.append(dict(price=price, name=name, type='main', allergens=food_allergens))
        elif HEADING_TO_TYPE[last_heading] == 'meat':
            hot_cold = HOT_COLD_MAPPING[last_heading]
            name, price = split_price(meal)
            if ':' in meal:  # Meat in the old way
                kind, name = [s.strip() for s in name.split(':')]
                kind = kind.lower()
                kind = TRANSLATE_KIND[kind]
                food_allergens = find_allergens_for_food(allergens, name)
                meats.append(dict(price=price, name=name, kind=kind, hot=hot_cold, allergens=food_allergens))
            else:  # Meat in the new way
                # If the name contains '-', it might be an indication of vegan/vegi
                if '-' in name:
                    kind = name.split('-')[-1].strip()
                    stripped_name = '-'.join(name.split('-')[:-1]).strip()  # Re-join other splits
                    if kind in TRANSLATE_KIND:
                        food_allergens = find_allergens_for_food(allergens, stripped_name)
                        meats.append(dict(price=price, name=stripped_name, kind=TRANSLATE_KIND[kind], hot=hot_cold,
                                          allergens=food_allergens))
                    else:
                        food_allergens = find_allergens_for_food(allergens, name)
                        meats.append(dict(price=price, name=name, kind='meat', hot=hot_cold, allergens=food_allergens))
                else:
                    # Sometimes there is vegan/vegetarian in the name, in which case they don't repeat the type.
                    if any(possible in name.lower() for possible in POSSIBLE_VEGETARIAN):
                        kind = 'vegetarian'
                    elif any(possible in name.lower() for possible in POSSIBLE_VEGAN):
                        kind = 'vegan'
                    elif any(possible in name.lower() for possible in POSSIBLE_FISH):
                        kind = 'fish'
                    else:
                        kind = 'meat'
                    food_allergens = find_allergens_for_food(allergens, name)
                    meats.append(dict(price=price, name=name, kind=kind, hot=hot_cold, allergens=food_allergens))
        elif HEADING_TO_TYPE[last_heading] == 'vegetables':
            vegetables.append(meal)
            if ":" in meal:
                kind, name = meal.split(":")
                if kind in POSSIBLE_VEGETARIAN:
                    kind = 'vegetarian'
                elif kind in POSSIBLE_VEGAN:
                    kind = 'vegan'
                else:
                    kind = 'meat'
            else:
                kind = 'meat'
                name = meal
            vegetable_allergens = find_allergens_for_food(allergens, name)
            vegetable = {
                'name': name.strip(),
                'kind': kind,
                'allergens': vegetable_allergens
            }
            vegetables2.append(vegetable)
        else:
            raise ValueError(f"Oops, HEADING_TO_TYPE contains unknown value for {last_heading}.")

    # sometimes the closed indicator has a different layout.
    if not vegetables and not soups and not meats:
        return dict(open=False)

    r = dict(open=True, vegetables=vegetables, vegetables2=vegetables2, soup=soups, meat=meats)
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
                            allergens=meal['allergens'],
                        ))
                    for meal in day_menu['meat']:
                        menu['meals'].append(dict(
                            kind=meal['kind'],
                            name=meal['name'],
                            price=meal['price'],
                            type='main' if meal['hot'] == 'hot' else 'cold',
                            allergens=meal['allergens'],
                        ))
                    menu['vegetables'] = day_menu['vegetables']
                    menu['vegetables2'] = day_menu['vegetables2']

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

    # We want to include allergens, so get the allergens and a number of relevant sections.
    # This assumes you have run the allergen scraper first!
    allergens = {}
    try:
        with open(f"{output_v2}/allergens.json", 'r') as allergen_file:
            all_allergens = json.load(allergen_file)
            for section in RELEVANT_ALLERGEN_SECTIONS:
                allergens |= all_allergens[section]
    except KeyError:
        print(f"Could not find allergen section {section} in {all_allergens}.", file=sys.stderr)
        print("Skipping allergens.", file=sys.stderr)
        traceback.print_exc()
    except IOError:
        print("Could not find allergen file.", file=sys.stderr)
        print("Using a default, but this is not normal.", file=sys.stderr)
        traceback.print_exc()

    all_problems = {}
    menus = {}
    for which in TYPES:
        problems = []
        menus[which] = {}

        weeks = {}
        # noinspection PyBroadException
        try:
            # Get weeks. Expect at least this week (if <= friday) and the
            # following.
            weeks = get_weeks(which)
        except Exception:
            problems.append(f"Failed to parse the weekmenu on {WEEK_MENU_URL[which]}.")
            traceback.print_exc()

        for week, week_url in weeks.items():

            year, week = week
            days = {}
            # noinspection PyBroadException
            try:
                # Get days. Expect every day to be there.
                days = get_days(which, week, week_url)
                problems.extend([
                    f"{day} is not available in week {week}."
                    for day in days
                    if days[day] is None and day >= datetime.date.today()
                ])
            except Exception:
                problem = f"Failed to parse days from {week_url}."
                problems.append(problem)
                traceback.print_exc()

            week_dict = {}
            for day, day_url in days.items():
                if day_url is None:
                    continue  # Skip unavailable days.

                # noinspection PyBroadException
                try:
                    menu = get_day_menu(which, day_url, allergens)
                    week_dict[day] = menu
                except Exception:
                    problems.append(f"Failed parsing daymenu from {day_url}.")
                    traceback.print_exc()

            menus[which][(year, week)] = week_dict

        if problems:
            all_problems[which] = problems

    # Support copies
    for copy, original in COPIED_ENDPOINTS.items():
        if copy not in menus:
            menus[copy] = {}
        originals = menus[original]
        copies = menus[copy]
        for week, original_menu in originals.items():
            # If the day already exists, don't copy it.
            if week not in copies:
                copies[week] = original_menu

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

from pprint import pprint

import json
import collections
import datetime
import os
import sys

from util import stderr_print
from backoff import retry_session
from requests.exceptions import ConnectionError, Timeout

from pyquery import PyQuery as pq

# Where to write to.
OUTFILE = "resto/1.0/menu/{}/{}.json"
OUTFILE_2_0 = "resto/2.0/menu/{}/{}/{}/{}.json"
OVERVIEWFILE_2_0 = "resto/2.0/menu/{}/overview.json"

LINK_FORMAT = "http://www.ugent.be/student/nl/meer-dan-studeren/resto/{}/overzicht/@@rss2json"
ALGEMEEN = LINK_FORMAT.format("weekmenu")

# The url containing the list of weekmenu's.
WEEKMENU_URL = {
    "nl": ALGEMEEN,
    "en": "https://www.ugent.be/en/facilities/restaurants/weekly-menu/overzicht/@@rss2json",
    "nl-sintjansvest": LINK_FORMAT.format("weekmenu-sintjansvest"),
    "nl-debrug": LINK_FORMAT.format("weekmenurestodebrug"),
    "nl-heymans": LINK_FORMAT.format("weekmenurestocampusheymans"),
    "nl-kantienberg": LINK_FORMAT.format("weekmenurestokantienberg")
}

# Languages
TYPES = list(WEEKMENU_URL.keys())

# The jQuery selector for each day title <a> element on each weekmenu.
DAY_SELECTOR = ".summary.url"

# The jQuery selector for the meals on the menu page.
CLOSED_SELECTOR = "#content-core"
MEAL_SELECTOR = "#content-core li"

# The string indicating a closed day.
CLOSED = collections.defaultdict(lambda: "GESLOTEN", en="CLOSED")

# Dictionary to translate dutch kinds to English
TRANSLATE_KIND = collections.defaultdict(lambda: 'meat', {
    'vegetarisch': 'vegetarian',
    'veggie': 'vegetarian',
    'vis': 'fish',
    'vlees': 'meat',
    'vis/vlees': 'fish',
    'vegetarische wrap': 'vegetarian',
    'veganistisch': 'vegetarian'
})


def get_weeks(which):
    """Retrieves a dictionary of weeknumbers to the url of the menu for that
    week from the given weekmenu overview.
    """
    try:
        page = retry_session.get(WEEKMENU_URL[which])
    except (ConnectionError, Timeout) as e:
        stderr_print("Failed to connect: ", e)
        raise e
    weekmenu = json.loads(page.text)
    week_urls = [x["identifier"] for x in weekmenu]
    r = {}
    for url in week_urls:
        try:
            iso_week = url.split("week")[-1]
            iso_week = int(iso_week)
        except Exception as e:
            print('Failure parsing week "{}", ignoring it.'.format(iso_week))
            print(e)
            continue
        iso_year, iso_week, _ = DateStuff.from_iso_week(iso_week).isocalendar()
        r[(iso_year, iso_week)] = url
    return r


def get_days(which, iso_week, url):
    "Retrieves a dictionary from isoweeks on which the resto is open."
    # close all days by default.
    r = {
        DateStuff.from_iso_week_day(which, iso_week, day): None
        for day in DateStuff.DAY_OF_THE_WEEK[which]
    }

    # open on the available days
    weekmenu = pq(url=url)
    r.update({
        DateStuff.from_iso_week_day(which, iso_week, pq(e).html()):
            str(pq(e).attr("href"))
        for e in weekmenu(DAY_SELECTOR)
    })

    return r


def get_day_menu(which, url):
    "Parses the daymenu from the given url."
    # Assumptions:
    # - The #content-core contains only <li> items belonging to the menu.
    # - Menu items without a price are vegetables.
    # - First item is the soup.
    # - Second item is the meal soup. (unused in old JSON)
    # - Priced items are of the form "\(.*\)-\([^-]*\)" where \1 is the name
    #       and \2 is the price.
    # TODO: parse heading f.e Soup, Main course soup, Main course, ...
    daymenu = pq(url=url)
    vegetables = []
    meats = []
    soups = []

    if CLOSED[which] in daymenu(CLOSED_SELECTOR).html():
        return dict(open=False)

    for meal in daymenu(MEAL_SELECTOR):
        meal = pq(meal).html()
        if meal is None:  # meal is empty li
            continue
        if '€' in meal:
            price = meal.split('-')[-1].strip()
            name = '-'.join(meal.split('-')[:-1]).strip()
            if ':' in meal:  # Meat
                kind, name = [s.strip() for s in name.split(':')]
                kind = kind.lower()
                kind = TRANSLATE_KIND[kind]
                meats.append(dict(price=price, name=name, kind=kind))
            else:  # Soup
                soups.append(dict(price=price, name=name))
        else:
            vegetables.append(meal)

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
        "The gregorian calendar date of the first day of the given ISO year"
        fourth_jan = datetime.date(iso_year, 1, 4)
        delta = datetime.timedelta(fourth_jan.isoweekday() - 1)
        return fourth_jan - delta

    @staticmethod
    def iso_to_gregorian(iso_year, iso_week, iso_day):
        "Gregorian calendar date for the given ISO year, week and day"
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


def write_json(menu, filename):
    directory = os.path.dirname(filename)
    if not os.path.exists(directory):
        os.makedirs(directory)
    with open(filename, 'w') as f:
        json.dump(menu, f, sort_keys=True)


def write_1_0(menus):
    # 1.0 is only nl.
    prev_weekmenu = None  # do not care for the current week
    for weekyear, weekmenu in menus['nl'].items():
        year, week = weekyear
        menu = {}
        combined_weekmenu = dict()  # fix divergent calendars (Issue #225)
        if prev_weekmenu:
            combined_weekmenu.update(prev_weekmenu)
        combined_weekmenu.update(weekmenu)
        prev_weekmenu = weekmenu
        for day, daymenu in combined_weekmenu.items():
            daymenu1_0 = {}
            if not daymenu["open"]:
                daymenu1_0 = {"open": False}
            else:
                daymenu1_0 = {
                    "open": True,
                    "soup": daymenu["soup"][0],
                    "meat": [daymenu["soup"][1]],
                    "vegetables": daymenu["vegetables"]
                }
                daymenu1_0["meat"][0]["recommended"] = False
                for meat in daymenu["meat"]:
                    name = meat["name"]
                    price = meat["price"]
                    if "vegetarian" in meat["kind"]:
                        name = "Veg. " + name
                    daymenu1_0["meat"].append(
                        dict(name=name, price=price, recommended=False)
                    )
            menu[str(day)] = daymenu1_0
        write_json(menu, OUTFILE.format(year, week))


def write_2_0(menus):
    for resto, resto_menu in menus.items():
        overview = []
        for week_year, weekmenu in resto_menu.items():
            for day, daymenu in weekmenu.items():
                menu = dict(
                    open=daymenu['open'],
                    date=day.strftime('%Y-%m-%d'),
                    meals=[],
                    vegetables=[],
                )
                if daymenu['open']:
                    for i, meal in enumerate(daymenu['soup']):
                        menu['meals'].append(dict(
                            kind='soup',
                            name=meal['name'],
                            price=meal['price'],
                            # side comes first, FIXME
                            type='side' if i == 0 else 'main',
                        ))
                    for meal in daymenu['meat']:
                        menu['meals'].append(dict(
                            kind=meal['kind'],
                            name=meal['name'],
                            price=meal['price'],
                            type='main',
                        ))
                    menu['vegetables'] = daymenu['vegetables']

                if day >= datetime.date.today():
                    overview.append(menu)

                write_json(
                    menu,
                    OUTFILE_2_0.format(resto, day.year, day.month, day.day)
                )

        write_json(
            sorted(
                overview,
                key=lambda x: datetime.datetime.strptime(x['date'], '%Y-%m-%d')
            )[:10],
            OVERVIEWFILE_2_0.format(resto)
        )


def main():
    "The main method."

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
                WEEKMENU_URL[which]))
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

    write_1_0(menus)
    write_2_0(menus)


if __name__ == '__main__':
    main()


from pprint import pprint
from pyquery import PyQuery as pq
import json
import datetime
import collections
import sys

# Where to write to.
OUTFILE = "resto/1.0/menu/{}/{}.json"

# Languages
TYPES = ['nl', 'en', 'nl-sintjansvest']

# The url containing the list of weekmenu's.
WEEKMENU_URL = {
    "nl": "http://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu",
    "en": "http://www.ugent.be/en/facilities/restaurants/weekly-menu",
    "nl-sintjansvest": "http://www.ugent.be/student/nl/meer-dan-studeren/resto/weekmenu-sintjansvest"
}

# The jQuery selector for each weekmenu <a> element on the WEEKMENU_URL page.
WEEK_SELECTOR = {
    "nl": ".summary .url",
    "en": ".summary .url",
    "nl-sintjansvest": "#content-core .state-published"
}

# The jQuery selector for each day title <a> element on each weekmenu.
DAY_SELECTOR = ".summary.url"

# The jQuery selector for the meals on the menu page.
CLOSED_SELECTOR = "#content-core"
MEAL_SELECTOR = "#content-core li"

# The string indicating a closed day.
CLOSED = collections.defaultdict(lambda: "GESLOTEN", en="CLOSED")


def get_weeks(which):
    """Retrieves a dictionary of weeknumbers to the url of the menu for that
    week from the given weekmenu overview.
    """
    weekmenu = pq(url=WEEKMENU_URL[which])
    week_urls = (pq(e).attr("href") for i, e in weekmenu(WEEK_SELECTOR[which]))

    r = {}
    for url in week_urls:
        iso_week = int(url.split("week")[-1])
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

    # open on the avaible days
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
    daymenu = pq(url=url)
    vegetables = []
    meats = []
    soups = []

    if CLOSED[which] in daymenu(CLOSED_SELECTOR).html():
        return dict(open=False)

    for meal in daymenu(MEAL_SELECTOR):
        meal = pq(meal).html()
        if '€' in meal:
            price = meal.split('-')[-1].strip()
            name = '-'.join(meal.split('-')[:-1]).strip()
            if ':' in meal:  # Meat
                kind, name = [s.strip() for s in name.split(':')]
                meats.append(dict(price=price, name=name, kind=kind))
            else:  # Soup
                soups.append(dict(price=price, name=name))
        else:
            vegetables.append(meal)
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

    def iso_year_start(iso_year):
        "The gregorian calendar date of the first day of the given ISO year"
        fourth_jan = datetime.date(iso_year, 1, 4)
        delta = datetime.timedelta(fourth_jan.isoweekday() - 1)
        return fourth_jan - delta

    def iso_to_gregorian(iso_year, iso_week, iso_day):
        "Gregorian calendar date for the given ISO year, week and day"
        year_start = DateStuff.iso_year_start(iso_year)
        return year_start + datetime.timedelta(days=iso_day - 1,
                                               weeks=iso_week - 1)

    def from_iso_week(iso_week):
        return DateStuff._from_iso_week_day(iso_week, 1)

    def from_iso_week_day(which, iso_week, iso_day_name):
        iso_day = DateStuff.DAY_OF_THE_WEEK[which][iso_day_name]
        return DateStuff._from_iso_week_day(iso_week, iso_day)

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

    def problems_with_weeks(weeks):
        year, week, day = datetime.date.today().isocalendar()
        problems = []
        # If before saturday, should contain the current week.
        if(day < 6 and (year, week) not in weeks):
            problems.append("Failed to retrieve the menu of the current week.")
        # Should contain the next week, always.
        one_week_from_now = datetime.date.today() + datetime.timedelta(weeks=1)
        year, week, day = one_week_from_now.isocalendar()
        if (year, week) not in weeks:
            problems.append("Failed to retrieve the menu of the next week.")
        return problems


def write_1_0(menus):
    # 1.0 is only nl.
    for weekyear, weekmenu in menus['nl'].items():
        year, week = weekyear
        menu = {}
        for day, daymenu in weekmenu.items():
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
                    if "Vegetarisch" in meat["kind"]:
                        name = "Veg. " + name
                    daymenu1_0["meat"].append(
                        dict(name=name, price=price, recommended=False)
                    )
            menu[str(day)] = daymenu1_0
        json.dump(menu, open(OUTFILE.format(year, week), 'w'), sort_keys=True)


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
            problems.extend(DateStuff.problems_with_weeks(weeks))
        except:
            problems.append("Failed to parse the weekmenu on {}.".format(
                WEEKMENU_URL[which]))

        for week, week_url in weeks.items():

            year, week = week
            days = {}
            try:
                # Get days. Expect every day to be there.
                days = get_days(which, week, week_url)
                problems.extend([
                    "{} is not available in week {}.".format(day, week)
                    for day in days if days[day] is None
                ])
            except:
                problem = "Failed to parse days from {}.".format(week_url)
                problems.append(problem)

            week_dict = {}
            for day, day_url in days.items():
                if day_url is None:
                    continue  # Skip unavailable days.

                try:
                    menu = get_day_menu(which, day_url)
                    week_dict[day] = menu
                except Exception as e:
                    problems.append("Failed parsing daymenu from {}.".format(
                        day_url))
                    print(e)

            menus[which][(year, week)] = week_dict

        if problems:
            all_problems[which] = problems

    # Print the parsing problems.
    if all_problems:
        pprint(all_problems, stream=sys.stderr)

    write_1_0(menus)


if __name__ == '__main__':
    main()

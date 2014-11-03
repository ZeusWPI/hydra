
from pprint import pprint
from pyquery import PyQuery as pq
import json
import datetime
import collections
import sys

# Where to write to.
OUTFILE = "resto/1.0/menu/{}/{}.json"

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
    "Retrieves a dictionary of weeknumbers to the url of the menu for that week from the given weekmenu overview."
    weekmenu = pq(url=WEEKMENU_URL[which])
    week_urls = weekmenu(WEEK_SELECTOR[which]).map(lambda i, e: pq(e).attr("href"))

    r = {}
    for url in week_urls:
        iso_year, iso_week, _ = DateStuff.from_iso_week(int(url.split("week")[-1])).isocalendar()
        r[(iso_year, iso_week)] = url
    return r

def get_days(which, iso_week, url):
    "Retrieves a dictionary from isoweeks on which the resto is open."
    # close all days by default.
    r = {
        str(DateStuff.from_iso_week_day(which, iso_week, day)): None
        for day in DateStuff.DAY_OF_THE_WEEK[which]
    }

    # open on the avaible days
    weekmenu = pq(url=url)
    r.update({
        str(DateStuff.from_iso_week_day(which, iso_week, pq(e).html())):
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
    priced = []

    if CLOSED[which] in daymenu(CLOSED_SELECTOR).html():
        return {"open": False}

    for meal in daymenu(MEAL_SELECTOR):
        meal = pq(meal).html()
        if '€' in meal:
            priced.append({
                "name": '-'.join(meal.split('-')[:-1]).strip(),
                "price": meal.split('-')[-1].strip()
            })
        else:
            vegetables.append(meal)
    soup, *meats = priced
    return {
        "open": True,
        "vegetables": vegetables,
        "soup": soup,
        "meat": [dict(meat, recommended=False) for meat in meats]
    }


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
        delta = datetime.timedelta(fourth_jan.isoweekday()-1)
        return fourth_jan - delta

    def iso_to_gregorian(iso_year, iso_week, iso_day):
        "Gregorian calendar date for the given ISO year, week and day"
        year_start = DateStuff.iso_year_start(iso_year)
        return year_start + datetime.timedelta(days=iso_day-1, weeks=iso_week-1)

    def from_iso_week(iso_week):
        return DateStuff._from_iso_week_day(iso_week, 1)

    def from_iso_week_day(which, iso_week, iso_day_name):
        iso_day = DateStuff.DAY_OF_THE_WEEK[which][iso_day_name]
        return DateStuff._from_iso_week_day(iso_week, iso_day)

    def _from_iso_week_day(iso_week, iso_day):
        iso_current_year, iso_current_week, _ = datetime.date.today().isocalendar()
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
        year, week, day = (datetime.date.today() + datetime.timedelta(weeks=1)).isocalendar()
        if (year, week) not in weeks:
            problems.append("Failed to retrieve the menu of the next week.")
        return problems

def main():
    "The main method."
    which = "en"
    problems = []

    weeks = {}
    try:
        # Get weeks. Expect at least this week (if <= friday) and the following.
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
            problems.append("Failed to parse days from {}.".format(week_url))

        week_dict = {}
        for day, day_url in days.items():
            if day_url is None: continue # skipping unavailable days.

            try:
                menu = get_day_menu(which, day_url)
                week_dict[day] = menu
            except:
                problems.append("Failed parsing daymenu from {}.".format(
                    day_url))

        # Write menu to file.
        json.dump(week_dict, open(OUTFILE.format(year, week), 'w'), sort_keys=True)

    if problems: pprint(problems, stream=sys.stderr)




if __name__ == '__main__':
    main()


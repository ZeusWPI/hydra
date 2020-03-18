#!/usr/bin/env python3
import argparse
import glob
import json
import os
import re
from collections import defaultdict
from datetime import date, timedelta, datetime

OVERVIEW_COUNT = 10


# Common things ---------------------------------------------------------------
# See main at bottom
class ManualChange:
    """
    Apply a change to a range of menus in the v2 API. v1 is not supported.
    """

    def __init__(self, replacer, resto, start, end, all_days=False):
        """
        :param replacer: The function that will do the replacements. It will receive the path to the file and the
        original menu.
        :param start: The start date (inclusive).
        :param end: The end date (inclusive).
        :param resto: Which restaurant to apply to.
        :param all_days: If the message should be added for all weekdays in the range. If false (the default), the
        changes will only be applied if there already is a menu for the day.
        """
        self.replacer = replacer
        self.start = start
        self.end = end
        self.resto = resto
        self.all_days = all_days

    def is_applicable(self, menu_date):
        """Check if this change is applicable to the given date"""
        return self.start <= menu_date <= self.end

    def get_overview_glob(self):
        """Get relative glob for the overview"""
        return f"menu/{self.resto}/overview.json"

    def date_range(self):
        """Return an iterator over the applicable range. Only weekdays are returned."""
        for n in range(int((self.end - self.start).days) + 1):
            result = self.start + timedelta(n)
            if result.weekday() < 5:
                yield result


# Restjesmaand Zomer 18
# Sint-Jansvest die geen menu meer serveert, alleen overschotten.
def restjesmaand18_replacer(_path, original):
    # original: {"date": "2018-06-14", "meals": [], "open": false, "vegetables": []}

    name = ("Om voedseloverschotten op het einde van het academiejaar te beperken, "
            "kunnen we geen dagmenu presenteren. "
            "Ga langs en laat je verrassen door ons keukenpersoneel.")

    return {
        "message": name,
        "date": original["date"],
        "meals": [],
        "open": True,
        "vegetables": [],
    }


# Paasvakantie 2019
def paasvakantie19_general(_path, original):
    original['message'] = ("Tijdens de paasvakantie zijn resto's Campus Sterre en Campus Merelbeke geopend als "
                           "cafetaria.")
    original['open'] = True
    return original


def paasvakantie19_en(_path, original):
    original['message'] = 'During the Easter Holiday restos Campus Sterre and Campus Merelbeke operate as cafetaria.'
    original['open'] = True
    return original


def paasvakantie19_brug(_path, original):
    original['message'] = "Tijdens de paasvakantie is De Brug enkel 's middags geopend."
    return original


# Werken in De Brug waardoor de resto gesloten is.
def werken_brug19_replacer(_path, original):
    message = ('De Brug sluit van 20 mei tot 30 september 2019 voor verbouwingswerken. Tijdens de sluiting neemt resto '
               'Kantienberg de functies en het aanbod van de Brug over, zoals de avondopening.')
    return {
        "message": message,
        "date": original["date"],
        "open": False
    }


def werken_brug19_replacer2(_path, original):
    message = ("Resto De Brug en Cafetaria De Brug zijn nog even gesloten in afwachting van het voltooien van de"
               " werken. Tot dan kan je's middags en 's avonds terecht in Resto Kantienberg. Wij houden jullie op de"
               " hoogte!<br>'s Middags is Resto Sint-Jansvest tijdelijk een reguliere resto met een uitgebreid aanbod"
               " aan belegde broodjes. Enkel soep of broodjes nodig? Dan is Cafetaria campus Boekentoren (via"
               " Blandijnberg) zeer dichtbij.")
    return {
        "message": message,
        "date": original["date"],
        "open": False
    }


def tijdelijke_sluiting_sint_jansvest(_path, original):
    message = "Resto Sint-Jansvest is tijdelijk gesloten wegens wegenwerken. Tijdens de werken kan u terecht in De " \
              "Brug. "
    return {
        "message": message,
        "date": original["date"],
        "open": False,
        "meals": original.get("meals", [])
    }


def corona_sluiting_nl(_path, original):
    message = "De studentenrestaurants en cafetaria's sluiten vanaf maandag 16 maart 2020 de deuren. " \
              "De UGent neemt die maatregel om verdere verspreiding van het coronavirus tot een minimum te beperken. " \
              "De sluiting loopt zeker tot het einde van de paasvakantie."
    return {
        "message": message,
        "date": original["date"],
        "open": False
    }


def corona_sluiting_en(_path, original):
    message = "The student restaurants and cafeterias well be closed as from Monday 16 March 2020. " \
              "Ghent University is taking this measure to minimize the further spreading of the coronavirus. " \
              "The closure will certainly last until the end of the Easter holidays."
    return {
        "message": message,
        "date": original["date"],
        "open": False
    }


def create_changes(root_path):
    return [
        # Restjesmaand 2018
        ManualChange(
            replacer=restjesmaand18_replacer,
            resto="nl-sintjansvest",
            start=date(2018, 6, 1),
            end=date(2018, 6, 30),
        ),
        # Dingen voor de paasvakantie 19
        ManualChange(
            replacer=paasvakantie19_general,
            resto="nl",
            start=date(2019, 4, 8),
            end=date(2019, 4, 19)
        ),
        ManualChange(
            replacer=paasvakantie19_en,
            resto="en",
            start=date(2019, 4, 8),
            end=date(2019, 4, 19)
        ),
        ManualChange(
            replacer=paasvakantie19_brug,
            resto="nl-debrug",
            start=date(2019, 4, 8),
            end=date(2019, 4, 19)
        ),
        # Werken aan De Brug from 20/05/2019 - 30/09/2019
        ManualChange(
            replacer=werken_brug19_replacer,
            resto="nl-debrug",
            start=date(2019, 5, 20),
            end=date(2019, 9, 29),
            all_days=True
        ),
        # Er is nog meer vertraging
        ManualChange(
            replacer=werken_brug19_replacer2,
            resto="nl-debrug",
            start=date(2019, 9, 30),
            end=date(2019, 11, 11),
            all_days=True
        ),
        ManualChange(
            replacer=tijdelijke_sluiting_sint_jansvest,
            resto="nl-sintjansvest",
            start=date(2019, 12, 16),
            end=date(2020, 1, 10),
            all_days=True,
        ),
        # Corona
        ManualChange(
            replacer=corona_sluiting_nl,
            resto="nl",
            start=date(2020, 3, 16),
            end=date(2020, 4, 17),
            all_days=True
        ),
        ManualChange(
            replacer=corona_sluiting_nl,
            resto="nl-sintjansvest",
            start=date(2020, 3, 16),
            end=date(2020, 4, 17),
            all_days=True
        ),
        ManualChange(
            replacer=corona_sluiting_nl,
            resto="nl-debrug",
            start=date(2020, 3, 16),
            end=date(2020, 4, 17),
            all_days=True
        ),
        ManualChange(
            replacer=corona_sluiting_nl,
            resto="nl-heymans",
            start=date(2020, 3, 16),
            end=date(2020, 4, 17),
            all_days=True
        ),
        ManualChange(
            replacer=corona_sluiting_nl,
            resto="nl-kantienberg",
            start=date(2020, 3, 16),
            end=date(2020, 4, 17),
            all_days=True
        ),
        ManualChange(
            replacer=corona_sluiting_en,
            resto="en",
            start=date(2020, 3, 16),
            end=date(2020, 4, 17),
            all_days=True
        ),
    ]


# Actually do things ----------------------------------------------------------

def apply_existing_menus_only(output, manual_change, dates):
    """Apply the change to only existing menus"""
    print(f"Matching existing menus from {manual_change.resto} between {manual_change.start} to {manual_change.end}")
    print("====================================================================")

    files = glob.glob(f"{output}/menu/{manual_change.resto}/*/*/*.json")
    file_pattern = re.compile(r'.*/(\d+)/(\d+)/(\d+)\.json$')
    for path in files:
        # Check if this file applies or not.
        m = file_pattern.search(path.replace("\\", "/"))
        file_date = date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
        if not manual_change.is_applicable(file_date):
            continue

        with open(path, 'r') as f:
            overview = json.loads(f.read())
            _new_content = manual_change.replacer(path, overview)
            dates[manual_change.resto][_new_content["date"]] = _new_content
            new_content = json.dumps(_new_content)

        with open(path, 'w') as f:
            f.write(new_content)
            print("Changed {} to".format(path))
            print(new_content)
            print("-------------------------------------------------------")


def apply_all_menus(output, manual_change, dates):
    """Apply the change to all dates in the applicable range. If no menu exist for a day, it will be created."""
    print(f"Matching all menus from {manual_change.resto} between {manual_change.start} to {manual_change.end}")
    print("====================================================================")

    for applicable_date in manual_change.date_range():
        year = applicable_date.year
        month = applicable_date.month
        day = applicable_date.day
        # Get existing file if it exists
        path = f"{output}/menu/{manual_change.resto}/{year}/{month}/{day}.json"
        try:
            with open(path, 'r') as f:
                menu = json.loads(f.read())
        except IOError:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            menu = {'open': False, 'date': applicable_date.strftime('%Y-%m-%d'), 'meals': [], 'vegetables': []}

        # Apply the changes
        _new_content = manual_change.replacer(path, menu)
        dates[manual_change.resto][_new_content["date"]] = _new_content
        new_content = json.dumps(_new_content)

        with open(path, 'w+') as f:
            f.write(new_content)
            print("Changed {} to".format(path))
            print(new_content)
            print("-------------------------------------------------------")


def main(output):
    to_apply = create_changes(output)

    dates = defaultdict(dict)
    for manual_change in to_apply:
        if manual_change.all_days:
            apply_all_menus(output, manual_change, dates)
        else:
            apply_existing_menus_only(output, manual_change, dates)

    for manual_change in to_apply:
        print("Rebuilding overviews")
        match_glob = manual_change.get_overview_glob()
        print(match_glob)
        print("===============================================================")
        overviews = glob.glob(f"{output}/{match_glob}")

        # For each overview that should be rebuild
        for path in overviews:
            print("Rebuilding {}".format(path))
            print("-----------------------------------------------------------")
            new_overview = []
            with open(path, 'r') as f:
                overview = json.loads(f.read())

            last_day = None
            # If the date is modified, replace it
            for day in overview:
                if day["date"] in dates[manual_change.resto]:
                    print(f"Updating {day['date']}")
                    new_overview.append(dates[manual_change.resto][day["date"]])
                else:
                    print(f"Keeping {day['date']}")
                    new_overview.append(day)
                last_day = day["date"]

            # We want to provide at least ten days in the future.
            to_add = max(OVERVIEW_COUNT - len(overview), 0)
            if last_day:
                last_day = datetime.strptime(last_day, '%Y-%m-%d').date()
            for day in dates[manual_change.resto]:
                dday = datetime.strptime(day, '%Y-%m-%d').date()
                if ((last_day and dday <= last_day) or (last_day is None and dday < date.today())) or to_add <= 0:
                    continue
                new_overview.append(dates[manual_change.resto][day])
                to_add -= 1

            with open(path, 'w') as f:
                f.write(json.dumps(new_overview))
                print("Wrote updated overview")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Apply manual corrections to scraped menu')
    parser.add_argument('output', help='Folder of v2 output.')
    args = parser.parse_args()

    main(args.output)

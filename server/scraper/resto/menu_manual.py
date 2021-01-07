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
        :param resto: Which restaurant(s) to apply to.
        :param all_days: If the message should be added for all weekdays in the range. If false (the default), the
        changes will only be applied if there already is a menu for the day.
        """
        self.replacer = replacer
        self.start = start
        self.end = end
        self.resto = resto
        if isinstance(self.resto, str):
            self.resto = [self.resto]
        assert isinstance(self.resto, list)
        self.all_days = all_days

    def is_applicable(self, menu_date):
        """Check if this change is applicable to the given date"""
        return self.start <= menu_date <= self.end

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
              "De sluiting loopt zeker tot en met 7 juni 2020."
    return {
        "message": message,
        "date": original["date"],
        "open": False
    }


def corona_sluiting_en(_path, original):
    message = "The student restaurants and cafeterias will be closed as from Monday 16 March 2020. " \
              "Ghent University is taking this measure to minimize the further spreading of the coronavirus. " \
              "The closure will certainly last until 7 June 2020."
    return {
        "message": message,
        "date": original["date"],
        "open": False
    }


def corona_heropening_nl(_path, original):
    message = "Ter plaatse eten is momenteel niet mogelijk; enkel takeaway van een beperkt aanbod. De coronamaatregelen blijven van kracht! " \
              "Resto Dunant, Coupure en Sterre en van cafetaria UZ Gent en Boekentoren zijn opnieuw open. " \
              "Bij de start van het academiejaar volgen de andere locaties."
    return {
        "message": message,
        "date": original["date"],
        "open": True,
        "meals": [{
            "kind": "meat",
            "type": "main",
            "name": "Spaghetti bolognese met kaas",
            "price": "\u20ac 3,60"
        }, {
            "kind": "vegetarian",
            "type": "main",
            "name": "Salad bowl: Caesar",
            "price": ""
        }, {
            "kind": "vegetarian",
            "type": "main",
            "name": "Salad bowl: Tomaat-Mozzarella",
            "price": ""
        }, {
            "kind": "soup",
            "type": "main",
            "name": "Dagsoep",
            "price": ""
        }],
        "vegetables": []
    }


def corona_heropening_en(_path, original):
    message = "The canteen is closed; only takeaway of a reduced offering is possible. The Corona measures remain active! " \
              "Resto Dunant, Coupure & Sterre and cafetaria UZ Gent & Boekentoren are open. " \
              "At the start of the academic year, the other locations will follow."
    return {
        "message": message,
        "date": original["date"],
        "open": True,
        "meals": [{
            "kind": "meat",
            "type": "main",
            "name": "Spaghetti bolognese with cheese",
            "price": "\u20ac 3,60"
        }, {
            "kind": "vegetarian",
            "type": "main",
            "name": "Salad bowl: Caesar",
            "price": ""
        }, {
            "kind": "vegetarian",
            "type": "main",
            "name": "Salad bowl: Tomato-Mozzarella",
            "price": ""
        }, {
            "kind": "soup",
            "type": "main",
            "name": "Soup of the day",
            "price": ""
        }],
        "vegetables": []
    }


def corona_closed_for_now(_path, original):
    message = "Resto Dunant, Coupure en Sterre en van cafetaria UZ Gent en Boekentoren zijn opnieuw open. " \
              "Bij de start van het academiejaar volgen de andere locaties."
    return {
        "message": message,
        "date": original["date"],
        "open": False
    }


def kantienberg_2020(_path, original):
    return {
        "message": "Resto Kantienberg blijft gesloten tijdens academiejaar 2020-2021.",
        "date": original["date"],
        "open": False
    }


def corona_2020_2021_nl(_path, original):
    message = "Door de coronamaatregelen veranderen enkele zaken: ter plaatse eten is niet mogelijk " \
              "(enkel afhalen) en er is een beperkter aanbod."
    original["message"] = message
    return original


def corona_2020_2021_en(_path, original):
    message = "Due to the corona measures, some changes are made: only takeaway is possible " \
              "and the offering is reduced."
    original["message"] = message
    return original


def corona_2020_2021_nl_red(_path, original):
    message = "Enkel afhalen en een beperkter aanbod. De coronamaatregelen blijven van kracht!"
    original["message"] = message
    return original


def corona_2020_2021_cold(_path, original):
    message = "Enkel cafetaria-aanbod en koude meeneemgerechten. De coronamaatregelen blijven van kracht!"
    original["message"] = message
    return original


def corona_2020_2021_en_red(_path, original):
    message = "Due to the corona measures, some changes are made: only takeaway is possible " \
              "and the offering is reduced. " \
              "The restaurants and cafetaria's will remain open in code red."
    original["message"] = message
    return original


def exam_closure_sterre_2020(_path, original):
    message = "Door examens zal de resto gesloten zijn op 4, 15, 18 en 26 januari."
    original["message"] = message
    original["open"] = False
    return original


def exam_closure_dunant_2020(_path, original):
    message = "Door examens zal de resto gesloten zijn op 4, 8, 15, 18, 22, 25 en 29 januari."
    original["message"] = message
    original["open"] = False
    return original


def christmas(_path, original):
    original["message"] = "Naast de UGent-verlofdagen zijn de resto's ook gesloten tijdens de eerste week van de " \
                          "kerstvakantie. "
    original["open"] = False
    return original


def exam_closure_en_2020(_path, original):
    original["message"] = "Resto Sterre and Dunant are closed on some days in January due to exams. Check the site " \
                          "for more details."
    return original


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
            resto=["nl", "nl-sintjansvest", "nl-debrug", "nl-heymans", "nl-kantienberg"],
            start=date(2020, 3, 16),
            end=date(2020, 6, 7),
            all_days=True
        ),
        ManualChange(
            replacer=corona_sluiting_en,
            resto="en",
            start=date(2020, 3, 16),
            end=date(2020, 6, 7),
            all_days=True
        ),
        ManualChange(
            replacer=corona_heropening_nl,
            resto="nl",
            start=date(2020, 9, 7),
            end=date(2020, 9, 20),
            all_days=True
        ),
        ManualChange(
            replacer=corona_heropening_en,
            resto="en",
            start=date(2020, 9, 7),
            end=date(2020, 9, 20),
            all_days=True
        ),
        ManualChange(
            replacer=corona_closed_for_now,
            resto=["nl-debrug", "nl-heymans"],
            start=date(2020, 9, 7),
            end=date(2020, 9, 20),
            all_days=True
        ),
        ManualChange(
            replacer=kantienberg_2020,
            resto="nl-kantienberg",
            start=date(2020, 9, 7),
            end=date(2021, 7, 1),
            all_days=True
        ),
        ManualChange(
            replacer=corona_2020_2021_en,
            resto="en",
            start=date(2020, 9, 21),
            end=date(2020, 10, 18)
        ),
        ManualChange(
            replacer=corona_2020_2021_nl,
            resto=["nl", "nl-debrug", "nl-heymans"],
            start=date(2020, 9, 21),
            end=date(2020, 10, 18)
        ),
        ManualChange(
            replacer=corona_2020_2021_en_red,
            resto="en",
            start=date(2020, 10, 19),
            end=date(2020, 12, 19)
        ),
        ManualChange(
            replacer=corona_2020_2021_nl_red,
            resto=["nl-debrug", "nl-heymans", "nl-sterre", "nl-ardoyen"],
            start=date(2020, 10, 19),
            end=date(2020, 12, 19)
        ),
        ManualChange(
            replacer=corona_2020_2021_cold,
            resto=["nl-coupure", "nl-dunant", "nl-merelbeke"],
            start=date(2020, 11, 28),
            end=date(2020, 12, 31)
        ),
        ManualChange(
            replacer=christmas,
            resto=["nl-debrug", "nl-heymans", "nl-dunant", "nl-coupure", "nl-sterre", "nl-ardoyen", "nl-merelbeke"],
            start=date(2020, 12, 21),
            end=date(2020, 12, 25),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_dunant_2020,
            resto="nl-dunant",
            start=date(2021, 1, 4),
            end=date(2021, 1, 4),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_dunant_2020,
            resto="nl-dunant",
            start=date(2021, 1, 8),
            end=date(2021, 1, 8),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_dunant_2020,
            resto="nl-dunant",
            start=date(2021, 1, 15),
            end=date(2021, 1, 15),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_dunant_2020,
            resto="nl-dunant",
            start=date(2021, 1, 18),
            end=date(2021, 1, 18),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_dunant_2020,
            resto="nl-dunant",
            start=date(2021, 1, 22),
            end=date(2021, 1, 22),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_dunant_2020,
            resto="nl-dunant",
            start=date(2021, 1, 25),
            end=date(2021, 1, 25),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_dunant_2020,
            resto="nl-dunant",
            start=date(2021, 1, 29),
            end=date(2021, 1, 29),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_sterre_2020,
            resto="nl-sterre",
            start=date(2021, 1, 4),
            end=date(2021, 1, 5),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_sterre_2020,
            resto="nl-sterre",
            start=date(2021, 1, 4),
            end=date(2021, 1, 4),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_sterre_2020,
            resto="nl-sterre",
            start=date(2021, 1, 15),
            end=date(2021, 1, 15),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_sterre_2020,
            resto="nl-sterre",
            start=date(2021, 1, 18),
            end=date(2021, 1, 18),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_sterre_2020,
            resto="nl-sterre",
            start=date(2021, 1, 26),
            end=date(2021, 1, 26),
            all_days=True
        ),
        ManualChange(
            replacer=exam_closure_en_2020,
            resto="en",
            start=date(2021, 1, 4),
            end=date(2021, 1, 29),
            all_days=False
        )
    ]


# Actually do things ----------------------------------------------------------

def apply_existing_menus_only(output, manual_change, dates):
    """Apply the change to only existing menus"""
    print(f"Matching existing menus from {manual_change.resto} between {manual_change.start} to {manual_change.end}")
    print("====================================================================")

    for resto in manual_change.resto:
        files = glob.glob(f"{output}/menu/{resto}/*/*/*.json")
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
                dates[resto][_new_content["date"]] = _new_content
                new_content = json.dumps(_new_content)

            with open(path, 'w') as f:
                f.write(new_content)


def apply_all_menus(output, manual_change, dates):
    """Apply the change to all dates in the applicable range. If no menu exist for a day, it will be created."""
    print(f"Matching all menus from {manual_change.resto} between {manual_change.start} to {manual_change.end}")
    print("====================================================================")

    for applicable_date in manual_change.date_range():
        year = applicable_date.year
        month = applicable_date.month
        day = applicable_date.day
        # Get existing file if it exists
        for resto in manual_change.resto:
            path = f"{output}/menu/{resto}/{year}/{month}/{day}.json"
            try:
                with open(path, 'r') as f:
                    menu = json.loads(f.read())
            except IOError:
                os.makedirs(os.path.dirname(path), exist_ok=True)
                menu = {'open': False, 'date': applicable_date.strftime('%Y-%m-%d'), 'meals': [], 'vegetables': []}
    
            # Apply the changes
            _new_content = manual_change.replacer(path, menu)
            dates[resto][_new_content["date"]] = _new_content
            new_content = json.dumps(_new_content)
    
            with open(path, 'w+') as f:
                f.write(new_content)


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
        for resto in manual_change.resto:
            match_glob = f"menu/{resto}/overview.json"
            print(match_glob)
            overviews = glob.glob(f"{output}/{match_glob}")

            # For each overview that should be rebuild
            for path in overviews:
                print(f"Rebuilding {path}")
                new_overview = []
                with open(path, 'r') as f:
                    overview = json.loads(f.read())

                last_day = None
                # If the date is modified, replace it
                for day in overview:
                    if day["date"] in dates[resto]:
                        print(f"Updating {day['date']}")
                        new_overview.append(dates[resto][day["date"]])
                    else:
                        print(f"Keeping {day['date']}")
                        new_overview.append(day)
                    last_day = day["date"]

                # We want to provide at least ten days in the future.
                to_add = max(OVERVIEW_COUNT - len(overview), 0)
                if last_day:
                    last_day = datetime.strptime(last_day, '%Y-%m-%d').date()
                for day in dates[resto]:
                    dday = datetime.strptime(day, '%Y-%m-%d').date()
                    if ((last_day and dday <= last_day) or (last_day is None and dday < date.today())) or to_add <= 0:
                        continue
                    new_overview.append(dates[resto][day])
                    to_add -= 1

                with open(path, 'w') as f:
                    f.write(json.dumps(new_overview))
                    print("Wrote updated overview")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Apply manual corrections to scraped menu')
    parser.add_argument('output', help='Folder of v2 output.')
    args = parser.parse_args()

    main(args.output)

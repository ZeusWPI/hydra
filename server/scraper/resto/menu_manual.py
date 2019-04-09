#!/usr/bin/env python3
import argparse
import glob
import json
import re
from collections import defaultdict

from datetime import date


# Common things ---------------------------------------------------------------
# See main at bottom
class ManualChange:
    """
    Apply a change to a range of menus in the v2 API. v1 is not supported.
    """

    def __init__(self, replacer, resto, start, end):
        """
        :param replacer: The function that will do the replacements. It will receive the path to the file and the
        original menu.
        :param start: The start date (inclusive).
        :param end: The end date (inclusive).
        :param resto: Which resto to apply to.
        """
        self.replacer = replacer
        self.start = start
        self.end = end
        self.resto = resto

    def is_applicable(self, menu_date):
        """Check if this change is applicable to the given date"""
        return self.start <= menu_date <= self.end

    def get_overview_glob(self):
        """Get relative glob for the overview"""
        return f"menu/{self.resto}/overview.json"


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
    original['message'] = ("Tijdens de paasvakantie zijn Resto Campus Sterre en Resto Campus Merelbeke geopend als "
                           "cafetaria.")
    original['open'] = True
    return original


def paasvakantie19_en(_path, original):
    original['message'] = ("During the Easter Holiday, Resto Campus Sterre and Resto Campus Merelbeke are open as "
                           "cafetaria.")
    original['open'] = True
    return original


def paasvakantie19_brug(_path, original):
    # Simply add a message, keep the rest
    original['message'] = "Tijdens de paasvakantie is De Brug enkel 's middags geopend."
    return original


# Werken in De Brug waardoor de resto gesloten is.
def werken_brug19_replacer(_path, original):
    message = ('De Brug is voor werken gesloten van 20 mei tot 20 september 2019 voor verbouwingswerken. '
               'Vanaf volgend academiejaar zal de nieuwe ingang op het studentenplein in gebruik genomen worden.'
               '\n\nTijdens de sluiting neemt resto Kantienberg de functies en het aanbod van de Brug over, zoals '
               'de avondopening.')
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
        # Werken aan De Brug from 20/05/2019 - 20/09/2019
        ManualChange(
            replacer=werken_brug19_replacer,
            resto="nl-debrug",
            start=date(2019, 5, 20),
            end=date(2019, 9, 20)
        ),
    ]


# Actually do things ----------------------------------------------------------


def main(output):
    to_apply = create_changes(output)
    dates = defaultdict(dict)
    for manual_change in to_apply:
        print(f"Matching menus from {manual_change.resto} between {manual_change.start} to {manual_change.end}")
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

            # If the date is modified, replace it
            for day in overview:
                if day["date"] in dates[manual_change.resto]:
                    print(f"Updating {day['date']}")
                    new_overview.append(dates[manual_change.resto][day["date"]])
                else:
                    print(f"Keeping {day['date']}")
                    new_overview.append(day)

            with open(path, 'w') as f:
                f.write(json.dumps(new_overview))
                print("Wrote updated overview")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Apply manual corrections to scraped menu')
    parser.add_argument('output', help='Folder of v2 output.')
    args = parser.parse_args()

    main(args.output)

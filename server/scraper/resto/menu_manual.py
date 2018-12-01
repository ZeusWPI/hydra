from string import Template

import glob
import json

# Common things ---------------------------------------------------------------
# See main at bottom

RESTO_PATH = "resto"


class ManualChange():
    """
    API v1 is not supported
    """

    def __init__(self, replacer, api="*", year="*", resto="*", month="*", day="*"):
        """
        All parameters except the replacer should be a glob pattern that matches
        the respective attribute in the file path. Wildcards are allowed.
        See: https://docs.python.org/3/library/fnmatch.html
        e.g.:
          month=*
          month=6
          month=[0-9]
        """
        self.replacer = replacer
        self.api = api
        self.year = year
        self.resto = resto
        self.month = month
        self.day = day

    def to_glob(self):
        api2_template = Template("{}/$api/menu/$resto/$year/$month/$day".format(RESTO_PATH))
        return api2_template.substitute(self.to_dict())

    def get_overview_glob(self):
        api2_template = Template("{}/$api/menu/$resto/overview.json".format(RESTO_PATH))
        return api2_template.substitute(self.to_dict())

    def to_dict(self):
        return dict(
            api=self.api,
            resto=self.resto,
            year=self.year,
            month=self.month,
            day=self.day
        )

# Restjes Maand Zomer 18 ------------------------------------------------------
# Sint-Jansvest die geen menu meer serveert, alleen overschotten.


def restjesmaand18_replacer(_path, original):
    # original: {"date": "2018-06-14", "meals": [], "open": false, "vegetables": []}

    name = ("Om voedseloverschotten op het einde van het academiejaar te beperken, "
            "kunnen we geen dagmenu presenteren. "
            "Ga langs en laat je verrassen door ons keukenpersoneel.")

    return {
        "date": original["date"],
        "meals": [{
            "kind": "meat",
            "name": name,
            "price": "???",
            "type": "main",
        }],
        "open": True,
        "vegetables": [],
    }


restjesmaand18 = ManualChange(
    api="2.0",
    year="2018",
    resto="nl-sintjansvest",
    month="6",
    day="*",
    replacer=restjesmaand18_replacer)

# Actually do things ----------------------------------------------------------


def main():
    to_apply = [
        restjesmaand18,
    ]
    dates = dict()
    for manual_change in to_apply:
        match_glob = manual_change.to_glob()
        print("Using glob to match: {}".format(match_glob))
        print("===============================================================")
        files = glob.glob(match_glob)
        for path in files:
            with open(path, 'r') as f:
                overview = json.loads(f.read())
                _new_content = manual_change.replacer(path, overview)
                dates[_new_content["date"]] = _new_content
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
        overviews = glob.glob(match_glob)

        # For each overview that should be rebuild
        for path in overviews:
            print("Rebuilding {}".format(path))
            print("-----------------------------------------------------------")
            new_overview = []
            with open(path, 'r') as f:
                overview = json.loads(f.read())

            # If the date is modified, replace it
            for day in overview:
                if day["date"] in dates:
                    print("Updating {}".format(day["date"]))
                    new_overview.append(dates[day["date"]])
                else:
                    print("Keeping {}".format(day["date"]))
                    new_overview.append(day)

            with open(path, 'w') as f:
                f.write(json.dumps(new_overview))
                print("Wrote updated overview")


if __name__ == '__main__':
    main()

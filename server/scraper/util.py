import os
import re
import sys
import json


def parse_money(moneystring):
    # Sometimes 0 is O :(
    moneystring = moneystring.replace("O", "0")
    return re.sub("[^0-9,]", "", str(moneystring)).replace(',', '.')


def stderr_print(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def write_json_to_file(obj, path):
    """
    Write an object to JSON at the specified path.
    """
    directory = os.path.dirname(path)
    os.makedirs(directory, exist_ok=True)
    with open(path, mode='w') as f:
        json.dump(obj, f, sort_keys=True)


def split_price(meal):
    if "-" in meal:
        price = meal.split('-')[-1].strip()
        name = '-'.join(meal.split('-')[:-1]).strip()
        return name, price
    elif "€" in meal:
        meal, price = meal.split("€")
        return meal.strip(), price
    else:
        return meal.strip(), ""

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


def move_junk_from_price_to_name(name, price):
    """
    >>> name = "veggie: Penne pomodori mascarpone"
    >>> price = '€ 4,65 (not in resto Campus Dunant and resto Campus Merelbeke)'
    >>> move_junk_from_price_to_name(name, price)
    ('veggie: Penne pomodori mascarpone (not in resto Campus Dunant and resto Campus Merelbeke)', '€ 4,65')
    >>> price = '€ 4,65'
    >>> move_junk_from_price_to_name(name, price)
    ('veggie: Penne pomodori mascarpone', '€ 4,65')
    """
    junk_after = len("€ x4,65")
    new_price = price[0:junk_after].strip()
    if price[junk_after:]:
        new_name = name + " " + price[junk_after:]
    else:
        new_name = name
    return new_name, new_price


def split_price(meal):
    if "-" in meal:
        price = meal.split('-')[-1].strip()
        name = '-'.join(meal.split('-')[:-1]).strip()
        name, price = move_junk_from_price_to_name(name, price)
        return name, price
    elif "/" in meal and "€" in meal:
        price = meal.split('/')[-1].strip()
        name = '/'.join(meal.split('/')[:-1]).strip()
        name, price = move_junk_from_price_to_name(name, price)
        return name, price
    elif "€" in meal:
        meal, price = meal.split("€")
        return meal.strip(), price
    else:
        return meal.strip(), ""


if __name__ == "__main__":
    import doctest
    doctest.testmod()

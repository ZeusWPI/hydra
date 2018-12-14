import os
import re
import sys
import json


def parse_money(moneystring):
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

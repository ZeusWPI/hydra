import re
import sys


def parse_money(moneystring):
    return re.sub("[^0-9,]", "", str(moneystring)).replace(',', '.')


def stderr_print(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

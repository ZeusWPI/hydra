import re


def parse_money(moneystring):
    return re.sub("[^0-9,]", "", str(moneystring)).replace(',', '.')
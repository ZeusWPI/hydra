import re


def parse_money(money_string):
    return re.sub("[^0-9,]", "", str(money_string)).replace(',', '.')

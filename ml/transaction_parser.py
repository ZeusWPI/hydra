# Parses raw transaction data into a Transaction class
import datetime
import json
import logging
import string

import pandas as pd
import numpy as np

from typing import NamedTuple, List, Optional

from crowdinator import Transaction, Types


class MenuMeal(NamedTuple):
    kind: str
    name: str
    price: str
    type: str


class Menu(NamedTuple):
    meals: List[MenuMeal]
    vegetables: List[str]


def parse_resto_data(resto: str, date: datetime.date, root: str) -> Optional[Menu]:
    """
    Parses the menu data for a certain resto on a certain date.
    :param resto: The resto to use.
    :param date: The date to query.
    :param root: The root folder for the data files.
    """

    filename = f"{root}/{resto}/{date.year}/{date.month}/{date.day}.json"
    logging.debug(f"Looking for resto file {filename}")

    try:
        with open(filename, 'r') as file:
            data = json.load(file)
            if 'closed' in data and data['closed']:
                raise Exception(f'Resto was closed on {date}')
            meals = [MenuMeal(**x) for x in data['meals']]
            return Menu(meals, data['vegetables'])
    except FileNotFoundError:
        logging.debug(f'File for {date} not found. Perhaps there was no menu?')
        return None


def parse_transactions(transactions: pd.DataFrame, resto: str, root: str) -> List[Transaction]:
    """
    Create a list of transactions, where each transaction represents a customer. (Note that this is on a best efforts
    base)
    :param transactions: The raw transactions.
    :param resto: Which resto the transactions are for.
    :param root: Root folder of the menu data.
    """
    grouped = transactions.groupby(['timestamp'])

    logging.info(f"Grouped transactions into groups")

    grouped_transactions = []

    skipped = set()

    for (timestamp, data) in grouped:
        items = data['description']
        if isinstance(timestamp, pd.Timestamp):
            timestamp = timestamp.to_pydatetime()

        # Get the menu for the day.
        menu = parse_resto_data(resto, timestamp.date(), root)
        if menu is None:
            skipped.add(timestamp.date())
            continue
        all_types = [convert_purchase_to_meal(menu, trans) for trans in items]
        valid_types = [x for x in all_types if x is not None]
        grouped_transactions.append(Transaction(timestamp, valid_types))

    if skipped:
        logging.warning(f'Skipped {len(skipped)} days, because there was no menu: {skipped}')

    logging.info(f"Completed transaction parsing")
    return grouped_transactions


# Known non-food items.
# TODO: can we use "meeneemtoeslag" as indicator? Perhaps just not count the whole order for that person.
NON_FOOD_ITEMS = {'onbekend', 'drinkbus', 'waterbeker', 'toeslag', 'toeslag meeneem maaltijdsoep', 'koude saus',
                  'toeslag meeneem basissoep', 'keepcup', 'meeneembeker', 'supplement', 'botertje', 'consumptie € 2,00',
                  'consumptie € 1,00', 'toeslag meeneem', 'forfait 1'}

# Suffixes we should remove from the name before processing
DELETABLE_SUFFIXES = ['meeneemversie', 'fair trade', 'provençal', 'asc', 'acs', 'msc', 'gap', 'klein', 'kl', 'vettaks',
                      'xl', 'veg veg', 'groot', 'delight', 'soepsoep', 'gl gap', 'global', 'global gap', 'ggap', 'g',
                      'gl', '1l', '33cl', '25cl']

DELETABLE_PREFIXES = ['klein', 'kl', 'meeneemversie']

DESSERTS = {'chocomousse', 'fruit', 'muffin', 'oikos griekse yoghurt aardbei', 'chocoladekoek', 'rijstdessert vanille',
            'soya dessert', 'vitalinea fruityoghurt', 'ijs', 'worstenbroodje', 'tiramisu', 'muffin met chocolade',
            'oikos griekse yoghurt passievrucht', 'pudding', 'speculoosmousse', 'brownie', 'puddin', 'notenkoek',
            'koffiekoek ronde suisse', 'boterkoek met rozijnen', 'gesuikerde donut', 'croissant hamkaas', 'croissant',
            'acht met crème', 'dessert extra snelverkoop', 'koffiekoek chococrème', 'dessert basis snelverkoop'}

VEGETABLES = {'normale portie warme groenten', 'normale portie koude groenten', 'salad bowl',
              'dagelijks wisselend aanbod in salad bar', 'salad bowl bord', 'makreelsalade',
              'extra portie warme groenten', 'extra portie koude groenten', 'eiersla'}

SIDE = {'garnaalkroketten', 'zetmeel', 'frietenkroketten extra', 'zetmeel extra', 'kaaskroketten',
        'vettaks frieten  kroketten', 'garnaalkroketten'}

SANDWICHES = {'toscane', 'hoevebroodje', 'tomaat mozarella', 'préparé', 'maison', 'gerookte zalm kruidenkaas',
              'martino', 'brie', 'kip curry', 'kaas', 'kruidenkaas', 'ecologisch', 'ham', 'gezond', 'croque ugent',
              'houthakkersbrood', 'ceasar', 'argenteuil'}

DRINKS = {'water bruis', 'fanta', 'water plat', 'cola zero', 'tropical', 'pils', 'fruitsap', 'nestea', 'chocomelk',
          'coca cola', 'finley pompelmoesbloedsinaasappel', 'water plat pet', 'cola light', 'rode wijn', 'fuze tea',
          'bionade gembersinaas', 'finley citroenvlierbloesem', 'bionade vlierbessen', 'cola life pet', 'sprite',
          'witte wijn', 'cola', 'bionade kruiden', 'warme chocomelk', 'koffie'}

SOUP = {'basissoep', 'maaltijdsoep', 'soepbroodje', 'soep kleine portie', 'maaltijdsoep kleine portie'}

FRUIT = {'fruit basis', 'fruit extra'}

# Some special menu items we classify as main course, but cannot be extracted from the menu.
# Also used to correct wrong menu items: sometimes the UGent provides wrong menu items.
MAIN = {'koude schotel vegetarisch', 'spaghetti vegetarisch', 'lasagne', 'varkensgoulash', 'pangasius gratino',
        'ontbijt', 'spaghetti bolognaise', 'thaise wokschotel met kip', 'scholfilet gepaneerd', 'wienerschnitzel',
        'balletjes in tomatensaus', 'scholfilet', 'kabeljauwsticks', 'taartje brieappel', 'kip tikka masala',
        'zalmsteak gratino', 'gierstkaas schnitzel', 'pic nic', 'tomaatmozzarella taartje', 'kabeljauwsalade',
        'ardeens gebraad', 'tortellini vier kazen', 'kipschnitzel italiano', 'crumble van kabeljauw', 'swiss steak',
        'tongrolletjes thermidor', 'mimosaburger', 'gegrilde hoki', 'tomaat met tofuvulling', 'seizoensburger',
        'courgette met seitanvulling', 'toscaans kalkoenlapje', 'kipfilet', 'quiche mediteranné', 'veggie loempia',
        'quiche met geitenkaas en walnoot', 'hocki meunière', 'fair trade burger', 'alaska pollack gepaneerd', 'heek',
        'seacrunch van kabeljauw', 'gegrilde hocki', 'courgette met sojavullin', 'lasagne mozarella', 'blinde vink',
        'tomaat met tofuvullin', 'courgette met seitanvullin', 'veggie stoofpotje', 'penne met groentenballetjes',
        'pangasius gepaneerd', 'quiche mediteranné', 'quiche met geitenkaas en walnoot', 'veggie worst', 'volauvent',
        'couscous falafelschotel', 'haasje van pangasius', 'konijnenburger', 'oosterse falafel schotel', 'veggie gyros',
        'kabeljauw in saffraansaus', 'gehaktstammetje in spinazieroom', 'groentenstrüdel', 'gemarineerde zalmsteak',
        'lasagne florentine', 'pangasiusrolletjes in  kreeftensaus', 'haasje van kabeljauw', 'kalkoen stoofpotje',
        'tomaat met seitanvullin', 'pangasius op oosterse wijze', 'varkenslapje', 'haasje koolvis', 'tiroler schnitzel',
        'couscous bonenschotel', 'veggie reepjes stroganoff', 'trulli met paksoi', 'kalkoen cordon bleu', 'kalkoenpavé',
        'quorn cordon bleu', 'kipbil gebakken', 'pasta met olijf', 'gevulde paprika', 'kipbil in jagersaus',
        'kiptournedos', 'gehaktbrood', 'kalkoengebraad', 'gentse stoverij', 'boulet bicky', 'hamrolletjes met witloof',
        'groentekrustie', 'champignon à la grecque', 'kipschnitzel hawai', 'varkensgebraad', 'rundhamburger',
        'oostends vispannetje', 'veggiebereiding zuurzoet', 'haasje van koolvis', 'ossentong in madeirasaus',
        'rundhamburger', 'duo van zalm en koolvis', 'groentekrustie', 'chili  con carne met mais', 'braadworst',
        'heekfilet met tomaat en basilicum', 'veggie burger', 'volauveggie', 'orloffschijf', 'visfilet met amandel',
        'toast mediterrané', 'macaroni', 'kinowaburger', 'ravioli pesto', 'quorn bereidin', 'kaasburger met bloemkool',
        'koolvis met tapenade', 'zalmstaart', 'lente ovenschotel', 'ravioli verdura', 'sojaballetjes', 'zalmstaart',
        'kippenhaasjes in roze pepersaus', 'kippenboomstammetje', 'chili sin carne', 'keftaballetjes in tomatensaus',
        'mighty mushroom burger', 'koolvis met tapenade', 'quinoa groentepan', 'alaska pollak italiano', 'nasirol',
        'emmental burger', 'cordon bleu van pladijs', 'moussaka met seitan', 'vleesbrochette', 'hazelnootburger',
        'zuiderse farfalle', 'zwamburger', 'rundsteak', 'koude schotel vleesvis', 'vissalade', 'kip op zijn oosters'}


def sanitize_name(original: str) -> str:
    data = original.lower()
    data = data.translate(str.maketrans('', '', string.punctuation))
    data = data.strip()

    potential_suffix = True
    while potential_suffix:
        potential_suffix = False
        for suffix in DELETABLE_SUFFIXES:
            data = data.strip()
            if data.endswith(suffix):
                potential_suffix = True
                logging.debug(f'Stripping {suffix} from raw data {data}')
                data = data[:-len(suffix)].strip()

    potential_prefix = True
    while potential_prefix:
        potential_prefix = False
        for prefix in DELETABLE_PREFIXES:
            data = data.strip()
            if data.startswith(prefix):
                potential_prefix = True
                logging.debug(f'Stripping {prefix} from raw data {data}')
                data = data[len(prefix):].strip()

    return data


def convert_purchase_to_meal(menu: Menu, raw_data: str) -> Optional[Types]:
    """
    Match a raw description to a type. This function uses the menu data to improve lookup chances. If a known non-food
    item is encountered, None is returned. If the type cannot be determined unexpectedly, an error is thrown.

    :param menu: The menu for the date and location the raw data is from.
    :param raw_data: The raw description string as provided by the data.
    :return: A type if it was matched. If it is None, it should be discarded.
    """

    data = sanitize_name(raw_data)

    # Check for non-food
    if data in NON_FOOD_ITEMS:
        logging.debug(f'{raw_data} was recognized as non-food')
        return None

    if data in DESSERTS:
        logging.debug(f'{raw_data} was recognized as dessert')
        return Types.DESSERT

    if data in SANDWICHES:
        logging.debug(f'{raw_data} was recognized as sandwich')
        return Types.SANDWICH

    if data in VEGETABLES:
        logging.debug(f'{raw_data} was recognized as vegetable')
        return Types.VEGETABLE

    if data in SOUP:
        logging.debug(f'{raw_data} was recognized as soup')
        return Types.SOUP

    if data in FRUIT:
        logging.debug(f'{raw_data} was recognized as fruit')
        return Types.FRUIT

    if data in DRINKS:
        logging.debug(f'{raw_data} was recognized as drink')
        return Types.DRINKS

    if data in SIDE:
        logging.debug(f'{raw_data} was recognized as side stuff, but is ignored for now')
        return None

    menu_items = []
    for meal in menu.meals:
        new_meal = MenuMeal(meal.kind, sanitize_name(meal.name), meal.price, meal.type)
        menu_items.append(new_meal)
    filtering = (x for x in menu_items if data in x.name or x.name in data)
    matched = next(filtering, None)
    if matched:
        logging.debug(f'{raw_data} was recognized in menu as {menu}')
        if matched.kind == 'soup':
            return Types.SOUP
        elif matched.type == 'main':
            return Types.MAIN
        else:
            logging.error(f"Could not determine type of {matched}, menu was: {menu}")

    if data in MAIN:
        logging.debug(f'{raw_data} was recognized as special main course')
        return Types.MAIN

    logging.error(f'"{data}" (raw: {raw_data}) could not be matched, menu for the day was: {menu}')
    return None

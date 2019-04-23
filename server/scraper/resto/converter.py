# Utility to convert from one API format to another
# Note: this is not part of the scraper; as such it is not run regularly.
# This file uses internals of the resto scraper; these might change an this file might not be up to date.
import argparse
import glob
import os
import json
import sys

from datetime import datetime
from collections import defaultdict

sys.path.append('.')
from menu import write_1_0, write_2_0

vissen = ["Aal",
          "Adderzeenaald",
          "Adelaarsrog",
          "Alaskakoolvis",
          "Alpinotandbaars",
          "Alver",
          "Ansjovis",
          "Arendskoprog",
          "Bahamazaaghaai",
          "Ballonegelvis",
          "Bandeng",
          "Baracuda",
          "Barbeel",
          "Beekforel",
          "Beekprik",
          "Beekridder",
          "Bermpje",
          "Bezemstaartlipvis",
          "Bittervoorn",
          "Blankvoorn",
          "Blauwband",
          "Blauwbandpapegaaivis",
          "Blauwkeeltje",
          "Blauwneus",
          "Blauwrugeenhoornvis",
          "Blauwvintrekkervis",
          "Blauwvlekfluitvis",
          "Blei",
          "Blobvis",
          "Bokvis",
          "Bonito",
          "Bot",
          "Botervis",
          "Braam",
          "Braamhaai",
          "Brakwatergrondel",
          "Brasem",
          "Bruid van de zee",
          "Bultkopvleermuisvis",
          "Chinookzalm",
          "Chocoladehaai",
          "Citroenbarbeel",
          "Citroenstekelmakreel",
          "Congeraal",
          "Dikkopje",
          "Diklipharder",
          "Diklipzeebrasem",
          "Dolfijnvis",
          "Donkervinbarracuda",
          "Doornhaai",
          "Draadvinkardinaalbaars",
          "Driebandkoraalvlinder",
          "Drievlekkenjuffertje",
          "Dubbelzadelbarbeel",
          "Dunlipharder",
          "Dwergbolk",
          "Dwergtarbot",
          "Dwergtong",
          "Dwergtonijn",
          "Eekhoornvis",
          "Elft",
          "Elrits",
          "Evervis",
          "Forelbaars",
          "Fregatmakreel",
          "Gaffelkabeljauw",
          "Geelbekmurene",
          "Geelbuikjuffertje",
          "Geelmaskerkeizervis",
          "Geelstaart",
          "Geelstaarthamletbaars",
          "Geelvinbarbeel",
          "Geelvinstraatveger",
          "Geelvintonijn",
          "Geep",
          "Giebel",
          "Girelle",
          "Gitaarrog",
          "Glasgrondel",
          "Goerami",
          "Golfrog",
          "Gordelkardinaalbaars",
          "Gorgoondwerggrondel",
          "Goudbrasem",
          "Goudgrondel",
          "Goudharder",
          "Goudmakreel",
          "Goudvis",
          "Graskarper",
          "Griet",
          "Grondel",
          "Grootdoorneekhoornvis",
          "Grootkopkarper",
          "Grootoogbaarzen",
          "Grootoogstraatveger",
          "Grootoogtonijn",
          "Grootvinhaai",
          "Guppy",
          "Halfmaanvlindervis",
          "Haring",
          "Haringhaai",
          "Harnasmannetje",
          "Heek",
          "Heilbot",
          "Helmpoon",
          "Hertogsvis",
          "Hondshaai",
          "Hondstong",
          "Hondsvis",
          "Horsmakreel",
          "Houting",
          "Kaardrog",
          "Kabeljauw",
          "Kardinaalbaars",
          "Karper",
          "Kathaai",
          "Keilrog",
          "Keizersvis",
          "Keizersvissen",
          "Kleinbekbaars",
          "Kleinkopzuignapvis",
          "Kleinooghamerhaai",
          "Kleinoogrog",
          "Kleintandzandtijgerhaai",
          "Kliplipvis",
          "Knorhanen",
          "Knorrepos",
          "Koekoeksrog",
          "Koekopvis",
          "Konijnvissen",
          "Koning van de poon",
          "Koningsvis",
          "Koolvis",
          "Koornaarvis",
          "Kopvoorn",
          "Koraalvlinders",
          "Kortvingrootoogbaars",
          "Kroonkoraalvlinder",
          "Kwabaal",
          "Langneusdoornhaai",
          "Langvinvleermuisvis",
          "Lantaarnvis",
          "Laxeervis",
          "Lemargo",
          "Leng",
          "Lepelsteur",
          "Lettervijlvis",
          "Lichtvlekstraatveger",
          "Lierstaartlipvis",
          "Lodde",
          "Lom",
          "Lompje",
          "Loodsmannetje",
          "Luipaardgrondel",
          "Luipaardtrekkervis",
          "Maagdslaapgrondel",
          "Maanstaartjuweelbaars",
          "Maanvis",
          "Mahoniesnapper",
          "Makreel",
          "Makreelgeep",
          "Makreelhaai",
          "Manta",
          "Marene",
          "Markiezinnetje",
          "Maskereenhoornvis",
          "Maskerkogelvis",
          "Maskerkoraalvlinder",
          "Maskerwimpelvis",
          "Meerval",
          "Melkhaai",
          "Midaskamtandslijmvis",
          "Middellandsezeeknorvis",
          "Middellandsezeeleng",
          "Moeraal",
          "Monniksvis",
          "Nalolokamtandslijmvis",
          "Napoleonvis",
          "Nassau(tand)baars",
          "Net-egelvis",
          "Netzeenaald",
          "Neusbultpapegaaivis",
          "Oblada",
          "Ombervis",
          "Oogvlekkoraalvlinder",
          "Oogvleklipvis",
          "Oogvlekrifwachter",
          "Oorsardientje",
          "Oranjelijnenkardinaalbaars",
          "Oranjevleklipvis",
          "Pagrus",
          "Paling",
          "Panterbot",
          "Pantersidderrog",
          "Parelmurene",
          "Pauwlipvis",
          "Pauwoogkeizersvis",
          "Pelser",
          "Picassotrekkervis",
          "Pijlstaartrog",
          "Pincetvis",
          "Pitvis",
          "Pollak",
          "Poolkabeljauw",
          "Pos",
          "Puitaal",
          "Regenboogforel",
          "Reuzenbekhaai",
          "Reuzenhaai",
          "Reuzenkardinaalbaars",
          "Reuzenkogelvis",
          "Reuzenmurene",
          "Rietvoorn",
          "Rifhagedisvis",
          "Rivierdonderpad",
          "Rivierharing",
          "Rivierprik",
          "Rodezeeanemoonvis",
          "Rodezeebarbeel",
          "Rodezeedoktersvis",
          "Rodezeefuselier",
          "Rodezeejuffertje",
          "Rodezeetandbaars",
          "Rodezeetrekkervis",
          "Rodezeewimpelvis",
          "Rodezeewrakbaars",
          "Roestnekpapegaaivis",
          "Roodbaars",
          "Roodbekgrondel",
          "Roodstreepbarbeel",
          "Roodstreepeekhoornvis",
          "Roodtandtrekkervis",
          "Roodvlektandbaars",
          "Sardine",
          "Schaakbordlipvis",
          "Schar",
          "Scharrentong",
          "Schelvis",
          "Schemerhaai",
          "Scherpsnuitrog",
          "Schol",
          "Schommelvoorhoofdsvinvis",
          "Schoolmeester",
          "Schoolwimpelvis",
          "Schorpioenvis",
          "Schriftbaars",
          "Schurftvis",
          "Sergeant-majoorvis",
          "Seriola",
          "Serpeling",
          "Sidderrog",
          "Sikkeltrekkervis",
          "Sjerpenpseudosnapper",
          "Slakdolf",
          "Slijmvis",
          "Slipvis",
          "Smelt",
          "Snappers",
          "Sneep",
          "Snoek",
          "Snoekbaars",
          "Snotolf",
          "Spiegelrog",
          "Spiering",
          "Spitssnuitkoraalklimmer",
          "Spitssnuitlipvis",
          "Spitssnuitzevenkieuwshaai",
          "Sprot",
          "Staartvlekgrondel",
          "Staartvlekzandbaars",
          "Steenbolk",
          "Steenvis",
          "Stekelrog",
          "Sterrog",
          "Steur",
          "Stierhaai",
          "Stomkophaai",
          "Straatvegers",
          "Symbiosegrondels",
          "Tarbot",
          "Tarpoen",
          "Tijgerhaai",
          "Tijgerkardinaalbaars",
          "Tolhaai",
          "Tong",
          "Tongschar",
          "Tonijn",
          "Trekkervis",
          "Trekzalm",
          "Trompetvis",
          "Tweekleurenkamtandslijmvis",
          "Vetje",
          "Vijflijnenkardinaalbaars",
          "Vijfvlek-lipvis",
          "Vioolkoptorpedobaars",
          "Vlaggenbaarsje",
          "Vlagzalm",
          "Vleermuisvis",
          "Vleet",
          "Vorskwab",
          "Voshaai",
          "Vuurpijlvis",
          "Walvishaai",
          "Wangstreeplipvis",
          "Wangvlekkardinaalbaars",
          "Wierschorpioenvis",
          "Wijting",
          "Winde",
          "Winterbot",
          "Witborstdoktersvis",
          "Witkraagkoraalvlinder",
          "Witpuntdrievin",
          "Witpuntrifhaai",
          "Wolfskardinaalbaars",
          "Wrakbaars",
          "Wrattensteenvis",
          "Zaagroggen",
          "Zadelvlekspitskopkogelvis",
          "Zandgrondel",
          "Zandkrokodilvis",
          "Zandtijgerhaai",
          "Zandtong",
          "Zandtorpedobaars",
          "Zee-engel",
          "Zeebaars",
          "Zeebrasem",
          "Zeedonderpad",
          "Zeeduivel",
          "Zeeforel",
          "Zeekarper",
          "Zeelt",
          "Zeepaardje",
          "Zeepaling",
          "Zeeprik",
          "Zeerat",
          "Zeesnoek",
          "Zeestekelbaars",
          "Zeewolf",
          "Zeewolven",
          "Zeezwijn",
          "Zeilvis",
          "Zijdehaai",
          "Zilverkarper",
          "Zilverpunthaai",
          "Zilversmelt",
          "Zomervogel",
          "Zonnebaars",
          "Zonnevis",
          "Zwaardvis",
          "Zwartbandkardinaalbaars",
          "Zwartbandslijmvis",
          "Zwartgordelkardinaalbaars",
          "Zwartoogkonijnvis",
          "Zwartooglipvis",
          "Zwartpunthaai",
          "Zwartvinanemoonvis",
          "Zwartvlektoonhaai",
          "Zwartzadelvijlvis",
          "Zwaveljuffertje",
          "Zweepkoraaldwerggrondel",
          "anemoonvis",
          "baars",
          "barracuda",
          "bokvis",
          "buisaal",
          "bultkop",
          "diklipvis",
          "doktersvis",
          "doornhaai",
          "driepuntkeizersvis",
          "duivelsrog",
          "dwergbaars",
          "dwergbot",
          "dwergkoraalduivel",
          "dwergmeerval",
          "dwergtarbot",
          "egelvis",
          "engelvis",
          "fluitbek",
          "glasvis",
          "griet",
          "grondel",
          "grootoogbaars",
          "grouper",
          "haai",
          "hamerhaai",
          "hamletbaars",
          "haring",
          "heek",
          "heilbot",
          "hondshaai",
          "jodenvis",
          "juffertje",
          "kabeljauw",
          "kardinaalbaars",
          "karetschildpad",
          "kathaai",
          "koffervis",
          "kogelvis",
          "konijnvis",
          "koolvis",
          "kopergrootoogbaars",
          "koraalbaars",
          "koraalduivel",
          "koraalklimmer",
          "koraalmeerval",
          "koraalvlinder",
          "krokodilvis",
          "lantaarnvisje",
          "leng",
          "lipvis",
          "makreel",
          "marene",
          "marlijn",
          "meerval",
          "meun",
          "modderkruiper",
          "monniksvis",
          "murene",
          "netmurene",
          "ombervis",
          "oogvlekkoraalvlinder",
          "paling",
          "papegaaivis",
          "pelser",
          "pieterman",
          "pijlstaartrog",
          "pincetvis",
          "poetslipvis",
          "poon",
          "pseudosnapper",
          "raster-koraalvlinder",
          "riddervis",
          "rifbaars",
          "rifhaai",
          "rifwachter",
          "rog",
          "sardien",
          "schar",
          "scheermesvis",
          "schorpioenvis",
          "sidderrog",
          "slakdolf",
          "slangaal",
          "slangkopvis",
          "slijmvis",
          "snapper",
          "snoekbaars",
          "soldatenvis",
          "sprotje",
          "steenvis",
          "stekelbaars",
          "stekelrog",
          "tandbaars",
          "tong",
          "tonijn",
          "torpedobaars",
          "trekkervis",
          "verpleegsterhaai",
          "verpleegstershaai",
          "vijlvis",
          "vis",
          "vlagbaars",
          "vlaggebaars",
          "vleermuisvis",
          "wijting",
          "wimpelvis",
          "witpunthaai",
          "wrakbaars",
          "zalm",
          "zandspiering",
          "zee-engel",
          "zeebarbeel",
          "zeebrasem",
          "zeedonderpad",
          "zeenaald",
          "zeewolf",
          "zesstrepenzeepbaars",
          "zuignapvis"
          ]


def v2_to_internal(menu):
    """Convert a v2 menu object to an internal menu object"""
    if not menu['open']:
        return {'open': False}

    def soup_to_soup(soup):
        return {
            'price': soup['price'],
            'name': soup['name']
        }

    def other_to_other(other):
        return {
            'price': other['price'],
            'name': other['name'],
            'kind': other['kind']
        }

    all_soups = [soup_to_soup(x) for x in menu['meals'] if x['kind'] == 'soup']
    others = [other_to_other(x) for x in menu['meals'] if x['kind'] != 'soup']

    if not others or not all_soups:
        return {'open': False}

    return {
        'open': True,
        "soup": all_soups,
        "vegetables": menu['vegetables'],
        'meat': others
    }


def v1_to_internal(menu):
    """Convert a v1 menu object to an internal menu object"""
    if not menu['open']:
        return {'open': False}

    def estimate_kind(name):
        if 'veg.' in name.lower():
            return 'vegetarian'
        # Try some common fish types
        others = ['viscube', 'visstick', 'vispan', 'vispave', 'vispavé', ' msc ', ' asc ']
        if any(x.lower() in name.lower() for x in vissen + others):
            matched = next(x for x in (vissen + others) if x.lower() in name.lower())
            print(f"Match {name} with {matched}")
            return 'fish'

        return 'meat'

    def other_to_other(meal):
        return {
            'price': meal['price'],
            'name': meal['name'],
            'kind': estimate_kind(meal['name'])
        }

    # Get soups
    soups = [menu['soup']] + [x for x in menu["meat"] if any(y in x['name'].lower() for y in ('soep', 'goulash'))]
    rest = [other_to_other(x) for x in menu["meat"] if x not in soups]

    return {
        'open': True,
        "soup": soups,
        "vegetables": menu['vegetables'],
        'meat': rest
    }


def v2_to_v1(output_v1, output_v2):
    """Convert v2 API to v1 API"""

    week_map = defaultdict(dict)

    filter1 = os.path.join(output_v2, 'menu', 'nl', '**', '[0-9][0-9].json')
    filter2 = os.path.join(output_v2, 'menu', 'nl', '**', '[0-9].json')
    for day_path in glob.glob(filter1, recursive=True) + glob.glob(filter2, recursive=True):
        with open(day_path, 'r') as f:
            menu = json.load(f)
            date = datetime.strptime(menu['date'], "%Y-%m-%d").date()
            year, week, _ = date.isocalendar()
            week_map[(year, week)][date] = v2_to_internal(menu)

    write_1_0(output_v1, {'nl': week_map}, use_existing=False)


def v1_to_v2(output_v1, output_v2):
    """Convert v1 API to v2 API"""
    week_map = defaultdict(dict)

    filter1 = os.path.join(output_v1, 'menu', '**', '[0-9][0-9].json')
    filter2 = os.path.join(output_v1, 'menu', '**', '[0-9].json')
    for day_path in glob.glob(filter1, recursive=True) + glob.glob(filter2, recursive=True):
        with open(day_path, 'r') as f:
            menus = json.load(f)
            for m_date, menu in menus.items():
                date = datetime.strptime(m_date, "%Y-%m-%d").date()
                year, week, _ = date.isocalendar()
                week_map[(year, week)][date] = v1_to_internal(menu)

    write_2_0(output_v2, {'nl': week_map})


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run main resto scraper')
    parser.add_argument('v1', help='Folder for v1 output. Will be created if needed.')
    parser.add_argument('v2', help='Folder for v2 output. Will be created if needed.')
    parser.add_argument('mode', help='Convert what to what', choices=['1to2', '2to1'])
    args = parser.parse_args()

    output_path_v1 = os.path.abspath(args.v1)  # Like realpath
    output_path_v2 = os.path.abspath(args.v2)  # Like realpath

    if args.mode == '2to1':
        v2_to_v1(output_path_v1, output_path_v2)
    elif args.mode == '1to2':
        print(f"WARNING! Converting from v1 to v2 means some data is guessed.")
        v1_to_v2(output_path_v1, output_path_v2)

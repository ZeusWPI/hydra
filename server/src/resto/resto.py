"""
Hydra Aggregated Resto Parser (HARP)

Parses the data from the UGent servers. This module will parse all data:

- Menu data
- Manual adjustments
- Cafetaria
- Sandwiches

Note tha the metadata is static data and available as json file.
"""

from utils import parse_output
from . import cafetaria
from . import resto_manual as overrider
from . import sandwiches
from . import scraper


def main():
    output_directory = parse_output('Resto scraper')

    print('Scraping all the resto menus')
    scraper.main(output_directory)

    # TODO: should this be perhaps defined in a JSON file?
    print('Applying manual changes')
    overrider.main(output_directory)

    print('Eating all the sandwiches')
    sandwiches.main(output_directory)

    print('Finding all the desserts')
    cafetaria.main(output_directory)


if __name__ == "__main__":
    main()

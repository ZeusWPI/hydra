"""
Hydra Aggregated Resto Parser (HARP)

Parses the data from the UGent servers. This module will parse all data:

- Menu data
- Manual adjustments
- Cafetaria
- Sandwiches

Note tha the metadata is static data and available as json file.
"""
import shutil

import resto.cafetaria as cafetaria
import resto.resto_manual as overrider
import resto.sandwiches as sandwiches
import resto.scraper as scraper
from ...src.utils import parse_output


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

    print('Adding metadata')
    meta_directory = '{}/2.0/'.format(output_directory)
    shutil.copy2('meta.json', meta_directory)


if __name__ == "__main__":
    main()

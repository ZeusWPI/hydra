#!/usr/bin/env python3
"""
Check for missing/superfluous logos.
"""
import argparse
import json
import os
import urllib.request

URL = "http://student.ugent.be/hydra/api/3.0/associations.json"


def read_json():
    response = urllib.request.urlopen(URL)
    data = response.read()
    return data.decode('utf-8')


def check(folder):
    data = read_json()
    parsed = json.loads(data)
    all_associations = {x['internal_name'].lower() for x in parsed}

    logo_associations = set()

    for file in os.listdir(folder):
        if file.endswith('.png') or file.endswith('.jpg') or file.endswith('.svg'):
            name, _ = os.path.splitext(file)
            logo_associations.add(name.lower())

    no_logo = all_associations - logo_associations
    no_association = logo_associations - all_associations

    print('Associations present in the API but without logo (MISSING):')
    print(f'\t{no_logo}')
    print('Associations not in the API but with logo (EXTRA):')
    print(f'\t{no_association}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run Schamper scraper')
    parser.add_argument('folder', help='Path of the folder which contains the logos.')
    args = parser.parse_args()
    output_path = os.path.abspath(args.folder)
    check(output_path)
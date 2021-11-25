#!/usr/bin/env python3

import argparse
import os
import requests

from util import write_json_to_file

URL = "http://widgets.lib.ugent.be/library_groups/main.json"

def run(output):
    
    output_path = os.path.abspath(output)  
    os.makedirs(output_path, exist_ok=True)
    
    response = requests.get(URL)
    json_file = response.json()
    write_json_to_file(json_file, output)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run UGent library scraper')
    parser.add_argument('output',                                                                                                               help='Path of the folder in which the output must be written. Will be created if needed.')
    args = parser.parse_args()
    
    try:
        run(args.output)
    except RequestException as error:
        print("Failed to run UGent library scraper", file=sys.stderr)
        print(error, file=sys.stderr)
        sys.exit(1)

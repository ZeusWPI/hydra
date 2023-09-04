#!/usr/bin/env python3
import argparse
import os
import sys
from typing import Union

from bs4 import BeautifulSoup, Tag
from requests import RequestException

# Bad python module system
sys.path.append('..')

from backoff import retry_session
from util import write_json_to_file

URL = "https://www.ugent.be/student/nl/meer-dan-studeren/resto/allergenen"
SKIPPED_ELEMENTS = [
    "vegetarisch",
    "vegan"
]


def get_section_indeces(raw_parts: list[Tag]) -> list[int]:
    return [idx for idx, val in enumerate(raw_parts) if val.name == "h2"]


def parse_section_item(section_item: str) -> Union[dict[str, list[str]], None]:
    """
    Parses strings of the form `food: allergen, allergen, allergen`
    """
    
    if "soep van de dag" in section_item:
        item_name = "Soep van de dag"
        item_allergen_list = section_item
    else:
        item_name, item_allergen_list = section_item.split(":")

    # Sometimes a section will have extra info before the item list,
    # this should not be parsed
    if item_allergen_list == "":
        return None

    item_allergens = list(map(lambda a: a.strip(), item_allergen_list.split(",")))

    # Exclude last item, it is not an allergen but a diet name
    # eg. 'Vegetarian' or 'Vegan'
    return {item_name.lower(): sorted({x.strip(".") for x in item_allergens if x.strip(".") not in SKIPPED_ELEMENTS})}


def make_sections(
        section_indices: list[int], raw_parts: list[Tag]
) -> dict[str, dict[str, list[str]]]:
    sections = dict()

    for meta_idx in range(len(section_indices)):
        header_idx = section_indices[meta_idx]
        section_header = raw_parts[header_idx].get_text(strip=True).lower()

        if section_header == "meer info":
            continue

        assert section_header not in sections

        next_header_idx = (
            section_indices[meta_idx + 1] if meta_idx < len(section_indices) - 1 else -1
        )

        # Get the list of items from this header, up to the next
        # and filter out ones we don't need
        raw_section_items = raw_parts[header_idx + 1: next_header_idx]
        raw_section_items = [x for x in raw_section_items if x.name == "p"]

        sections[section_header] = dict()
        for raw_section_item in raw_section_items:
            section_item = raw_section_item.get_text(strip=True)
            assert section_item is not None

            section_item_map = parse_section_item(section_item)
            if section_item_map is None:
                continue

            sections[section_header] |= section_item_map

    return sections


def parse_allergens():
    raw_html = retry_session.get(URL).text
    soup = BeautifulSoup(raw_html, "html.parser")

    content_div = soup.select_one(
        "article#content #content-core #parent-fieldname-text"
    )
    # Splits the content div into a list of tags
    # The ones we care about are
    #  - h2: name of the food group type
    #  - p: the food itself and its allergens
    content_parts = content_div.find_all(True)

    # Get the indices of the h2 tags so the tag list can be
    # split into sections
    section_indices = get_section_indeces(content_parts)

    sections = make_sections(section_indices, content_parts)

    # for sect_h, sect_i in sections.items():
    #     print(f"\"{sect_h}\":")
    #     for item_h, item_a in sect_i.items():
    #         print(f"\t\"{item_h}\": {item_a}")
    #     print("")

    return sections


def run(output):
    """
    Run the scraper.
    :param output: The output directory for the data.
    """
    output_path = os.path.abspath(output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p
    output_file = os.path.join(output_path, "allergens.json")  # Output file

    result = parse_allergens()
    write_json_to_file(result, output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run allergen scraper and parser")
    parser.add_argument(
        "output",
        help="Path of the folder in which the output must be written. Will be created if needed.",
    )
    args = parser.parse_args()

    try:
        run(args.output)
    except RequestException as error:
        print("Failed to run allergens scraper", file=sys.stderr)
        print(error, file=sys.stderr)
        sys.exit(1)

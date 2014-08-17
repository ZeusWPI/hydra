#!/usr/bin/env python
# encoding: utf-8

"""
Converts a database table dump of all DSA associations (through stdin) to a
json list (through stdout), which the apps can handle.
It's output is supposed to be served through the API.
"""

import csv

KONVENT_MAP = {
    'fk': 'FKCENTRAAL',
    'hk': 'HKCENTRAAL',
    'ik': 'IKCENTRAAL',
    'kultk': 'KULTKCENTRAAL',
    'pfk': 'PFKCENTRAAL',
    'schamper': 'SCHAMPER',
    'sk': 'SKCENTRAAL',
    'urgent': 'URGENT',
    'wvk': 'WVKCENTRAAL'
}


def jsonify(db_line):
    entry = {
        'internalName': db_line[2],
        'parentAssociation': KONVENT_MAP[db_line[6]]
    }
    if db_line[5] == 'NULL':
        entry['displayName'] = db_line[3]
    else:
        entry['displayName'] = db_line[5]
        entry['fullName'] = db_line[3]
    return entry


def in_vkv(db_line):
    return db_line[6] in KONVENT_MAP


def parse_and_sort(file_):
    reader = csv.reader(file_, delimiter=';')
    return sorted((jsonify(assoc) for assoc in reader if in_vkv(assoc)),
                  key=lambda x: (x['parentAssociation'], x['internalName']))


if __name__ == '__main__':
    import sys
    import json
    print(json.dumps(parse_and_sort(sys.stdin), indent=4, sort_keys=True))

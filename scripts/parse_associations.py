#!/usr/bin/env python
# encoding: utf-8

"""
Converts a database table dump of all DSA associations (through stdin) to a
json list (through stdout), which the apps can handle.
It's output is supposed to be served through the API.
"""

import csv

KONVENT_SET = {
    'fk', 'hk', 'ik', 'kultk', 'pfk', 'schamper', 'sk', 'urgent', 'wvk'
}


def jsonify(db_line):
    entry = {
        'internalName': db_line[1].upper(),
        'parentAssociation': db_line[6].upper() + "CENTRAAL"
    }
    if db_line[5] == 'NULL':
        entry['displayName'] = db_line[3]
    else:
        entry['displayName'] = db_line[5]
        entry['fullName'] = db_line[3]
    return entry


def in_vkv(db_line):
    return db_line[6] in KONVENT_SET


def parse_and_sort(file_):
    reader = csv.reader(file_, delimiter=';')
    return sorted((jsonify(assoc) for assoc in reader if in_vkv(assoc)),
                  key=lambda x: (x['parentAssociation'], x['internalName']))


if __name__ == '__main__':
    import sys
    import json
    print(json.dumps(parse_and_sort(sys.stdin), indent=4, sort_keys=True))

#!/usr/bin/python

from plistlib import readPlist, writePlist
from sys import stdin, stdout

plist = readPlist(stdin)
plist = sorted(plist, key = lambda k: (k['parentAssociation'], k['internalName']))
writePlist(plist, stdout)

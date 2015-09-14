#!/bin/bash
cd ../iOS/Resources
plutil -convert json Associations.plist -o temp.json
cat temp.json | python -m json.tool > Associations.json
rm temp.json

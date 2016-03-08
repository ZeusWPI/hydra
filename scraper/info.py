'''
Creates an SQL full-text search index from the info pages. This can be served
statically to the apps to implement search functionality.
'''

import sqlite3
import os
import json
import requests
from bs4 import BeautifulSoup

index_file_path = 'info/index.sqlite'

def build():
    try:
        os.remove(index_file_path)
    except FileNotFoundError:
        pass

    db = sqlite3.connect(index_file_path)
    c = db.cursor()
    c.execute('''
        create virtual table idx using fts3(
            title text,
            content text
        )
    ''')
    toc = json.load(open('info/info-content.json'))
    c.executemany('insert into idx values(?, ?)', find_content(toc))

    db.commit()
    db.close()

def node_content(node):
    if 'html' in node:
        return extract_text(open('info/' + node['html']).read())
    
    # Works quite well, but bloats the index (filesize x 4).
    # if 'url' in node:
    #     return requests.get(node['url']).text

    return ''

def extract_text(html):
    return ' '.join(BeautifulSoup(html, 'lxml').findAll(text=True))

def find_content(node, found=None):
    children = []

    if isinstance(node, list):
        children = node
    elif 'subcontent' in node:
        children = node['subcontent']

    if not children:
        return [(node['title'], node_content(node))]

    return [
        data
        for child in children
        for data in find_content(child)
    ]

if __name__ == '__main__':
    build()
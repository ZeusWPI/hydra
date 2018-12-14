#!/usr/bin/env python3
"""
Run the Schamper scraper.
"""

import argparse
import locale
import os
import sys
from collections import defaultdict
from datetime import datetime

import htmlmin
import lxml.html
from bs4 import BeautifulSoup, CData, Tag
from requests import RequestException

from backoff import retry_session
from util import write_json_to_file

BASE_URL = 'https://www.schamper.ugent.be'
RSS_URL = BASE_URL + '/rss'

XML_PARSER = 'lxml-xml'
HTML_PARSER = 'lxml'

# Hard-coded colours from the website
CATEGORY_COLORS = defaultdict(lambda: '#010101', {
    'Satire': '#F9B126',
    'Onderwijs': '#70BE93',
    'Wetenschap': '#46ADE2',
    'Cultuur': '#E83F68',
    'Opinie': '#292929'
})


def read_xml_from_url(url):
    response = retry_session.get(url)
    return BeautifulSoup(response.text, XML_PARSER)


def read_html_from_string(string):
    """Parse a string as HTML"""
    soup = BeautifulSoup(string, HTML_PARSER)
    prettified = soup.prettify()
    absolutified = lxml.html.make_links_absolute(prettified, base_url=BASE_URL)
    return BeautifulSoup(absolutified, HTML_PARSER)


def write_xml_to_file(doc, path):
    with open(path, mode='w', encoding="utf-8") as f:
        f.write(str(doc))


def convert_rss_to_json(rss_feed):
    return list(map(rss_item_to_object, rss_feed('item')))


def rss_item_to_object(rss_item):
    def convert_date(date):
        # TODO: Maybe convert this to ISO time or something?
        locale.setlocale(locale.LC_TIME, "en_US.utf8")
        return datetime.strptime(date, "%a, %d %b %Y %H:%M:%S %z").isoformat()

    def find_first_image_in_content(article_content):
        soupified = BeautifulSoup(article_content, HTML_PARSER)
        images = [x.get('src') for x in soupified.find_all('img')]
        if len(images) > 0:
            return images[0]
        return None

    content = "".join(rss_item.description.contents)
    category = rss_item.find('category').text
    return {
        'title': rss_item.title.text,
        'link': rss_item.link.text,
        'text': content,
        'pub_date': convert_date(rss_item.pubDate.text),
        'author': rss_item.creator.text,
        'category': category,
        'image': find_first_image_in_content(content),
        'category_color': CATEGORY_COLORS[category]
    }


def parse_content_in_json(articles):
    """Loop through articles and parse them"""
    return list(map(parse_content_object_in_json, articles))


def parse_content_object_in_json(json_content):
    """Extract stuff from the actual article"""
    # The parsed article content
    text = BeautifulSoup(json_content['text'], 'lxml')

    intro_node = text.select_one('div.field-name-field-inleiding p')

    if intro_node is not None:
        intro = intro_node.text.strip()
        text.find('div', class_='field-name-field-inleiding').decompose()
    else:
        intro = ""  # Use empty text when there is no intro.

    # Extract images
    images = []
    for wrapper in text.find_all('div', class_='article-image-wrapper'):
        images.append({
            'url': wrapper.find('img')['src'],
            'caption': wrapper.text.strip()
        })

    # Remove empty tags
    for el in text.find_all(['p', 'div']):
        if not el.contents and (not el.string or not el.string.strip()):
            el.decompose()

    return {
        'author': json_content['author'],
        'title': json_content['title'],
        'link': json_content['link'],
        'pub_date': json_content['pub_date'],
        'intro': intro,
        'image': json_content['image'],
        'images': images,
        'body': "".join(text.find('body').decode_contents(formatter='html')),
        'category': json_content['category'],
        'category_color': json_content['category_color']
    }


def transform_item_in_feed(item):
    """Transform an <item>"""

    link = item.link.text
    print('Processing {}'.format(link))

    # Ignore empty articles
    if item.description is None or len(item.description.contents) == 0:
        print('Empty article body, ignoring...')
        item.decompose()
        return

    # Ignore articles without title
    if item.title is None or len(item.title) == 0:
        print('Article without title, ignoring...')
        item.decompose()
        return

    # Parse the article content as HTML
    article = read_html_from_string(item.description.contents[0])

    # The creator in the RSS is a username, so try first to parse from the HTML.
    html_authors = _parse_article_authors(article)

    if html_authors is not None:
        item.creator.string = html_authors
        # Remove authors from article text itself
        article.find('div', class_='field-name-field-auteurs').decompose()

    # Get the category
    category_tag = Tag(name='category')
    category_node = article.select_one('div.field-name-field-rubriek a')

    if category_node is not None:
        category_tag.string = category_node.text.strip()
        category_tag['domain'] = category_node['href']
        # Remove category from the article body
        article.find('div', class_='field-name-field-rubriek').decompose()

    item.append(category_tag)

    # Remove edition from article body if present
    edition_node = article.find('div', class_='field-name-field-editie')
    if edition_node is not None:
        edition_node.decompose()

    encoded = article.find('body').decode_contents(formatter='html')
    item.description.contents = [CData(htmlmin.minify(encoded, remove_optional_attribute_quotes=False))]


def _parse_article_authors(article):
    """Parse authors from the article"""
    author_urls = article.select("div.field-name-field-auteurs a")

    if len(author_urls) == 0:
        return None

    authors = list(map(lambda a: a.text.strip(), author_urls))

    assert len(authors) >= 1

    if len(authors) == 1:
        author_string = authors[0]
    else:
        author_string = ', '.join(authors[:-1]) + ' & ' + authors[-1]

    return author_string


def run(output):
    """
    Run the scraper.
    """
    output_path = os.path.abspath(output)  # Like realpath
    os.makedirs(output_path, exist_ok=True)  # Like mkdir -p

    rss_feed = read_xml_from_url(RSS_URL)

    for item in rss_feed('item'):
        transform_item_in_feed(item)

    xml_output = os.path.join(output_path, 'daily.xml')
    json_output = os.path.join(output_path, 'daily.json')
    json_android_output = os.path.join(output_path, 'daily_android.json')

    write_xml_to_file(rss_feed, xml_output)
    articles = convert_rss_to_json(rss_feed)
    write_json_to_file(articles, json_output)
    android_articles = parse_content_in_json(articles)
    write_json_to_file(android_articles, json_android_output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run Schamper scraper')
    parser.add_argument('output',
                        help='Path of the folder in which the output must be written. Will be created if needed.')
    args = parser.parse_args()

    try:
        run(args.output)
    except RequestException as error:
        print("Failed to run Schamper scraper", file=sys.stderr)
        print(error, file=sys.stderr)
        sys.exit(1)

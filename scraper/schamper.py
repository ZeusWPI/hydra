#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
import re
import locale
import urllib.parse
import urllib.request
from datetime import datetime

import htmlmin
import lxml.html
from bs4 import BeautifulSoup, CData, Tag

BASE_URL = 'http://www.schamper.ugent.be'
RSS_URL = BASE_URL + '/rss'
API_PATH = './schamper/'
XML_PARSER = 'lxml-xml'
HTML_PARSER = 'lxml'
CATEGORY_COLORS = {'Satire': '#F9B126',
                   'Onderwijs': '#70BE93',
                   'Wetenschap': '#46ADE2',
                   'Cultuur': '#E83F68',
                   'Opinie': '#292929'}


def process_schamper(destination_path):
    rss_feed = read_xml_from_url(RSS_URL)

    for item in rss_feed('item'):
        transform_item_in_feed(item)

    write_xml_to_file(rss_feed, destination_path + 'daily.xml')
    articles = convert_rss_to_json(rss_feed)
    write_json_to_file(articles, destination_path + 'daily.json')
    android_articles = parse_content_in_json(articles)
    write_json_to_file(android_articles, destination_path + 'daily_android.json')


def read_xml_from_url(url, parser=XML_PARSER):
    with urllib.request.urlopen(url) as rss_feed:
        return BeautifulSoup(rss_feed, parser)


def read_html_from_string(string):
    """Parse a string as HTML"""
    soup = BeautifulSoup(string, HTML_PARSER)
    prettified = soup.prettify()
    absolutified = lxml.html.make_links_absolute(prettified, base_url=BASE_URL)
    return BeautifulSoup(absolutified, HTML_PARSER)


def write_xml_to_file(doc, path):
    directory = os.path.dirname(path)
    os.makedirs(directory, exist_ok=True)
    with open(path, mode='w', encoding="utf-8") as file_:
        file_.write(str(doc))


def write_json_to_file(articles, path):
    with open(path, mode='w', encoding="utf-8") as f:
        json.dump(articles, f, sort_keys=True)


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
    category_color = CATEGORY_COLORS[category] if category in CATEGORY_COLORS else '#010101'
    return {
        'title': rss_item.title.text,
        'link': rss_item.link.text,
        'text': content,
        'pub_date': convert_date(rss_item.pubDate.text),
        'author': rss_item.creator.text,
        'category': category,
        'image': find_first_image_in_content(content),
        'category_color': category_color
    }


def parse_content_in_json(articles):
    """Loop through articles and parse them"""
    return list(map(parse_content_object_in_json, articles))


def parse_content_object_in_json(json_content):
    """Extract stuff from the actual article"""
    # The parsed article content
    text = BeautifulSoup(json_content['text'], HTML_PARSER)

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
        _remove_authors(article)

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


def _remove_authors(article):
    """Remove the authors from an article"""
    article.find('div', class_='field-name-field-auteurs').decompose()


# def _extract_article_body(page):
#     article = page.find(id='artikel').find(class_='content')
#
#     body = Tag(name='temporary_tag')
#
#     # +1 internetz for the person who can tell me why I can't write:
#     #   for element in article.children:
#     # or
#     #   for element in article.contents:
#     for element in list(article.children):
#         # Ignore the comment form
#         if element.name == 'form':
#             continue
#
#         # Ignore whitespace
#         if element.name is None and re.search('\S', str(element)) is None:
#             continue
#
#         # Nor div, nor form, nor whitespace: probably article content
#         if element.name != 'div':
#             body.append(element.extract())
#             continue
#
#         # TODO uncomment me when the app is ready to support subtitles
#         # Oh, and change the next if with an elif
#         #  if 'field-field-ondertitel' in element['class']:
#         #      paragraph = _extract_paragraph(element, 'subtitle')
#         #      body.append(paragraph)
#
#         if 'field-field-inleiding' in element['class']:
#             paragraph = _extract_paragraph(element, 'introduction')
#             body.append(paragraph)
#
#         elif 'field-field-img-regulier' in element['class']:
#             images_div = Tag(name='div', attrs={'class': 'image'})
#             for image_and_caption in element(id='image-and-caption'):
#                 image = image_and_caption.img
#                 caption = image_and_caption.find(class_='caption-text')
#
#                 paragraph = Tag(name='p')
#                 paragraph.append(image)
#                 if caption is not None:
#                     paragraph.append(caption.text)
#
#                 images_div.append(paragraph)
#             body.append(images_div)
#
#         elif 'field-field-website' in element['class']:
#             label = element.find(class_='field-label').text
#             label_p = Tag(name='p')
#             label_s = Tag(name='strong')
#             label_s.append(label)
#             label_p.append(label_s)
#             body.append(label_p)
#
#             websites = element.find(class_='field-item').contents
#             for website in list(websites):
#                 body.append(website)
#
#         else:
#             # Ignore other divs
#             pass
#
#     return body


def _extract_paragraph(element, name):
    item = element.find(class_='field-item').extract()
    item_contents = [part for part in item.contents if not _is_empty(part)]
    paragraph = _ensure_wrapped_in_paragraph(item_contents)
    paragraph['class'] = name
    return paragraph


def _is_empty(node):
    return isinstance(node, str) and re.search('\S', node) is None


def _ensure_wrapped_in_paragraph(contents):
    if len(contents) == 1 and contents[0].name == 'p':
        return contents[0]
    else:
        paragraph = Tag(name='p')
        paragraph.contents = contents
        return paragraph


if __name__ == '__main__':
    process_schamper(API_PATH)

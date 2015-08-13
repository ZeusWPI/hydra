#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import sys
import urllib.parse
import urllib.request

from bs4 import BeautifulSoup, CData, Tag
import lxml.html
import htmlmin

BASE_URL = 'http://www.schamper.ugent.be'
RSS_URL = BASE_URL + '/dagelijks'
API_PATH = './schamper/daily.xml'
XML_PARSER = 'lxml-xml'
HTML_PARSER = 'lxml'


def process_schamper(destination_path):
    rss_feed = read_xml_from_url(RSS_URL)

    for item in rss_feed('item'):
        transform_item_in_feed(item)

    write_xml_to_file(rss_feed, destination_path)


def read_xml_from_url(url, parser=XML_PARSER):
    with urllib.request.urlopen(url) as rss_feed:
        return BeautifulSoup(rss_feed, parser)


def read_html_from_url(url):
    soup = read_xml_from_url(url, parser=HTML_PARSER)
    prettified = soup.prettify()
    absolutified = lxml.html.make_links_absolute(prettified, base_url=BASE_URL)
    return BeautifulSoup(absolutified, HTML_PARSER)


def write_xml_to_file(doc, path):
    directory = os.path.dirname(path)
    os.makedirs(directory, exist_ok=True)
    with open(path, 'w') as file_:
        file_.write(str(doc))


def transform_item_in_feed(item):
    link = item.link.text
    print('Processing {}'.format(link), file=sys.stderr)

    article = read_html_from_url(link)

    # Remove and ignore articles without title
    title_node = item.title
    if title_node is None or len(title_node.text) == 0:
        item.decompose()
        return

    author_node = item.creator
    author_node.string = _parse_article_authors(article)

    parsed_body = _extract_article_body(article)
    encoded = parsed_body.decode_contents(formatter='html')
    minified = htmlmin.minify(encoded, remove_optional_attribute_quotes=False)
    item.description.contents = [CData(minified)]


def _parse_article_authors(article):
    authors = article.find('span', class_='submitted')

    if len(authors) == 0:
        return ''

    match = re.search('\sdoor\s+((.|\n)*\S)\s*$', authors.text)
    if match is None:
        raise Exception('Couldn\'t parse authors "{}"'.format(authors.text))

    return match.group(1)


def _extract_article_body(page):
    article = page.find(id='artikel').find(class_='content')

    body = Tag(name='temporary_tag')

    # +1 internetz for the person who can tell me why I can't write:
    #   for element in article.children:
    # or
    #   for element in article.contents:
    for element in list(article.children):
        # Ignore the comment form
        if element.name == 'form':
            continue

        # Ignore whitespace
        if element.name is None and re.search('\S', str(element)) is None:
            continue

        # Nor div, nor form, nor whitespace: probably article content
        if element.name != 'div':
            body.append(element.extract())
            continue

        # TODO uncomment me when the app is ready to support subtitles
        # Oh, and change the next if with an elif
        #  if 'field-field-ondertitel' in element['class']:
        #      paragraph = _extract_paragraph(element, 'subtitle')
        #      body.append(paragraph)

        if 'field-field-inleiding' in element['class']:
            paragraph = _extract_paragraph(element, 'introduction')
            body.append(paragraph)

        elif 'field-field-img-regulier' in element['class']:
            images_div = Tag(name='div', attrs={'class': 'image'})
            for image_and_caption in element(id='image-and-caption'):
                image = image_and_caption.img
                caption = image_and_caption.find(class_='caption-text')

                paragraph = Tag(name='p')
                paragraph.append(image)
                if caption is not None:
                    paragraph.append(caption.text)

                images_div.append(paragraph)
            body.append(images_div)

        elif 'field-field-website' in element['class']:
            label = element.find(class_='field-label').text
            label_p = Tag(name='p')
            label_s = Tag(name='strong')
            label_s.append(label)
            label_p.append(label_s)
            body.append(label_p)

            websites = element.find(class_='field-item').contents
            for website in list(websites):
                body.append(website)

        else:
            # Ignore other divs
            pass

    return body


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

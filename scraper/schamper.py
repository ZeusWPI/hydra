'''
Created on 11 dec. 2012

@author: feliciaan
'''
from __future__ import with_statement
import urllib, libxml2, os, re

SOURCE = 'http://www.schamper.ugent.be/dagelijks'
API_PATH = './schamper/daily.xml'

def process_schamper(source_url, destination_path):
    doc = read_rss_from_url(source_url)

    # To handle namespaces, we need a new context
    context = doc.xpathNewContext()
    context.xpathRegisterNs('dc', 'http://purl.org/dc/elements/1.1/')

    for item in context.xpathEval('//item'):
        context.setContextNode(item)
        fetch_full_article(context)

    write_feed_to_file(doc, destination_path)

def read_rss_from_url(url):
    f = urllib.urlopen(url)
    doc = libxml2.readDoc(f.read(), None, 'UTF-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)
    return doc

def read_html_from_url(url):
    f = urllib.urlopen(url)
    doc = libxml2.htmlReadDoc(f.read(), None, 'UTF-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)
    return doc

def write_feed_to_file(doc, path):
    directory = os.path.dirname(path)
    if not os.path.isdir(directory):
        os.makedirs(directory)
    with open(path, 'w') as file:
        doc.saveTo(file, 'UTF-8')

def fetch_full_article(item):
    link = item.xpathEval('./link')[0].content
    print('Processing ' + link)
    article = read_html_from_url(link)

    authorNode = item.xpathEval('./dc:creator')[0]
    authors = get_article_authors(article)
    authorNode.setContent(article.encodeSpecialChars(authors))

    descriptionNode = item.xpathEval('./description')[0]
    body = get_article_body(article)
    descriptionNode.setContent(None)
    descriptionNode.addChild(article.newCDataBlock(body, len(body)))

def get_article_authors(page):
    authors = page.xpathEval("//span[@class='submitted']")[0]
    m = re.search(' door (.+)$', authors.getContent())
    return m.group(1)

def get_article_body(page):
    result = ''

    bodyNodes = page.xpathEval("//div[@id='artikel']/*/div[@class='content']/*")
    for node in bodyNodes:
        # Normal text (or header etc)
        if node.name != 'form' and node.name != 'div':
            result += node.serialize('UTF-8')

        # Introductory paragraph
        elif node.name == 'div' and node.prop('class').find('inleiding') >= 0:
            introNode = node.xpathEval('./div/div')[0]
            # Sometimes there's a wrapping <p>, sometimes there isn't
            paragraph = introNode.xpathEval('./p')
            if len(paragraph) == 0:
                paragraph = [page.newDocRawNode(None, 'p', introNode.children.serialize('UTF-8'))]

            paragraph[0].setProp('class', 'introduction')
            result += paragraph[0].serialize('UTF-8')

        # Image
        elif node.name == 'div' and node.prop('class').find('img-regulier') >= 0:
            image = node.xpathEval(".//img")[0]
            image.setProp('src', 'http://www.schamper.ugent.be' + image.prop('src'))
            result += '<p class="image">' + image.serialize('UTF-8') + '</p>'

    return result

if __name__ == '__main__':
    process_schamper(SOURCE, API_PATH)

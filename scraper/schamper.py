from __future__ import with_statement
import urllib, libxml2, os, re, urlparse

SOURCE = 'http://www.schamper.ugent.be/dagelijks'
API_PATH = './schamper/daily.xml'
BASE_URL = 'http://www.schamper.ugent.be'

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

    # Make all links and images absolute
    for link in page.xpathEval('.//*[@href]'):
        url = urlparse.urlparse(link.prop('href'))
        if url.hostname == None:
            link.setProp('href', BASE_URL + link.prop('href'))
    for image in page.xpathEval('.//*[@src]'):
        url = urlparse.urlparse(image.prop('src'))
        if url.hostname == None:
            image.setProp('src', BASE_URL + image.prop('src'))

    bodyNodes = page.xpathEval("//div[@id='artikel']/*/div[@class='content']/*")
    for node in bodyNodes:
        # Simple fix for div's missing a class
        if node.name == 'div' and node.prop('class') == None:
            node.setProp('class', '')

        # Normal text (or header etc)
        if node.name != 'form' and node.name != 'div':
            result += node.serialize('UTF-8')

        # Introductory paragraph
        elif node.name == 'div' and node.prop('class').find('inleiding') >= 0:
            paragraph = wrap_paragraph(node.xpathEval(".//*[@class='field-item']")[0], page)
            paragraph.setProp('class', 'introduction')
            result += paragraph.serialize('UTF-8')

        # External links
        elif node.name == 'div' and node.prop('class').find('website') >= 0:
            label = node.xpathEval(".//*[@class='field-label']")[0]
            result += '<p><strong>' + label.content + '</strong></p>'
            paragraph = wrap_paragraph(node.xpathEval(".//*[@class='field-item']")[0], page)
            result += paragraph.serialize('UTF-8')

        # Image
        elif node.name == 'div' and node.prop('class').find('img-regulier') >= 0:
            # Multiple images are possible
            images = node.xpathEval(".//*[@id='image-and-caption']")
            for imageWrapper in images:
                captionText = ''
                caption = imageWrapper.xpathEval(".//*[@class='caption-text']")
                if len(caption) > 0:
                    captionText = caption[0].children.serialize('utf-8')

                image = imageWrapper.xpathEval('.//img')[0]
                result += '<div class="image"><p>' + image.serialize('UTF-8') + captionText + '</p></div>'

    return result

def wrap_paragraph(node, page):
    # Sometimes there's a wrapping <p>, sometimes there isn't
    paragraph = node.xpathEval('./p')
    if len(paragraph) == 0:
        paragraph = [page.newDocRawNode(None, 'p', node.children.serialize('UTF-8'))]
    return paragraph[0]

if __name__ == '__main__':
    process_schamper(SOURCE, API_PATH)

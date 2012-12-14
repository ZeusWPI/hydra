'''
Created on 11 dec. 2012

@author: feliciaan
'''
import urllib, libxml2, os

API_PATH = './schamper/'
FILENAME = 'schamper'
SCHAMPER_LINK = 'http://www.schamper.ugent.be/dagelijks'
ZEUS_LINK = 'http://zeus.ugent.be/schamper/rss'

def read_rss_from_url(url):
    f = urllib.urlopen(url)
    doc = libxml2.readDoc(f.read(), None, 'UTF-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)
    return doc

def read_html_from_url(url):
    f = urllib.urlopen(url)
    doc = libxml2.htmlReadDoc(f.read(), None, 'UTF-8', libxml2.XML_PARSE_RECOVER | libxml2.XML_PARSE_NOERROR)
    return doc

def change_to_rss_feed(doc):
    channel = doc.xpathEval("//channel")[0]  
    #channel link to ZEUS_LINK
    channel.xpathEval("link")[0].setContent(ZEUS_LINK)
    channel.xpathEval("title")[0].setContent("Schamper Daily for Hydra")
    channel.xpathEval("description")[0].setContent("RSS feed van de dailies voor Hydra")

def change_item_info(doc):
    items = doc.xpathEval("//item")
    for item in items:
        link = item.xpathEval("link")[0].content
        page = read_html_from_url(link)
        description = item.xpathEval("description")[0]
        description.setContent(get_content(page))
        for x in item.xpathEval("*"):
            if(x.name == 'creator'):
                x.setContent(get_author(page))

def get_intro(page):
    intro = page.xpathEval("//*[contains(@class,'field-field-inleiding')]")
    if (len(intro) > 0):
        s = intro[0].getContent()
        s = s.strip()
        s = '<div class="inleiding">' + s + '</div>'
        return s
    else:
        return None

def get_content(page):
    content = page.xpathEval("//div[@id='artikel']//div[@class='content']")
    intro = get_intro(page)
    s = ""
    if intro != None:
        s += intro
    p = content[0].xpathEval("p")
    for i in p:
        s += i.__str__()
    return s

def get_author(page):
    author = page.xpathEval("//span[@class='submitted']/a[contains(@href,'user')]")[0]
    return author.getContent()
    

def write_document_to_file(doc):
    print "Writing object tree to file in RSS format"
    path = API_PATH
    filename = FILENAME
    if not os.path.isdir(path):
        os.makedirs(path)
    f = open ('%s/%s.rss' % (path, filename), 'w')
    doc.saveTo(f, 'UTF-8')
    f.close()     

if __name__ == '__main__':
    doc = read_rss_from_url(SCHAMPER_LINK)
    change_to_rss_feed(doc) 
    change_item_info(doc)
    write_document_to_file(doc)

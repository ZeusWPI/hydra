package be.ugent.zeus.resto.client.util;

import android.util.Log;
import java.io.IOException;
import java.io.StringReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import be.ugent.zeus.resto.client.data.NewsItem;

public class NewsXmlParser {
  private static final SimpleDateFormat format = new SimpleDateFormat("dd/mm/yyyy");

  public ArrayList<NewsItem> parse(String clubXML) throws SAXException, IOException, ParserConfigurationException, DOMException, ParseException {
    DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

    Document doc = dbf.newDocumentBuilder().parse(new InputSource(new StringReader(clubXML)));
    doc.getDomConfig().setParameter("cdata-sections", false);

    Node clubNode = doc.getFirstChild();
    NodeList newsList = clubNode.getChildNodes();
    int len = newsList.getLength();
    ArrayList<NewsItem> list = new ArrayList<NewsItem>();

    for (int i = 0; i < len; i++) {
      list.add(parseNewsItem(newsList.item(i)));
    }

    return list;
  }

  private NewsItem parseNewsItem(Node item) throws DOMException, ParseException {
    Date date;
    String club;
    String title;
    String description;

    date = format.parse(item.getAttributes().getNamedItem("date").getTextContent());
    club = item.getAttributes().getNamedItem("association_id").getTextContent();

    title = item.getFirstChild().getTextContent();
    title = title.substring(9, title.length() - 3);
    description = item.getLastChild().getTextContent();

    return new NewsItem(date, club, title, description);
  }
}

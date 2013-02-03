package be.ugent.zeus.hydra.util;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import be.ugent.zeus.hydra.data.NewsItem;
import java.io.ByteArrayInputStream;
import org.w3c.dom.Document;

public class NewsXmlParser {

    private static final SimpleDateFormat format = new SimpleDateFormat("dd/mm/yyyy");

    public ArrayList<NewsItem> parse(String clubXML) throws SAXException, IOException, ParserConfigurationException, DOMException, ParseException {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

        ByteArrayInputStream stream = new ByteArrayInputStream(clubXML.getBytes("ISO-8859-1"));
        Document doc = dbf.newDocumentBuilder().parse(stream);

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
        Date date = format.parse(item.getAttributes().getNamedItem("date").getTextContent());
        String club = item.getAttributes().getNamedItem("association_id").getTextContent();

        String title = item.getFirstChild().getTextContent();
        if (title.startsWith("<![CDATA[")) {
            title = title.substring(9, title.length() - 3);
        }

        String description = item.getLastChild().getTextContent();
        if (description.startsWith("<![CDATA[")) {
            description = description.substring(9, description.length() - 3);
        }

        return new NewsItem(date, club, title, description);
    }
}

package be.ugent.zeus.hydra.util;

import android.util.Log;
import be.ugent.zeus.hydra.data.rss.Category;
import be.ugent.zeus.hydra.data.rss.Channel;
import be.ugent.zeus.hydra.data.rss.Item;
import java.io.IOException;
import java.io.StringReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * An absolutely incomplete RSS parser. Only implemented the tags i need to parse the schamper rss
 * feed...
 *
 * FYI I HATE PARSING XML LIKE THIS
 *
 * @author Thomas Meire
 */
public class RSSParser {

    private static final SimpleDateFormat format = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss z");

    private Item createItem(Node node, String baseURL) {
        Item item = new Item();

        NodeList children = node.getChildNodes();
        for (int i = 0; i < children.getLength(); i++) {
            Node child = children.item(i);

            if ("title".equals(child.getNodeName())) {
                item.title = child.getTextContent();
            } else if ("comments".equals(child.getNodeName())) {
                item.comments = child.getTextContent();
            } else if ("description".equals(child.getNodeName())) {
                item.description = child.getTextContent();
                // dirty hack to avoid links without protocol & hostname
                if (item.description.contains("href=\"/")) {
                    item.description = item.description.replace("href=\"/", "href=\"" + baseURL + "/");
                }
            } else if ("dc:creator".equals(child.getNodeName())) {
                item.creator = child.getTextContent();
            } else if ("link".equals(child.getNodeName())) {
                item.link = child.getTextContent();
            } else if ("pubDate".equals(child.getNodeName())) {
                // Parse date in format "Thu, 01 Mar 2012 22:11:17 +0100"
                try {
                    item.pubDate = format.parse(child.getTextContent());
                } catch (ParseException e) {
                    item.pubDate = new Date();
                }
            } else if ("category".equals(child.getNodeName())) {
                Category category = new Category();
                category.domain = child.getAttributes().getNamedItem("domain").getTextContent();
                category.value = child.getTextContent();
                item.categories.add(category);
            } else {
                // ignore guid & #text tags
            }
        }
        return item;
    }

    public Channel parse(String feedXML) {
        Channel channel = new Channel();

        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        try {
            Document doc = dbf.newDocumentBuilder().parse(new InputSource(new StringReader(feedXML)));

            Node rss = doc.getFirstChild();
            if (rss == null || !"rss".equals(rss.getNodeName().toLowerCase())) {
                Log.w("[RSSParser]", "Not an rss feed!");
                return channel;
            }

            String baseURL = "";
            Node base = rss.getAttributes().getNamedItem("xml:base");
            if (base != null) {
                baseURL = base.getTextContent();
            }

            // get the channel node
            NodeList children = rss.getChildNodes();
            int i = 0;
            Node channelNode = children.item(0);
            while (!channelNode.getNodeName().equals("channel")) {
                channelNode = children.item(++i);
            }

            children = channelNode.getChildNodes();
            for (int j = 0; j < children.getLength(); j++) {
                Node child = children.item(j);

                if ("item".equals(child.getNodeName())) {
                    channel.items.add(createItem(child, baseURL));
                } else if ("title".equals(child.getNodeName())) {
                    channel.title = child.getTextContent();
                } else if ("description".equals(child.getNodeName())) {
                    channel.description = child.getTextContent();
                } else if ("language".equals(child.getNodeName())) {
                    channel.language = child.getTextContent();
                } else if ("link".equals(child.getNodeName())) {
                    channel.link = child.getTextContent();
                } else {
                    // ignore #text tags
                }
            }

        } catch (ParserConfigurationException e) {
            Log.e("[RSSParser]", "XML parse error: " + e.getMessage());
        } catch (SAXException e) {
            Log.e("[RSSParser]", "Wrong XML file structure: " + e.getMessage());
        } catch (IOException e) {
            Log.e("[RSSParser]", "I/O exeption: " + e.getMessage());
        }
        Log.i("[RSSParser]", "Parsed channel '" + channel.title + "' with " + channel.items.size());
        return channel;
    }

    /*
     private static String load() {
     try {
     BufferedReader reader = new BufferedReader(new FileReader(new File("/home/blackskad/Downloads/schamper-dailies.rss")));
  
     String xml = "";
  
     String line;
     while ((line = reader.readLine()) != null) {
     xml += line;
     }
     return xml;
     } catch (Exception e) {
     return "";
     }
     }
  
     public static void main(String[] args) {
     String xml = load();
  
     RSSParser parser = new RSSParser();
     parser.parse(xml);
     }
     * 
     */
}

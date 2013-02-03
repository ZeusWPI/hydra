package be.ugent.zeus.hydra.util;

import android.util.Log;
import be.ugent.zeus.hydra.data.Activity;
import java.io.ByteArrayInputStream;
import java.util.LinkedList;
import java.util.List;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Parse the activity-xml into a list of activities. The activities are not yet grouped by date!
 *
 * @author Thomas Meire
 */
public class ActivityXmlParser {

    public List<Activity> parse(String activityXML) {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

        List<Activity> list = new LinkedList<Activity>();

        try {
            ByteArrayInputStream stream = new ByteArrayInputStream(activityXML.getBytes("ISO-8859-1"));
            Document doc = dbf.newDocumentBuilder().parse(stream);

            Node clubNode = doc.getFirstChild();
            NodeList activityList = clubNode.getChildNodes();
            int len = activityList.getLength();

            for (int i = 0; i < len; i++) {
                list.add(parse(activityList.item(i)));
            }
        } catch (Exception e) {
            Log.w("[ActivityXmlParser", "Something went wrong while parsing the activity xml!", e);
        }
        return list;
    }

    private Activity parse(Node node) {
        Activity activity = new Activity();

        NamedNodeMap attributes = node.getAttributes();
        activity.date = attributes.getNamedItem("date").getTextContent().replace("/", "-");
        activity.start = attributes.getNamedItem("from").getTextContent();
        activity.end = attributes.getNamedItem("to").getTextContent();
        activity.association_id = node.getAttributes().getNamedItem("association_id").getTextContent();
        // TODO parse the other attributes (to, from)

        NodeList children = node.getChildNodes();
        for (int i = 0; i < children.getLength(); i++) {
            Node child = children.item(i);

            if ("title".equals(child.getNodeName())) {
                activity.title = child.getTextContent();
                // FIXME: cutoff the CDATA tags
                activity.title = activity.title.substring(9, activity.title.length() - 3);
            } else if ("location".equals(child.getNodeName())) {
                activity.location = child.getTextContent();
                // FIXME: cutoff the CDATA tags
                activity.location = activity.location.substring(9, activity.location.length() - 3);
            } else {
                // unknown tag, ignore
            }
        }

        return activity;
    }
}

package be.ugent.zeus.resto.client.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.resto.client.data.NewsItem;
import be.ugent.zeus.resto.client.util.NewsXmlParser;
import java.io.StringReader;
import java.util.ArrayList;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

public class NewsIntentService extends HTTPIntentService {

	public NewsIntentService() {
		super("NewsIntentService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
    Log.i("blub", "handle intent");
		final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);
		
    final Bundle bundle = new Bundle();		
		try {
			String xml = fetch(HYDRA_BASE_URL + "versions.xml");
			
			ArrayList<NewsItem> list = new ArrayList<NewsItem>();
		
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			Document doc = dbf.newDocumentBuilder().parse(new InputSource(new StringReader(xml)));
			NodeList nodeList = doc.getFirstChild().getChildNodes();
			NewsXmlParser parser = new NewsXmlParser();
			
			for(int i = 0; i < nodeList.getLength(); i++) {
				Node node = nodeList.item(i);
				
				String path = node.getAttributes().getNamedItem("path").getTextContent();
				if(path.startsWith("News")) {
          try {
            Log.i("[NewsIntentService]", "Downloading " + path);
            String clubXML = fetch(HYDRA_BASE_URL + path);
            // TODO: filter based on user preferences
            list.addAll(parser.parse(clubXML));
          } catch (Exception e) {
            Log.e("[NewIntentService]", e.getMessage());
          }
				}
			}
			
			bundle.putSerializable("newsItemList", list);
			
		} catch (Exception e) {
      Log.e("[NewsIntentService]", e.getMessage());
		}		
    receiver.send(STATUS_FINISHED, bundle);
	}
}

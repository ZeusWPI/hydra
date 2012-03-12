package be.ugent.zeus.resto.client.data.services;

import java.io.StringReader;
import java.util.ArrayList;

import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import be.ugent.zeus.resto.client.data.NewsItem;
import be.ugent.zeus.resto.client.util.NewsXmlParser;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;

public class NewsIntentService extends HTTPIntentService {

	public NewsIntentService() {
		super("NewsIntentService");
		// TODO Auto-generated constructor stub
	}

	@Override
	protected void onHandleIntent(Intent intent) {
    Log.i("blub", "handle intent");
		final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);
		
		try {
			String xml = fetch("http://golive.myverso.com/ugent/versions.xml");
			
			final Bundle bundle = new Bundle();
		
			ArrayList<NewsItem> list = new ArrayList<NewsItem>();
		
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			Document doc = dbf.newDocumentBuilder().parse(new InputSource(new StringReader(xml)));
			NodeList nodeList = doc.getFirstChild().getChildNodes();
			NewsXmlParser parser = new NewsXmlParser();
			
			for(int i = 0; i < nodeList.getLength(); i++) {
				Node node = nodeList.item(i);
				
				String path = node.getAttributes().getNamedItem("path").getTextContent();
				if(path.startsWith("News")) {
          Log.i("[NewsIntentService]", "Downloading " + path);
					String clubXML = fetch("http://golive.myverso.com/ugent/" + path);
          // TODO: filter based on user preferences
					list.addAll(parser.parse(clubXML));
				}
			}
			
			bundle.putSerializable("newsItemList", list);
			
		} catch (Exception e) {
      Log.e("[NewsIntentService]", e.getMessage());
		}		
	}
}

package be.ugent.zeus.hydra.data.services;

import java.io.StringReader;
import java.util.ArrayList;

import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.caches.Cache;
import be.ugent.zeus.hydra.util.NewsXmlParser;

public abstract class AbstractNewsIntentService extends HTTPIntentService {

    private Cache<ArrayList<NewsItem>> cache;

    public AbstractNewsIntentService() {
        super("NewsIntentService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        cache = getCache();
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent
            .getParcelableExtra(RESULT_RECEIVER_EXTRA);

        boolean force = intent.getBooleanExtra(FORCE_UPDATE, true);

        final Bundle bundle = new Bundle();
        try {
            ArrayList<NewsItem> list;

            if (!cache.exists(cacheKey()) || force) {
                String xml = cache.exists(cacheKey()) ? fetch(HYDRA_BASE_URL
                    + "versions.xml") : fetch(HYDRA_BASE_URL + "versions.xml",
                    cache.lastModified(cacheKey()));
                list = getNewsItems(xml);
                cache.put(cacheKey(), list);
            } else {
                list = cache.get(cacheKey());
            }

            bundle.putSerializable(cacheKey(), list);
        } catch (Exception e) {
            Log.e("[NewsIntentService]", e.getMessage());
        }
        receiver.send(STATUS_FINISHED, bundle);
    }

    private ArrayList<NewsItem> getNewsItems(String xml) throws Exception {
        ArrayList<NewsItem> list = new ArrayList<NewsItem>();
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        Document doc = dbf.newDocumentBuilder().parse(
            new InputSource(new StringReader(xml)));
        NodeList nodeList = doc.getFirstChild().getChildNodes();
        NewsXmlParser parser = new NewsXmlParser();

        for (int i = 0; i < nodeList.getLength(); i++) {
            Node node = nodeList.item(i);

            String path = node.getAttributes().getNamedItem("path").getTextContent();
            if (filter(path)) {
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

        return list;
    }

    public abstract boolean filter(String path);

    public abstract String cacheKey();

    public abstract Cache<ArrayList<NewsItem>> getCache();
}

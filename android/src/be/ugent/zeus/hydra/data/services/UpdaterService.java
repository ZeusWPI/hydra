package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;
import be.ugent.zeus.hydra.data.caches.VersionCache;
import java.io.ByteArrayInputStream;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 *
 * @author Thomas Meire
 */
public class UpdaterService extends HTTPIntentService {

    private static final String LAST_UPDATE = "last-global-update";
    private VersionCache cache;

    public UpdaterService() {
        super("UpdaterService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        cache = new VersionCache(this);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        cache.close();
    }

    private void store(String xml) {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

        try {
            ByteArrayInputStream stream = new ByteArrayInputStream(xml.getBytes("ISO-8859-1"));
            Document doc = dbf.newDocumentBuilder().parse(stream);

            NodeList paths = doc.getFirstChild().getChildNodes();
            for (int i = 0; i < paths.getLength(); i++) {
                Node path = paths.item(i);

                NamedNodeMap attributes = path.getAttributes();
                String name = attributes.getNamedItem("name").getTextContent();
                String url = attributes.getNamedItem("path").getTextContent();
                int version = Integer.parseInt(attributes.getNamedItem("version").getTextContent());

                if (version > cache.version(name)) {
                    // update the cache
                    cache.put(name, version);

                    if ("all_activities".equals(name)) {
                        // refresh the calendar feed
                        Intent intent = new Intent(this, ActivityIntentService.class);
                        intent.putExtra(HTTPIntentService.FORCE_UPDATE, true);

                        startService(intent);
                    } else if ("SCHAMPER".equals(name) || "restomenu".equals(name)) {
                        // ignore schamper & menu's, handled separatly
                    } else {
                        // refresh all other feeds as news
                        Intent intent = new Intent(this, NewsIntentService.class);
                        intent.putExtra(HTTPIntentService.FORCE_UPDATE, true);
                        intent.putExtra(NewsIntentService.FEED_NAME, name);
                        intent.putExtra(NewsIntentService.FEED_URL, url);
                        startService(intent);
                    }
                }
            }
        } catch (Exception e) {
        }
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);

        long last = prefs.getLong(LAST_UPDATE, 0);
        if (System.currentTimeMillis() - last < 3600000) {
            Log.i("[UpdaterService]", "Last update was less than an hour ago. Don't update.");
            return;
        }

        prefs.edit().putLong(LAST_UPDATE, System.currentTimeMillis()).commit();

        String location = HYDRA_BASE_URL + "versions.xml";
        try {
            store(fetch(location));
        } catch (Exception e) {
            Log.e("[UpdaterService]", "Something went wrong while fetching versions! " + e.getMessage());
        }
    }
}

package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.caches.NewsCache;
import be.ugent.zeus.hydra.util.NewsXmlParser;
import java.util.ArrayList;

public class NewsIntentService extends HTTPIntentService {

    public static final String FEED_NAME = "news-feed-name";
    public static final String FEED_URL = "news-feed-url";
    private NewsCache cache;

    public NewsIntentService() {
        super("NewsIntentService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        cache = NewsCache.getInstance(this);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);

        String feed = intent.getStringExtra(FEED_NAME);
        String url = intent.getStringExtra(FEED_URL);

        boolean force = intent.getBooleanExtra(FORCE_UPDATE, true);

        try {
            if (!cache.exists(feed) || force) {
                String xml = fetch(HYDRA_BASE_URL + url);

                NewsXmlParser parser = new NewsXmlParser();
                ArrayList<NewsItem> list = parser.parse(xml);
                cache.put(feed, list);
            } else {
                cache.get(feed);
            }
        } catch (Exception e) {
            Log.e("[NewsIntentService]", "Exception: " + e.getMessage());
        }
        if (receiver != null) {
            receiver.send(STATUS_FINISHED, Bundle.EMPTY);
        }
    }
}

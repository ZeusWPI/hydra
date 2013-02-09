package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.caches.NewsCache;
import java.util.ArrayList;
import java.util.Arrays;
import org.json.JSONArray;

public class NewsIntentService extends HTTPIntentService {

    public static final String FEED_NAME = "news-feed-name";
    public static final String NEWS_URL = "all_news.json";
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

        boolean force = intent.getBooleanExtra(FORCE_UPDATE, true);

        try {
            if (!cache.exists(FEED_NAME) || force) {

                JSONArray data = new JSONArray(fetch(HYDRA_BASE_URL + NEWS_URL));
                ArrayList<NewsItem> newsList = new ArrayList<NewsItem>(Arrays.asList(parseJsonArray(data, NewsItem.class)));

                cache.put(FEED_NAME, newsList);
            } else {
                cache.get(FEED_NAME);
            }
        } catch (Exception e) {
            Log.e("[NewsIntentService]", "Exception:");
            e.printStackTrace();
        }
        if (receiver != null) {
            receiver.send(STATUS_FINISHED, Bundle.EMPTY);
        }
    }
}

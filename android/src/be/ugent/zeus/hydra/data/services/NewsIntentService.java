package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.Hydra;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.caches.NewsCache;
import java.text.SimpleDateFormat;
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

        try {

            String fetchedData = fetch(HYDRA_BASE_URL + NEWS_URL, cache.lastModified(FEED_NAME));

            if (fetchedData != null) {
                ArrayList<NewsItem> newsList = new ArrayList<NewsItem>(Arrays.asList(parseJsonArray(new JSONArray(fetchedData), NewsItem.class)));

                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ssZ", Hydra.LOCALE);
                for (NewsItem newsItem : newsList) {
                    newsItem.dateDate = dateFormat.parse(newsItem.date);
                }

                cache.put(FEED_NAME, newsList);
            }

        } catch (Exception e) {
            Log.e("[NewsIntentService]", "Exception:");
            e.printStackTrace();

            if (receiver != null) {
                receiver.send(STATUS_ERROR, Bundle.EMPTY);
            }
        }

        if (receiver != null) {
            receiver.send(STATUS_FINISHED, Bundle.EMPTY);
        }
    }
}

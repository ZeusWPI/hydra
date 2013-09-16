package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.Hydra;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.caches.NewsCache;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import org.json.JSONArray;

public class NewsIntentService extends HTTPIntentService {

    public static final String FEED_NAME = "news-feed-name";
    public static final String NEWS_URL = "all_news.json";
    public static final int REFRESH_TIME = 1000 * 60 * 60;
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

                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Hydra.LOCALE);
                for (NewsItem newsItem : newsList) {
                    newsItem.dateDate = dateFormat.parse(newsItem.date);
                }

                // Get the old items
                ArrayList<NewsItem> oldList = cache.get(FEED_NAME);
                HashSet<Integer> readIds = new HashSet<Integer>();
                
                // If there are old items, do some magic!
                if(oldList != null) {
                    
                    // If they are read: add their ID to the set
                    for(NewsItem item : oldList) {
                        if(item.read) {
                            readIds.add(item.id);
                        }
                    }
                    
                    // Loop over the new set and set the read status accordingly
                    for(NewsItem item : newsList) {
                        if(readIds.contains(item.id)) {
                            item.read = true;
                        }
                    }
                    
                }
                
                // And save the list
                cache.put(FEED_NAME, newsList);
            }

            if (receiver != null) {
                receiver.send(STATUS_FINISHED, Bundle.EMPTY);
            }

        } catch (Exception e) {
            Log.e("[NewsIntentService]", "Exception:");
            e.printStackTrace();

            if (receiver != null) {
                receiver.send(STATUS_ERROR, Bundle.EMPTY);
            }
        }

    }
}

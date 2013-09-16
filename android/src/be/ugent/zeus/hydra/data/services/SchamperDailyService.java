package be.ugent.zeus.hydra.data.services;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.caches.ChannelCache;
import be.ugent.zeus.hydra.data.rss.Channel;
import be.ugent.zeus.hydra.data.rss.Item;
import be.ugent.zeus.hydra.util.RSSParser;
import java.util.HashSet;
import java.util.Set;

/**
 * TODO: Rework a bit, so we can show a notification if new schamper posts are
 * availble
 *
 * @author Thomas Meire
 */
public class SchamperDailyService extends HTTPIntentService {

    private static final String SCHAMPER_RSS_URL = "http://zeus.ugent.be/hydra/api/1.0/schamper/daily.xml";
    public static final int REFRESH_TIME = 1000 * 60 * 60;
    private ChannelCache cache;

    public SchamperDailyService() {
        super("SchamperDailyService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // get an instance of the menu cache
        cache = ChannelCache.getInstance(this);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);

        RSSParser parser = new RSSParser();
        try {

            String fetchedData = fetch(SCHAMPER_RSS_URL, cache.lastModified(ChannelCache.SCHAMPER));

            if (fetchedData != null) {
                Channel parse = parser.parse(fetchedData);

                Set<String> idSet = new HashSet<String>();
                for (Item item : parse.items) {
                    idSet.add(item.link);
                }

                // Get the read ID's
                SharedPreferences sharedPrefs = getSharedPreferences("be.ugent.zeus.hydra.schamper", Context.MODE_PRIVATE);
                Set<String> readItemSet = sharedPrefs.getAll().keySet();

                // Remove the items that do not exist anymore
                readItemSet.removeAll(idSet);

                for (String readItem : readItemSet) {
                    sharedPrefs.edit().remove(readItem);
                }
                sharedPrefs.edit().apply();

                // And put the items in the cache
                cache.put(ChannelCache.SCHAMPER, parse);
            }

            if (receiver != null) {
                receiver.send(STATUS_FINISHED, Bundle.EMPTY);
            }

        } catch (Exception e) {
            if (receiver != null) {
                receiver.send(STATUS_ERROR, Bundle.EMPTY);
            }
            Log.e("[SchamperDaily]", "An exception occured while downloading & parsing the schamper feed! (" + e.getMessage() + ")");
        }

    }
}

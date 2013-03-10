package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.caches.ChannelCache;
import be.ugent.zeus.hydra.util.RSSParser;

/**
 * TODO: Rework a bit, so we can show a notification if new schamper posts are availble
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
                cache.put(ChannelCache.SCHAMPER, parser.parse(fetchedData));
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

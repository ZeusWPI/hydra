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
        if (receiver != null) {
            receiver.send(STATUS_STARTED, Bundle.EMPTY);
        }

        boolean force = intent.getBooleanExtra(FORCE_UPDATE, true);

        RSSParser parser = new RSSParser();
        try {
            if (!cache.exists(ChannelCache.SCHAMPER)) {
                cache.put(ChannelCache.SCHAMPER, parser.parse(fetch(SCHAMPER_RSS_URL)));
            } else if (force) {
                // Exists, but we want to force an update (if it's changed)
                String content = fetch(SCHAMPER_RSS_URL, cache.lastModified(ChannelCache.SCHAMPER));
                if (content != null) {
                    cache.put(ChannelCache.SCHAMPER, parser.parse(content));
                }
            } else {
                // Exists, and don't force update, so ignore
            }
        } catch (Exception e) {
            Log.e("[SchamperDaily]", "An exception occured while downloading & parsing the schamper feed! (" + e.getMessage() + ")");
        }

        // send the result to the receiver
        if (receiver != null) {
            final Bundle bundle = new Bundle();
            receiver.send(STATUS_FINISHED, bundle);
        }
    }
}

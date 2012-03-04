package be.ugent.zeus.resto.client.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.resto.client.data.caches.ChannelCache;
import be.ugent.zeus.resto.client.data.rss.Channel;
import be.ugent.zeus.resto.client.util.RSSParser;

/**
 *
 * @author Thomas Meire
 */
public class SchamperDailyService extends HTTPIntentService {

  private static final String SCHAMPER_CACHE_KEY = "schamper";
  private static final String SCHAMPER_RSS_URL = "http://www.schamper.ugent.be/dagelijks";
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

  private void sync() {
    Log.i("[SchamperDaily]", "Fetching schamper feed from " + SCHAMPER_RSS_URL);

    long lastModified = cache.lastModified(SCHAMPER_CACHE_KEY);
    
    try {
      RSSParser parser = new RSSParser();
      Channel feed = parser.parse(fetch(SCHAMPER_RSS_URL, lastModified));
      cache.put(SCHAMPER_CACHE_KEY, feed);
    } catch (Exception e) {
      Log.e("[SchamperDaily]", "An exception occured while parsing the schamper feed!");
    }
  }

  @Override
  protected void onHandleIntent(Intent intent) {
    final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);
    if (receiver != null) {
      receiver.send(STATUS_STARTED, Bundle.EMPTY);
    }

    // get the menu from the local cache
    Channel channel = cache.get(SCHAMPER_CACHE_KEY);

    // if not in the cache, sync it from the rest service
    if (channel == null) {
      sync();
    }

    // send the result to the receiver
    if (receiver != null) {
      final Bundle bundle = new Bundle();
      receiver.send(STATUS_FINISHED, bundle);
    }
  }
}

package be.ugent.zeus.resto.client.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.resto.client.data.caches.ChannelCache;
import be.ugent.zeus.resto.client.util.RSSParser;

/**
 * TODO: Rework a bit, so we can show a notification if new schamper posts are availble
 * 
 * @author Thomas Meire
 */
public class SchamperDailyService extends HTTPIntentService {

  private static final long REFRESH_TIMEOUT = 24 * 60 * 60 * 1000;
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

  private void sync(long lastModified) {
    Log.i("[SchamperDaily]", "Fetching schamper feed from " + SCHAMPER_RSS_URL);

    RSSParser parser = new RSSParser();
    try {
      String content = (lastModified == -1) ? fetch(SCHAMPER_RSS_URL) : fetch(SCHAMPER_RSS_URL, lastModified);

      cache.put(ChannelCache.SCHAMPER, parser.parse(content));
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

    long lastModified = cache.lastModified(ChannelCache.SCHAMPER);

    if (lastModified == -1 || (System.currentTimeMillis() - lastModified) > REFRESH_TIMEOUT) {
      sync(lastModified);
    }

    // send the result to the receiver
    if (receiver != null) {
      final Bundle bundle = new Bundle();
      receiver.send(STATUS_FINISHED, bundle);
    }
  }
}

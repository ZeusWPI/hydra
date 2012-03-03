package be.ugent.zeus.resto.client;

import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.widget.ArrayAdapter;
import be.ugent.zeus.resto.client.data.caches.ChannelCache;
import be.ugent.zeus.resto.client.data.rss.Channel;
import be.ugent.zeus.resto.client.data.rss.Item;
import be.ugent.zeus.resto.client.data.services.HTTPIntentService;
import be.ugent.zeus.resto.client.data.services.SchamperDailyService;
import be.ugent.zeus.resto.client.ui.schamper.ChannelAdapter;

/**
 *
 * @author Thomas Meire
 */
public class SchamperDaily extends ListActivity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_schamper);

    Intent intent = new Intent(this, SchamperDailyService.class);
    intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new SchamperResultReceiver());
    startService(intent);
  }

  private class SchamperResultReceiver extends ResultReceiver {

    public SchamperResultReceiver() {
      super(null);
    }

    @Override
    public void onReceiveResult(int code, Bundle icicle) {
      switch (code) {
        case HTTPIntentService.STATUS_FINISHED:
          SchamperDaily.this.runOnUiThread(new Runnable() {

            public void run() {
              ChannelCache cache = ChannelCache.getInstance(SchamperDaily.this);
              Channel channel = cache.get("schamper");

              Log.i("[SchamperDaily]", "Retrieved channel '" + channel.title + "' with " + channel.items.size() + " items");
              if (channel != null) {
                setTitle(channel.title);

                ArrayAdapter<Item> adapter = new ChannelAdapter(SchamperDaily.this, channel);
                SchamperDaily.this.setListAdapter(adapter);
              } else {
                Log.e("[SchamperDaily]", "Noooooooo!!!! ");
              }
            }
          });
          break;
        case HTTPIntentService.STATUS_ERROR:
          // TODO: show toast & go back to dashboard
          break;
      }
    }
  }
}

package be.ugent.zeus.resto.client;

import android.app.ListActivity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import be.ugent.zeus.resto.client.data.caches.ChannelCache;
import be.ugent.zeus.resto.client.data.rss.Channel;
import be.ugent.zeus.resto.client.data.rss.Item;
import be.ugent.zeus.resto.client.data.services.HTTPIntentService;
import be.ugent.zeus.resto.client.data.services.SchamperDailyService;
import be.ugent.zeus.resto.client.ui.schamper.ChannelAdapter;

/**
 * TODO: add spinner while loading the feed similar to menu's
 * 
 * @author Thomas Meire
 */
public class SchamperDaily extends ListActivity {

  private static final long REFRESH_TIMEOUT = 24 * 60 * 60 * 1000;
  private ChannelCache cache = ChannelCache.getInstance(SchamperDaily.this);

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_schamper);

    View footer = getLayoutInflater().inflate(R.layout.schamper_footer, null);
    Button visitOnline = (Button) footer.findViewById(R.id.schamper_visit_online);
    visitOnline.setOnClickListener(new View.OnClickListener() {

      public void onClick(View arg0) {
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.setData(Uri.parse("http://www.schamper.ugent.be/editie/2012-online"));
        startActivity(i);
      }
    });
    getListView().addFooterView(footer);

    // if feed is older than 1 day or does not exist, refresh
    long age = cache.lastModified("schamper");
    if (age == -1 || age > REFRESH_TIMEOUT) {
      Intent intent = new Intent(this, SchamperDailyService.class);
      intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new SchamperResultReceiver());
      startService(intent);
    } else {
      show();
    }
  }

  private void show() {
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

  @Override
  protected void onListItemClick(ListView l, View v, int position, long id) {
    super.onListItemClick(l, v, position, id);

    // Get the item that was clicked
    Item item = (Item) getListAdapter().getItem(position);

    // Launch a new activity
    Intent intent = new Intent(this, SchamperDailyItem.class);
    intent.putExtra("item", item);
    startActivity(intent);
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
              show();
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

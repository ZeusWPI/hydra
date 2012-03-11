package be.ugent.zeus.resto.client;

import android.app.AlarmManager;
import android.app.ListActivity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;
import be.ugent.zeus.resto.client.data.caches.ChannelCache;
import be.ugent.zeus.resto.client.data.receivers.SchamperDailyReceiver;
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
  private ChannelCache cache;

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_schamper);
    getListView().setCacheColorHint(0);

    // add a button to the end of the list to read more online.
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

    cache = ChannelCache.getInstance(SchamperDaily.this);

    // if feed is older than 1 day or does not exist, refresh
    long age = System.currentTimeMillis() - cache.lastModified(ChannelCache.SCHAMPER);
    if (age == -1 || age > REFRESH_TIMEOUT) {
      refresh(false);
    } else {
      show();
    }
  }

  private void refresh(boolean force) {
    if (force) {
      cache.invalidate(ChannelCache.SCHAMPER);
    }
    Intent intent = new Intent(this, SchamperDailyService.class);
    intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new SchamperResultReceiver());
    startService(intent);
  }

  private void show() {
    Channel channel = cache.get(ChannelCache.SCHAMPER);

    if (channel != null) {
      Log.i("[SchamperDaily]", "Retrieved channel '" + channel.title + "' with " + channel.items.size() + " items");
      setTitle(channel.title);

      ArrayAdapter<Item> adapter = new ChannelAdapter(SchamperDaily.this, channel);
      SchamperDaily.this.setListAdapter(adapter);
    } else {
      Log.e("[SchamperDaily]", "Noooooooo!!!! ");
    }
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.schamper_daily, menu);
    return true;
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    // Handle item selection
    switch (item.getItemId()) {
      case R.id.refresh:
        refresh(true);
      default:
        return super.onOptionsItemSelected(item);
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
          Toast.makeText(SchamperDaily.this, R.string.schamper_update_failed, Toast.LENGTH_SHORT).show();
          // TODO: go back to dashboard if nothing to display
          break;
      }
    }
  }

  public static void scheduleRecurringUpdate(Context context) {
    AlarmManager am = (AlarmManager) context.getSystemService(ALARM_SERVICE);

    SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);

    Intent intent = new Intent(context, SchamperDailyReceiver.class);
    PendingIntent sender = PendingIntent.getBroadcast(context, 0, intent, 0);

    if (prefs.getBoolean("schamper_daily_auto_update", true)) {
      // get the auto update timeout in minutes
      int timeout = Integer.parseInt(prefs.getString("schamper_daily_auto_update_timeout", "60"));

      // setup an alarm to refresh the feed every timeout minutes
      am.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), timeout * 60 * 1000, sender);

      Log.d("[SchamperDaily]", "Scheduling recurring update alarm every " + timeout + " minutes.");
    } else {
      // cancel the alarm
      am.cancel(sender);

      Log.d("[SchamperDaily]", "Cancelled recurring update alarm.");
    }
  }
}

package be.ugent.zeus.resto.client;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import be.ugent.zeus.resto.client.data.services.HTTPIntentService;
import be.ugent.zeus.resto.client.data.services.UpdaterService;
import com.actionbarsherlock.app.SherlockActivity;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuInflater;
import com.actionbarsherlock.view.MenuItem;
import com.google.android.apps.analytics.GoogleAnalyticsTracker;

/**
 *
 * @author Thomas Meire
 */
public class Hydra extends SherlockActivity {

  GoogleAnalyticsTracker tracker;

  private void link(int id, final Class activity, final String name) {
    findViewById(id).setOnClickListener(new View.OnClickListener() {
      public void onClick(View view) {
        tracker.trackPageView("/" + name);
        startActivity(new Intent(Hydra.this, activity));
      }
    });
  }

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);

    tracker = GoogleAnalyticsTracker.getInstance();

    // Start the tracker in automatic dispatch mode...
    tracker.startNewSession("UA-25444917-3", 20, this);
    tracker.trackPageView("/Home");

    setContentView(R.layout.hydra);
    setTitle("");

    link(R.id.home_btn_news, News.class, "News");
    link(R.id.home_btn_calendar, Calendar.class, "Calendar");
    link(R.id.home_btn_info, Info.class, "Info");
    link(R.id.home_btn_menu, RestoMenu.class, "RestoMenu");
    link(R.id.home_btn_gsr, GSR.class, "GSR");
    link(R.id.home_btn_schamper, SchamperDaily.class, "Schamper");

    Intent intent = new Intent(this, UpdaterService.class);
    intent.putExtra(HTTPIntentService.FORCE_UPDATE, true);
    startService(intent);
  }

  /*
  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    MenuInflater inflater = getSupportMenuInflater();
    inflater.inflate(R.menu.hydra, menu);
    return true;
  }
  */

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    // Handle item selection
    switch (item.getItemId()) {
      case R.id.settings:
        Intent intent = new Intent(this, Settings.class);
        startActivity(intent);
        return true;
      default:
        return super.onOptionsItemSelected(item);
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    // Stop the tracker when it is no longer needed.
    tracker.stopSession();
  }
}

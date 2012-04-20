package be.ugent.zeus.resto.client;

import android.app.ListActivity;
import android.os.Bundle;
import android.widget.Toast;
import be.ugent.zeus.resto.client.data.Activity;
import be.ugent.zeus.resto.client.data.caches.ActivityCache;
import be.ugent.zeus.resto.client.ui.ActivityAdapter;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * TODO: needs swiping or buttons to go to the next days! cfr resto menu
 * 
 * @author blackskad
 */
public class Calendar extends ListActivity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_calendar);

    final String date = new SimpleDateFormat("dd-MM-yyyy").format(java.util.Calendar.getInstance().getTime());
    List<Activity> activities = ActivityCache.getInstance(this).get(date);
    if (activities == null || activities.isEmpty()) {
				Toast.makeText(this, "No activities available!", Toast.LENGTH_SHORT).show();
        finish();
    }

    setListAdapter(new ActivityAdapter(Calendar.this, activities));
  }
}

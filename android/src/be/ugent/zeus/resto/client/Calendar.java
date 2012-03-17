package be.ugent.zeus.resto.client;

import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.widget.ListAdapter;
import be.ugent.zeus.resto.client.data.services.ActivityIntentService;
import be.ugent.zeus.resto.client.data.services.HTTPIntentService;
import be.ugent.zeus.resto.client.ui.ActivityAdapter;
import java.text.SimpleDateFormat;

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

    Intent intent = new Intent(this, ActivityIntentService.class);
    intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new CalendarResultReceiver());
    startService(intent);
  }

  private class CalendarResultReceiver extends ResultReceiver {

    public CalendarResultReceiver() {
      super(null);
    }

    @Override
    public void onReceiveResult(int code, Bundle bundle) {
      if (code == HTTPIntentService.STATUS_FINISHED) {
        final String date = new SimpleDateFormat("dd-MM-yyyy").format(java.util.Calendar.getInstance().getTime());
        final ListAdapter adapter = new ActivityAdapter(Calendar.this, date);

        runOnUiThread(new Runnable() {

          public void run() {
            setTitle(date);
            setListAdapter(adapter);
          }
        });
      } else if (code == HTTPIntentService.STATUS_ERROR) {
        // TODO: show toaster
      }
    }
  }
}

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
        java.util.Calendar date = java.util.Calendar.getInstance();

        final ListAdapter adapter = new ActivityAdapter(Calendar.this, new SimpleDateFormat("dd-MM-yyyy").format(date.getTime()));
        runOnUiThread(new Runnable() {

          public void run() {
            setListAdapter(adapter);
          }
        });
      } else if (code == HTTPIntentService.STATUS_ERROR) {
        // TODO: show toaster
      }
    }
  }
}

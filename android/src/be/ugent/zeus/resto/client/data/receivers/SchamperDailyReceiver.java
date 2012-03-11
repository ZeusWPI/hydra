package be.ugent.zeus.resto.client.data.receivers;

import android.app.Notification;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.widget.Toast;
import be.ugent.zeus.resto.client.data.services.HTTPIntentService;
import be.ugent.zeus.resto.client.data.services.SchamperDailyService;

/**
 *
 * @author Thomas Meire
 */
public class SchamperDailyReceiver extends BroadcastReceiver {
  
  private static final String DEBUG_TAG = "SchamperDailyReceiver";
  
  @Override
  public void onReceive(Context context, Intent intent) {
    Log.d(DEBUG_TAG, "Recurring alarm; requesting Schamper Daily refresh service.");

    Toast toast = Toast.makeText(context, "Schamper Daily freshing...", Toast.LENGTH_SHORT);
    toast.show();
    
    // start the refresh
    Intent refresher = new Intent(context, SchamperDailyService.class);
    refresher.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new ResultReceiver(null) {
      
      @Override
      public void onReceiveResult(int code, Bundle data) {
        if (code == SchamperDailyService.STATUS_ERROR) {
          Log.e(DEBUG_TAG, "An error occured during the recurring schamper update.");
        }
      }
    });
    context.startService(refresher);
  }
}

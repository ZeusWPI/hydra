package be.ugent.zeus.hydra.data.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.data.services.SchamperDailyService;

/**
 *
 * @author Thomas Meire
 */
public class SchamperDailyReceiver extends BroadcastReceiver {

  private static final String DEBUG_TAG = "SchamperDailyReceiver";

  @Override
  public void onReceive(Context context, Intent intent) {
    Log.d(DEBUG_TAG, "Recurring alarm; requesting Schamper Daily refresh service.");

    // start the refresh
    Intent refresher = new Intent(context, SchamperDailyService.class);
    refresher.putExtra(HTTPIntentService.FORCE_UPDATE, true);
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

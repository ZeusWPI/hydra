package be.ugent.zeus.resto.client.data.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import be.ugent.zeus.resto.client.SchamperDaily;

/**
 *
 * @author Thomas Meire
 */
public class BootReceiver extends BroadcastReceiver {
  
  @Override
  public void onReceive(Context context, Intent arg1) {
    // schedule the alarm for the schamper daily refresh (every hour)
    SchamperDaily.scheduleRecurringUpdate(context);
  }
}

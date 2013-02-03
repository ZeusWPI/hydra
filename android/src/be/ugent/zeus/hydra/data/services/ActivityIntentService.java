package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.data.caches.ActivityCache;
import be.ugent.zeus.hydra.util.ActivityXmlParser;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 *
 * @author Thomas Meire
 */
public class ActivityIntentService extends HTTPIntentService {

    public ActivityIntentService() {
        super("ActivityIntentService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);

        if (receiver != null) {
            receiver.send(STATUS_STARTED, Bundle.EMPTY);
        }

        ActivityXmlParser parser = new ActivityXmlParser();
        try {
            List<Activity> activities = parser.parse(fetch(HYDRA_BASE_URL + "all_activities.xml"));

            Map<String, ArrayList<Activity>> groups = new HashMap<String, ArrayList<Activity>>();

            // group them in lists by date
            for (Activity activity : activities) {
                ArrayList<Activity> group = groups.get(activity.date);
                if (group == null) {
                    group = new ArrayList<Activity>();
                    groups.put(activity.date, group);
                }
                group.add(activity);
            }

            ActivityCache cache = ActivityCache.getInstance(this);

            // dump the lists in the cache
            for (Entry<String, ArrayList<Activity>> group : groups.entrySet()) {
                cache.put(group.getKey(), group.getValue());
            }
        } catch (Exception e) {
            if (receiver != null) {
                receiver.send(STATUS_ERROR, Bundle.EMPTY);
            }
            return;
        }
        if (receiver != null) {
            receiver.send(STATUS_FINISHED, Bundle.EMPTY);
        }
    }
}

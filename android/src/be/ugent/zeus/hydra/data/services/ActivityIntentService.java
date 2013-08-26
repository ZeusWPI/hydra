package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import be.ugent.zeus.hydra.Hydra;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.data.caches.ActivityCache;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import org.json.JSONArray;

/**
 *
 * @author Thomas Meire
 */
public class ActivityIntentService extends HTTPIntentService {

    public static final String FEED_NAME = "activities-feed-name";
    public static final String ACTIVITY_URL = "all_activities.json";
    public static final int REFRESH_TIME = 1000 * 60 * 60;
    private ActivityCache cache;

    public ActivityIntentService() {
        super("ActivityIntentService");
        cache = ActivityCache.getInstance(this);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);

        try {

            String fetchedData = fetch(HYDRA_BASE_URL + "all_activities.json", cache.lastModified(FEED_NAME));

            if (fetchedData != null) {
                ArrayList<Activity> activities = new ArrayList<Activity>(Arrays.asList(parseJsonArray(new JSONArray(fetchedData), Activity.class)));

                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Hydra.LOCALE);

                for (Activity activity : activities) {
                    activity.startDate = dateFormat.parse(activity.start);
                    activity.endDate = dateFormat.parse(activity.end);
                }

                cache.put(FEED_NAME, activities);

            }

            if (receiver != null) {
                receiver.send(STATUS_FINISHED, Bundle.EMPTY);
            }

        } catch (Exception e) {
            if (receiver != null) {
                receiver.send(STATUS_ERROR, Bundle.EMPTY);
            }
            e.printStackTrace();
        }
    }
}

package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.RestoLegend;
import be.ugent.zeus.hydra.data.caches.LegendCache;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Thomas Meire
 */
public class LegendService extends HTTPIntentService {


    public static final String FEED_NAME = "resto-legend-cache";
    public static final int REFRESH_TIME = 1000 * 60 * 60 * 24;
    private static final String RESTO_URL = "http://zeus.ugent.be/hydra/api/1.0/resto/meta.json";
    private LegendCache legendCache;

    public LegendService() {
        super("LegendService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        legendCache = LegendCache.getInstance(this);
    }

    private void sync() {
        Log.i("[RestoFetcherThread]", "Fetching resto's from " + RESTO_URL);

        try {
            JSONObject raw_data = new JSONObject(fetch(RESTO_URL));

            ArrayList<RestoLegend> legendList = new ArrayList<RestoLegend>(Arrays.asList(parseJsonArray(new JSONArray(raw_data.getString("legend")), RestoLegend.class)));

            legendCache.put(FEED_NAME, legendList);

        } catch (Exception e) {
            Log.e("[RestoService]", "An exception occured while parsing the json response! " + e.getMessage());
        }
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);
        if (receiver != null) {
            receiver.send(STATUS_STARTED, Bundle.EMPTY);
        }

        // get the menu from the local cache
        List<RestoLegend> restos = legendCache.get(FEED_NAME);

        // if not in the cache, sync it from the rest service
        if (restos == null || restos.isEmpty()) {
            sync();
        }

        // send the result to the receiver
        if (receiver != null) {
            final Bundle bundle = new Bundle();
            receiver.send(STATUS_FINISHED, bundle);
        }
    }
}

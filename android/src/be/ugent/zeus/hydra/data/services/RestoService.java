package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.Resto;
import be.ugent.zeus.hydra.data.caches.RestoCache;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Thomas Meire
 */
public class RestoService extends HTTPIntentService {

    public static final String FEED_NAME = "restos";
    public static final int REFRESH_TIME = 1000 * 60 * 60 * 24 * 7;
    private static final String RESTO_URL = "http://zeus.ugent.be/hydra/api/1.0/resto/meta.json";
    private RestoCache cache;

    public RestoService() {
        super("RestoService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // get an instance of the menu cache
        cache = RestoCache.getInstance(this);
    }

    private void sync() {
        Log.i("[RestoFetcherThread]", "Fetching resto's from " + RESTO_URL);

        try {
            JSONObject raw_data = new JSONObject(fetch(RESTO_URL));
            JSONArray data = new JSONArray(raw_data.getString("locations"));
            Resto[] restos = parseJsonArray(data, Resto.class);
            cache.put(FEED_NAME, restos);
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
        Resto[] restos = cache.get(FEED_NAME);

        // if not in the cache, sync it from the rest service
        if (restos == null || restos.length == 0) {
            sync();
        }

        // send the result to the receiver
        if (receiver != null) {
            final Bundle bundle = new Bundle();
            receiver.send(STATUS_FINISHED, bundle);
        }
    }
}

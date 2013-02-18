package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.Resto;
import be.ugent.zeus.hydra.data.RestoLegend;
import be.ugent.zeus.hydra.data.caches.LegendCache;
import be.ugent.zeus.hydra.data.caches.RestoCache;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Thomas Meire
 */
public class LegendService extends HTTPIntentService {

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
            
            JSONArray legend = new JSONArray(raw_data.getString("legend"));
            RestoLegend[] restoLegend = parseJsonArray(legend, RestoLegend.class);
            for (RestoLegend l : restoLegend) {
                legendCache.put(l.key, l);
            }
            
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
        List<RestoLegend> restos = legendCache.getAll();

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

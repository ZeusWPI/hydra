package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.Resto;
import be.ugent.zeus.hydra.data.caches.RestoCache;
import java.util.List;
import org.json.JSONArray;

/**
 *
 * @author Thomas Meire
 */
public class RestoService extends HTTPIntentService {

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
            JSONArray data = new JSONArray(fetch(RESTO_URL));
            Resto[] restos = parseJsonArray(data, Resto.class);
            for (Resto r : restos) {
                cache.put(r.name, r);
            }
        } catch (Exception e) {
            Log.e("[RestoService]", "An exception occured while parsing the json response!");
        }
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);
        if (receiver != null) {
            receiver.send(STATUS_STARTED, Bundle.EMPTY);
        }

        // get the menu from the local cache
        List<Resto> restos = cache.getAll();

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

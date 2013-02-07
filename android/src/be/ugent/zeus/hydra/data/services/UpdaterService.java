package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

/**
 *
 * @author Thomas Meire
 */
public class UpdaterService extends HTTPIntentService {

    private static final String LAST_UPDATE = "last-global-update";
    public static final int CACHE_REFRESH = 0 * 60;

    public UpdaterService() {
        super("UpdaterService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);

        long last = prefs.getLong(LAST_UPDATE, 0);

        if (System.currentTimeMillis() - last < CACHE_REFRESH) {
            Log.i("[UpdaterService]", "Cache is still fresh. Don't update.");

        } else {

            prefs.edit().putLong(LAST_UPDATE, System.currentTimeMillis()).commit();
            refreshNewsCache();
            refreshActivityCache();
        }
    }

    public void refreshNewsCache() {
        Intent intent = new Intent(this, NewsIntentService.class);
        intent.putExtra(HTTPIntentService.FORCE_UPDATE, true);
        startService(intent);
    }

    public void refreshActivityCache() {
        Intent intent = new Intent(this, ActivityIntentService.class);
        intent.putExtra(HTTPIntentService.FORCE_UPDATE, true);
        startService(intent);
    }
}

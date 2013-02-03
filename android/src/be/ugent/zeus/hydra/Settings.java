package be.ugent.zeus.hydra;

import com.actionbarsherlock.app.SherlockPreferenceActivity;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.R;

/**
 *
 * @author blackskad
 */
public class Settings extends SherlockPreferenceActivity implements SharedPreferences.OnSharedPreferenceChangeListener {

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_preferences);

        /**
         * FIXME: disable color cache hint. Might be good to set it to R.color.ugent_yellow_light
         * but doing to turns the rows black.
         */
        getListView().setCacheColorHint(0);

        addPreferencesFromResource(R.xml.preferences);

        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        prefs.registerOnSharedPreferenceChangeListener(this);
    }

    public void onSharedPreferenceChanged(SharedPreferences prefs, String key) {
        if (key == null) {
            Log.e("[Settings]", "WTF, changed preference key is null...?!");
        }
    }
}

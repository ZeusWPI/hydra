package be.ugent.zeus.hydra.settings;

import android.content.SharedPreferences;
import android.os.Bundle;
import be.ugent.zeus.hydra.AbstractSherlockPreferenceActivity;
import be.ugent.zeus.hydra.R;

/**
 *
 * @author Silox
 */
public class Settings extends AbstractSherlockPreferenceActivity implements SharedPreferences.OnSharedPreferenceChangeListener {

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_preferences);
        addPreferencesFromResource(R.xml.settings);
    }

    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
    }
}
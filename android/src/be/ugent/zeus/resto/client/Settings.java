package be.ugent.zeus.resto.client;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;
import android.util.Log;

/**
 *
 * @author blackskad
 */
public class Settings extends PreferenceActivity implements SharedPreferences.OnSharedPreferenceChangeListener {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_preferences);

    /**
     * FIXME: disable color cache hint. Might be good to set it to
     * R.color.ugent_yellow_light but doing to turns the rows black.
     */
    getListView().setCacheColorHint(0);

    addPreferencesFromResource(R.xml.preferences);

    SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
    prefs.registerOnSharedPreferenceChangeListener(this);
  }

  public void onSharedPreferenceChanged(SharedPreferences prefs, String key) {
    if (key == null) {
      Log.e("[HeraclesPreferences]", "WTF, changed preference key is null...?!");
    }
    Log.d("[prefs]", "Pref changed: " + key);
    if (key.startsWith("schamper_daily_auto_update")) {
      SchamperDaily.scheduleRecurringUpdate(this);
    }
  }
}

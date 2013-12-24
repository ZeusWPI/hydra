package be.ugent.zeus.hydra.settings;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import be.ugent.zeus.hydra.AbstractSherlockPreferenceActivity;
import be.ugent.zeus.hydra.R;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;

/**
 *
 * @author Silox
 */
public class Settings extends AbstractSherlockPreferenceActivity implements SharedPreferences.OnSharedPreferenceChangeListener {

    private UiLifecycleHelper uiHelper;

    public class SessionStatusCallback implements Session.StatusCallback {

        @Override
        public void call(Session session, SessionState state, Exception exception) {
            onSessionStateChange(session, state, exception);
        }
    }

    private void onSessionStateChange(Session session, SessionState state, Exception exception) {
        Log.i("FACEBOOK", "Onsessionstatechange: " + state.toString());
    }

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_preferences);
        addPreferencesFromResource(R.xml.settings);

        /**
         * Facebook
         */
        boolean firstrun = getSharedPreferences("PREFERENCE", MODE_PRIVATE).getBoolean("advertise_facebook", true);
        if (firstrun) {
            getSharedPreferences("PREFERENCE", MODE_PRIVATE)
                .edit()
                .putBoolean("advertise_facebook", false)
                .commit();
        }

        Settings.SessionStatusCallback statusCallback = new Settings.SessionStatusCallback();
        uiHelper = new UiLifecycleHelper(this, statusCallback);

        uiHelper.onCreate(icicle);
        Session session = Session.getActiveSession();
        if (session == null || !session.isOpened()) {

            if (icicle != null) {
                session = Session.restoreSession(this, null, statusCallback, icicle);
            }
            if (session == null) {
                session = new Session(this);
            }
            if (session.getState().equals(SessionState.CREATED_TOKEN_LOADED)) {
                session.openForRead(new Session.OpenRequest(this).setCallback(statusCallback));
            } else if (session.getState().equals(SessionState.CREATED)) {
                Session.openActiveSession(this, false, statusCallback);
            }

            onSessionStateChange(session, session.getState(), null);

        } else if (session.isOpened() || session.isClosed()) {
            onSessionStateChange(session, session.getState(), null);
        }

    }

    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
    }

    @Override
    public void onResume() {
        super.onResume();

        uiHelper.onResume();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        uiHelper.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onPause() {
        super.onPause();

        uiHelper.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        uiHelper.onDestroy();
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);

        uiHelper.onSaveInstanceState(outState);
    }
}

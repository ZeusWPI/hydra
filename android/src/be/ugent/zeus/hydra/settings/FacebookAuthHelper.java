/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.settings;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import be.ugent.zeus.hydra.AbstractSherlockActivity;
import be.ugent.zeus.hydra.R;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;

public class FacebookAuthHelper extends AbstractSherlockActivity {

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

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setTitle(R.string.details);
        setContentView(R.layout.settings_facebook);

        /**
         * Facebook
         */
        FacebookAuthHelper.SessionStatusCallback statusCallback = new FacebookAuthHelper.SessionStatusCallback();

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

        } else if (session != null
            && (session.isOpened() || session.isClosed())) {
            onSessionStateChange(session, session.getState(), null);
        }


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

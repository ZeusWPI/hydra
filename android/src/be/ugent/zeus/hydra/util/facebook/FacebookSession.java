/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import be.ugent.zeus.hydra.Hydra;
import com.facebook.Session;
import com.facebook.SessionState;

public class FacebookSession {

    private static FacebookSession fbSession;
    private static final String TAG = "FACEBOOK";
    private Session session;
    private Session.StatusCallback statusCallback = new SessionStatusCallback();

    protected FacebookSession(Bundle savedInstanceState, Context context, Activity activity) {
        session = Session.getActiveSession();
        if (session == null) {
            if (savedInstanceState != null) {
                session = Session.restoreSession(context, null, statusCallback, savedInstanceState);
            }
            if (session == null) {
                session = new Session(context);
                session.addCallback(statusCallback);
            }
            Session.setActiveSession(session);
            if (session.getState().equals(SessionState.CREATED_TOKEN_LOADED)) {
                session.openForRead(new Session.OpenRequest(activity));
            }
        }
    }

    public static FacebookSession getInstance(Bundle savedInstanceState, Context context, Activity activity) {

        if (fbSession == null) {
            fbSession = new FacebookSession(savedInstanceState, context, activity);
        }

        return fbSession;
    }

    public void tryOpenSession(Activity activity) {
        Session.openActiveSession(activity, false, statusCallback);
    }
    
    public void login(Activity activity, boolean allowLoginUI) {
        if (!session.isOpened() && !session.isClosed()) {
            session.openForRead(new Session.OpenRequest(activity).setCallback(statusCallback));
        } else {
            Session.openActiveSession(activity, allowLoginUI, statusCallback);
        }
    }

    public void logout() {
        if (!session.isClosed()) {
            session.closeAndClearTokenInformation();
        }
    }

    public boolean isOpen() {
        return session.isOpened();
    }

    private class SessionStatusCallback implements Session.StatusCallback {

        @Override
        public void call(Session session, SessionState state, Exception exception) {

            Log.i(TAG, state.toString());

            switch (state) {
                case CLOSED:
                case CLOSED_LOGIN_FAILED:
                    session.closeAndClearTokenInformation();
                    break;
                default:
                    break;
            }
        }
    }
}

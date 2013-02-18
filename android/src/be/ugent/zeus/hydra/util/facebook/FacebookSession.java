/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook;

import android.R;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import com.facebook.HttpMethod;
import com.facebook.Request;
import com.facebook.Session;
import com.facebook.SessionState;

public class FacebookSession {

    private static final String APP_ID = "146947948791011";
    private static final String ACCESS_TOKEN = "146947948791011|QqOR99OREkC_vAvOkfJm2tp-02k";
    private static FacebookSession fbSession;
    public static final String TAG = "FACEBOOK";
    private Activity activity;
    private Context context;
    private Session.StatusCallback statusCallback = new SessionStatusCallback();

    protected FacebookSession(Activity activity, Context context) {
        this.activity = activity;
        this.context = context;
        
        Session session = Session.getActiveSession();
        if (session == null) {
            session = new Session.Builder(context)
                .setApplicationId(APP_ID)
                .build();
            session.addCallback(statusCallback);
            Session.setActiveSession(session);
        }
    }

    public static FacebookSession getInstance(Activity activity, Context context) {

        if (fbSession == null) {
            fbSession = new FacebookSession(activity, context);
        }

        return fbSession;
    }

    public Session getSession() {
        return Session.getActiveSession();
    }

    public void tryOpenSession(Activity activity) {
        Session session = Session.openActiveSession(activity, false, statusCallback);
        Session.setActiveSession(session);
    }

    public void login(Activity activity, boolean allowLoginUI) {
        Session session = Session.getActiveSession();

        if (!session.isOpened() && !session.isClosed()) {
            session.openForRead(new Session.OpenRequest(activity).setCallback(statusCallback));
        } else {
            Session.openActiveSession(activity, allowLoginUI, statusCallback);
        }
    }

    public void logout() {
        Session session = Session.getActiveSession();

        if (!session.isClosed()) {
            session.closeAndClearTokenInformation();
        }
    }

    public boolean isOpen() {

        Session session = Session.getActiveSession();
        return session.isOpened();
    }

    public Request requestWithQuery(String query) {
        
        Bundle bundle = new Bundle();
        bundle.putString("q", query);
        
        return requestWithGraphPath("/fql", bundle, "GET");
    }

    private Request requestWithGraphPath(String path, Bundle bundle, String method) {

        // Get the session
        Session session = Session.getActiveSession();

        // No session? Try to open one without user interaction
        if (session == null) {
            session = Session.openActiveSession(activity, false, statusCallback);
            Session.setActiveSession(session);
        }

        // Still no session? Use the default key
        if(session == null) {
            bundle.putString("acces_token", ACCESS_TOKEN);
        }

        return new Request(session, path, bundle, HttpMethod.valueOf(method));
        
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

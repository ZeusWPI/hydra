/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook;

import android.util.Log;
import com.facebook.Session;
import com.facebook.SessionState;

public class Callback implements Session.StatusCallback {

    public static final String TAG = "FACEBOOK";
    
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
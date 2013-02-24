/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook;

import android.os.Bundle;
import be.ugent.zeus.hydra.ActivityItemActivity;
import com.facebook.HttpMethod;
import com.facebook.Request;
import com.facebook.Session;

public class RequestBuilder {

    public static final String ACCESS_TOKEN = "146947948791011|QqOR99OREkC_vAvOkfJm2tp-02k";
    public static final String TAG = "FACEBOOK";
    private static Session.StatusCallback statusCallback = new Callback();

    public static Request requestWithQuery(String query) {

        Bundle bundle = new Bundle();
        bundle.putString("q", query);

        return requestWithGraphPath("/fql", bundle, "GET");
    }

    private static Request requestWithGraphPath(String path, Bundle bundle, String method) {

        // Get the session
        Session session = Session.getActiveSession();

        // Still no session? Use the default key
        if (session == null || !session.isOpened()) {
            session = null;
            bundle.putString("access_token", ACCESS_TOKEN);
        }

        return new Request(session, path, bundle, HttpMethod.valueOf(method));

    }
}

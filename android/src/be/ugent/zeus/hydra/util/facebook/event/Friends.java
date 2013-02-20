/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook.event;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;
import be.ugent.zeus.hydra.util.facebook.FacebookSession;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.model.GraphObject;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 *
 * @author silox
 */
public class Friends extends AsyncTask<Void, Void, String> {

    String eventId;
    Activity activity;
    TextView friends;

    public Friends(Activity activity, String eventId, TextView friends) {
        this.activity = activity;
        this.eventId = eventId;
        this.friends = friends;
    }

    @Override
    protected void onPreExecute() {
        friends.setText("Laden...");
    }

    @Override
    protected String doInBackground(Void... params) {
        Log.i(FacebookSession.TAG, "Fetching event with id " + eventId);

        String query = String.format(
            "SELECT name, pic_square FROM user WHERE uid IN"
            + "(SELECT uid2 FROM friend WHERE uid1 = me() AND uid2 IN"
            + "(SELECT uid FROM event_member WHERE eid = '%s' "
            + "AND rsvp_status = 'attending'))", eventId);

        

        Request requestWithQuery = FacebookSession.requestWithQuery(query);

        Response response = requestWithQuery.executeAndWait();

        if (response.getError() != null) {
            Log.e(FacebookSession.TAG, response.getError().getErrorCode() + ": " + response.getError().getErrorMessage());
            return null;
        }

        //GraphObject object = response.getGraphObject();



//        JSONObject obj = null;
//        try {
//            obj = ((JSONArray) object.getProperty("data")).getJSONObject(0);
//        } catch (JSONException ex) {
//        }

        return response.toString();
    }

    @Override
    protected void onPostExecute(String result) {
        friends.setText(result);
    }
}

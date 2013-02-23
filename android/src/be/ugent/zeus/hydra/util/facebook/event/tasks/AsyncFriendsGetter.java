/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook.event.tasks;

import android.os.AsyncTask;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.util.facebook.FacebookSession;
import be.ugent.zeus.hydra.util.facebook.event.data.Friend;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.model.GraphObject;
import java.util.Arrays;
import java.util.Collections;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;

/**
 *
 * @author silox
 */
public class AsyncFriendsGetter extends AsyncTask<Void, Void, JSONArray> {

    String eventId;
    TextView guests;
    ImageView[] guestIcons;

    public AsyncFriendsGetter(String eventId, TextView guests, ImageView[] guestIcons) {
        this.eventId = eventId;
        this.guests = guests;
        this.guestIcons = guestIcons;
    }

    @Override
    protected void onPreExecute() {
        guests.setText("Laden...");
    }

    @Override
    protected JSONArray doInBackground(Void... params) {
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

        GraphObject object = response.getGraphObject();


        return ((JSONArray) object.getProperty("data"));
    }

    @Override
    protected void onPostExecute(JSONArray result) {
        if (result != null && result.length() > 0) {
            guests.setText(guests.getText() + ", " + String.valueOf(result.length()) + " vrienden");

            Friend[] friends = null;

            try {
                friends = HTTPIntentService.parseJsonArray(result, Friend.class);
            } catch (Exception ex) {
                Logger.getLogger(AsyncFriendsGetter.class.getName()).log(Level.SEVERE, null, ex);
            }

            Collections.shuffle(Arrays.asList(friends));

            int showMax = Math.min(result.length(), 5);

            for (int i = 0; i < showMax; i++) {
                new AsyncPicGetter(guestIcons[i], friends[i].pic_square).execute();
            }
        }
    }
}

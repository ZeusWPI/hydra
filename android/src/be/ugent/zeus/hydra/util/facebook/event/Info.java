/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook.event;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;
import be.ugent.zeus.hydra.util.facebook.FacebookSession;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.model.GraphObject;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 *
 * @author silox
 */
public class Info extends AsyncTask<Void, Void, JSONObject> {

    String eventId;
    Bundle icicle;
    Context context;
    Activity activity;
    TextView gasten;
    ImageView image;

    public Info(Bundle icicle, Context context, Activity activity, String eventId, TextView gasten, ImageView image) {
        this.icicle = icicle;
        this.context = context;
        this.activity = activity;
        this.eventId = eventId;
        this.gasten = gasten;
        this.image = image;
    }

    @Override
    protected void onPreExecute() {
        gasten.setText("Laden...");
    }

    @Override
    protected JSONObject doInBackground(Void... params) {
        Log.i(FacebookSession.TAG, "Fetching event with id " + eventId);

        String query = String.format("SELECT attending_count, pic, pic_big FROM event WHERE eid = '%s'", eventId);
        Request requestWithQuery = FacebookSession.getInstance(icicle, activity, context).requestWithQuery(query);

        Response response = requestWithQuery.executeAndWait();

        if (response.getError() != null) {
            Log.e(FacebookSession.TAG, response.getError().getErrorCode() + ": " + response.getError().getErrorMessage());
            return null;
        }
        GraphObject object = response.getGraphObject();
        JSONObject obj = null;
        try {
            obj = ((JSONArray) object.getProperty("data")).getJSONObject(0);
        } catch (JSONException ex) {
        }

        return obj;
    }

    @Override
    protected void onPostExecute(JSONObject result) {

        if (result != null && result.length() > 0) {
            String count = "";
            String picUrl = "";
            try {
                count = String.valueOf(result.getInt("attending_count"));
                picUrl = result.getString("pic").replace("\\/", "/");
                new Pic(image, picUrl).execute();
            } catch (JSONException ex) {
            }

            gasten.setText(count);
        }
    }
}

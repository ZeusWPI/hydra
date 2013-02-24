/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook.event.tasks;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import be.ugent.zeus.hydra.util.facebook.FacebookSession;
import be.ugent.zeus.hydra.util.facebook.event.data.AttendingStatus;
import com.facebook.HttpMethod;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.model.GraphObject;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 *
 * @author silox
 */
public class AsyncComingSetter extends AsyncTask<Void, Void, Void> {

    Context context;
    String eventId;
    Button button;
    AttendingStatus status;

    public AsyncComingSetter(Context context, String eventId, Button button, AttendingStatus status) {
        this.context = context;
        this.eventId = eventId;
        this.button = button;
        this.status = status;
    }

    @Override
    protected void onPreExecute() {
    }

    @Override
    protected Void doInBackground(Void... params) {
        Log.i(FacebookSession.TAG, "Fetching event with id " + eventId);

        String query = String.format("%s/%s", eventId, status.toString().toLowerCase());


        Request request = new Request(Session.getActiveSession(), query, Bundle.EMPTY, HttpMethod.POST);

        Response response = request.executeAndWait();

        if (response.getError() != null) {
            Log.e(FacebookSession.TAG, response.getError().getErrorCode() + ": " + response.getError().getErrorMessage());
            return null;
        }
        
        Log.i(FacebookSession.TAG, "Response: " + response.toString());
        
        return null;
    }

    @Override
    protected void onPostExecute(Void result) {
        button.setText(status.toButtonString(context));
    }
}

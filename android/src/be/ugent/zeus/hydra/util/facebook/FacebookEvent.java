/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import com.facebook.Request;
import com.facebook.Response;

/**
 *
 * @author silox
 */
public class FacebookEvent extends AsyncTask<Object, Object, Object> {
    
    String eventId;
    Context context;
    Activity activity;
    
    public FacebookEvent(Context context, Activity activity, String eventId) {
        this.context = context;
        this.activity = activity;
        this.eventId = eventId;
    }
    
    public void sharedInit() {
    }
    
    public void update() {
        fetchEventInfo();
//        fetchUserInfo();
//        fetchFriendsInfo();
    }
    
    public void fetchEventInfo() {
        Log.i(FacebookSession.TAG, "Fetching event with id " + eventId);
        
        String query = String.format("SELECT attending_count, pic, pic_big FROM event WHERE eid = '%s'", eventId);
        Request requestWithQuery = FacebookSession.getInstance(activity, context).requestWithQuery(query);
        requestWithQuery.setCallback(new Request.Callback() {

            public void onCompleted(Response response) {
                Log.i(FacebookSession.TAG, response.toString());
            }
        });
        
        Response response = requestWithQuery.executeAndWait();
        
    }

    @Override
    protected Object doInBackground(Object... params) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}

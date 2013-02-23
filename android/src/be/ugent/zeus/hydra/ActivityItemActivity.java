/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;
import android.util.Log;
import android.view.View;
import android.view.ViewManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.util.facebook.FacebookSession;
import be.ugent.zeus.hydra.util.facebook.event.tasks.AsyncFriendsGetter;
import be.ugent.zeus.hydra.util.facebook.event.tasks.AsyncInfoGetter;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;
import com.google.analytics.tracking.android.EasyTracker;
import java.text.SimpleDateFormat;

public class ActivityItemActivity extends AbstractSherlockActivity {

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
        setContentView(R.layout.activity_item);


        /**
         * Get the activity
         */
        final Activity item = (Activity) getIntent().getSerializableExtra("item");

        EasyTracker.getTracker().sendView("Activity > " + item.title);

        /**
         * Facebook
         */
        SessionStatusCallback statusCallback = new ActivityItemActivity.SessionStatusCallback();

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
            Log.i(FacebookSession.TAG, "Current state: " + session.getState().toString());
            if (session.getState().equals(SessionState.CREATED_TOKEN_LOADED)) {
                session.openForRead(new Session.OpenRequest(this).setCallback(statusCallback));
            } else if (session.getState().equals(SessionState.CREATED)) {
                Session.openActiveSession(this, true, statusCallback);
            }

        } else if (session != null
            && (session.isOpened() || session.isClosed())) {
            onSessionStateChange(session, session.getState(), null);
        }

        /**
         * Image
         */
        ImageView image = (ImageView) findViewById(R.id.activity_item_image);

        /**
         * Title
         */
        TextView title = (TextView) findViewById(R.id.activity_item_title);
        title.setText(item.title);

        /**
         * Date
         */
        TextView date = (TextView) findViewById(R.id.activity_item_date);
        String datum =
            new SimpleDateFormat("EEE dd MMMM", Hydra.LOCALE).format(item.startDate);
        String start =
            new SimpleDateFormat("HH:mm", Hydra.LOCALE).format(item.startDate);
        String eind =
            new SimpleDateFormat("HH:mm", Hydra.LOCALE).format(item.endDate);

        date.setText(
            String.format(getResources().getString(R.string.activity_item_time_location),
            datum, start, eind));

        /**
         * Association
         */
        TextView association = (TextView) findViewById(R.id.activity_item_association);

        String poster = item.association.display_name;
        if (item.association.full_name != null) {
            poster += " (" + item.association.full_name + ")";
        }

        association.setText(
            String.format(getResources().getString(R.string.activity_item_association_title), poster));

        /**
         * Location
         */
        TextView location = (TextView) findViewById(R.id.activity_item_location);

        if (item.location == null || "".equals(item.location)) {

            LinearLayout locationContainer = (LinearLayout) findViewById(R.id.activity_item_location_container);
            View locationContainerBottomBorder = (View) findViewById(R.id.activity_item_location_bottomborder);

            ((ViewManager) locationContainer.getParent()).removeView(locationContainer);
            ((ViewManager) locationContainerBottomBorder.getParent()).removeView(locationContainerBottomBorder);

        } else {

            location.setText(item.location);
            ImageView directions = (ImageView) findViewById(R.id.activity_item_directions);

            if (item.latitude != 0 && item.longitude != 0) {
                directions.setOnClickListener(new View.OnClickListener() {
                    public void onClick(View v) {
                        onDirectionsClick(item.latitude, item.longitude);
                    }
                });

            } else {

                directions.setVisibility(View.INVISIBLE);
            }
        }


        /**
         * Facebook friends
         */
        LinearLayout guestsContainer = (LinearLayout) findViewById(R.id.activity_item_guests_container);
        View guestsBottomBorder = (View) findViewById(R.id.activity_item_guests_bottomborder);
        ImageView external = (ImageView) findViewById(R.id.activity_item_facebook_external);

        if (item.facebook_id == null) {
            ((ViewManager) guestsContainer.getParent()).removeView(guestsContainer);
            ((ViewManager) guestsBottomBorder.getParent()).removeView(guestsBottomBorder);
        } else {
            ImageView[] guestIcons = new ImageView[5];
            guestIcons[0] = (ImageView) findViewById(R.id.activity_item_friends1);
            guestIcons[1] = (ImageView) findViewById(R.id.activity_item_friends2);
            guestIcons[2] = (ImageView) findViewById(R.id.activity_item_friends3);
            guestIcons[3] = (ImageView) findViewById(R.id.activity_item_friends4);
            guestIcons[4] = (ImageView) findViewById(R.id.activity_item_friends5);

            TextView guests = (TextView) findViewById(R.id.activity_item_guests);

            external.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(String.format("https://www.facebook.com/events/%s/", item.facebook_id)));
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
                    startActivity(intent);
                }
            });

            new AsyncInfoGetter(item.facebook_id, guests, image).execute();
            new AsyncFriendsGetter(item.facebook_id, guests, guestIcons).execute();
        }

        /**
         * Content
         */
        LinearLayout contentContainer = (LinearLayout) findViewById(R.id.activity_item_content_container);
        TextView content = (TextView) findViewById(R.id.activity_item_content);

        if (item.description != null) {
            content.setText(Html.fromHtml(item.description.replace("\n", "<br>")));
            content.setMovementMethod(LinkMovementMethod.getInstance());
            Linkify.addLinks(content, Linkify.ALL);
        } else {
            ((ViewManager) contentContainer.getParent()).removeView(contentContainer);
        }
    }

    public void onDirectionsClick(double latitude, double longitude) {
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(String.format("http://maps.google.com/maps?q=%s,%s", latitude, longitude)));
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
        startActivity(intent);
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
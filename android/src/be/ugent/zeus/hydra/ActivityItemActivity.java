/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;
import android.util.Log;
import android.view.View;
import android.view.ViewManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.util.facebook.RequestBuilder;
import be.ugent.zeus.hydra.util.facebook.event.data.AttendingStatus;
import be.ugent.zeus.hydra.util.facebook.event.tasks.AsyncComingGetter;
import be.ugent.zeus.hydra.util.facebook.event.tasks.AsyncComingSetter;
import be.ugent.zeus.hydra.util.facebook.event.tasks.AsyncFriendsGetter;
import be.ugent.zeus.hydra.util.facebook.event.tasks.AsyncInfoGetter;
import com.facebook.Session;
import com.facebook.SessionDefaultAudience;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;
import com.google.analytics.tracking.android.EasyTracker;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.List;

public class ActivityItemActivity extends AbstractSherlockActivity {

    private int selected;
    private UiLifecycleHelper uiHelper;
    private Activity item;
    private boolean fetched;

    public class SessionStatusCallback implements Session.StatusCallback {

        @Override
        public void call(Session session, SessionState state, Exception exception) {
            onSessionStateChange(session, state, exception);
        }
    }

    private void onSessionStateChange(Session session, SessionState state, Exception exception) {
        Log.i("FACEBOOK", "Onsessionstatechange: " + state.toString());

        TextView guests = (TextView) findViewById(R.id.activity_item_guests);
        ImageView image = (ImageView) findViewById(R.id.activity_item_image);

        ImageView[] guestIcons = new ImageView[5];
        guestIcons[0] = (ImageView) findViewById(R.id.activity_item_friends1);
        guestIcons[1] = (ImageView) findViewById(R.id.activity_item_friends2);
        guestIcons[2] = (ImageView) findViewById(R.id.activity_item_friends3);
        guestIcons[3] = (ImageView) findViewById(R.id.activity_item_friends4);
        guestIcons[4] = (ImageView) findViewById(R.id.activity_item_friends5);

        Button button = (Button) findViewById(R.id.activity_item_button);

        switch (state) {
            case OPENED_TOKEN_UPDATED:
                if (selected != -1) {
                    new AsyncComingSetter(this, item.facebook_id, button, AttendingStatus.values()[selected]).execute();
                }
                if (fetched) {
                    return;
                }

            case OPENED:
                if (!fetched) {
                    fetched = true;
                    new AsyncInfoGetter(item.facebook_id, guests, image).execute();
                    new AsyncComingGetter(this, item.facebook_id, button).execute();
                    new AsyncFriendsGetter(item.facebook_id, guests, guestIcons).execute();
                }
                return;

            case CLOSED:
            case CREATED:
                new AsyncInfoGetter(item.facebook_id, guests, image).execute();

                for (ImageView imageView : guestIcons) {
                    imageView.setVisibility(View.GONE);
                }
                button.setVisibility(View.GONE);
                return;

        }
    }

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setTitle(R.string.details);
        setContentView(R.layout.activity_item);

        selected = -1;
        fetched = false;

        /**
         * Get the activity
         */
        item = (Activity) getIntent().getSerializableExtra("item");

        EasyTracker.getTracker().sendView("Activity > " + item.title);

        /**
         * Facebook
         */
        if (item.facebook_id != null && !"".equals(item.facebook_id)) {
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
                if (session.getState().equals(SessionState.CREATED_TOKEN_LOADED)) {
                    session.openForRead(new Session.OpenRequest(this).setCallback(statusCallback));
                } else if (session.getState().equals(SessionState.CREATED)) {
                    Session.openActiveSession(this, false, statusCallback);
                }

                onSessionStateChange(session, session.getState(), null);

            } else if (session != null
                && (session.isOpened() || session.isClosed())) {
                onSessionStateChange(session, session.getState(), null);
            }
        }

        /**
         * Image
         */
        ImageView image = (ImageView) findViewById(R.id.activity_item_image);
        image.setVisibility(View.INVISIBLE);


        /**
         * Title
         */
        TextView title = (TextView) findViewById(R.id.activity_item_title);
        title.setText(item.title);

        /**
         * Button
         */
        final Button button = (Button) findViewById(R.id.activity_item_button);
        if (item.facebook_id == null) {
            button.setVisibility(View.GONE);
        } else {
            button.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    changeAttendingStatus(button, item.facebook_id);
                }
            });
        }

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
        View locationContainerSideBorder = (View) findViewById(R.id.activity_item_location_sideborder);

        if (item.location == null || "".equals(item.location)) {

            LinearLayout locationContainer = (LinearLayout) findViewById(R.id.activity_item_location_container);
            View locationContainerBottomBorder = (View) findViewById(R.id.activity_item_location_bottomborder);

            ((ViewManager) locationContainer.getParent()).removeView(locationContainer);
            ((ViewManager) locationContainerBottomBorder.getParent()).removeView(locationContainerBottomBorder);
            ((ViewManager) locationContainerSideBorder.getParent()).removeView(locationContainerSideBorder);

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
                locationContainerSideBorder.setVisibility(View.INVISIBLE);
                directions.setVisibility(View.INVISIBLE);
            }
        }


        /**
         * Facebook friends
         */
        LinearLayout guestsContainer = (LinearLayout) findViewById(R.id.activity_item_guests_container);
        View guestsBottomBorder = (View) findViewById(R.id.activity_item_guests_bottomborder);
        ImageView external = (ImageView) findViewById(R.id.activity_item_facebook_external);

        if (item.facebook_id == null || "".equals(item.facebook_id)) {
            ((ViewManager) guestsContainer.getParent()).removeView(guestsContainer);
            ((ViewManager) guestsBottomBorder.getParent()).removeView(guestsBottomBorder);
        } else {
            external.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(String.format("https://www.facebook.com/events/%s/", item.facebook_id)));
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
                    startActivity(intent);
                }
            });
        }

        /**
         * Content
         */
        View contentBottomBorder = (View) findViewById(R.id.activity_item_content_bottomborder);
        TextView content = (TextView) findViewById(R.id.activity_item_content);

        if (item.description == null || "".equals(item.description)) {
            ((ViewManager) content.getParent()).removeView(content);
            ((ViewManager) contentBottomBorder.getParent()).removeView(contentBottomBorder);
        } else {
            content.setText(Html.fromHtml(item.description.replace("\n", "<br>")));
            content.setMovementMethod(LinkMovementMethod.getInstance());
            Linkify.addLinks(content, Linkify.ALL);
        }


        /**
         * More content
         */
        LinearLayout moreContentContainer = (LinearLayout) findViewById(R.id.activity_item_more_content_container);
        TextView moreContent = (TextView) findViewById(R.id.activity_item_more_content);

        if (item.url == null || "".equals(item.url)) {
            ((ViewManager) moreContentContainer.getParent()).removeView(moreContentContainer);
        } else {
            moreContent.setText(item.url);
            moreContentContainer.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(item.url));
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
                    startActivity(intent);
                }
            });
        }
    }

    public void onDirectionsClick(double latitude, double longitude) {
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(String.format("http://maps.google.com/maps?q=%s,%s", latitude, longitude)));
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
        startActivity(intent);
    }

    public void changeAttendingStatus(final Button button, final String id) {
        final CharSequence[] choiceList = {getResources().getString(R.string.attending),
            getResources().getString(R.string.maybe),
            getResources().getString(R.string.declined)
        };

        new AlertDialog.Builder(this)
            .setTitle("Status")
            .setCancelable(true)
            .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                updateStatus(button, id);
            }
        })
            .setNegativeButton("Cancel", null)
            .setSingleChoiceItems(choiceList, selected, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                selected = which;
            }
        })
            .create().show();
    }

    public void updateStatus(Button button, String id) {
        Session session = Session.getActiveSession();
        List<String> permissions = session.getPermissions();

        if (!permissions.contains("rsvp_event")) {

            List<String> newPermissions = Arrays.asList("rsvp_event");

            session.requestNewPublishPermissions(
                new Session.NewPermissionsRequest(this, newPermissions)
                .setDefaultAudience(SessionDefaultAudience.FRIENDS)
                .setCallback(new ActivityItemActivity.SessionStatusCallback()));
        } else {
            new AsyncComingSetter(this, id, button, AttendingStatus.values()[selected]).execute();
        }

    }

    @Override
    public void onResume() {
        super.onResume();

        if (item.facebook_id != null && !"".equals(item.facebook_id)) {
            uiHelper.onResume();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (item.facebook_id != null && !"".equals(item.facebook_id)) {
            uiHelper.onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override
    public void onPause() {
        super.onPause();

        if (item.facebook_id != null && !"".equals(item.facebook_id)) {
            uiHelper.onPause();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if (item.facebook_id != null && !"".equals(item.facebook_id)) {
            uiHelper.onDestroy();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);

        if (item.facebook_id != null && !"".equals(item.facebook_id)) {
            uiHelper.onSaveInstanceState(outState);
        }
    }
}
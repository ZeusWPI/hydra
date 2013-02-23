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
import android.view.View;
import android.view.ViewManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import be.ugent.zeus.hydra.data.Activity;
import com.google.analytics.tracking.android.EasyTracker;
import java.text.SimpleDateFormat;

public class ActivityItemActivity extends AbstractSherlockActivity {

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setTitle(R.string.details);
        setContentView(R.layout.activity_item);

        final Activity item = (Activity) getIntent().getSerializableExtra("item");

        EasyTracker.getTracker().sendView("Activity > " + item.title);

        /**
         * Image
         */
        ImageView image = (ImageView) findViewById(R.id.activity_item_image);
        if (item.facebook_id == null) {
//            ((ViewManager) image.getParent()).removeView(image);
        } // else gets handled in the guests here

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
            new SimpleDateFormat("dd MMMM yyyy", Hydra.LOCALE).format(item.startDate);
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
//        LinearLayout guestsContainer = (LinearLayout) findViewById(R.id.activity_item_guests_container);
//        TextView guests = (TextView) findViewById(R.id.activity_item_guests);
//        TextView friends = (TextView) findViewById(R.id.activity_item_friends);
        if (item.facebook_id == null) {
//            ((ViewManager) guestsContainer.getParent()).removeView(guestsContainer);
        } else {
//            new Info(icicle, getApplicationContext(), this, item.facebook_id, guests, image).execute();
//            new Friends(icicle, getApplicationContext(), this, item.facebook_id, friends).execute();
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
}
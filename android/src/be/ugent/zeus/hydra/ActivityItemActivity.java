/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;
import android.widget.ImageView;
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

        Activity item = (Activity) getIntent().getSerializableExtra("item");

        EasyTracker.getTracker().sendView("Activity > " + item.title);

        ImageView image = (ImageView) findViewById(R.id.activity_item_image);
        TextView title = (TextView) findViewById(R.id.activity_item_title);
        TextView date = (TextView) findViewById(R.id.activity_item_date);
        TextView association = (TextView) findViewById(R.id.activity_item_association);
        TextView location = (TextView) findViewById(R.id.activity_item_location);
        TextView guests = (TextView) findViewById(R.id.activity_item_guests);
        TextView content = (TextView) findViewById(R.id.activity_item_content);
        title.setText(item.title);


        String poster = item.association.display_name;
        if (item.association.full_name != null) {
            poster += " (" + item.association.full_name + ")";
        }

        String datum =
            new SimpleDateFormat("dd MMMM yyyy 'om' hh:mm", Hydra.LOCALE).format(item.startDate);

        
        image.setImageResource(R.drawable.urgent);
        title.setText(item.title);
        date.setText(datum);
        association.setText(poster);
        location.setText(item.location);
        guests.setText("hier fancy facebook stuff");

        if (item.description != null) {
            content.setText(Html.fromHtml(item.description.replace("\n", "<br>")));
            content.setMovementMethod(LinkMovementMethod.getInstance());
            Linkify.addLinks(content, Linkify.ALL);
        }
    }
}
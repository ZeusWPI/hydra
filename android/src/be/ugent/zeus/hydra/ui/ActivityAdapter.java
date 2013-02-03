package be.ugent.zeus.hydra.ui;

import android.content.Context;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.Activity;
import java.util.List;

/**
 *
 * @author Thomas Meire
 */
public class ActivityAdapter extends ArrayAdapter<Activity> {

    private List<Activity> activities;

    public ActivityAdapter(Context context, List<Activity> activities) {
        super(context, 0);
        this.activities = activities;
    }

    @Override
    public int getCount() {
        return (activities != null) ? activities.size() : 0;
    }

    @Override
    public Activity getItem(int item) {
        return activities.get(item);
    }

    @Override
    public View getView(int item, View repurposed, ViewGroup parent) {
        View row = repurposed;
        if (row == null) {
            LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            row = inflater.inflate(R.layout.activity_list_item, parent, false);
        }

        Activity activity = activities.get(item);

        String title = getContext().getResources().getString(R.string.activity_item_title);

        TextView titleView = (TextView) row.findViewById(R.id.activity_item_title);
        titleView.setText(Html.fromHtml(String.format(title, activity.start, activity.title)));

        String location = getContext().getResources().getString(R.string.activity_item_time_location);

        TextView locationView = (TextView) row.findViewById(R.id.activity_item_time_location);
        locationView.setText(Html.fromHtml(String.format(location, activity.start, activity.end, activity.location)));

        TextView association = (TextView) row.findViewById(R.id.activity_item_association);
        association.setText(Html.fromHtml(activity.association_id));

        return row;
    }
}

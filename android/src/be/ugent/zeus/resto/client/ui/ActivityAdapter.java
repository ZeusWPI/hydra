package be.ugent.zeus.resto.client.ui;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import be.ugent.zeus.resto.client.R;
import be.ugent.zeus.resto.client.data.Activity;
import be.ugent.zeus.resto.client.data.caches.ActivityCache;
import java.util.List;

/**
 *
 * @author Thomas Meire
 */
public class ActivityAdapter extends ArrayAdapter<Activity> {

  private List<Activity> activities;

  public ActivityAdapter(Context context, String date) {
    super(context, 0);
    activities = ActivityCache.getInstance(context).get(date);
  }

  @Override
  public int getCount () {
    return activities.size();
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
    
    TextView title = (TextView) row.findViewById(R.id.activity_item_title);
    title.setText(activity.title);
    
    TextView association = (TextView) row.findViewById(R.id.activity_item_association);
    association.setText(activity.association_id);
    
    return row;
  }
}

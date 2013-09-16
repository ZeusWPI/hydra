/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.ui;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.ImageView;
import android.widget.TextView;
import be.ugent.zeus.hydra.Hydra;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.Activity;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersAdapter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

public class ActivityListAdapter extends BaseAdapter implements StickyListHeadersAdapter {

    private ArrayList<Activity> activities;
    private ArrayList<Activity> filtered;
    private LayoutInflater inflater;
    private Filter filter;

    public ActivityListAdapter(Context context, ArrayList<Activity> items) {
        inflater = LayoutInflater.from(context);
        
        activities = items;
        Collections.sort(activities, new ActivityComparator());
        
        filtered = activities;
    }

    @Override
    public int getCount() {
        return filtered.size();
    }

    @Override
    public Object getItem(int position) {
        return filtered.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;

        if (convertView == null) {
            holder = new ViewHolder();
            convertView = inflater.inflate(R.layout.activity_list_item, parent, false);
            holder.title = (TextView) convertView.findViewById(R.id.activity_item_title);
            holder.assocation = (TextView) convertView.findViewById(R.id.activity_item_association);
            holder.time = (TextView) convertView.findViewById(R.id.activity_item_time_location);
            holder.hilighted = (ImageView) convertView.findViewById(R.id.activity_hilighted_image);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        Activity activity = filtered.get(position);

        holder.title.setText(activity.title);
        holder.assocation.setText(activity.association.display_name);
        holder.time.setText(activity.start.substring(11, 16));

        if (activity.highlighted == 0) {
            holder.hilighted.setVisibility(ImageView.GONE);
        } else {
            holder.hilighted.setVisibility(ImageView.VISIBLE);
        }

        return convertView;
    }

    @Override
    public View getHeaderView(int position, View convertView, ViewGroup parent) {
        HeaderViewHolder holder;
        if (convertView == null) {
            holder = new HeaderViewHolder();
            convertView = inflater.inflate(R.layout.activity_list_header, parent, false);
            holder.header_text = (TextView) convertView.findViewById(R.id.header_text);
            convertView.setTag(holder);
        } else {
            holder = (HeaderViewHolder) convertView.getTag();
        }

        String headerChar = new SimpleDateFormat("dd MMMM", Hydra.LOCALE).format(filtered.get(position).startDate);
        holder.header_text.setText(headerChar);
        return convertView;
    }

    //remember that these have to be static, postion=1 should walys return the same Id that is.
    @Override
    public long getHeaderId(int position) {
        return new SimpleDateFormat("dd MMMM").format(filtered.get(position).startDate).hashCode();
    }
    
    public Filter getFilter() {
        if (filter == null) {
            filter = new ActivityListAdapter.ActivityFilter();
        }
        return filter;
    }

    private class HeaderViewHolder {

        TextView header_text;
    }

    private class ViewHolder {

        TextView title;
        TextView assocation;
        TextView time;
        ImageView hilighted;
    }

    private class ActivityComparator implements Comparator<Activity> {

        public int compare(Activity item1, Activity item2) {
            return item1.start.compareTo(item2.start);
        }
    }
    
    private class ActivityFilter extends Filter {

        @Override
        protected Filter.FilterResults performFiltering(CharSequence constraint) {
            Filter.FilterResults results = new Filter.FilterResults();
            if (constraint == null || constraint.length() == 0) {
                results.values = activities;
                results.count = activities.size();
            } else {
                ArrayList<Activity> activityList = new ArrayList<Activity>();
                for (Activity activity : activities) {
                    
                    if(activity.title.toLowerCase().contains(constraint.toString().toLowerCase())
                        || activity.association.display_name.toLowerCase().contains(constraint.toString().toLowerCase())
                        || categoryContains(constraint.toString(), activity.categories)) {
                        activityList.add(activity);
                    }
                    
                }
                results.values = activityList;
                results.count = activityList.size();
            }
            return results;
        }

        private boolean categoryContains(String constraint, String[] categories) {
            
            if(categories != null && categories.length > 0) {
                for(String category : categories) {
                    if(category.toLowerCase().contains(constraint.toLowerCase())) {
                        return true;
                    }
                }
            }
            
            return false;
        }
        
        protected void publishResults(CharSequence constraint, Filter.FilterResults results) {
            if (results.count == 0) {
                notifyDataSetInvalidated();
            } else {
                filtered = (ArrayList<Activity>) results.values;

                notifyDataSetChanged();
            }
        }
    }
}

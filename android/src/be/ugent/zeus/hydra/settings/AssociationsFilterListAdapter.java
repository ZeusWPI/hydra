/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.settings;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.Activity;
import com.dd.plist.NSArray;
import com.dd.plist.NSDictionary;
import com.dd.plist.NSObject;
import com.dd.plist.NSString;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersAdapter;
import java.util.Comparator;
import java.util.HashMap;

public class AssociationsFilterListAdapter extends BaseAdapter implements StickyListHeadersAdapter {

    private NSArray assocations;
    private LayoutInflater inflater;
    private HashMap<NSObject, String> centraal;

    public AssociationsFilterListAdapter(Context context, NSArray assocations) {
        inflater = LayoutInflater.from(context);
        this.assocations = assocations;


        /*
         * Let's make a quick HashMap so we don't have to iterate through the list in the 
         * getHeaderId method everytime we scroll through the list to get the 'nice' header
         * text
         */
        centraal = new HashMap<NSObject, String>();
        for (int i = 0; i < assocations.count(); i++) {
            NSDictionary association = (NSDictionary) assocations.objectAtIndex(i);
            if (((NSString) association.objectForKey("internalName")).toString()
                .equals(((NSString) association.objectForKey("parentAssociation")).toString())) {
                centraal.put(association.objectForKey("internalName"),
                    ((NSString) association.objectForKey("displayName")).toString());
            }
        }

    }

    @Override
    public int getCount() {
        return assocations.count();
    }

    @Override
    public Object getItem(int position) {
        return assocations.objectAtIndex(position);
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
            convertView = inflater.inflate(R.layout.settings_filter_list_item, parent, false);
            holder.checkBox = (CheckBox) convertView.findViewById(R.id.checkBox);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        NSDictionary item = (NSDictionary) assocations.objectAtIndex(position);
        String name;
        if (item.objectForKey("fullName") != null) {
            name = ((NSString) item.objectForKey("fullName")).toString();
        } else {
            name = ((NSString) item.objectForKey("displayName")).toString();
        }

        holder.checkBox.setText(name);

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

        NSDictionary item = (NSDictionary) assocations.objectAtIndex(position);

        holder.header_text.setText(centraal.get(item.objectForKey("parentAssociation")));
        return convertView;
    }

    //remember that these have to be static, postion=1 should walys return the same Id that is.
    @Override
    public long getHeaderId(int position) {
        NSDictionary item = (NSDictionary) assocations.objectAtIndex(position);
        return ((NSString) item.objectForKey("parentAssociation")).toString().hashCode();
    }

    class HeaderViewHolder {

        TextView header_text;
    }

    class ViewHolder {

        CheckBox checkBox;
        TextView assocation;
    }

    private class ActivityComparator implements Comparator<Activity> {

        public int compare(Activity item1, Activity item2) {
            return item1.start.compareTo(item2.start);
        }
    }
}

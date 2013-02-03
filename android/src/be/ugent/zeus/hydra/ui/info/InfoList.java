package be.ugent.zeus.hydra.ui.info;

import android.content.Context;
import android.database.DataSetObserver;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Adapter;
import android.widget.ListAdapter;
import android.widget.TextView;
import com.dd.plist.NSArray;
import com.dd.plist.NSDictionary;
import com.dd.plist.NSString;

/**
 *
 * @author Thomas Meire
 */
public class InfoList implements ListAdapter {

    private Context context;
    private NSArray array;

    public InfoList(Context context, NSArray array) {
        this.context = context;
        this.array = array;
    }

    public int getCount() {
        return array.count();
    }

    public boolean isEmpty() {
        return array.count() == 0;
    }

    public Object getItem(int position) {
        return array.objectAtIndex(position);
    }

    public long getItemId(int position) {
        return position;
    }

    public boolean hasStableIds() {
        return true;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        NSDictionary dict = (NSDictionary) array.objectAtIndex(position);

        TextView text = new TextView(context);
        text.setTextSize(20);
        text.setText(((NSString) dict.objectForKey("title")).toString());
        text.setGravity(Gravity.CENTER_VERTICAL);
        text.setPadding(5, 0, 5, 0);

        double density = context.getResources().getDisplayMetrics().density;
        text.setHeight((int) (48.0 * density + 0.5));

        int iconid = 0;
        int extid = 0;

        NSString image = (NSString) dict.objectForKey("image");
        if (image != null) {
            iconid = context.getResources().getIdentifier("drawable/" + image.toString().replace("-", "_"), null, "be.ugent.zeus.hydra");
        }

        if (dict.objectForKey("url") != null || dict.objectForKey("url-android") != null) {
            extid = context.getResources().getIdentifier("drawable/external_link", null, "be.ugent.zeus.hydra");
        }

        text.setCompoundDrawablesWithIntrinsicBounds(iconid, 0, extid, 0);
        text.setCompoundDrawablePadding(10);

        return text;
    }

    public int getItemViewType(int position) {
        return Adapter.IGNORE_ITEM_VIEW_TYPE;
    }

    public int getViewTypeCount() {
        return 1;
    }

    public boolean isEnabled(int position) {
        return true;
    }

    public boolean areAllItemsEnabled() {
        return true;
    }

    public void registerDataSetObserver(DataSetObserver observer) {
    }

    public void unregisterDataSetObserver(DataSetObserver observer) {
    }
}

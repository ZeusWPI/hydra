package be.ugent.zeus.hydra.ui.schamper;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import be.ugent.zeus.hydra.Hydra;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.rss.Channel;
import be.ugent.zeus.hydra.data.rss.Item;
import org.ocpsoft.prettytime.PrettyTime;

/**
 *
 * @author Thomas Meire
 */
public class ChannelAdapter extends ArrayAdapter<Item> {

    public ChannelAdapter(Context context, Channel channel) {
        super(context, R.layout.schamper_list_item, channel.items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        if (row == null) {
            LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            row = inflater.inflate(R.layout.schamper_list_item, parent, false);
        }

        Item item = getItem(position);

        TextView title = (TextView) row.findViewById(R.id.schamper_item_title);
        
        // Have we read the article?
        SharedPreferences sharedPrefs = getContext().getSharedPreferences("be.ugent.zeus.hydra.schamper", Context.MODE_PRIVATE);
        boolean read = sharedPrefs.getBoolean(item.link, false);

        // Yes? Normalize the title!
        if (read) {
            title.setTypeface(null, Typeface.NORMAL);
        }
        title.setText(item.title);

        String postedBy = getContext().getResources().getString(R.string.posted_by);

        TextView date = (TextView) row.findViewById(R.id.schamper_item_date);


        date.setText(String.format(postedBy, new PrettyTime(Hydra.LOCALE).format(item.pubDate), item.creator));
        return row;
    }
}

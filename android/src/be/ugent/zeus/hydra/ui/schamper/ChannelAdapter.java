package be.ugent.zeus.hydra.ui.schamper;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.rss.Channel;
import be.ugent.zeus.hydra.data.rss.Item;
import java.text.SimpleDateFormat;

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
        title.setText(item.title);

        String postedBy = getContext().getResources().getString(R.string.posted_by);

        TextView date = (TextView) row.findViewById(R.id.schamper_item_date);
        date.setText(String.format(postedBy, item.creator,
            new SimpleDateFormat("EEEE dd MMM yyyy hh:mm", parent.getResources().getConfiguration().locale).format(item.pubDate)));
        return row;
    }
}

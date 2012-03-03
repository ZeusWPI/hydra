package be.ugent.zeus.resto.client.ui.schamper;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import be.ugent.zeus.resto.client.R;
import be.ugent.zeus.resto.client.data.rss.Channel;
import be.ugent.zeus.resto.client.data.rss.Item;

/**
 *
 * @author Thomas Meire
 */
public class ChannelAdapter extends ArrayAdapter<Item> {

  public ChannelAdapter(Context context, Channel channel) {
    super(context, R.layout.schamper_item, channel.items);
  }

  @Override
  public View getView(int position, View convertView, ViewGroup parent) {
    Log.i("[ChannelAdapter]", "Getting view " + position + "...");
    View row = convertView;
    if (row == null) {
      LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
      row = inflater.inflate(R.layout.schamper_item, parent, false);
    }

    Item item = getItem(position);

    TextView title = (TextView) row.findViewById(R.id.schamper_item_title);
    title.setText(item.title);
    
    TextView date = (TextView) row.findViewById(R.id.schamper_item_date);
    date.setText("By " + item.creator + " on " + item.pubDate);
    return row;
  }
}

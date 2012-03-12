package be.ugent.zeus.resto.client.data;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import be.ugent.zeus.resto.client.R;

public class NewsList extends ArrayAdapter<NewsItem> {

  public NewsList(Context context, List<NewsItem> objects) {
    super(context, R.layout.news_list_item, objects);
  }

  @Override
  public View getView(int position, View convertView, ViewGroup parent) {
    View row = convertView;
    if (row == null) {
      LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
      row = inflater.inflate(R.layout.news_list_item, parent, false);
    }

    NewsItem item = getItem(position);

    TextView title = (TextView) row.findViewById(R.id.news_item_title);
    title.setText(item.title);
    return row;
  }
}

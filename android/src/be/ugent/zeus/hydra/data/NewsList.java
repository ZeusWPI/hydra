package be.ugent.zeus.hydra.data;

import android.content.Context;
import static android.content.Context.MODE_PRIVATE;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.text.Html;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import be.ugent.zeus.hydra.Hydra;
import be.ugent.zeus.hydra.R;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import org.ocpsoft.prettytime.PrettyTime;

public class NewsList extends ArrayAdapter<NewsItem> {

    /**
     * The length of the article previews, in number of characters.
     */
    public NewsList(Context context, List<NewsItem> objects) {
        super(context, R.layout.news_list_item, objects);
        sort(new NewsItemComparator());
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
        // We opened a news item: add the ID to the shared preferences
        SharedPreferences sharedPrefs = getContext().getSharedPreferences("be.ugent.zeus.hydra.news", MODE_PRIVATE);
        boolean read = sharedPrefs.getBoolean(Integer.toString(item.id), false);
        if(read) {
           title.setTypeface(null, Typeface.NORMAL);
        }
        title.setText(Html.fromHtml(item.title));

        String postedBy = getContext().getResources().getString(R.string.posted_by);
        TextView association = (TextView) row.findViewById(R.id.news_item_association);
        try {
            PrettyTime p = new PrettyTime(Hydra.LOCALE);
            Date date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Hydra.LOCALE).parse(item.date);
            CharSequence dateStr = p.format(date);

            association.setText(
                String.format(postedBy, dateStr, Html.fromHtml(item.association.display_name)));
        } catch (ParseException ex) {
            Log.w("Parse error", "");
            ex.printStackTrace();
        }


        TextView shorttxt = (TextView) row.findViewById(R.id.news_item_short);
        shorttxt.setText(Html.fromHtml(item.content));
        if (item.highlighted == 1) {

            int higlightedid = getContext().getResources().getIdentifier("drawable/icon_star", null, "be.ugent.zeus.hydra");

            title.setCompoundDrawablesWithIntrinsicBounds(higlightedid, 0, 0, 0);
            title.setCompoundDrawablePadding(10);
        } else {
            title.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0);
            title.setCompoundDrawablePadding(0);
        }

        return row;
    }

    private class NewsItemComparator implements Comparator<NewsItem> {

        public int compare(NewsItem item1, NewsItem item2) {
            return item2.date.compareTo(item1.date);
        }
    }
}

package be.ugent.zeus.hydra;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;
import android.util.Log;
import android.widget.TextView;
import be.ugent.zeus.hydra.data.NewsItem;
import com.google.analytics.tracking.android.EasyTracker;
import java.text.SimpleDateFormat;

/**
 *
 * @author blackskad
 */
public class NewsItemActivity extends AbstractSherlockActivity {

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setTitle(R.string.title_news);
        setContentView(R.layout.news_item);

        NewsItem item = (NewsItem) getIntent().getSerializableExtra("item");

        EasyTracker.getInstance().setContext(this);
        EasyTracker.getTracker().sendView("News > " + item.title);

        TextView title = (TextView) findViewById(R.id.news_item_title);
        title.setText(item.title);

        String postedBy = getResources().getString(R.string.posted_by_newline);
        TextView association = (TextView) findViewById(R.id.news_item_info);

        String poster = item.association.display_name;
        if (item.association.full_name != null) {
            poster += " (" + item.association.full_name + ")";
        }

        String datum =
            new SimpleDateFormat("EEE dd MMMM yyyy 'om' HH:mm", Hydra.LOCALE).format(item.dateDate);

        association.setText(String.format(postedBy, datum, Html.fromHtml(poster)));

        TextView content = (TextView) findViewById(R.id.news_item_content);
        content.setText(Html.fromHtml(item.content.replace("\n\n", "").replace("\n", "<br>")));
        content.setMovementMethod(LinkMovementMethod.getInstance());
        Linkify.addLinks(content, Linkify.ALL);
        
        // We opened a news item: add the ID to the shared preferences
        SharedPreferences sharedPrefs = getSharedPreferences("be.ugent.zeus.hydra.news", MODE_PRIVATE);
        sharedPrefs.edit().putBoolean(Integer.toString(item.id), true).apply();
    }
}

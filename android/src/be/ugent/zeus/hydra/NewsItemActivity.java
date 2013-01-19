package be.ugent.zeus.hydra;

import com.actionbarsherlock.app.SherlockActivity;

import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.NewsItem;
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

        TextView title = (TextView) findViewById(R.id.news_item_title);
        title.setText(item.title);

        String postedBy = getResources().getString(R.string.posted_by);
        TextView association = (TextView) findViewById(R.id.news_item_info);
        association.setText(String.format(postedBy, Html.fromHtml(item.club),
            new SimpleDateFormat("EEEE dd MMM yyyy hh:mm", getResources().getConfiguration().locale).format(item.date)));

        TextView content = (TextView) findViewById(R.id.news_item_content);
        content.setText(Html.fromHtml(item.description.replace("\n", "<br>")));
        content.setMovementMethod(LinkMovementMethod.getInstance());
        Linkify.addLinks(content, Linkify.ALL);
    }
}

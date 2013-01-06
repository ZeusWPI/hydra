package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.webkit.WebView;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.rss.Item;
import com.actionbarsherlock.app.SherlockActivity;
import java.text.SimpleDateFormat;

/**
 * TODO: implement this properly as a fragment, so we can display this a lot
 * cleaner on tablets (running 4.0+, i think)
 *
 * @author Thomas Meire
 */
public class SchamperDailyItem extends SherlockActivity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_schamper);
    setContentView(R.layout.schamper_item);

    Item item = (Item) getIntent().getSerializableExtra("item");

    TextView title = (TextView) findViewById(R.id.schamper_item_title);
    title.setText(item.title);

    String postedBy = getResources().getString(R.string.posted_by);

    TextView date = (TextView) findViewById(R.id.schamper_item_date);
    date.setText(String.format(postedBy, item.creator, new SimpleDateFormat("EEEE dd MMM yyyy hh:mm").format(item.pubDate)));

    WebView content = (WebView) findViewById(R.id.schamper_item_content);
    content.loadDataWithBaseURL(null, item.description, "text/html", "utf-8", null);
  }
}

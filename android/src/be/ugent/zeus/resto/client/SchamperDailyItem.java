package be.ugent.zeus.resto.client;

import android.app.Activity;
import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.widget.TextView;
import be.ugent.zeus.resto.client.data.rss.Item;

/**
 * TODO: implement this properly as a fragment, so we can display this a lot
 * cleaner on tablets (running 4.0+, i think)
 * 
 * @author Thomas Meire
 */
public class SchamperDailyItem extends Activity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_schamper);
    setContentView(R.layout.schamper_item);

    Item item = (Item) getIntent().getSerializableExtra("item");

    TextView title = (TextView) findViewById(R.id.schamper_item_title);
    title.setText(item.title);
    
    // TODO: add proper i18n
    TextView date = (TextView) findViewById(R.id.schamper_item_date);
    date.setText("By " + item.creator + " on " + item.pubDate);

    TextView content = (TextView) findViewById(R.id.schamper_item_content);
    content.setText(Html.fromHtml(item.description));
    content.setMovementMethod(LinkMovementMethod.getInstance());
  }
}

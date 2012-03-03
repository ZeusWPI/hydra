package be.ugent.zeus.resto.client;

import android.app.Activity;
import android.os.Bundle;
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
    
    Item item = (Item) getIntent().getSerializableExtra("item");
    setTitle(item.title);
  }
}

package be.ugent.zeus.resto.client;

import android.app.Activity;
import android.os.Bundle;

/**
 *
 * @author blackskad
 */
public class News extends Activity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_news);
  }
}

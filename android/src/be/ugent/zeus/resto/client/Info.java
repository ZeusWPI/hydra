package be.ugent.zeus.resto.client;

import android.app.ListActivity;
import android.os.Bundle;

/**
 *
 * @author blackskad
 */
public class Info extends ListActivity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_info);
  }
}

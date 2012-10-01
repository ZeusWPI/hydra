package be.ugent.zeus.resto.client;

import com.actionbarsherlock.app.SherlockListActivity;

import android.os.Bundle;

/**
 *
 * @author blackskad
 */
public class Info extends SherlockListActivity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_info);
  }
}

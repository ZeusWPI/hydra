package be.ugent.zeus.resto.client;

import be.ugent.zeus.resto.client.data.MenuProvider;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import java.util.Date;

/**
 *
 * @author Thomas Meire
 */
public class RestoMenu extends Activity {

  public MenuProvider provider;

  /** Called when the activity is first created. */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    // set the layout, initializes all widgets
    setContentView(R.layout.main);

    Log.i("[RestoMenu]", "onCreate");

    provider = new MenuProvider(getCacheDir());
    // get the menu for today,
    provider.getMenu(new Date());

    int index = 0;

    TextView day = (TextView) findViewById(R.id.day);
    day.setText("index " + index);
  }
}

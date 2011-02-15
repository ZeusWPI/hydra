
package be.ugent.zeus.resto.client;

import be.ugent.zeus.resto.client.data.MenuProvider;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 *
 * @author Thomas Meire
 */
public class RestoMenu extends Activity {

  public MenuProvider provider;

  private String getStringFromDate(Date date) {

    Date today = new Date();
    if (date.getDay() == today.getDay()) {
      return getString(R.string.today);
    } else if (date.getDay() == today.getDay() + 1) {
      return getString(R.string.tomorrow);
    }
    return new SimpleDateFormat("EEEE").format(date);
  }

  /** Called when the activity is first created. */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // set the layout, initializes all widgets
    setContentView(R.layout.main);

    Log.i("[RestoMenu]", "onCreate");

    provider = new MenuProvider(getCacheDir());
    // get the menu for today,
    Date date = new Date();
    provider.getMenu(date);

    TextView day = (TextView) findViewById(R.id.day);
    day.setText(getStringFromDate(date));
  }
}

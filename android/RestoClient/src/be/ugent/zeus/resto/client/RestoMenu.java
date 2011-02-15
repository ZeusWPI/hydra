
package be.ugent.zeus.resto.client;

import be.ugent.zeus.resto.client.data.MenuProvider;

import android.app.Activity;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import be.ugent.zeus.resto.client.data.Menu;
import be.ugent.zeus.resto.client.data.Product;

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

    provider = new MenuProvider(getCacheDir());

    // get the menu for today,
    Date date = new Date();
    Menu menu = provider.getMenu(date);

    if (menu == null) {
      setContentView(R.layout.unavailable);
    } else {
      setContentView(R.layout.main);

      TextView day = (TextView) findViewById(R.id.day);
      day.setText(getStringFromDate(date));

      TextView soup = (TextView) findViewById(R.id.soup);
      soup.setText(menu.soup.name);
      TextView soupPrice = (TextView) findViewById(R.id.soup_price);
      soupPrice.setText(menu.soup.price);

      TableLayout meats = (TableLayout) findViewById(R.id.meat);
      meats.removeAllViews();
      TableRow row;
      TextView meatView, priceView;
      for (Product meat : menu.meat) {
        row = new TableRow(this);

        meatView = new TextView(this);
        meatView.setText(meat.name);
        if (meat.recommended) {
          meatView.setTypeface(Typeface.DEFAULT_BOLD);
        }
        row.addView(meatView);

        priceView = new TextView(this);
        priceView.setText(meat.price);
        priceView.setGravity(Gravity.RIGHT);
        row.addView(priceView);
        meats.addView(row);
      }

      TableLayout vegetables = (TableLayout) findViewById(R.id.vegetables);
      TextView vegetableView;
      for (String vegetable : menu.vegetables) {
        row = new TableRow(this);
        vegetableView = new TextView(this);
        vegetableView.setText(vegetable);
        row.addView(vegetableView);
        vegetables.addView(row);
      }
    }
  }
}

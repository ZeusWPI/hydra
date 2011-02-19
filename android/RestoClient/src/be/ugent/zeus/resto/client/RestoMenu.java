package be.ugent.zeus.resto.client;

import be.ugent.zeus.resto.client.data.MenuProvider;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import be.ugent.zeus.resto.client.data.Menu;
import be.ugent.zeus.resto.client.data.Product;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 *
 * @author Thomas Meire
 */
public class RestoMenu extends Activity {

  public MenuProvider provider;

  private String getStringFromDate(Calendar calendar) {
    int date = calendar.get(Calendar.DATE);
    Log.i("[jkdfh]", "" + date);
    Log.i("[jkdfh]", "" + new Date().getDate());


    Date today = new Date();
    if (date == today.getDay()) {
      return getString(R.string.today);
    } else if (date == today.getDay() + 1) {
      return getString(R.string.tomorrow);
    }
    return new SimpleDateFormat("EEEE").format(date);
  }

  private Calendar getActualDisplayDate() {
    Calendar c = Calendar.getInstance();
    c.setTime(new Date());


    if (c.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY) {
      // saturday? show the menu for next monday
      c.add(Calendar.DATE, 2);
    } else if (c.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
      // sunday? show the menu for next monday
      c.add(Calendar.DATE, 1);
    }
    return c;
  }

  /** Called when the activity is first created. */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    provider = new MenuProvider(getCacheDir());

    // get the menu for today,
    Calendar cal = getActualDisplayDate();
    Menu menu = provider.getMenu(cal);

    if (menu == null) {
      setContentView(R.layout.unavailable);
    } else {
      setContentView(R.layout.main);

      TextView day = (TextView) findViewById(R.id.day);
      day.setText(getStringFromDate(cal));

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

  @Override
  public boolean onCreateOptionsMenu(android.view.Menu menu) {
    Log.i("[RestoMenu]", "" + menu);
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.viewmap, menu);
    return true;
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    // Handle item selection
    switch (item.getItemId()) {
      case R.id.show_map:
        // trigger intent for RestoMap Activity
        startActivity(new Intent(this, RestoMap.class));
        return true;
      case R.id.show_about:
        showAboutDialog();
      default:
        return super.onOptionsItemSelected(item);
    }
  }

  /**
   * About dialog based on code from Mobile Vikings for Android by Ben Van Daele
   */
  public void showAboutDialog() {
    Builder builder = new Builder(this);
    builder.setIcon(android.R.drawable.ic_dialog_info);
    builder.setTitle(getString(R.string.about));
    builder.setMessage(getAboutMessage());
    builder.setPositiveButton(getString(android.R.string.ok), null);
    AlertDialog dialog = builder.create();
    dialog.show();
  }

  public CharSequence getAboutMessage() {
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append(getString(R.string.app_name));
    stringBuilder.append(" ");
    stringBuilder.append(getVersionName());
    stringBuilder.append("\n\n");
    stringBuilder.append("http://github.com/blackskad/Resto-menu\n\n");

    return stringBuilder;
  }

  private String getVersionName() {
    try {
      ComponentName componentName = new ComponentName(this, RestoMenu.class);
      PackageInfo info = getPackageManager().getPackageInfo(componentName.getPackageName(), 0);
      return info.versionName;
    } catch (NameNotFoundException e) {
      // Won't happen, versionName is present in the manifest!
      return "";
    }
  }
}

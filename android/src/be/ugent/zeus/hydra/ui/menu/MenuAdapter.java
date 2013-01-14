package be.ugent.zeus.hydra.ui.menu;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.Menu;
import be.ugent.zeus.hydra.data.services.MenuService;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

/**
 *
 * @author Thomas Meire
 */
public class MenuAdapter extends ResultReceiver {

  private Activity context;
  private Calendar date;
  private Menu menu;
  private LinearLayout layout;

  public MenuAdapter(Activity context, Calendar date) {
    super(null);
    this.context = context;
    this.date = date;

    layout = new LinearLayout(context);
    layout.setOrientation(LinearLayout.VERTICAL);
    layout.setGravity(Gravity.CENTER);

    // refresh the daya
    refresh();
  }

  public final void refresh() {
    // temporarily show a progress bar
    ProgressBar throbber = new ProgressBar(context);
    throbber.setIndeterminate(true);

    layout.removeAllViews();
    layout.setGravity(Gravity.CENTER);
    layout.addView(throbber, 50, 50);

    load(date);
  }

  private void load(Calendar date) {
    Intent intent = new Intent(context, MenuService.class);
    intent.putExtra(MenuService.RESULT_RECEIVER_EXTRA, this);
    intent.putExtra(MenuService.DATE_EXTRA, date);
    context.startService(intent);
  }

  private boolean isTodayWithOffset(Calendar date, int offset) {
    Calendar ref = Calendar.getInstance();

    ref.add(Calendar.DATE, offset);
    return ref.get(Calendar.DAY_OF_MONTH) == date.get(Calendar.DAY_OF_MONTH);
  }

  private String getStringFromCalendar(Calendar date) {
    if (isTodayWithOffset(date, 0)) {
      return context.getString(R.string.today);
    } else if (isTodayWithOffset(date, 1)) {
      return context.getString(R.string.tomorrow);
    }
    return new SimpleDateFormat("EEEE dd MMM", context.getResources().getConfiguration().locale).format(date.getTime());
  }

  public TextView getTab() {
    TextView title = (TextView) LayoutInflater.from(context).inflate(R.layout.tab_indicator, layout, false);
    title.setText(getStringFromCalendar(date));

    return title;
  }

  public View getView() {
    return layout;
  }

  @Override
  protected void onReceiveResult(int code, Bundle data) {
    if (code == MenuService.STATUS_STARTED) {
      Log.i("[MenuAdapter]", "Loading started!");
    }
    if (code == MenuService.STATUS_FINISHED) {
      Log.i("[MenuAdapter]", "Loading finished!");
      menu = (Menu) data.getSerializable(MenuService.MENU);

      context.runOnUiThread(new Runnable() {
        public void run() {
          layout.removeAllViews();
          if (menu == null) {
            // add a warning image & small text
            ImageView warning = new ImageView(context);
            warning.setImageDrawable(context.getResources().getDrawable(android.R.drawable.ic_dialog_alert));

            TextView title = new TextView(context);
            title.setGravity(Gravity.CENTER);
            title.setText(R.string.menu_unavailable);
            title.setTextSize(20);

            layout.setGravity(Gravity.CENTER);
            layout.addView(warning);
            layout.addView(title);
          } else {
            if (menu.open) {
              // add a view for the menu
              layout.setGravity(Gravity.TOP);
              layout.addView(new MenuView(context, menu));
            } else {
              // add the "sorry, we're closed" image
              ImageView warning = new ImageView(context);
              warning.setImageDrawable(context.getResources().getDrawable(R.drawable.closed));
              layout.setGravity(Gravity.CENTER);
              layout.addView(warning);
            }
          }
        }
      });
    }
  }
}

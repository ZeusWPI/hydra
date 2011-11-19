
package be.ugent.zeus.resto.client.menu;

import android.content.Context;
import android.view.Gravity;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import java.util.Calendar;

/**
 *
 * @author Thomas Meire
 */
public class MenuUnavailableView extends LinearLayout {
  public MenuUnavailableView (Context context, Calendar date) {
    super(context);
    setOrientation(LinearLayout.VERTICAL);
    setGravity(Gravity.CENTER_HORIZONTAL);

    TextView title = new TextView(context);
    title.setText("Menu unavailable!");
    title.setTextSize(30);

    addView(title);

    ImageView warning = new ImageView (context);
    warning.setImageDrawable(context.getResources().getDrawable(android.R.drawable.ic_dialog_alert));
    addView(warning);
  }
}


package be.ugent.zeus.resto.client.menu;

import android.content.Context;
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

    TextView title = new TextView(context);
    title.setText("Menu unavailable!");
    addView(title);
  }
}

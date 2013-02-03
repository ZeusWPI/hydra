package be.ugent.zeus.hydra.ui.menu;

import android.content.Context;
import android.graphics.Typeface;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.Menu;
import be.ugent.zeus.hydra.data.Product;

/**
 *
 * @author Thomas Meire
 */
public class MenuView extends LinearLayout {

    private ScrollView scroller;

    public MenuView(Context context, Menu menu) {
        super(context);
        setMenu(menu);
    }

    private View getSubtitle(int id, int drawable) {
        Context context = getContext();

        LinearLayout container = new LinearLayout(getContext());
        container.setOrientation(LinearLayout.HORIZONTAL);
        container.setPadding(10, 10, 10, 5);
        container.setGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);

        ImageView icon = new ImageView(context);
        icon.setImageDrawable(context.getResources().getDrawable(drawable));

        TextView title = new TextView(context);
        title.setText(context.getString(id));
        title.setTextSize(23);

        LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        params.setMargins(15, 0, 0, 0);

        container.addView(icon);
        container.addView(title, params);
        return container;
    }

    private View getSeperator() {
        Context context = getContext();
        LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        params.height = 2;

        View seperator = new View(context);
        seperator.setBackgroundResource(android.R.drawable.divider_horizontal_dim_dark);
        seperator.setLayoutParams(params);

        return seperator;
    }

    private View getSoupView(Menu menu) {
        Context context = getContext();

        TextView name = new TextView(context);
        name.setText(menu.soup.name);

        TextView price = new TextView(context);
        price.setText(menu.soup.price);
        price.setGravity(Gravity.RIGHT);

        TableRow row = new TableRow(context);
        row.addView(name);
        row.addView(price);

        TableLayout view = new TableLayout(context);
        view.setStretchAllColumns(true);
        view.setPadding(25, 5, 25, 20);
        view.addView(row);
        return view;
    }

    private View getMeatView(Menu menu) {
        Context context = getContext();

        TableLayout view = new TableLayout(context);
        view.setStretchAllColumns(true);
        view.setPadding(25, 5, 25, 20);

        for (Product meat : menu.meat) {
            TextView name = new TextView(context);
            name.setText(meat.name);
            if (meat.recommended) {
                name.setTypeface(Typeface.DEFAULT_BOLD);
            }

            TextView price = new TextView(context);
            price.setText(meat.price);
            price.setGravity(Gravity.RIGHT);

            TableRow row = new TableRow(context);
            row.addView(name);
            row.addView(price);

            view.addView(row);
        }
        return view;
    }

    private View getVegetableView(Menu menu) {
        Context context = getContext();

        TableLayout view = new TableLayout(context);
        view.setStretchAllColumns(true);
        view.setPadding(25, 5, 25, 20);

        for (String vegetable : menu.vegetables) {
            TextView name = new TextView(context);
            name.setText(vegetable);

            TableRow row = new TableRow(context);
            row.addView(name);

            view.addView(row);
        }
        return view;
    }

    private void setMenu(Menu menu) {
        setOrientation(VERTICAL);

        Context context = getContext();

        LinearLayout content = new LinearLayout(context);
        content.setOrientation(LinearLayout.VERTICAL);

        // the line with the soup
        content.addView(getSubtitle(R.string.soup, R.drawable.icon_soup));
        content.addView(getSeperator());
        content.addView(getSoupView(menu));

        // the line with the meat
        content.addView(getSubtitle(R.string.meat, R.drawable.icon_meal));
        content.addView(getSeperator());
        content.addView(getMeatView(menu));

        // the line with the vegetables
        content.addView(getSubtitle(R.string.vegetables, R.drawable.icon_vegetables));
        content.addView(getSeperator());
        content.addView(getVegetableView(menu));

        scroller = new ScrollView(context);
        scroller.addView(content);

        addView(scroller);
    }

    public void addTouchListener(OnTouchListener listener) {
        scroller.setOnTouchListener(listener);
    }
}

package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.data.caches.ActivityCache;
import be.ugent.zeus.hydra.ui.ActivityAdapter;
import be.ugent.zeus.hydra.ui.SwipeyTabs;
import be.ugent.zeus.hydra.ui.SwipeyTabsAdapter;
import com.actionbarsherlock.app.SherlockActivity;
import com.google.analytics.tracking.android.EasyTracker;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * TODO: needs swiping or buttons to go to the next days! cfr resto menu
 *
 * @author blackskad
 */
public class Calendar extends AbstractSherlockActivity {

    private static final int VIEWABLE_DATES = 7;
    private ViewPager pager;
    private SwipeyTabs tabs;
    private CalendarTabAdapter adapter;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setContentView(R.layout.activity_list);
        setTitle(R.string.title_calendar);

        pager = (ViewPager) findViewById(R.id.pager);
        tabs = (SwipeyTabs) findViewById(R.id.tabs);
        pager.setOnPageChangeListener(tabs);

        adapter = new CalendarTabAdapter();
        pager.setAdapter(adapter);
        tabs.setAdapter(adapter);
    }

    private class CalendarTabAdapter extends PagerAdapter implements SwipeyTabsAdapter {

        private List<java.util.Calendar> dates;
        private List<ListView> views = new ArrayList<ListView>(VIEWABLE_DATES);

        public CalendarTabAdapter() {
            dates = getViewableDates();
            for (java.util.Calendar date : dates) {
                List<Activity> activities = ActivityCache.getInstance(Calendar.this).get(
                    new SimpleDateFormat("dd-MM-yyyy").format(date.getTime()));

                /*
                 * if (activities == null || activities.isEmpty()) {
                 * Toast.makeText(this, "No activities available!",
                 * Toast.LENGTH_SHORT).show(); finish(); }
                 */

                ListView calendar = new ListView(Calendar.this);
                calendar.setAdapter(new ActivityAdapter(Calendar.this, null));
                views.add(calendar);
            }
        }

        public int getCount() {
            return 5;
        }

        public TextView getTab(final int position, SwipeyTabs root) {
            java.util.Calendar date = dates.get(position);
            TextView title = (TextView) LayoutInflater.from(Calendar.this).inflate(R.layout.tab_indicator, null, false);
            title.setText(getStringFromCalendar(date));

            title.setOnClickListener(new View.OnClickListener() {
                public void onClick(final View v) {
                    pager.setCurrentItem(position);
                }
            });
            return title;
        }

        @Override
        public Object instantiateItem(View collection, int position) {
            ((ViewPager) collection).addView(views.get(position), 0);

            return views.get(position);
        }

        @Override
        public void destroyItem(View collection, int position, Object view) {
            ((ViewPager) collection).removeView((View) view);
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return view == ((View) object);
        }

        @Override
        public void startUpdate(View view) {
        }

        @Override
        public void finishUpdate(View view) {
        }

        @Override
        public Parcelable saveState() {
            return null;
        }

        @Override
        public void restoreState(Parcelable prclbl, ClassLoader cl) {
        }
    }

    private List<java.util.Calendar> getViewableDates() {
        List<java.util.Calendar> days = new ArrayList<java.util.Calendar>(VIEWABLE_DATES);

        java.util.Calendar instance = java.util.Calendar.getInstance();
        for (int i = 0; i < VIEWABLE_DATES; i++) {
            days.add((java.util.Calendar) instance.clone());
            instance.add(java.util.Calendar.DATE, 1);
        }
        return days;
    }

    private String getStringFromCalendar(java.util.Calendar date) {
        if (isTodayWithOffset(date, 0)) {
            return getString(R.string.today);
        } else if (isTodayWithOffset(date, 1)) {
            return getString(R.string.tomorrow);
        }
        return new SimpleDateFormat("EEEE dd MMM", getResources().getConfiguration().locale).format(date.getTime());
    }

    private boolean isTodayWithOffset(java.util.Calendar date, int offset) {
        java.util.Calendar ref = java.util.Calendar.getInstance();

        ref.add(java.util.Calendar.DATE, offset);
        return ref.get(java.util.Calendar.DAY_OF_MONTH) == date.get(java.util.Calendar.DAY_OF_MONTH);
    }
}

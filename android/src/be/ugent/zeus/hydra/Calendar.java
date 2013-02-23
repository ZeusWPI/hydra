package be.ugent.zeus.hydra;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.caches.ActivityCache;
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
import be.ugent.zeus.hydra.data.services.ActivityIntentService;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.ui.ActivityListAdapter;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersListView;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

/**
 * @author blackskad
 */
public class Calendar extends AbstractSherlockActivity implements OnScrollListener,
    AdapterView.OnItemClickListener {

    private static final String KEY_LIST_POSITION = "KEY_LIST_POSITION";
    private int firstVisible;
    private List<Activity> items;
    private ActivityCache cache;
    private AssociationsCache assCache;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        setTitle(R.string.title_calendar);

        if (savedInstanceState != null) {
            firstVisible = savedInstanceState.getInt(KEY_LIST_POSITION);
        }

        cache = ActivityCache.getInstance(this);
        assCache = AssociationsCache.getInstance(this);

        long lastModified = cache.lastModified(ActivityIntentService.FEED_NAME);
        boolean exists = cache.exists(ActivityIntentService.FEED_NAME);

        // Als hij bestaat en de cache is recent (< 1 uur): refresh niet
        refresh(exists && System.currentTimeMillis() - lastModified < ActivityIntentService.REFRESH_TIME);
    }

    private void refresh(boolean synced) {
        if (!synced) {

            Intent intent = new Intent(this, ActivityIntentService.class);
            intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new Calendar.CalendarResultReceiver());
            startService(intent);

        } else {

            items = cache.get(ActivityIntentService.FEED_NAME);
            if (items == null) {
                items = new ArrayList<Activity>();
            }

            Iterator<Activity> iterator = items.iterator();

            while (iterator.hasNext()) {
                Activity activity = iterator.next();

                if (activity.endDate.getTime() < System.currentTimeMillis()) {
                    iterator.remove();
                }
            }

            SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
            boolean showAll = preferences.getBoolean("prefFilter", false);
            HashSet<String> lists = new HashSet<String>();

            if (!showAll) {
                lists = assCache.get("associations");

                if (lists == null) {
                    lists = new HashSet<String>();
                }

                Iterator i = items.iterator();
                while (i.hasNext()) {
                    Activity activityItem = (Activity) i.next();

                    if (activityItem.highlighted == 0 && !lists.contains(activityItem.association.internal_name)) {
                        i.remove();
                    }
                }
            }

            // No items
            if (items.isEmpty()) {
                if (!showAll && lists.isEmpty()) {
                    Toast.makeText(this, R.string.no_associations_selected, Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(this, R.string.no_activities_available, Toast.LENGTH_SHORT).show();
                }

                finish();

            } else {

                StickyListHeadersListView stickyList = (StickyListHeadersListView) findViewById(R.id.list);
                stickyList.setOnScrollListener(this);
                stickyList.setOnItemClickListener(this);

                stickyList.setAdapter(new ActivityListAdapter(this, items));
                stickyList.setSelection(firstVisible);
            }
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(KEY_LIST_POSITION, firstVisible);
    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem,
        int visibleItemCount, int totalItemCount) {
        this.firstVisible = firstVisibleItem;
    }

    @Override
    public void onScrollStateChanged(AbsListView view, int scrollState) {
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

        // Launch a new activity
        Intent intent = new Intent(this, ActivityItemActivity.class);
        intent.putExtra("class", this.getClass().getCanonicalName());
        intent.putExtra("item", items.get(position));
        startActivity(intent);
    }

    private class CalendarResultReceiver extends ResultReceiver {

        private ProgressDialog progressDialog;

        public CalendarResultReceiver() {
            super(null);

            Calendar.this.runOnUiThread(new Runnable() {
                public void run() {
                    progressDialog = ProgressDialog.show(Calendar.this,
                        getResources().getString(R.string.title_calendar),
                        getResources().getString(R.string.loading));
                }
            });
        }

        @Override
        public void onReceiveResult(int code, Bundle icicle) {
            Calendar.this.runOnUiThread(new Runnable() {
                public void run() {
                    progressDialog.dismiss();
                }
            });

            switch (code) {
                case HTTPIntentService.STATUS_FINISHED:
                    Calendar.this.runOnUiThread(new Runnable() {
                        public void run() {
                            refresh(true);
                        }
                    });
                    break;
                case HTTPIntentService.STATUS_ERROR:
                    Toast.makeText(Calendar.this, R.string.activities_updated_failed, Toast.LENGTH_SHORT).show();
                    Calendar.this.runOnUiThread(new Runnable() {
                        public void run() {
                            refresh(true);
                        }
                    });
                    break;
            }
        }
    }
}
package be.ugent.zeus.hydra;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
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
import be.ugent.zeus.hydra.data.caches.ActivityCache;
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
import be.ugent.zeus.hydra.data.services.ActivityIntentService;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.settings.Settings;
import be.ugent.zeus.hydra.ui.ActivityListAdapter;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem;
import com.actionbarsherlock.widget.SearchView;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersListView;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import uk.co.senab.actionbarpulltorefresh.library.PullToRefreshAttacher;
import uk.co.senab.actionbarpulltorefresh.library.PullToRefreshLayout;

/**
 * @author blackskad
 */
public class Calendar extends AbstractSherlockActivity implements OnScrollListener,
    AdapterView.OnItemClickListener,
    PullToRefreshAttacher.OnRefreshListener,
    SearchView.OnQueryTextListener, MenuItem.OnActionExpandListener {

    private static final String KEY_LIST_POSITION = "KEY_LIST_POSITION";
    private int firstVisible;
    private ArrayList<Activity> items;
    private ActivityCache cache;
    private AssociationsCache assCache;
    private PullToRefreshAttacher attacher;
    private ActivityListAdapter listAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        setTitle(R.string.title_calendar);

        if (savedInstanceState != null) {
            firstVisible = savedInstanceState.getInt(KEY_LIST_POSITION);
        }

        boolean firstrun = getSharedPreferences("PREFERENCE", MODE_PRIVATE).getBoolean("advertise_facebook", true);
        if (firstrun) {
            getSharedPreferences("PREFERENCE", MODE_PRIVATE)
                .edit()
                .putBoolean("advertise_facebook", false)
                .commit();

            new AlertDialog.Builder(this)
                .setCancelable(true)
                .setTitle(getResources().getString(R.string.koppel_title))
                .setMessage(getResources().getString(R.string.koppel_text))
                .setPositiveButton(getResources().getString(R.string.now), new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    Intent intent = new Intent(Calendar.this, Settings.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
                    startActivity(intent);
                }
            })
                .setNegativeButton(getResources().getString(R.string.not_now), new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    dialog.cancel();
                }
            })
                .create()
                .show();
        }

        cache = ActivityCache.getInstance(this);
        assCache = AssociationsCache.getInstance(this);

        long lastModified = cache.lastModified(ActivityIntentService.FEED_NAME);
        boolean exists = cache.exists(ActivityIntentService.FEED_NAME);

        // Als hij bestaat en de cache is recent (< 1 uur): refresh niet
        refresh(exists && System.currentTimeMillis() - lastModified < ActivityIntentService.REFRESH_TIME, false);

        attacher = PullToRefreshAttacher.get(this);
        PullToRefreshLayout ptrLayout = (PullToRefreshLayout) findViewById(R.id.activity_list_container);
        ptrLayout.setPullToRefreshAttacher(attacher, (PullToRefreshAttacher.OnRefreshListener) this);
    }

    private void refresh(boolean synced, boolean withPullToRefresh) {
        if (!synced) {

            Intent intent = new Intent(this, ActivityIntentService.class);
            intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new Calendar.CalendarResultReceiver(withPullToRefresh));
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

            if (withPullToRefresh) {
                attacher.setRefreshComplete();
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

                listAdapter = new ActivityListAdapter(this, items);
                
                stickyList.setAdapter(listAdapter);
                stickyList.setSelection(firstVisible);
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        //Create the search view
        SearchView searchView = new SearchView(getSupportActionBar().getThemedContext());
        searchView.setQueryHint(getString(R.string.pref_filter_associations_hint));
        searchView.setOnQueryTextListener(this);

        menu.add("Search")
            .setOnActionExpandListener(this)
            .setIcon(R.drawable.abs__ic_search)
            .setActionView(searchView)
            .setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM | MenuItem.SHOW_AS_ACTION_COLLAPSE_ACTION_VIEW);

        return super.onCreateOptionsMenu(menu);
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
        intent.putExtra("item", (Activity) listAdapter.getItem(position));
        startActivity(intent);
    }

    public void onRefreshStarted(View view) {
        refresh(false, true);
    }

    /*
     * SearchViewListeners
     */
    public boolean onQueryTextSubmit(String query) {
        // No need to handle this as filtering happens after a keyup
        return true;
    }

    public boolean onQueryTextChange(String newText) {
        listAdapter.getFilter().filter(newText);
        return false;
    }

    /*
     * ActionViewExpandlisteners
     */
    public boolean onMenuItemActionExpand(MenuItem item) {
        return true;
    }

    public boolean onMenuItemActionCollapse(MenuItem item) {
        // If the search closes: remove the filter
        if ("Search".equals(item.getTitle())) {
            listAdapter.getFilter().filter("");
        }
        return true;
    }
    
    private class CalendarResultReceiver extends ResultReceiver {

        private ProgressDialog progressDialog;
        private boolean withPullToRefresh;

        public CalendarResultReceiver(boolean withPullToRefresh) {
            super(null);
            this.withPullToRefresh = withPullToRefresh;

            if (!withPullToRefresh) {
                Calendar.this.runOnUiThread(new Runnable() {
                    public void run() {
                        progressDialog = ProgressDialog.show(Calendar.this,
                            getResources().getString(R.string.title_calendar),
                            getResources().getString(R.string.loading));
                    }
                });
            }
        }

        @Override
        public void onReceiveResult(final int code, Bundle icicle) {

            Calendar.this.runOnUiThread(new Runnable() {
                public void run() {
                    if (!withPullToRefresh) {
                        progressDialog.dismiss();
                    }

                    if (code == HTTPIntentService.STATUS_ERROR) {
                        Toast.makeText(Calendar.this, R.string.activities_updated_failed, Toast.LENGTH_SHORT).show();
                    }

                    refresh(true, withPullToRefresh);

                }
            });

        }
    }
}

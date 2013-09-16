package be.ugent.zeus.hydra;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.NewsList;
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
import be.ugent.zeus.hydra.data.caches.NewsCache;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.data.services.NewsIntentService;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import uk.co.senab.actionbarpulltorefresh.library.PullToRefreshAttacher;

/**
 *
 * @author blackskad
 */
public class News extends AbstractSherlockListActivity implements PullToRefreshAttacher.OnRefreshListener {

    private NewsCache cache;
    AssociationsCache assCache;
    private PullToRefreshAttacher attacher;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_news);
        getListView().setCacheColorHint(0);

        cache = NewsCache.getInstance(this);
        assCache = AssociationsCache.getInstance(this);

        long lastModified = cache.lastModified(NewsIntentService.FEED_NAME);
        boolean exists = cache.exists(NewsIntentService.FEED_NAME);

        // Als hij bestaat en de cache is recent (< 1 uur): refresh niet
        refresh(exists && System.currentTimeMillis() - lastModified < NewsIntentService.REFRESH_TIME, false);

        // Pull-to-refresh
        attacher = PullToRefreshAttacher.get(this);
        attacher.addRefreshableView(getListView(), this);

    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        // Get the item that was clicked
        NewsItem item = (NewsItem) getListAdapter().getItem(position);

        // Launch a new activity
        Intent intent = new Intent(this, NewsItemActivity.class);
        intent.putExtra("item", item);
        startActivity(intent);
    }

    private void refresh(boolean synced, boolean withPullToRefresh) {
        if (!synced) {

            Intent intent = new Intent(this, NewsIntentService.class);
            intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new News.NewsResultReceiver(withPullToRefresh));
            startService(intent);

        } else {

            List<NewsItem> items = new ArrayList<NewsItem>();
            for (ArrayList<NewsItem> subset : cache.getAll()) {
                items.addAll(subset);
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
                    NewsItem newsItem = (NewsItem) i.next();

                    if (newsItem.highlighted == 0 && !lists.contains(newsItem.association.internal_name)) {
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
                    Toast.makeText(this, R.string.no_news_available, Toast.LENGTH_SHORT).show();
                }

                finish();

            } else {

                setListAdapter(new NewsList(this, items));
            }
        }

    }

    @Override
    public void onRefreshStarted(View view) {
        refresh(false, true);
    }

    private class NewsResultReceiver extends ResultReceiver {

        private ProgressDialog progressDialog;
        private boolean withPullToRefresh;

        public NewsResultReceiver(final boolean withPullToRefresh) {
            super(null);
            this.withPullToRefresh = withPullToRefresh;

            if (!withPullToRefresh) {
                News.this.runOnUiThread(new Runnable() {
                    public void run() {
                        progressDialog = ProgressDialog.show(News.this,
                                getResources().getString(R.string.title_news),
                                getResources().getString(R.string.loading));
                    }
                });
            }
        }

        @Override
        public void onReceiveResult(final int code, Bundle icicle) {

            News.this.runOnUiThread(new Runnable() {
                public void run() {
                    if (!withPullToRefresh) {
                        progressDialog.dismiss();
                    }

                    if (code == HTTPIntentService.STATUS_ERROR) {
                        Toast.makeText(News.this, R.string.news_update_failed, Toast.LENGTH_SHORT).show();
                    }

                    refresh(true, withPullToRefresh);
                }
            });
        }
    }
}

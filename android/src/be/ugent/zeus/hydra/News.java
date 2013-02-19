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

/**
 *
 * @author blackskad
 */
public class News extends AbstractSherlockListActivity {

    private NewsCache cache;
    AssociationsCache assCache;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_news);
        getListView().setCacheColorHint(0);

        cache = NewsCache.getInstance(this);
        assCache = AssociationsCache.getInstance(this);

        refresh(false);
    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        // Get the item that was clicked
        NewsItem item = (NewsItem) getListAdapter().getItem(position);

        // Launch a new activity
        Intent intent = new Intent(this, NewsItemActivity.class);
        intent.putExtra("class", this.getClass().getCanonicalName());
        intent.putExtra("item", item);
        startActivity(intent);
    }

    private void refresh(boolean synced) {
        if (!synced) {

            Intent intent = new Intent(this, NewsIntentService.class);
            intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new News.NewsResultReceiver());
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

            // No items
            if (items.isEmpty()) {
                if (!showAll && lists.isEmpty()) {
                    Toast.makeText(this, R.string.no_associations_selected, Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(this, R.string.no_news_available, Toast.LENGTH_SHORT).show();
                }

                finish();
            }

            setListAdapter(new NewsList(this, items));
        }

    }

    private class NewsResultReceiver extends ResultReceiver {

        private ProgressDialog progressDialog;

        public NewsResultReceiver() {
            super(null);

            News.this.runOnUiThread(new Runnable() {
                public void run() {
                    progressDialog = ProgressDialog.show(News.this,
                        getResources().getString(R.string.title_news),
                        getResources().getString(R.string.loading));
                }
            });
        }

        @Override
        public void onReceiveResult(int code, Bundle icicle) {
            News.this.runOnUiThread(new Runnable() {
                public void run() {
                    progressDialog.dismiss();
                }
            });

            switch (code) {
                case HTTPIntentService.STATUS_FINISHED:
                    News.this.runOnUiThread(new Runnable() {
                        public void run() {
                            refresh(true);
                        }
                    });
                    break;
                case HTTPIntentService.STATUS_ERROR:
                    Toast.makeText(News.this, R.string.news_update_failed, Toast.LENGTH_SHORT).show();
                    News.this.runOnUiThread(new Runnable() {
                        public void run() {
                            refresh(true);
                        }
                    });
                    break;
            }
        }
    }
}

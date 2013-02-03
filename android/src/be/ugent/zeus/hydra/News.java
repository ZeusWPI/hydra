package be.ugent.zeus.hydra;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ListView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.NewsList;
import be.ugent.zeus.hydra.data.caches.NewsCache;
import com.actionbarsherlock.app.SherlockListActivity;
import com.google.analytics.tracking.android.EasyTracker;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author blackskad
 */
public class News extends AbstractSherlockListActivity {

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_news);
        getListView().setCacheColorHint(0);

        NewsCache cache = NewsCache.getInstance(this);

        List<NewsItem> items = new ArrayList<NewsItem>();
        for (ArrayList<NewsItem> subset : cache.getAll()) {
            items.addAll(subset);
        }
        setListAdapter(new NewsList(this, items));
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
}

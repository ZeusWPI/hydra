package be.ugent.zeus.hydra;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.data.Association;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.NewsList;
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
import be.ugent.zeus.hydra.data.caches.NewsCache;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
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

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        boolean showAll = preferences.getBoolean("prefFilter", false);
        HashSet<String> lists = new HashSet<String>();
        
        if (!showAll) {
            AssociationsCache assCache = AssociationsCache.getInstance(this);
            lists = assCache.get("associations");
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
                Toast.makeText(this.getApplicationContext(), R.string.no_associations_selected, Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this.getApplicationContext(), R.string.no_news_available, Toast.LENGTH_SHORT).show();
            }

            finish();
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

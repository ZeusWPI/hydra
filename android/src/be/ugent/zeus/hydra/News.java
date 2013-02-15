package be.ugent.zeus.hydra;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
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

        if (!showAll) {
            AssociationsCache assCache = AssociationsCache.getInstance(this);
            HashSet<String> lists = assCache.get("associations");

            if (lists != null && !lists.isEmpty()) {
                Iterator i = items.iterator();
                while (i.hasNext()) {
                    Association assoc = ((NewsItem) i.next()).association;

                    if (!lists.contains(assoc.display_name) && !lists.contains(assoc.full_name)) {
                        i.remove();
                    }
                }
            } else { // Nothing to do here: close the activity & show a toast
                Toast.makeText(this.getApplicationContext(), "Selecteer ten minste 1 vereniging in de instellingen", Toast.LENGTH_SHORT).show();

                finish();
            }
            
            // No items
            if(items.isEmpty()) {
                Toast.makeText(this.getApplicationContext(), "Geen nieuws beschikbaar.", Toast.LENGTH_SHORT).show();

                finish();
            }
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

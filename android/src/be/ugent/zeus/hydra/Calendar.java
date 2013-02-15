package be.ugent.zeus.hydra;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.Activity;
import be.ugent.zeus.hydra.data.Association;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.caches.ActivityCache;
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
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

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        setTitle(R.string.title_calendar);

        StickyListHeadersListView stickyList = (StickyListHeadersListView) findViewById(R.id.list);
        stickyList.setOnScrollListener(this);
        stickyList.setOnItemClickListener(this);

        if (savedInstanceState != null) {
            firstVisible = savedInstanceState.getInt(KEY_LIST_POSITION);
        }

        ActivityCache cache = ActivityCache.getInstance(this);

        List<Activity> items = new ArrayList<Activity>();
        for (ArrayList<Activity> subset : cache.getAll()) {
            items.addAll(subset);
        }
        
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        boolean showAll = preferences.getBoolean("prefFilter", false);

        AssociationsCache assCache = AssociationsCache.getInstance(this);
        HashSet<String> lists = assCache.get("associations");

        if (lists == null) {
            lists = new HashSet<String>();
        }

        if (!showAll) {
            Iterator i = items.iterator();
            while (i.hasNext()) {
                Activity newsItem = (Activity) i.next();

                if (newsItem.highlighted == 0 && !lists.contains(newsItem.association.internal_name)) {
                    i.remove();
                }
            }
        }

        // No items
        if (items.isEmpty()) {
            if (!showAll && lists.isEmpty()) {
                Toast.makeText(this.getApplicationContext(), "Selecteer ten minste 1 vereniging in de instellingen.", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this.getApplicationContext(), "Geen activiteiten beschikbaar.", Toast.LENGTH_SHORT).show();
            }

            finish();
        }
        

        stickyList.setAdapter(new ActivityListAdapter(this, items));
        stickyList.setSelection(firstVisible);
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
        Toast.makeText(this, "Item " + position + " clicked!", Toast.LENGTH_SHORT).show();
    }
}
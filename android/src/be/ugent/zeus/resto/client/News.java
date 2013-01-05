package be.ugent.zeus.resto.client;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ListView;
import be.ugent.zeus.resto.client.data.NewsItem;
import be.ugent.zeus.resto.client.data.NewsList;
import be.ugent.zeus.resto.client.data.caches.NewsCache;
import com.actionbarsherlock.app.SherlockListActivity;
import com.google.analytics.tracking.android.EasyTracker;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author blackskad
 */
public class News extends SherlockListActivity {

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
    intent.putExtra("item", item);
    startActivity(intent);
  }  

  @Override
  public void onStart() {
    super.onStart();
    EasyTracker.getInstance().activityStart(this); // Add this method.
  }

  @Override
  public void onStop() {
    super.onStop();
    EasyTracker.getInstance().activityStop(this); // Add this method.
  }
}

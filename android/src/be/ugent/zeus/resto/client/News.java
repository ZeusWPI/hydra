package be.ugent.zeus.resto.client;

import java.util.List;

import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import be.ugent.zeus.resto.client.data.NewsItem;
import be.ugent.zeus.resto.client.data.NewsList;
import be.ugent.zeus.resto.client.data.services.HTTPIntentService;
import be.ugent.zeus.resto.client.data.services.NewsIntentService;

/**
 * 
 * @author blackskad
 */
public class News extends ListActivity {

	private static final String url = "http://golive.myverso.com/ugent/versions.xml";

	@Override
	public void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		setTitle(R.string.title_news);
		getListView().setCacheColorHint(0);
		refresh(false);
	}

	private void refresh(boolean force) {
		Intent intent = new Intent(this, NewsIntentService.class);
		intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA,
		    new NewsResultReceiver());
		intent.putExtra(HTTPIntentService.FORCE_UPDATE, force);
		startService(intent);
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

	private class NewsResultReceiver extends ResultReceiver {
		private ProgressDialog progressDialog;

		public NewsResultReceiver() {
			super(null);
			News.this.runOnUiThread(new Runnable() {
				public void run() {
					progressDialog = ProgressDialog.show(News.this, getResources()
					    .getString(R.string.title_news),
					    getResources().getString(R.string.loading));
				}
			});
		}

		@Override
		protected void onReceiveResult(int code, final Bundle resultData) {
			News.this.runOnUiThread(new Runnable() {
				public void run() {
					progressDialog.dismiss();
				}
			});

			switch (code) {
			case HTTPIntentService.STATUS_FINISHED:
				runOnUiThread(new Runnable() {

					public void run() {
						List<NewsItem> items = (List<NewsItem>) resultData
						    .getSerializable("newsItemList");
						if (items != null) {
							Log.i("[NewsResultReceiver]", "Downloaded items: " + items.size());
							setListAdapter(new NewsList(News.this, items));
						} else {
							Toast.makeText(News.this, R.string.schamper_update_failed,
							    Toast.LENGTH_SHORT).show();
						}
					}
				});
				break;
			case HTTPIntentService.STATUS_ERROR:
				Toast.makeText(News.this, R.string.schamper_update_failed,
				    Toast.LENGTH_SHORT).show();
				// TODO: go back to dashboard if nothing to display
				break;
			}

		}
	}
}

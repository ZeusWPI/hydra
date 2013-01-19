package be.ugent.zeus.hydra;

import java.util.List;

import com.actionbarsherlock.app.SherlockListActivity;
import com.google.analytics.tracking.android.EasyTracker;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.NewsItem;
import be.ugent.zeus.hydra.data.NewsList;
import be.ugent.zeus.hydra.data.services.GSRIntentService;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;

/**
 *
 * @author blackskad
 */
public class GSR extends AbstractSherlockListActivity {

    public static final String CACHE_FILE = "gsr";
    public static final String CACHE_KEY = "gsrItemList";
    public static final String FILTER_PREFIX = "GSR/Forced";

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_gsr);
        getListView().setCacheColorHint(0);
        refresh(false);
    }

    private void refresh(boolean force) {
        Intent intent = new Intent(this, GSRIntentService.class);
        intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA,
            new GSRResultReceiver());
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
        intent.putExtra("class", this.getClass().getCanonicalName());
        startActivity(intent);
    }

    private class GSRResultReceiver extends ResultReceiver {

        private ProgressDialog progressDialog;

        public GSRResultReceiver() {
            super(null);
            GSR.this.runOnUiThread(new Runnable() {
                public void run() {
                    progressDialog = ProgressDialog.show(GSR.this, getResources().getString(R.string.title_gsr),
                        getResources().getString(R.string.loading));
                }
            });
        }

        @Override
        protected void onReceiveResult(int code, final Bundle resultData) {
            GSR.this.runOnUiThread(new Runnable() {
                public void run() {
                    progressDialog.dismiss();
                }
            });

            switch (code) {
                case HTTPIntentService.STATUS_FINISHED:
                    runOnUiThread(new Runnable() {
                        public void run() {
                            List<NewsItem> items = (List<NewsItem>) resultData.getSerializable(CACHE_KEY);
                            if (items != null) {
                                Log.i("[GSRResultReceiver]", "Downloaded items: " + items.size());
                                setListAdapter(new NewsList(GSR.this, items));
                            } else {
                                Toast.makeText(GSR.this, R.string.schamper_update_failed,
                                    Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
                    break;
                case HTTPIntentService.STATUS_ERROR:
                    Toast.makeText(GSR.this, R.string.schamper_update_failed,
                        Toast.LENGTH_SHORT).show();
                    // TODO: go back to dashboard if nothing to display
                    break;
            }
        }
    }
}

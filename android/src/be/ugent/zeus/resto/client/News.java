package be.ugent.zeus.resto.client;

import be.ugent.zeus.resto.client.data.services.HTTPIntentService;
import be.ugent.zeus.resto.client.data.services.NewsIntentService;
import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.widget.Toast;
import be.ugent.zeus.resto.client.data.NewsItem;
import be.ugent.zeus.resto.client.data.NewsList;
import java.util.List;

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
    intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new NewsResultReceiver());
    intent.putExtra(HTTPIntentService.FORCE_UPDATE, force);
    startService(intent);
  }

  private class NewsResultReceiver extends ResultReceiver {

    public NewsResultReceiver() {
      super(null);
    }

    @Override
    protected void onReceiveResult(int code, final Bundle resultData) {
      switch (code) {
        case HTTPIntentService.STATUS_FINISHED:
          News.this.runOnUiThread(new Runnable() {

            public void run() {
              setListAdapter(new NewsList(News.this, (List<NewsItem>) resultData.getSerializable("newsItemList")));
            }
          });
          break;
        case HTTPIntentService.STATUS_ERROR:
          Toast.makeText(News.this, R.string.schamper_update_failed, Toast.LENGTH_SHORT).show();
          // TODO: go back to dashboard if nothing to display
          break;
      }

    }
  }
}

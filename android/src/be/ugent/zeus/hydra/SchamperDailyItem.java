package be.ugent.zeus.hydra;

import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebView;
import be.ugent.zeus.hydra.data.rss.Item;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuInflater;
import com.actionbarsherlock.view.MenuItem;
import com.actionbarsherlock.widget.ShareActionProvider;
import com.google.analytics.tracking.android.EasyTracker;
import java.text.SimpleDateFormat;

/**
 * TODO: implement this properly as a fragment, so we can display this a lot cleaner on tablets
 * (running 4.0+, i think)
 *
 * @author Thomas Meire
 */
public class SchamperDailyItem extends AbstractSherlockActivity {

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setContentView(R.layout.schamper_item);


        Item item = (Item) getIntent().getSerializableExtra("item");

        setTitle(item.title);

        String date = String.format(
            new SimpleDateFormat("dd MMMM yyyy 'om' hh:mm", Hydra.LOCALE).format(item.pubDate));

        String html =
            "<head>"
            + "	<meta http-equiv='content-type' content='text/html; charset=utf-8' />"
            + "	<link rel='stylesheet' type='text/css' href='schamper.css' />"
            + "</head>"
            + "<body>"
            + "	<header><h1>" + item.title + "</h1><p class='meta'>" + date + "<br />door " + item.creator + "</div></header>"
            + "	<div class='content'>" + item.description + "</div>"
            + "</body>";


        EasyTracker.getTracker().sendView("Schamper > " + item.title);

        WebView content = (WebView) findViewById(R.id.schamper_item);
        content.loadDataWithBaseURL("file:///android_asset/", html, "text/html", "UTF-8", null);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {


        getSupportMenuInflater().inflate(R.menu.share, menu);

        MenuItem menuItem = menu.findItem(R.id.share);
        
        ShareActionProvider mShareActionProvider = (ShareActionProvider) menuItem.getActionProvider();

        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
        shareIntent.setType("text/plain");

        shareIntent.putExtra(Intent.EXTRA_TEXT, "Een titel");
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, "Een tekst");

        mShareActionProvider.setShareIntent(shareIntent);

        return super.onCreateOptionsMenu(menu);
    }
}

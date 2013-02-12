/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.settings;

import android.os.Bundle;
import android.widget.AbsListView;
import be.ugent.zeus.hydra.AbstractSherlockActivity;
import be.ugent.zeus.hydra.R;
import com.dd.plist.NSArray;
import com.dd.plist.XMLPropertyListParser;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersListView;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AssociationsFilter extends AbstractSherlockActivity implements AbsListView.OnScrollListener {

    private static final String KEY_LIST_POSITION = "KEY_LIST_POSITION";
    private int firstVisible;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        setTitle(R.string.title_settings_associations_filter);

        StickyListHeadersListView stickyList = (StickyListHeadersListView) findViewById(R.id.list);
        stickyList.setOnScrollListener(this);

        // We can't put extra's in the HTML, so let's do it here.
        getIntent().putExtra("class", Settings.class.getCanonicalName());
        
        if (savedInstanceState != null) {
            firstVisible = savedInstanceState.getInt(KEY_LIST_POSITION);
        }
        NSArray assocations = null;
        try {
            assocations = (NSArray) XMLPropertyListParser.parse(getResources()
                .openRawResource(R.raw.assocations));
        } catch (Exception ex) {
            Logger.getLogger(AssociationsFilter.class.getName()).log(Level.SEVERE, null, ex);
        }

        stickyList.setAdapter(new AssociationsFilterListAdapter(this, assocations));
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
}
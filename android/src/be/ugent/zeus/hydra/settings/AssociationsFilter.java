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
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
import com.dd.plist.NSArray;
import com.dd.plist.NSDictionary;
import com.dd.plist.NSObject;
import com.dd.plist.NSString;
import com.dd.plist.XMLPropertyListParser;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersListView;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AssociationsFilter extends AbstractSherlockActivity implements AbsListView.OnScrollListener {

    private static final String KEY_LIST_POSITION = "KEY_LIST_POSITION";
    public static final String FILTERED_ACTIVITIES = "FILTERED_ACTIVITIES";
    private int firstVisible;
    private StickyListHeadersListView stickyList;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        setTitle(R.string.title_settings_associations_filter);

        stickyList = (StickyListHeadersListView) findViewById(R.id.list);
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

        HashMap<String, String> centraal = new HashMap<String, String>();
        for (int i = 0; i < assocations.count(); i++) {
            NSDictionary association = (NSDictionary) assocations.objectAtIndex(i);
            if (((NSString) association.objectForKey("internalName")).toString()
                .equals(((NSString) association.objectForKey("parentAssociation")).toString())) {
                centraal.put(((NSString) association.objectForKey("internalName")).toString(),
                    ((NSString) association.objectForKey("displayName")).toString());
            }
        }
        
        HashSet<String> checkedAssociations = AssociationsCache.getInstance(this).get("associations");
        
        ArrayList<PreferenceAssociation> associationList = new ArrayList<PreferenceAssociation>();
        for (int i = 0; i < assocations.count(); i++) {
            NSDictionary item = (NSDictionary) assocations.objectAtIndex(i);


            String name;
            if (item.objectForKey("fullName") != null) {
                name = ((NSString) item.objectForKey("fullName")).toString();
            } else {
                name = ((NSString) item.objectForKey("displayName")).toString();
            }

            boolean checked = false;
            if(checkedAssociations != null) {
                checked = checkedAssociations.contains(name);
            }
            
            PreferenceAssociation association =
                new PreferenceAssociation(
                name,
                centraal.get(((NSString) item.objectForKey("parentAssociation")).toString()),
                checked);

            associationList.add(association);
        }


        stickyList.setAdapter(new AssociationsFilterListAdapter(this, associationList));
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
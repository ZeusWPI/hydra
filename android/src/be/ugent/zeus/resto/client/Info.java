package be.ugent.zeus.resto.client;

import android.database.DataSetObserver;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Adapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import be.ugent.zeus.resto.client.ui.info.InfoList;
import com.actionbarsherlock.app.SherlockListActivity;
import com.dd.plist.NSArray;
import com.dd.plist.NSDictionary;
import com.dd.plist.NSObject;
import com.dd.plist.XMLPropertyListParser;

/**
 *
 * @author blackskad
 */
public class Info extends SherlockListActivity {

  @Override
  public void onCreate(Bundle icicle) {
    super.onCreate(icicle);
    setTitle(R.string.title_info);

    try {
      NSObject content = XMLPropertyListParser.parse(getResources().openRawResource(R.raw.info_content));

      setListAdapter(new InfoList(this, (NSArray) content));
      //    ListAdapter adapter = new NSArrayAdapter((NSArray) content);
      for (NSObject object : ((NSArray) content).getArray()) {
        System.err.println(object);
      }
    } catch (Exception ex) {
      System.err.println(ex);
      ex.printStackTrace();
      Log.e("[Hydra.Info]", "Failed to parse the info content!");
    }
  }
}

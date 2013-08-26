package be.ugent.zeus.hydra;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import be.ugent.zeus.hydra.ui.info.InfoList;
import com.dd.plist.BinaryPropertyListParser;
import com.dd.plist.BinaryPropertyListWriter;
import com.dd.plist.NSArray;
import com.dd.plist.NSDictionary;
import com.dd.plist.NSObject;
import com.dd.plist.NSString;
import com.dd.plist.XMLPropertyListParser;
import com.google.analytics.tracking.android.EasyTracker;

/**
 *
 * @author blackskad
 */
public class Info extends AbstractSherlockListActivity {

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setTitle(R.string.title_info);

        EasyTracker.getInstance().setContext(this);
        
        NSArrayWrapper wrapper = (NSArrayWrapper) getIntent().getParcelableExtra("content");
        NSArray content;
        if (wrapper != null) {
            content = wrapper.array;
        } else {
            try {
                content = (NSArray) XMLPropertyListParser.parse(getResources()
                    .openRawResource(R.raw.info_content));

            } catch (Exception ex) {
                Log.e("[Hydra.Info]", "Failed to parse the info content!");
                ex.printStackTrace();
                this.finish();
                return;
            }
        }

        if (getIntent() != null) {
            if (getIntent().getStringExtra("tracking") == null) {
                getIntent().putExtra("tracking", "Info");
            } else {
                EasyTracker.getTracker().sendView(getIntent().getStringExtra("tracking"));
                Log.i("Tracking", getIntent().getStringExtra("tracking"));
            }
        }

        setListAdapter(new InfoList(this, content));
    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        // Get the item that was clicked
        NSDictionary item = (NSDictionary) getListAdapter().getItem(position);

        NSObject action;
        if ((action = item.objectForKey("subcontent")) != null) {
            NSArrayWrapper wrapper = new NSArrayWrapper((NSArray) action);

            Intent intent = new Intent(this, Info.class);
            intent.putExtra("tracking", getIntent().getStringExtra("tracking") + "/" + item.objectForKey("title"));
            intent.putExtra("content", wrapper);
            startActivity(intent);

        } else if ((action = item.objectForKey("url")) != null || (action = item.objectForKey("url-android")) != null) {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(((NSString) action).toString()));
            // Handle external activities as described in 
            // http://developer.android.com/training/implementing-navigation/descendant.html#external-activities
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);

            // We can't call the code in the onCreate as we may be opening the play store, so track it here.
            EasyTracker.getTracker().sendView(getIntent().getStringExtra("tracking") + " > " + item.objectForKey("title"));
            Log.i("Tracking", getIntent().getStringExtra("tracking") + " > " + item.objectForKey("title"));

            startActivity(intent);
        } else if ((action = item.objectForKey("html")) != null) {
            Intent intent = new Intent(this, InfoWebActivity.class);

            EasyTracker.getTracker().sendView(getIntent().getStringExtra("tracking") + " > " + item.objectForKey("title"));
            Log.i("Tracking", getIntent().getStringExtra("tracking") + " > " + item.objectForKey("title"));

            intent.putExtra("page", ((NSString) action).toString());
            startActivity(intent);
        } else if ((action = item.objectForKey("association")) != null) {
            Toast.makeText(this, "TODO: implement the association for " + action.toString(), Toast.LENGTH_SHORT).show();
            System.err.println(action);
        } else {
            System.err.println("WHAT THE FUCK IS THIS SHIT?");
        }
    }

    private static class NSArrayWrapper implements Parcelable {

        private NSArray array;

        public NSArrayWrapper(NSArray array) {
            this.array = array;
        }

        private NSArrayWrapper(Parcel in) {
            try {
                int size = in.readInt();
                byte[] data = new byte[size];
                in.readByteArray(data);
                array = (NSArray) BinaryPropertyListParser.parse(data);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        public int describeContents() {
            return 0;
        }

        public void writeToParcel(Parcel dest, int flags) {
            try {
                byte[] data = BinaryPropertyListWriter.writeToArray(array);
                dest.writeInt(data.length);
                dest.writeByteArray(data);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        // this is used to regenerate your object. All Parcelables must have a CREATOR that implements these two methods
        public static final Parcelable.Creator<NSArrayWrapper> CREATOR = new Parcelable.Creator<NSArrayWrapper>() {
            public NSArrayWrapper createFromParcel(Parcel in) {
                return new NSArrayWrapper(in);
            }

            public NSArrayWrapper[] newArray(int size) {
                return new NSArrayWrapper[size];
            }
        };
    }
}

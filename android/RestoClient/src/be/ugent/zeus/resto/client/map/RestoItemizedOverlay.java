package be.ugent.zeus.resto.client.map;

import android.app.AlertDialog;
import android.content.Context;
import android.graphics.drawable.Drawable;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.OverlayItem;
import java.util.ArrayList;

/**
 *
 * @author Thomas Meire
 */
public class RestoItemizedOverlay extends ItemizedOverlay {

  private ArrayList<OverlayItem> mOverlays = new ArrayList<OverlayItem>();
  private Context context;

  public RestoItemizedOverlay(Drawable defaultMarker, Context context) {
    super(boundCenterBottom(defaultMarker));
    this.context = context;
  }

  public void add(OverlayItem overlay) {
    mOverlays.add(overlay);
    populate();
  }

  public void remove(OverlayItem overlay) {
    mOverlays.remove(overlay);
    populate();
  }

  @Override
  protected boolean onTap(int index) {
    OverlayItem item = mOverlays.get(index);
    AlertDialog.Builder dialog = new AlertDialog.Builder(context);
    dialog.setTitle(item.getTitle());
    dialog.setMessage(item.getSnippet());
    dialog.show();
    return true;
  }

  @Override
  protected OverlayItem createItem(int i) {
    return mOverlays.get(i);
  }

  @Override
  public int size() {
    return mOverlays.size();
  }
}

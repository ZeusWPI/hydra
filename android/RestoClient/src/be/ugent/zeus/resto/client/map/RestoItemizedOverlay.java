package be.ugent.zeus.resto.client.map;

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

  public RestoItemizedOverlay(Drawable defaultMarker) {
    super(boundCenterBottom(defaultMarker));
  }

  public void addOverlay(OverlayItem overlay) {
    mOverlays.add(overlay);
    populate();
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

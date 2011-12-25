package be.ugent.zeus.resto.client.ui.map;

import android.app.AlertDialog;
import android.content.Context;
import be.ugent.zeus.resto.client.data.Resto;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.OverlayItem;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Thomas Meire
 */
public class RestoOverlay extends ItemizedOverlay {

  private List<OverlayItem> items;
  private Context context;

  public RestoOverlay(Context context, List<Resto> restos) {
    super(boundCenterBottom(context.getResources().getDrawable(android.R.drawable.star_on)));
    this.context = context;

    items = new ArrayList<OverlayItem>();
    for (Resto resto : restos) {
      GeoPoint userPoint = new GeoPoint(resto.latitude, resto.longitude);
      items.add(new OverlayItem(userPoint, resto.name, resto.address));
    }
    populate();
  }

  @Override
  protected boolean onTap(int index) {
    OverlayItem item = items.get(index);
    AlertDialog.Builder dialog = new AlertDialog.Builder(context);
    dialog.setTitle(item.getTitle());
    dialog.setMessage(item.getSnippet());
    dialog.show();
    return true;
  }

  @Override
  protected OverlayItem createItem(int i) {
    return items.get(i);
  }

  @Override
  public int size() {
    return items.size();
  }
}

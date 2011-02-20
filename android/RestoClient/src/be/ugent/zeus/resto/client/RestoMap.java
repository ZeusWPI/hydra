package be.ugent.zeus.resto.client;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import be.ugent.zeus.resto.client.data.MenuProvider;
import be.ugent.zeus.resto.client.data.Resto;
import be.ugent.zeus.resto.client.map.RestoItemizedOverlay;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapView;
import com.google.android.maps.MyLocationOverlay;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import java.util.List;

/**
 *
 * @author Thomas Meire
 */
public class RestoMap extends MapActivity {

  private MenuProvider provider;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.restomap);

    provider = new MenuProvider(getCacheDir());
    Drawable drawable = this.getResources().getDrawable(android.R.drawable.star_on);

    MapView map = (MapView) findViewById(R.id.mapview);
    if (map == null) {
      return;
    }
    map.setBuiltInZoomControls(true);
    List<Overlay> overlays = map.getOverlays();

    // Add an overlay containing all resto markers
    RestoItemizedOverlay restoOverlay = new RestoItemizedOverlay(drawable, this);

    for (Resto resto : provider.getRestos()) {
      GeoPoint userPoint = new GeoPoint(resto.latitude, resto.longitude);
      restoOverlay.add(new OverlayItem(userPoint, resto.name, resto.address));
    }
    overlays.add(restoOverlay);

    // Add a standard overlay containing the users location
    MyLocationOverlay myLocOverlay = new MyLocationOverlay(this, map);
		myLocOverlay.enableMyLocation();

    overlays.add(restoOverlay);
    overlays.add(myLocOverlay);
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }
}

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

    RestoItemizedOverlay restoOverlay = new RestoItemizedOverlay(drawable, this);

    for (Resto resto : provider.getRestos()) {
      restoOverlay.add(createOverlayItem(resto.name, resto.address, resto.latitude, resto.longitude));
    }
    overlays.add(restoOverlay);

    // Acquire a reference to the system Location Manager
    MyLocationOverlay myLocOverlay = new MyLocationOverlay(this, map);
		myLocOverlay.enableMyLocation();

    overlays.add(restoOverlay);
    overlays.add(myLocOverlay);
  }

  private OverlayItem createOverlayItem(String x, String y, int latitude, int longitude) {
    GeoPoint userPoint = new GeoPoint(latitude, longitude);
    return new OverlayItem(userPoint, x, y);
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }
}

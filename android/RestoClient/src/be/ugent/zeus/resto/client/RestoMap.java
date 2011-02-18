package be.ugent.zeus.resto.client;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import be.ugent.zeus.resto.client.data.MenuProvider;
import be.ugent.zeus.resto.client.data.Resto;
import be.ugent.zeus.resto.client.map.RestoItemizedOverlay;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapView;
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

    MapView mapView = (MapView) findViewById(R.id.mapview);
    if (mapView == null) {
      return;
    }
    mapView.setBuiltInZoomControls(true);
    List<Overlay> overlays = mapView.getOverlays();

    for (Resto resto : provider.getRestos()) {
      GeoPoint point = new GeoPoint(resto.longitude, resto.latitude);
      OverlayItem overlayitem = new OverlayItem(point, resto.name, resto.address);

      Drawable drawable = this.getResources().getDrawable(android.R.drawable.star_on);
      RestoItemizedOverlay overlay = new RestoItemizedOverlay(drawable);

      overlay.addOverlay(overlayitem);
      overlays.add(overlay);

    }
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }
}

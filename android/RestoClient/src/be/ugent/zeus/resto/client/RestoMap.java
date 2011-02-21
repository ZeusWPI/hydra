package be.ugent.zeus.resto.client;

import android.os.Bundle;
import be.ugent.zeus.resto.client.data.MenuProvider;
import be.ugent.zeus.resto.client.map.RestoOverlay;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapView;
import com.google.android.maps.MyLocationOverlay;
import com.google.android.maps.Overlay;
import java.util.List;

/**
 *
 * @author Thomas Meire
 */
public class RestoMap extends MapActivity {

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.restomap);

    MapView map = (MapView) findViewById(R.id.mapview);
    map.setBuiltInZoomControls(true);

    // Add an overlay containing all resto markers
    RestoOverlay restoOverlay = new RestoOverlay(this, new MenuProvider(getCacheDir()));

    // Add a standard overlay containing the users location
    MyLocationOverlay myLocOverlay = new MyLocationOverlay(this, map);
    myLocOverlay.enableMyLocation();

    List<Overlay> overlays = map.getOverlays();
    overlays.add(restoOverlay);
    overlays.add(myLocOverlay);
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }
}

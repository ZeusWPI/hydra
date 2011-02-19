package be.ugent.zeus.resto.client;

import android.graphics.drawable.Drawable;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;
import be.ugent.zeus.resto.client.data.MenuProvider;
import be.ugent.zeus.resto.client.data.Resto;
import be.ugent.zeus.resto.client.map.RestoItemizedOverlay;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import java.util.List;

import static java.lang.Math.ceil;

/**
 *
 * @author Thomas Meire
 */
public class RestoMap extends MapActivity {

  private MenuProvider provider;

  private LocationListener locationListener;
  private LocationManager locationManager;

  private MapView map;
  private Drawable drawable;

  // overlay for the users location
  private RestoItemizedOverlay overlay;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.restomap);

    provider = new MenuProvider(getCacheDir());
    drawable = this.getResources().getDrawable(android.R.drawable.star_on);

    map = (MapView) findViewById(R.id.mapview);
    if (map == null) {
      return;
    }
    map.setBuiltInZoomControls(true);
    List<Overlay> overlays = map.getOverlays();

    RestoItemizedOverlay restoOverlay = new RestoItemizedOverlay(drawable, this);

    for (Resto resto : provider.getRestos()) {
      restoOverlay.add(createOverlay(resto.name, resto.address, resto.latitude, resto.longitude));
    }
    overlays.add(restoOverlay);

    // Acquire a reference to the system Location Manager
    locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
    locationListener = new UserLocationListener();
    Location location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
    Log.i("[RestoMap]", "NETWORK_PROVIDER location: " + location);
    if (location == null) {
      location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
      Log.i("[RestoMap]", "GPS_PROVIDER location: " + location);
    }

    overlay = new RestoItemizedOverlay(drawable, this);
    if (location != null) {
      // add marker for the location of the user
      overlay.add(createOverlay("You", "Your location", (int) ceil(location.getLatitude() * 1E6), (int) ceil(location.getLongitude() * 1E6)));
    }
    locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 1, locationListener);
    locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 1, locationListener);

    overlays.add(restoOverlay);
    overlays.add(overlay);
  }

  @Override
  public void onResume (){
    super.onResume();
    locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 1, locationListener);
    locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 1, locationListener);
  }

  @Override
  public void onPause (){
    super.onPause();
    locationManager.removeUpdates(locationListener);
  }


  private OverlayItem createOverlay(String x, String y, int latitude, int longitude) {
    GeoPoint userPoint = new GeoPoint(latitude, longitude);
    return new OverlayItem(userPoint, x, y);
  }

  private void moveCurrentUserLocation(int latitude, int longitude) {
    List<Overlay> overlays = map.getOverlays();
    overlays.remove(overlay);
    
    overlay = new RestoItemizedOverlay(drawable, this);
    overlay.add(createOverlay("You", "Your location", latitude, longitude));

    map.getOverlays().add(overlay);
    map.invalidate();
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }

  class UserLocationListener implements LocationListener {

    public void onLocationChanged(Location location) {
      Log.i("[LocListener]", "Location changed for provider " + location.getProvider());
      moveCurrentUserLocation((int) ceil(location.getLatitude() * 1E6), (int) ceil(location.getLongitude() * 1E6));
    }

    public void onStatusChanged(String string, int i, Bundle bundle) {
    }

    public void onProviderEnabled(String string) {
    }

    public void onProviderDisabled(String string) {
    }
  }
}

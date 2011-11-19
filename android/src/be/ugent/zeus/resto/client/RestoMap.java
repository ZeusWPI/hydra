package be.ugent.zeus.resto.client;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import be.ugent.zeus.resto.client.data.MenuProvider;
import be.ugent.zeus.resto.client.map.RestoOverlay;
import com.google.android.maps.GeoPoint;
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

  private MapView map;

  private MenuProvider provider;
  private MyLocationOverlay myLocOverlay;

  private ServiceConnection connection = new ServiceConnection() {

    public void onServiceConnected(ComponentName cn, IBinder service) {
      provider = ((MenuProvider.LocalBinder) service).getService();
      addRestoOverlay();
    }

    public void onServiceDisconnected(ComponentName cn) {
      provider = null;
    }
  };

  private MapUpdateReceiver mapUpdateReceiver = new MapUpdateReceiver();

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // start & bind to the data providere service
    bindService(new Intent("be.ugent.zeus.resto.client.data.MenuProvider"), connection, Context.BIND_AUTO_CREATE);

    setContentView(R.layout.restomap);

    map = (MapView) findViewById(R.id.mapview);
    map.setBuiltInZoomControls(true);

    // center the map somewhere in Ghent
    map.getController().setCenter(new GeoPoint(51045792, 3722391));
    map.getController().setZoom(13);

    // Add a standard overlay containing the users location
    myLocOverlay = new MyLocationOverlay(this, map);
    myLocOverlay.enableMyLocation();

    List<Overlay> overlays = map.getOverlays();
    overlays.add(myLocOverlay);

    addRestoOverlay();
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    unbindService(connection);
  }

  @Override
  public void onResume() {
    super.onResume();
    registerReceiver(mapUpdateReceiver, new IntentFilter(RestoMap.MapUpdateReceiver.class.getName()));
    myLocOverlay.enableMyLocation();
  }

  @Override
  public void onPause() {
    super.onPause();
    unregisterReceiver(mapUpdateReceiver);
    myLocOverlay.disableMyLocation();
  }

  /**
   * Add an overlay containing all resto markers
   */
  private void addRestoOverlay() {
    if (provider != null) {
      List<Overlay> overlays = map.getOverlays();
      overlays.add(new RestoOverlay(this, provider));
    }
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }

  public class MapUpdateReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context cntxt, Intent intent) {
      addRestoOverlay();
    }
  }
}

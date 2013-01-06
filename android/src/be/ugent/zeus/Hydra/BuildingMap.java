package be.ugent.zeus.Hydra;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.widget.Toast;
import be.ugent.zeus.Hydra.R;
import be.ugent.zeus.Hydra.data.Resto;
import be.ugent.zeus.Hydra.data.caches.RestoCache;
import be.ugent.zeus.Hydra.data.services.HTTPIntentService;
import be.ugent.zeus.Hydra.data.services.RestoService;
import be.ugent.zeus.Hydra.ui.map.RestoOverlay;
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
public class BuildingMap extends MapActivity {

  private MapView map;
  private MyLocationOverlay myLocOverlay;
  private RestoResultReceiver receiver = new RestoResultReceiver();

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setTitle(R.string.title_buildings);
    setContentView(R.layout.restomap);

    map = (MapView) findViewById(R.id.mapview);

    // try to add an overlay with resto's
    addRestoOverlay(false);

    // enable the zoom controls
    map.setBuiltInZoomControls(true);

    // center the map somewhere in Ghent
    map.getController().setCenter(new GeoPoint(51045792, 3722391));
    map.getController().setZoom(13);

    // Add a standard overlay containing the users location
    myLocOverlay = new MyLocationOverlay(this, map);
    myLocOverlay.enableMyLocation();

    List<Overlay> overlays = map.getOverlays();
    overlays.add(myLocOverlay);
  }

  @Override
  public void onPause() {
    super.onPause();
    myLocOverlay.disableMyLocation();
  }

  @Override
  public void onResume() {
    super.onResume();
    myLocOverlay.enableMyLocation();
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    myLocOverlay.disableMyLocation();
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }

  private void addRestoOverlay(boolean synced) {
    final List<Resto> restos = RestoCache.getInstance(BuildingMap.this).getAll();

    if (restos.size() > 0) {
      List<Overlay> overlays = map.getOverlays();
      overlays.add(new RestoOverlay(BuildingMap.this, restos));
      map.postInvalidate();
    } else {
      if (!synced) {
        // start the intent service to fetch the list of resto's
        Intent intent = new Intent(this, RestoService.class);
        intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, receiver);
        startService(intent);
      } else {
        Toast.makeText(BuildingMap.this, R.string.no_restos_found, Toast.LENGTH_SHORT).show();
      }
    }
  }

  private class RestoResultReceiver extends ResultReceiver {

    public RestoResultReceiver() {
      super(null);
    }

    @Override
    protected void onReceiveResult(int code, Bundle data) {
      if (code == RestoService.STATUS_FINISHED) {
        addRestoOverlay(true);
      }
    }
  }
}

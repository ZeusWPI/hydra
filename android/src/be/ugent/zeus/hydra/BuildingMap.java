package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.os.ResultReceiver;
import be.ugent.zeus.hydra.data.services.RestoService;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.maps.MyLocationOverlay;

/**
 *
 * @author Thomas Meire
 */
public class BuildingMap extends AbstractMapActivity {

    private MapView mapView;
    private GoogleMap map;
    private MyLocationOverlay myLocOverlay;
    private RestoResultReceiver receiver = new RestoResultReceiver();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setTitle(R.string.title_buildings);
        setContentView(R.layout.restomap);

        mapView = (MapView) findViewById(R.id.mapview);
        mapView.onCreate(savedInstanceState);
        map = mapView.getMap();
        //map.getCameraPosition()


//        try to add an overlay with resto's
//        addRestoOverlay(false);

//        center the map somewhere in Ghent
//        map.getController().setCenter(new GeoPoint(51045792, 3722391));
//        map.getController().setZoom(13);

//        GoogleMapOptions options = new GoogleMapOptions();
//        options.camera(new CameraPosition(new LatLng(0, 0), 15, 0, 0));

//
//        // Add a standard overlay containing the users location
//        myLocOverlay = new MyLocationOverlay(this, map);
//        myLocOverlay.enableMyLocation();
//
//        List<Overlay> overlays = map.getOverlays();
//        overlays.add(myLocOverlay);
    }

    @Override
    public void onPause() {
        super.onPause();
//        myLocOverlay.disableMyLocation();
    }

    @Override
    public void onResume() {
        mapView.onResume();
        super.onResume();
//        myLocOverlay.enableMyLocation();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mapView.onDestroy();
//        myLocOverlay.disableMyLocation();
    }

    @Override
    protected boolean isRouteDisplayed() {
        return false;
    }

//    private void addRestoOverlay(boolean synced) {
//        final List<Resto> restos = RestoCache.getInstance(BuildingMap.this).getAll();
//
//        if (restos.size() > 0) {
//            List<Overlay> overlays = map.getOverlays();
//            overlays.add(new RestoOverlay(BuildingMap.this, restos));
//            map.postInvalidate();
//        } else {
//            if (!synced) {
//                // start the intent service to fetch the list of resto's
//                Intent intent = new Intent(this, RestoService.class);
//                intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, receiver);
//                startService(intent);
//            } else {
//                Toast.makeText(BuildingMap.this, R.string.no_restos_found, Toast.LENGTH_SHORT).show();
//            }
//        }
//    }
    private class RestoResultReceiver extends ResultReceiver {

        public RestoResultReceiver() {
            super(null);
        }

        @Override
        protected void onReceiveResult(int code, Bundle data) {
            if (code == RestoService.STATUS_FINISHED) {
//                addRestoOverlay(true);
            }
        }
    }
}

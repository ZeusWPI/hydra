package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.services.RestoService;
import com.actionbarsherlock.app.SherlockFragmentActivity;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;

/**
 *
 * @author Thomas Meire
 */
public class BuildingMap extends AbstractSherlockFragmentActivity {

    private GoogleMap map;
    private RestoResultReceiver receiver = new RestoResultReceiver();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setTitle(R.string.title_buildings);
        setContentView(R.layout.restomap);
        
        map = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map)).getMap();
        
        try {
            MapsInitializer.initialize(this);
        } catch (GooglePlayServicesNotAvailableException ex) {
            Log.e("GPS:", "Error" + ex);
        }

        map.setMyLocationEnabled(true);

//        TODO: Fix the map on the users location when he is in Ghent
//        LatLng location = new LatLng(map.getMyLocation().getLatitude(), map.getMyLocation().getLongitude());
//        LatLngBounds bounds = new LatLngBounds(new LatLng(51.016347, 3.677673), new LatLng(51.072684, 3.746338));

        CameraUpdate center;
        CameraUpdate zoom;
        // Is the user in Ghent?
//        if (bounds.contains(location)) {
//            center = CameraUpdateFactory.newLatLng(location);
//            zoom = CameraUpdateFactory.zoomTo(6);
//        } else {
        center = CameraUpdateFactory.newLatLng(new LatLng(51.052833, 3.723335));
        zoom = CameraUpdateFactory.zoomTo(13);
//        }

        map.moveCamera(center);
        map.animateCamera(zoom);


//        try to add an overlay with resto's
//        addRestoOverlay(false);
//
//        Add a standard overlay containing the users location
//        myLocOverlay = new MyLocationOverlay(this, map);
//        myLocOverlay.enableMyLocation();
//
//        List<Overlay> overlays = map.getOverlays();
//        overlays.add(myLocOverlay);
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

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

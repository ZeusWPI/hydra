package be.ugent.zeus.hydra;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.Resto;
import be.ugent.zeus.hydra.data.caches.RestoCache;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.data.services.RestoService;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import java.util.List;

/**
 *
 * @author Tom Naessens
 */
public class BuildingMap extends AbstractSherlockFragmentActivity {

    private GoogleMap map;
    private RestoResultReceiver receiver = new RestoResultReceiver();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setTitle(R.string.title_restomap);
        setContentView(R.layout.restomap);

        setUpMapIfNeeded();
    }

    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (map == null) {
            map = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map)).getMap();

            // Check if we were successful in obtaining the map.
            if (map != null) {
                // The Map is verified. It is now safe to manipulate the map.
                setUpMap();
            } else {
                int result = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
                if (result != ConnectionResult.SUCCESS) {
                    GooglePlayServicesUtil.getErrorDialog(result, this, 1);
                }
            }
        }
    }

    public void setUpMap() {
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

//        Is the user in Ghent?
//        if (bounds.contains(location)) {
//            center = CameraUpdateFactory.newLatLng(location);
//            zoom = CameraUpdateFactory.zoomTo(6);
//        } else {
        center = CameraUpdateFactory.newLatLng(new LatLng(51.052833, 3.723335));
        zoom = CameraUpdateFactory.zoomTo(13);
//        }

        map.moveCamera(center);
        map.animateCamera(zoom);

        addRestos(false);

    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onResume() {
        super.onResume();
        setUpMapIfNeeded();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    private void addRestos(boolean synced) {
        final List<Resto> restos = RestoCache.getInstance(BuildingMap.this).getAll();

        if (restos.size() > 0) {
            for (Resto resto : restos) {
                map.addMarker((new MarkerOptions()
                    .position(new LatLng(resto.latitude, resto.longitude))
                    .title(resto.name)));
            }
        } else {
            if (!synced) {
                Intent intent = new Intent(this, RestoService.class);
                intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, receiver);
                startService(intent);
            } else {
                Toast.makeText(BuildingMap.this, R.string.no_restos_found, Toast.LENGTH_SHORT).show();
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getSupportMenuInflater().inflate(R.menu.building_search, menu);

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.search:
                onSearchRequested();
                return true;
            default:
                return false;
        }
    }

    private class RestoResultReceiver extends ResultReceiver {

        public RestoResultReceiver() {
            super(null);
        }

        @Override
        protected void onReceiveResult(int code, Bundle data) {
            if (code == RestoService.STATUS_FINISHED) {
                runOnUiThread(new Runnable() {
                    public void run() {
                        addRestos(true);
                    }
                });
            }
        }
    }
}

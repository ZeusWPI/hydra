package be.ugent.zeus.hydra;

import android.app.SearchManager;
import android.content.Intent;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.Marker;
import java.util.HashMap;

/**
 *
 * @author Tom Naessens
 */
public class BuildingMap extends AbstractSherlockFragmentActivity implements GoogleMap.OnMarkerClickListener, GoogleMap.OnInfoWindowClickListener {

    private GoogleMap map;
    private HashMap<String, Marker> markerMap;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setTitle(R.string.title_restomap);
        setContentView(R.layout.restomap);

        markerMap = new HashMap<String, Marker>();

        setUpMapIfNeeded();

        handleIntent(getIntent());
    }

    @Override
    public void onNewIntent(Intent intent) {
        setIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        if (Intent.ACTION_SEARCH.equals(intent.getAction())) {
            String query = intent.getStringExtra(SearchManager.QUERY);
            doSearch(query);
        }
    }

    private void doSearch(String queryStr) {
        if (markerMap.containsKey(queryStr)) {
            Marker foundMarker = markerMap.get(queryStr);
            updateMarkerDistance(foundMarker);
            foundMarker.showInfoWindow();
            map.moveCamera(CameraUpdateFactory.newLatLng(foundMarker.getPosition()));

        } else {
            this.runOnUiThread(new Runnable() {
                public void run() {
                    Toast.makeText(BuildingMap.this, R.string.no_restos_found, Toast.LENGTH_SHORT).show();
                }
            });
        }
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

    public boolean onMarkerClick(Marker marker) {
        updateMarkerDistance(marker);
        marker.showInfoWindow();

        return true;
    }

    public void updateMarkerDistance(Marker marker) {
        if (map.getMyLocation() == null) {

            marker.setSnippet("");

        } else {

            float[] results = new float[1];

            Location.distanceBetween(map.getMyLocation().getLatitude(), map.getMyLocation().getLongitude(),
                    marker.getPosition().latitude, marker.getPosition().longitude, results);

            double distance = results[0];

            if (distance < 2000) {
                marker.setSnippet(String.format("Afstand: %.0f m", results[0]));
            } else {
                marker.setSnippet(String.format("Afstand: %.1f km", results[0] / 1000.0));
            }


        }
    }

    public void onInfoWindowClick(Marker marker) {
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(String.format("http://maps.google.com/maps?q=%s,%s", marker.getPosition().latitude, marker.getPosition().longitude)));
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
        startActivity(intent);
    }

    public GoogleMap getMap() {
        return map;
    }

    public HashMap<String, Marker> getMarkerMap() {
        return markerMap;
    }

    public void setUpMap() {
        try {
            MapsInitializer.initialize(this);
        } catch (GooglePlayServicesNotAvailableException ex) {
            Log.e("GPS:", "Error" + ex);
        }

        map.setMyLocationEnabled(true);
        map.setOnMarkerClickListener(this);
        map.setOnInfoWindowClickListener(this);
    }
}

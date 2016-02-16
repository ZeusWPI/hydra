package be.ugent.zeus.hydra;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ConfigurationInfo;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesUtil;
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
                final ActivityManager activityManager =
                        (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
                final ConfigurationInfo configurationInfo =
                        activityManager.getDeviceConfigurationInfo();
                final boolean supportsEs2 = configurationInfo.reqGlEsVersion >= 0x20000;
                if (!supportsEs2) {
                    Toast.makeText(this, R.string.maps_opengl_error,
                            Toast.LENGTH_SHORT).show();
                    finish();
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

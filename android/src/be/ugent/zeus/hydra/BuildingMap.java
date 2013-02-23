package be.ugent.zeus.hydra;

import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.Resto;
import be.ugent.zeus.hydra.data.caches.RestoCache;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.data.services.RestoService;
import be.ugent.zeus.hydra.ui.map.DirectionMarker;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem;
import com.actionbarsherlock.widget.SearchView;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import java.util.HashMap;
import java.util.List;

/**
 *
 * @author Tom Naessens
 */
public class BuildingMap extends AbstractSherlockFragmentActivity implements GoogleMap.OnMarkerClickListener, GoogleMap.OnInfoWindowClickListener {

    private GoogleMap map;
    private RestoResultReceiver receiver = new RestoResultReceiver();
    private HashMap<String, Marker> markerMap;
    private RestoCache restoCache;

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
        map.setOnMarkerClickListener(this);
        map.setOnInfoWindowClickListener(this);

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
        center = CameraUpdateFactory.newLatLng(new LatLng(51.042833, 3.723335));
        zoom = CameraUpdateFactory.zoomTo(13);
//        }

        map.moveCamera(center);
        map.animateCamera(zoom);
        map.setInfoWindowAdapter(new DirectionMarker(getLayoutInflater()));


        restoCache = RestoCache.getInstance(this);

        if (!restoCache.exists(RestoService.FEED_NAME)
            || System.currentTimeMillis() - restoCache.lastModified(RestoService.FEED_NAME) > RestoService.REFRESH_TIME) {
            addRestos(false);
        } else {
            addRestos(true);
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

    private void addRestos(boolean synced) {
        if (!synced) {
            Intent intent = new Intent(this, RestoService.class);
            intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, receiver);
            startService(intent);

        } else {

            Resto[] restos = RestoCache.getInstance(BuildingMap.this).get(RestoService.FEED_NAME);
            if (restos != null && restos.length > 0) {
                for (Resto resto : restos) {
                    MarkerOptions markerOptions = new MarkerOptions()
                        .position(new LatLng(resto.latitude, resto.longitude))
                        .title(resto.name);

                    Marker marker = map.addMarker(markerOptions);
                    markerMap.put(resto.name, marker);
                }
            } else {
                Toast.makeText(BuildingMap.this, R.string.no_restos_found, Toast.LENGTH_SHORT).show();
                finish();
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
//        getSupportMenuInflater().inflate(R.menu.building_search, menu);
//
//        SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
//        SearchView searchView = new SearchView(getSupportActionBar().getThemedContext());
//
//        searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));

        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.search:
                onSearchRequested();
                return true;
        }
        return super.onOptionsItemSelected(item);
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

    private class RestoResultReceiver extends ResultReceiver {

        public RestoResultReceiver() {
            super(null);
        }

        @Override
        protected void onReceiveResult(int code, Bundle data) {
            switch (code) {
                case RestoService.STATUS_FINISHED:
                    runOnUiThread(new Runnable() {
                        public void run() {
                            addRestos(true);
                        }
                    });
                    break;

                case HTTPIntentService.STATUS_ERROR:
                    Toast.makeText(BuildingMap.this, R.string.resto_update_failed, Toast.LENGTH_SHORT).show();
                    runOnUiThread(new Runnable() {
                        public void run() {
                            addRestos(true);
                        }
                    });
                    break;

            }

        }
    }
}

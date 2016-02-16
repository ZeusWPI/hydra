/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package be.ugent.zeus.hydra;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.Resto;
import be.ugent.zeus.hydra.data.caches.RestoCache;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.data.services.RestoService;
import be.ugent.zeus.hydra.ui.map.DirectionMarker;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

/**
 *
 * @author silox
 */
public class RestoMap extends BuildingMap {

    private RestoResultReceiver receiver = new RestoResultReceiver();
    private RestoCache restoCache;

    @Override
    public void setUpMap() {
        super.setUpMap();

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

        super.getMap().moveCamera(center);
        super.getMap().animateCamera(zoom);
        super.getMap().setInfoWindowAdapter(new DirectionMarker(getLayoutInflater()));


        restoCache = RestoCache.getInstance(RestoMap.this);

        if (!restoCache.exists(RestoService.FEED_NAME)
                || System.currentTimeMillis() - restoCache.lastModified(RestoService.FEED_NAME) > RestoService.REFRESH_TIME) {
            addRestos(false);
        } else {
            addRestos(true);
        }

    }

    private void addRestos(boolean synced) {
        if (!synced) {
            Intent intent = new Intent(this, RestoService.class);
            intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, receiver);
            startService(intent);

        } else {

            Resto[] restos = RestoCache.getInstance(RestoMap.this).get(RestoService.FEED_NAME);
            if (restos != null && restos.length > 0) {
                for (Resto resto : restos) {
                    MarkerOptions markerOptions = new MarkerOptions()
                            .position(new LatLng(resto.latitude, resto.longitude))
                            .title(resto.name);

                    Marker marker = super.getMap().addMarker(markerOptions);
                    super.getMarkerMap().put(resto.name, marker);
                }
            } else {
                Toast.makeText(RestoMap.this, R.string.no_restos_found, Toast.LENGTH_SHORT).show();
                finish();
            }
        }
    }

    private class RestoResultReceiver extends ResultReceiver {

        public RestoResultReceiver() {
            super(null);
        }

        @Override
        protected void onReceiveResult(final int code, Bundle data) {

            if (code != HTTPIntentService.STATUS_STARTED) {
                RestoMap.this.runOnUiThread(new Runnable() {
                    public void run() {


                        if (code == HTTPIntentService.STATUS_ERROR) {
                            Toast.makeText(RestoMap.this, R.string.resto_update_failed, Toast.LENGTH_SHORT).show();
                        }

                        addRestos(true);
                    }
                });
            }
        }
    }
}

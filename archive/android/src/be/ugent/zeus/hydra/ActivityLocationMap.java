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
public class ActivityLocationMap extends BuildingMap {

    @Override
    public void setUpMap() {
        super.setUpMap();

        CameraUpdate center;
        CameraUpdate zoom;

        center = CameraUpdateFactory.newLatLng(new LatLng(51.042833, 3.723335));
        zoom = CameraUpdateFactory.zoomTo(13);

        // Add the activity
        addActivity(getIntent().getExtras());

        // Move the camera
        super.getMap().moveCamera(center);
        super.getMap().animateCamera(zoom);
        super.getMap().setInfoWindowAdapter(new DirectionMarker(getLayoutInflater()));
    }

    private void addActivity(Bundle extras) {
        // Get the extras
        String name = extras.getString("name");
        Double lat = extras.getDouble("lat");
        Double lng = extras.getDouble("lng");

        // Create the marker
        MarkerOptions markerOptions = new MarkerOptions()
                .position(new LatLng(lat, lng))
                .title(name);

        // And add it!
        Marker marker = super.getMap().addMarker(markerOptions);
        super.getMarkerMap().put(name, marker);
    }
}

/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.ui.map;

import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Marker;

public class DirectionMarker implements GoogleMap.InfoWindowAdapter {

    LayoutInflater inflater;

    public DirectionMarker(LayoutInflater inflater) {
        this.inflater = inflater;
    }

    public View getInfoWindow(Marker marker) {
        return (null);
    }

    public View getInfoContents(Marker marker) {
        View popup = inflater.inflate(R.layout.directionmarker, null);

        TextView tv = (TextView) popup.findViewById(R.id.title);

        tv.setText(marker.getTitle());
        tv = (TextView) popup.findViewById(R.id.snippet);
        tv.setText(marker.getSnippet());

        return (popup);
    }
}

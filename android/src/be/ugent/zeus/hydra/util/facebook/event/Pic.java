/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook.event;

import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.widget.ImageView;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

public class Pic extends AsyncTask<Void, Void, Drawable> {

    ImageView image;
    String url;

    public Pic(ImageView image, String url) {
        this.image = image;
        this.url = url;
    }

    @Override
    protected Drawable doInBackground(Void... params) {
        InputStream is = null;
        try {
            is = (InputStream) new URL(url).getContent();
        } catch (MalformedURLException ex) {
        } catch (IOException ex) {
        }

        return Drawable.createFromStream(is, "Event picture");
    }

    @Override
    protected void onPostExecute(Drawable result) {
        image.setImageDrawable(result);
    }
}

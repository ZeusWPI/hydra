/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica
 * Universiteit Gent
 *
 */
package be.ugent.zeus.hydra;

import android.app.Activity;
import android.content.Intent;
import android.support.v4.app.NavUtils;
import android.support.v4.app.TaskStackBuilder;
import android.util.Log;
import be.ugent.zeus.hydra.settings.Settings;
import com.actionbarsherlock.view.MenuItem;

public class ActionBarHelper {

    public static boolean onOptionsItemSelected(MenuItem item, Activity activity) {
        // Handle item selection
        switch (item.getItemId()) {
            case android.R.id.home:
                NavUtils.navigateUpFromSameTask(activity);
                return true;
            case R.id.settings:
                Intent settingsIntent = new Intent(activity, Settings.class);
                activity.startActivity(settingsIntent);
                return true;
            case R.id.about:
                Intent aboutIntent = new Intent(activity, About.class);
                activity.startActivity(aboutIntent);
                return true;
            default:
                return true;
        }
    }
}

/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
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
            case R.id.settings:
                Intent settingsIntent = new Intent(activity, Settings.class);
                activity.startActivity(settingsIntent);
                return true;
            case R.id.about:
                Intent aboutIntent = new Intent(activity, About.class);
                activity.startActivity(aboutIntent);
                return true;
            case android.R.id.home:
                // This is called when the Home (Up) button is pressed
                // in the Action Bar.
                Intent upIntent = new Intent(activity, Hydra.class); // Default to Hydra

                if (activity.getIntent().getStringExtra("class") != null) {
                    try {
                        Log.d("Up-button functionality", activity.getIntent().getStringExtra("class"));
                        upIntent = new Intent(activity, Class.forName(activity.getIntent().getStringExtra("class")));
                    } catch (ClassNotFoundException ex) {
                    }
                }

                if (NavUtils.shouldUpRecreateTask(activity, upIntent)) {
                    // This activity is not part of the application's task, so create a new task
                    // with a synthesized back stack.
                    TaskStackBuilder.from(activity)
                        .addNextIntent(upIntent)
                        .startActivities();
                    activity.finish();
                } else {
                    // This activity is part of the application's task, so simply
                    // navigate up to the hierarchical parent activity.
                    NavUtils.navigateUpTo(activity, upIntent);
                }
                return true;
            default:
                return true;
        }
    }
}

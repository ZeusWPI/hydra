/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra;

import android.content.Intent;
import android.os.Bundle;
import com.actionbarsherlock.app.SherlockListActivity;
import com.actionbarsherlock.view.MenuItem;
import com.google.analytics.tracking.android.EasyTracker;

public abstract class AbstractSherlockListActivity extends SherlockListActivity {

	@Override
	public void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		setTitle(R.string.title_info);

		getActionBar().setDisplayHomeAsUpEnabled(true);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle item selection
		switch (item.getItemId()) {
			case android.R.id.home:
				// This is called when the Home (Up) button is pressed
				// in the Action Bar.
				Intent parentActivityIntent = new Intent(this, Hydra.class);
				parentActivityIntent.addFlags(
					 Intent.FLAG_ACTIVITY_CLEAR_TOP
					 | Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(parentActivityIntent);
				finish();
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onStart() {
		super.onStart();
		EasyTracker.getInstance().activityStart(this);
	}

	@Override
	public void onStop() {
		super.onStop();
		EasyTracker.getInstance().activityStop(this);
	}
}

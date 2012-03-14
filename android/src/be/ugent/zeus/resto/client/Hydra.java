package be.ugent.zeus.resto.client;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;

/**
 * 
 * @author Thomas Meire
 */
public class Hydra extends Activity {

	private void link(int id, final Class activity) {
		findViewById(id).setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				startActivity(new Intent(Hydra.this, activity));
			}
		});
	}

	@Override
	public void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		setContentView(R.layout.hydra);
    setTitle("");

		link(R.id.home_btn_news, News.class);
		link(R.id.home_btn_calendar, Calendar.class);
		link(R.id.home_btn_info, Info.class);
		link(R.id.home_btn_menu, RestoMenu.class);
		link(R.id.home_btn_gsr, GSR.class);
		link(R.id.home_btn_schamper, SchamperDaily.class);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.hydra, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle item selection
		switch (item.getItemId()) {
		case R.id.settings:
			Intent intent = new Intent(this, Settings.class);
			startActivity(intent);
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}
}

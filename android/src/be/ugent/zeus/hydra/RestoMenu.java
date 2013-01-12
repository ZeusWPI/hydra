package be.ugent.zeus.hydra;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.ComponentName;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.os.Parcelable;
import android.preference.PreferenceManager;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.caches.MenuCache;
import be.ugent.zeus.hydra.data.caches.RestoCache;
import be.ugent.zeus.hydra.ui.SwipeyTabs;
import be.ugent.zeus.hydra.ui.SwipeyTabsAdapter;
import be.ugent.zeus.hydra.ui.menu.MenuAdapter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import com.actionbarsherlock.app.SherlockActivity;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuInflater;
import com.actionbarsherlock.view.MenuItem;
import com.google.analytics.tracking.android.EasyTracker;

/**
 *
 * @author Thomas Meire
 */
public class RestoMenu extends AbstractSherlockActivity {

  private static final String VERSION = "be.ugent.zeus.hydra.version";
  private SharedPreferences prefs;
  private SwipeyTabs tabs;
  private ViewPager pager;
  private MenuPagerAdapter adapter;

  /**
   * Called when the activity is first created.
   */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    prefs = PreferenceManager.getDefaultSharedPreferences(this);

    int old = prefs.getInt(VERSION, 0);
    int current = getVersionCode();
    if (old < current) {
      Log.i("[RestoMenu]", "New version code " + current + " (Old code was: " + old + ")");
      clearCaches();
      Editor editor = prefs.edit();
      editor.putInt(VERSION, current);
      editor.commit();
    }

    setTitle(R.string.title_menu);
    setContentView(R.layout.menu);

    pager = (ViewPager) findViewById(R.id.pager);
    tabs = (SwipeyTabs) findViewById(R.id.tabs);
    pager.setOnPageChangeListener(tabs);

    adapter = new MenuPagerAdapter();
    pager.setAdapter(adapter);
    tabs.setAdapter(adapter);
  }

  @Override
  public void onResume() {
    super.onResume();
  }

  private void clearCaches() {
    Log.i("RestoMenu", "Should clear caches now...");
    MenuCache.getInstance(this).clear();
    RestoCache.getInstance(this).clear();
  }

  private List<Calendar> getViewableDates() {
    List<Calendar> days = new ArrayList<Calendar>(5);

    Calendar instance = Calendar.getInstance();
    for (int i = 0; i < 5; i++) {
      if (instance.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY) {
        instance.add(Calendar.DATE, 2);
      }
      if (instance.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
        instance.add(Calendar.DATE, 1);
      }
      days.add((Calendar) instance.clone());
      instance.add(Calendar.DATE, 1);
    }
    return days;
  }

  private class MenuPagerAdapter extends PagerAdapter implements SwipeyTabsAdapter {

    List<Calendar> dates;
    List<MenuAdapter> views = new ArrayList<MenuAdapter>(5);

    public MenuPagerAdapter() {
      dates = getViewableDates();
      for (Calendar date : dates) {
        views.add(new MenuAdapter(RestoMenu.this, date));
      }
    }

    @Override
    public int getCount() {
      return views.size();
    }

    /**
     * Create the page for the given position. The adapter is responsible for
     * adding the view to the container given here, although it only must ensure
     * this is done by the time it returns from {@link #finishUpdate()}.
     *
     * @param container The containing View in which the page will be shown.
     * @param position The page position to be instantiated.
     * @return Returns an Object representing the new page. This does not need
     * to be a View, but can be some other container of the page.
     */
    @Override
    public Object instantiateItem(View collection, int position) {
      ((ViewPager) collection).addView(views.get(position).getView(), 0);

      return views.get(position).getView();
    }

    /**
     * Remove a page for the given position. The adapter is responsible for
     * removing the view from its container, although it only must ensure this
     * is done by the time it returns from {@link #finishUpdate()}.
     *
     * @param container The containing View from which the page will be removed.
     * @param position The page position to be removed.
     * @param object The same object that was returned by
     * {@link #instantiateItem(View, int)}.
     */
    @Override
    public void destroyItem(View collection, int position, Object view) {
      ((ViewPager) collection).removeView((View) view);
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
      return view == ((View) object);
    }

    /**
     * Called when the a change in the shown pages has been completed. At this
     * point you must ensure that all of the pages have actually been added or
     * removed from the container as appropriate.
     *
     * @param container The containing View which is displaying this adapter's
     * page views.
     */
    @Override
    public void finishUpdate(View arg0) {
    }

    @Override
    public void restoreState(Parcelable arg0, ClassLoader arg1) {
    }

    @Override
    public Parcelable saveState() {
      return null;
    }

    @Override
    public void startUpdate(View arg0) {
    }

    public TextView getTab(final int position, SwipeyTabs root) {
      TextView title = views.get(position).getTab();
      title.setOnClickListener(new OnClickListener() {
        public void onClick(final View v) {
          pager.setCurrentItem(position);
        }
      });
      return title;
    }
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    MenuInflater inflater = getSupportMenuInflater();
    inflater.inflate(R.menu.viewmap, menu);
    return true;
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    // Handle item selection
    switch (item.getItemId()) {
      case R.id.show_about:
        showAboutDialog();
      default:
        return super.onOptionsItemSelected(item);
    }
  }

  /**
   * About dialog based on code from Mobile Vikings for Android by Ben Van Daele
   */
  public void showAboutDialog() {
    Builder builder = new Builder(this);
    builder.setIcon(android.R.drawable.ic_dialog_info);
    builder.setTitle(getString(R.string.about));
    builder.setMessage(getAboutMessage());
    builder.setPositiveButton(getString(android.R.string.ok), null);
    AlertDialog dialog = builder.create();
    dialog.show();
  }

  public CharSequence getAboutMessage() {
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append(getString(R.string.legend_swiping));
    stringBuilder.append("\n\n");
    stringBuilder.append(getString(R.string.legend)).append(":\n\n");
    stringBuilder.append(getString(R.string.legend_fries)).append("\n");
    stringBuilder.append(getString(R.string.legend_bold)).append("\n");
    stringBuilder.append(getString(R.string.legend_hash));
    return stringBuilder;
  }

  private int getVersionCode() {
    try {
      ComponentName componentName = new ComponentName(this, RestoMenu.class);
      PackageInfo info = getPackageManager().getPackageInfo(componentName.getPackageName(), 0);
      return info.versionCode;
    } catch (NameNotFoundException e) {
      // Won't happen, versionCode is present in the manifest!
      return 0;
    }
  }  
}

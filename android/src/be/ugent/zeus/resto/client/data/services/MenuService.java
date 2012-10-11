package be.ugent.zeus.resto.client.data.services;

import be.ugent.zeus.resto.client.data.caches.MenuCache;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.resto.client.data.Menu;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Iterator;
import org.json.JSONObject;

/**
 *
 * @author Thomas Meire
 */
public class MenuService extends HTTPIntentService {

  public static final String DATE_EXTRA = "date";
  public static final String MENU = "menu";
  /**
   * Location of the menu's for a certain week. '%s' has to be replaced by the
   * week of the year as returned by c.get(Calendar.WEEK_OF_YEAR).
   */
  private static final String MENU_URL = "http://zeus.ugent.be/hydra/api/1.0/resto/week/%s.json";
  /**
   *
   */
  private static final SimpleDateFormat FORMAT = new SimpleDateFormat("yyyy-MM-dd");
  private MenuCache cache = null;

  public MenuService() {
    super("MenuService");
  }

  @Override
  public void onCreate() {
    super.onCreate();
    // get an instance of the menu cache
    cache = MenuCache.getInstance(this);
  }

  private Menu sync(Calendar date) {
    String formatted = FORMAT.format(date.getTime());
    Menu menu = null;
    try {
      String url = String.format(MENU_URL, date.get(Calendar.WEEK_OF_YEAR));
      Log.i("[MenuService]", "Fetching menus from " + url);
      String content = fetch(url);
      JSONObject data = new JSONObject(content);

      Iterator<String> it = data.keys();
      while (it.hasNext()) {
        String name = it.next();
        Menu tmp = parseJsonObject(data.getJSONObject(name), Menu.class);
        cache.put(name, tmp);
        if (formatted.equals(name)) {
          menu = tmp;
        }
      }
    } catch (Exception e) {
      Log.i("[MenuService]", e.getMessage());
      e.printStackTrace();
    }
    return menu;
  }

  @Override
  protected void onHandleIntent(Intent intent) {
    final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);
    if (receiver != null) {
      receiver.send(STATUS_STARTED, Bundle.EMPTY);
    }

    final Calendar c = (Calendar) intent.getSerializableExtra(DATE_EXTRA);

    // get the menu from the local cache
    Menu menu = cache.get(FORMAT.format(c.getTime()));

    // if not in the cache, sync it from the rest service
    if (menu == null) {
      menu = sync(c);
    }

    // send the result to the receiver
    if (receiver != null) {
      final Bundle bundle = new Bundle();
      bundle.putSerializable("menu", menu);
      receiver.send(STATUS_FINISHED, bundle);
    }
  }
}

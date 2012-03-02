package be.ugent.zeus.resto.client.data.caches;

import android.content.Context;
import be.ugent.zeus.resto.client.data.Menu;
import java.io.File;

/**
 *
 * @author Thomas Meire
 */
public class MenuCache extends Cache<Menu> {

  // fixme: do we need a map of caches here?
  private static MenuCache cache;

  private MenuCache(File menuCacheDir) {
    super(menuCacheDir);
  }

  public static synchronized MenuCache getInstance(Context context) {
    if (cache == null) {
      File cacheDir = context.getCacheDir();
      File menuCacheDir = new File(cacheDir, "menu");
      cache = new MenuCache(menuCacheDir);
    }
    return cache;
  }
}

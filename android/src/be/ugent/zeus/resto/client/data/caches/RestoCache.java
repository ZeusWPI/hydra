package be.ugent.zeus.resto.client.data.caches;

import android.content.Context;
import be.ugent.zeus.resto.client.data.Resto;
import java.io.File;

/**
 *
 * @author Thomas Meire
 */
public class RestoCache extends Cache<Resto> {

  // fixme: do we need a map of caches here?
  private static RestoCache cache;

  private RestoCache(File restoCacheDir) {
    super(restoCacheDir);
  }

  public static RestoCache getInstance(Context context) {
    if (cache == null) {
      File cacheDir = context.getCacheDir();
      File restoCacheDir = new File(cacheDir, "resto");
      cache = new RestoCache(restoCacheDir);
    }
    return cache;
  }
}

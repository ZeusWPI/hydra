package be.ugent.zeus.Hydra.data.caches;

import android.content.Context;
import be.ugent.zeus.Hydra.data.Resto;
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

  public static synchronized RestoCache getInstance(Context context) {
    if (cache == null) {
      File cacheDir = context.getCacheDir();
      File restoCacheDir = new File(cacheDir, "resto");
      cache = new RestoCache(restoCacheDir);
    }
    return cache;
  }
}

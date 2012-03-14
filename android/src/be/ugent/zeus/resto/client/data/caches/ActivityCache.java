package be.ugent.zeus.resto.client.data.caches;

import android.content.Context;
import be.ugent.zeus.resto.client.data.Activity;
import java.io.File;
import java.util.ArrayList;

/**
 *
 * @author Thomas Meire
 */
public class ActivityCache extends Cache<ArrayList<Activity>> {

  private static ActivityCache cache;

  private ActivityCache(File activityCacheDir) {
    super(activityCacheDir);
  }

  public static synchronized ActivityCache getInstance(Context context) {
    if (cache == null) {
      File cacheDir = context.getCacheDir();
      File activityCacheDir = new File(cacheDir, "activity");
      cache = new ActivityCache(activityCacheDir);
    }
    return cache;
  }
}


package be.ugent.zeus.resto.client.data.caches;

import android.content.Context;
import be.ugent.zeus.resto.client.data.rss.Channel;
import java.io.File;

/**
 *
 * @author Thomas Meire
 */
public class ChannelCache extends Cache<Channel>{
  
  private static ChannelCache cache;

  private ChannelCache(File channelCacheDir) {
    super(channelCacheDir);
  }

  public static synchronized ChannelCache getInstance(Context context) {
    if (cache == null) {
      File cacheDir = context.getCacheDir();
      File channelCacheDir = new File(cacheDir, "channel");
      cache = new ChannelCache(channelCacheDir);
    }
    return cache;
  }
}

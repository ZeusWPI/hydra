package be.ugent.zeus.hydra.data.caches;

import android.content.Context;
import be.ugent.zeus.hydra.data.rss.Channel;
import java.io.File;

/**
 *
 * @author Thomas Meire
 */
public class ChannelCache extends Cache<Channel> {

    public static final String SCHAMPER = "schamper";
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

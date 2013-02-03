package be.ugent.zeus.hydra.data.caches;

import java.io.File;
import java.util.ArrayList;

import android.content.Context;
import be.ugent.zeus.hydra.GSR;
import be.ugent.zeus.hydra.data.NewsItem;

public class GSRCache extends Cache<ArrayList<NewsItem>> {

    private static GSRCache cache;

    private GSRCache(File gsrCacheDir) {
        super(gsrCacheDir);
    }

    public static synchronized GSRCache getInstance(Context context) {
        if (cache == null) {
            File cacheDir = context.getCacheDir();
            File gsrCacheDir = new File(cacheDir, GSR.CACHE_FILE);
            cache = new GSRCache(gsrCacheDir);
        }
        return cache;
    }
}

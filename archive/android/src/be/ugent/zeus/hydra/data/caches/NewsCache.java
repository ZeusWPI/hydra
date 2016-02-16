package be.ugent.zeus.hydra.data.caches;

import android.content.Context;
import be.ugent.zeus.hydra.data.NewsItem;
import java.io.File;
import java.util.ArrayList;

public class NewsCache extends Cache<ArrayList<NewsItem>> {

    private static NewsCache cache;

    private NewsCache(File newsCacheDir) {
        super(newsCacheDir);
    }

    public static synchronized NewsCache getInstance(Context context) {
        if (cache == null) {
            File cacheDir = context.getCacheDir();
            File newsCacheDir = new File(cacheDir, "news");
            cache = new NewsCache(newsCacheDir);
        }
        return cache;
    }
}

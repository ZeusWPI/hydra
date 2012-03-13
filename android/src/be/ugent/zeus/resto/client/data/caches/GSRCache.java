package be.ugent.zeus.resto.client.data.caches;

import java.io.File;
import java.util.ArrayList;

import android.content.Context;
import be.ugent.zeus.resto.client.data.NewsItem;

public class GSRCache extends Cache<ArrayList<NewsItem>> {
	private static GSRCache cache;

	private GSRCache(File gsrCacheDir) {
		super(gsrCacheDir);
	}

	public static synchronized GSRCache getInstance(Context context) {
		if (cache == null) {
			File cacheDir = context.getCacheDir();
			File gsrCacheDir = new File(cacheDir, "gsr");
			cache = new GSRCache(gsrCacheDir);
		}
		return cache;
	}
}

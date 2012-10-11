package be.ugent.zeus.resto.client.data.services;

import java.util.ArrayList;

import be.ugent.zeus.resto.client.GSR;
import be.ugent.zeus.resto.client.data.NewsItem;
import be.ugent.zeus.resto.client.data.caches.Cache;
import be.ugent.zeus.resto.client.data.caches.GSRCache;

public class GSRIntentService extends AbstractNewsIntentService {

  @Override
  public boolean filter(String path) {
    return path.startsWith(GSR.FILTER_PREFIX);
  }

  @Override
  public String cacheKey() {
    return GSR.CACHE_KEY;
  }

  @Override
  public Cache<ArrayList<NewsItem>> getCache() {
    return GSRCache.getInstance(this);
  }
}

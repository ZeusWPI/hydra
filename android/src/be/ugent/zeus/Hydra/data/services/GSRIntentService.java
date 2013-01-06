package be.ugent.zeus.Hydra.data.services;

import java.util.ArrayList;

import be.ugent.zeus.Hydra.GSR;
import be.ugent.zeus.Hydra.data.NewsItem;
import be.ugent.zeus.Hydra.data.caches.Cache;
import be.ugent.zeus.Hydra.data.caches.GSRCache;

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

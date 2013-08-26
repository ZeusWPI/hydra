/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.data.caches;

import android.content.Context;
import be.ugent.zeus.hydra.data.RestoLegend;
import java.io.File;
import java.util.ArrayList;

public class LegendCache extends Cache<ArrayList<RestoLegend>> {

    // fixme: do we need a map of caches here?
    private static LegendCache cache;

    private LegendCache(File legendCacheDir) {
        super(legendCacheDir);
    }

    public static synchronized LegendCache getInstance(Context context) {
        if (cache == null) {
            File cacheDir = context.getCacheDir();
            File legendCacheDir = new File(cacheDir, "legend");
            cache = new LegendCache(legendCacheDir);
        }
        return cache;
    }
}

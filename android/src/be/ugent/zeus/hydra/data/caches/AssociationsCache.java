/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.data.caches;

import android.content.Context;
import java.io.File;
import java.util.HashSet;

public class AssociationsCache extends Cache<HashSet<String>> {

    private static AssociationsCache cache;

    private AssociationsCache(File assocationsCacheDir) {
        super(assocationsCacheDir);
    }

    public static synchronized AssociationsCache getInstance(Context context) {
        if (cache == null) {
            File cacheDir = context.getCacheDir();
            File newsCacheDir = new File(cacheDir, "associations");
            cache = new AssociationsCache(newsCacheDir);
        }
        return cache;
    }
}

/*
 * Copyright 2013 Stijn Seghers <stijn.seghers at ugent.be>.
 */
package be.ugent.zeus.hydra.data.caches;

import android.content.Context;
import be.ugent.zeus.hydra.data.Song;
import java.io.File;

/**
 *
 * @author Stijn Seghers <stijn.seghers at ugent.be>
 */
public class SongCache extends Cache<Song> {

    public static final String CURRENT = "CURRENT";
    public static final String PREVIOUS = "PREVIOUS";
    private static SongCache cache;

    private SongCache(File NowPlayingCacheDir) {
        super(NowPlayingCacheDir);
    }

    public static synchronized SongCache getInstance(Context context) {
        if (cache == null) {
            File cacheDir = context.getCacheDir();
            File newsCacheDir = new File(cacheDir, "nowplaying");
            cache = new SongCache(newsCacheDir);
        }
        return cache;
    }
}

/*
 * Copyright 2013 Stijn Seghers <stijn.seghers at ugent.be>.
 */
package be.ugent.zeus.hydra.data.services;

import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.util.Log;
import be.ugent.zeus.hydra.data.Song;
import be.ugent.zeus.hydra.data.caches.SongCache;

/**
 *
 * @author Stijn Seghers <stijn.seghers at ugent.be>
 */
public class UrgentService extends HTTPIntentService {

    private static final String TAG = "UrgentService";
    private static final String SONG_URL = "http://urgent.fm/nowplaying/livetrack.txt";
    private static final String PROGRAM_URL = "http://urgent.fm/nowplaying/program.php";
    private SongCache cache;

    public UrgentService() {
        super("UrgentService");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        cache = SongCache.getInstance(this);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        final ResultReceiver receiver = intent.getParcelableExtra(RESULT_RECEIVER_EXTRA);
        if (receiver != null) {
            receiver.send(STATUS_STARTED, Bundle.EMPTY);
        }
        try {
            update();
            if (receiver != null) {
                receiver.send(STATUS_FINISHED, Bundle.EMPTY);
            }
        } catch (Exception ex) {
            Log.e(TAG, "Error: " + ex.getMessage());
            if (receiver != null) {
                receiver.send(STATUS_ERROR, Bundle.EMPTY);
            }
        }
    }

    private void update() throws Exception {
        long lastModified = cache.lastModified(SongCache.CURRENT);
        String title_and_artist = fetch(SONG_URL, lastModified);
        if (title_and_artist == null) {
            return;
        }
        Song current = cache.get(SongCache.CURRENT);
        if (current != null) {
            Song prev = new Song();
            prev.title_and_artist = current.title_and_artist;
            prev.program = current.program;
            cache.put(SongCache.PREVIOUS, prev);
        }
        Song song = new Song();
        song.title_and_artist = title_and_artist;
        song.program = fetch(PROGRAM_URL);
        cache.put(SongCache.CURRENT, song);
    }
}

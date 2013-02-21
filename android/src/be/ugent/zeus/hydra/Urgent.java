/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 * @author Stijn Seghers <stijn.seghers at ugent.be>
 */
package be.ugent.zeus.hydra;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.ResultReceiver;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import be.ugent.zeus.hydra.data.Song;
import be.ugent.zeus.hydra.data.caches.SongCache;
import be.ugent.zeus.hydra.data.services.HTTPIntentService;
import be.ugent.zeus.hydra.data.services.UrgentService;
import be.ugent.zeus.hydra.util.audiostream.MusicService;

public class Urgent extends AbstractSherlockActivity {

    private static final String TAG = "Urgent";
    private static final int REFRESH_TIME = 20 * 1000;
    private final Handler handler = new Handler();
    private Runnable refresh;
    private SongCache cache;
    private TextView show;
    private TextView previous;
    private TextView current;
    LinearLayout prevContainer;
    LinearLayout currentContainer;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setTitle(R.string.title_urgent);
        setContentView(R.layout.urgent);

        final ImageButton btnPlay = (ImageButton) findViewById(R.id.btnPlay);
        if (MusicService.mState == MusicService.State.Playing) {
            btnPlay.setImageResource(R.drawable.button_urgent_pause);
        } else {
            btnPlay.setImageResource(R.drawable.button_urgent_play);
        }


        show = (TextView) findViewById(R.id.urgent_current_show);
        previous = (TextView) findViewById(R.id.urgent_vorige);
        current = (TextView) findViewById(R.id.urgent_huidige);

        prevContainer = (LinearLayout) findViewById(R.id.urgent_vorige_container);
        currentContainer = (LinearLayout) findViewById(R.id.urgent_huidige_container);

        btnPlay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View arg0) {
                if (MusicService.mState != MusicService.State.Playing) {
                    btnPlay.setImageResource(R.drawable.button_urgent_pause);

                    handler.post(refresh);

                } else {
                    btnPlay.setImageResource(R.drawable.button_urgent_play);

                    handler.removeCallbacks(refresh);
                }
                startService(new Intent(MusicService.ACTION_TOGGLE_PLAYBACK));
            }
        });

        refresh = new Runnable() {
            public void run() {
                Log.d(TAG, "refreshing time!");
                refresh();
                handler.postDelayed(refresh, REFRESH_TIME);
            }
        };

        cache = SongCache.getInstance(Urgent.this);

        Log.v(TAG, "opgestart");
    }

    @Override
    protected void onPause() {
        super.onPause();
        handler.removeCallbacks(refresh);
    }

    @Override
    protected void onResume() {
        super.onResume();
        cache.clear();
        if (MusicService.mState == MusicService.State.Playing) {
            handler.post(refresh);
        }
    }

    private void refresh() {
        Intent intent = new Intent(this, UrgentService.class);
        intent.putExtra(HTTPIntentService.RESULT_RECEIVER_EXTRA, new SongResultReceiver());

        startService(intent);
    }

    private class SongResultReceiver extends ResultReceiver {

        SongResultReceiver() {
            super(null);
        }

        @Override
        public void onReceiveResult(int code, Bundle icicle) {
            switch (code) {
                case HTTPIntentService.STATUS_FINISHED:
                    Urgent.this.runOnUiThread(new Runnable() {
                        public void run() {
                            Song curSong = cache.get(SongCache.CURRENT);
                            Song prevSong = cache.get(SongCache.PREVIOUS);

                            // TODO: integrate this into the layout
                            if (prevSong != null && !prevSong.title_and_artist.equals("Geen plaat(info)")) {
                                previous.setText(prevSong.title_and_artist.toUpperCase());
                                prevContainer.setVisibility(TextView.VISIBLE);

                                Log.v(TAG, "Previous: " + prevSong.title_and_artist + " (" + prevSong.program + ")");
                            } else {
                                prevContainer.setVisibility(TextView.GONE);

                                Log.v(TAG, "Previous: " + R.string.no_song_info_found);
                            }
                            if (curSong != null && !curSong.title_and_artist.equals("Geen plaat(info)")) {
                                current.setText(curSong.title_and_artist.toUpperCase());
                                currentContainer.setVisibility(TextView.VISIBLE);

                                Log.v(TAG, "Current: " + curSong.title_and_artist + " (" + curSong.program + ")");
                            } else {
                                currentContainer.setVisibility(TextView.GONE);

                                Log.v(TAG, "Current: " + R.string.no_song_info_found);
                            }

                            if (curSong != null && !show.getText().equals(String.format(getResources().getString(R.string.urgent_show_prefix),
                                curSong.program.toUpperCase()))) {
                                show.setText(
                                    String.format(getResources().getString(R.string.urgent_show_prefix),
                                    curSong.program.toUpperCase()));
                            }

                        }
                    });
                    break;
                case HTTPIntentService.STATUS_ERROR:
                    Toast.makeText(Urgent.this, R.string.nowplaying_update_failed, Toast.LENGTH_SHORT).show();
                    break;
            }
        }
    }
}

/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import be.ugent.zeus.hydra.util.audiostream.MusicService;

public class Urgent extends AbstractSherlockActivity {

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

        btnPlay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View arg0) {
                if (MusicService.mState != MusicService.State.Playing) {
                    btnPlay.setImageResource(R.drawable.button_urgent_pause);
                } else {
                    btnPlay.setImageResource(R.drawable.button_urgent_play);
                }
                startService(new Intent(MusicService.ACTION_TOGGLE_PLAYBACK));
            }
        });

    }
}

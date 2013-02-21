/*
 * Copyright 2013 Stijn Seghers <stijn.seghers at ugent.be>.
 */
package be.ugent.zeus.hydra;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;

/**
 *
 * @author Stijn Seghers <stijn.seghers at ugent.be>
 */
public class About extends AbstractSherlockActivity {

    private static final String ZEUS_URL = "http://zeus.ugent.be";

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setTitle(R.string.title_about);
        setContentView(R.layout.about);
    }

    public void openZeusWebPage(View view) {
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
        i.setData(Uri.parse(ZEUS_URL));
        startActivity(i);
    }

    public void showExternalComponents(View view) {
        Intent intent = new Intent(this, ExternalComponents.class);
        intent.putExtra("class", this.getClass().getCanonicalName());
        startActivity(intent);
    }
}

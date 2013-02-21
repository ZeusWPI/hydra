/*
 * Copyright 2013 Stijn Seghers <stijn.seghers at ugent.be>.
 */
package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Stijn Seghers <stijn.seghers at ugent.be>
 */
public class ExternalComponents extends AbstractSherlockActivity {

    private static final String TAG = "EXT_COMP";
    private static final int DEFAULT_BUFFER_SIZE = 1024 * 4;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setTitle(R.string.title_external_components);
        setContentView(R.layout.external_components);

        WebView view = (WebView) findViewById(R.id.external_components_list);
        view.loadDataWithBaseURL(null, getContent(), "text/html", "utf8", null);
    }

    private String getContent() {
        StringBuilder out = new StringBuilder();

        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(getResources().openRawResource(R.raw.credits)));
            String line;
            while ((line = reader.readLine()) != null) {
                out.append(line).append("\n");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        }
        return out.toString();
    }
}

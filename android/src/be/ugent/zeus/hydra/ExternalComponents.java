/*
 * Copyright 2013 Stijn Seghers <stijn.seghers at ugent.be>.
 */
package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;
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
        InputStream stream = getResources().openRawResource(R.raw.credits);
        view.loadData(streamToString(stream, "utf-8"), "text/html", "utf-8");
    }
    
    private String streamToString(InputStream stream, String encoding) {
        InputStreamReader in = null;
        try {
            StringWriter sw = new StringWriter();
            in = new InputStreamReader(stream, encoding);
            char[] buffer = new char[DEFAULT_BUFFER_SIZE];
            int n = 0;
            while (-1 != (n = in.read(buffer))) {
                sw.write(buffer, 0, n);
            }
            return sw.toString();
        } catch (IOException ex) {
            Log.e(TAG, "Exception during raw file read: " + ex.getMessage());
        } finally {
            try {
                in.close();
            } catch (IOException ex) {
                Log.e(TAG, "Exception during close: " + ex.getMessage());
            }
        }
        return null;
    }
}

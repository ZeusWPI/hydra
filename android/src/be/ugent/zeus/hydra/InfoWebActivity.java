package be.ugent.zeus.hydra;

import android.os.Bundle;
import android.view.View;
import android.webkit.WebView;
import com.actionbarsherlock.app.SherlockActivity;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 *
 * @author Thomas Meire
 */
public class InfoWebActivity extends AbstractSherlockActivity {

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setContentView(R.layout.info_web_activity);

        String page = getContent(getIntent().getStringExtra("page"));

        WebView view = (WebView) findViewById(R.id.webview);
        view.getSettings().setLoadWithOverviewMode(true);
        view.getSettings().setUseWideViewPort(true);
        view.loadDataWithBaseURL("file:///android_asset/", page, "text/html", "utf8", null);
    }

    private String getResourceName(String name) {
        int idx = name.indexOf(".html");
        if (idx != -1) {
            name = name.substring(0, idx);
        }
        return "raw/" + name.replace("-", "_");
    }

    private String getContent(String name) {
        StringBuilder out = new StringBuilder();

        BufferedReader reader = null;
        try {
            int id = getResources().getIdentifier(getResourceName(name), null, "be.ugent.zeus.hydra");
            reader = new BufferedReader(new InputStreamReader(getResources().openRawResource(id)));
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

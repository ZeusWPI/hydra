/**
 *
 * @author http://www.roosmaa.net/application-wide-locale-override/
 *
 */
package be.ugent.zeus.hydra;

import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;
import java.util.Locale;

public class Localisation extends Application {

    @Override
    public void onCreate() {
        updateLanguage(this);
        super.onCreate();
    }

    public static void updateLanguage(Context ctx) {
        Configuration cfg = new Configuration();
        cfg.locale = new Locale("nl", "BE");

        ctx.getResources().updateConfiguration(cfg, null);
    }
}
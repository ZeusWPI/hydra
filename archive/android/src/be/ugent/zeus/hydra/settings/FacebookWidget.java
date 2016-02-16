/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.settings;

import android.content.Context;
import android.preference.Preference;
import android.util.AttributeSet;

public class FacebookWidget extends Preference {

    public FacebookWidget(Context context, AttributeSet attrs) {
        super(context, attrs);

        setLayoutResource(context.getResources().getIdentifier("settings_facebook", "layout", context.getPackageName()));

    }
}

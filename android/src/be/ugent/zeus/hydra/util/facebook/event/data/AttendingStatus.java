/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.util.facebook.event.data;

import android.content.Context;
import android.content.res.Resources;

public enum AttendingStatus {

    ATTENDING("attending","button_attending"),
    MAYBE("maybe","button_maybe"),
    DECLINED("declined","button_declined"),
    UNDECIDED("undecided","button_undecided");
    
    private String title;
    private String buttonTitle;

    private AttendingStatus(String title, String buttonTitle) {
        this.title = title;
        this.buttonTitle = buttonTitle;
    }

    public String toString(Context context) {
        Resources res = context.getResources();
        int resId = res.getIdentifier(title, "string", context.getPackageName());

        return res.getString(resId);
    }
    
    
    public String toButtonString(Context context) {
        Resources res = context.getResources();
        int resId = res.getIdentifier(buttonTitle, "string", context.getPackageName());

        return res.getString(resId);
    }
}

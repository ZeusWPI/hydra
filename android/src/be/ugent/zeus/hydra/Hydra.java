package be.ugent.zeus.hydra;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import com.actionbarsherlock.app.ActionBar;
import com.google.analytics.tracking.android.GoogleAnalytics;
import java.util.Locale;

/**
 * @author Zeus WPI
 */
public class Hydra extends AbstractSherlockActivity {

//    ZubhiumSDK sdk;
    public static final Locale LOCALE = new Locale("nl", "BE");
    private static final boolean DEBUG = false;
    private static final boolean BETA = false;
    public static boolean SHOWED_NETWORK = false;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setContentView(R.layout.hydra);
        setTitle("");

        if (!SHOWED_NETWORK) {
            // Check if internet is available
            ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
            if (activeNetworkInfo == null || !activeNetworkInfo.isConnectedOrConnecting()) {
                new AlertDialog.Builder(this)
                    .setTitle(R.string.no_network_title)
                    .setMessage(R.string.no_network)
                    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.dismiss();
                    }
                })
                    .show();
            }
            SHOWED_NETWORK = true;
        }

        // Set the default preference - won't be changed if the user altered it.
        PreferenceManager.setDefaultValues(this, R.xml.settings, false);

        // Center the image using a custom layout
        getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        getSupportActionBar().setCustomView(R.layout.abs_main);

        // Zubhium
//        if (!DEBUG) {
//        Log.d("Zubhium:", "Enable bugtracking");
//        sdk = ZubhiumSDK.getZubhiumSDKInstance(getApplicationContext(), "4837990a007ee67c597d1059742293");
//        if (sdk != null) {
//            // We are registering update receiver
//            sdk.registerUpdateReceiver(Hydra.this);
//        }
//        }

        // Google Analytics
        if (BETA || DEBUG) {
            Log.d("GAnalytics:", "Tracking disabled");
            GoogleAnalytics googleAnalytics = GoogleAnalytics.getInstance(getApplicationContext());
            googleAnalytics.setAppOptOut(true);
        }

        // Home screen: disable the button
        getSupportActionBar().setDisplayHomeAsUpEnabled(false);
        getSupportActionBar().setHomeButtonEnabled(false);

        link(R.id.home_btn_news, News.class);
        link(R.id.home_btn_calendar, Calendar.class);
        link(R.id.home_btn_info, Info.class);
        link(R.id.home_btn_menu, RestoMenu.class);
        link(R.id.home_btn_urgent, Urgent.class);
        link(R.id.home_btn_schamper, SchamperDaily.class);
    }

    private void link(int id, final Class activity) {
        findViewById(id).setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                Intent intent = new Intent(Hydra.this, activity);
                intent.putExtra("class", Hydra.class.getCanonicalName());
                startActivity(intent);
            }
        });
    }

//    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        MenuInflater inflater = getSupportMenuInflater();
//        inflater.inflate(R.menu.hydra, menu);
//        return super.onCreateOptionsMenu(menu);
//    }

//    @Override
//    public boolean onOptionsItemSelected(MenuItem item) {
//        // Handle item selection
//        switch (item.getItemId()) {
//            case R.id.feedbackButton:
//                setupFeedback();
//                return true;
//            default:
//                return super.onOptionsItemSelected(item);
//        }
//    }

//    @Override
//    protected void onDestroy() {
//        if (sdk != null) {
//            sdk.unRegisterUpdateReceiver();     // Don't forget to unregister receiver
//        }
//        super.onDestroy();
//    }

//    protected void setupFeedback() {
//        /**
//         * Now lets listen to users, by enabling in app help desk. *
//         */
//        if (sdk != null) {
//            sdk.openFeedbackDialog(Hydra.this);
//        }
//    }
}

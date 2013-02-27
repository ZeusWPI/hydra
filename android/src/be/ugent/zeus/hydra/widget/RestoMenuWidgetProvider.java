/**
 *
 * @author Ruben Taelman
 *
 */
package be.ugent.zeus.hydra.widget;

import java.util.Calendar;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.view.View;
import android.widget.RemoteViews;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.RestoMenu;
import be.ugent.zeus.hydra.data.Menu;
import be.ugent.zeus.hydra.data.services.MenuService;
import be.ugent.zeus.hydra.data.services.RestoService;
import be.ugent.zeus.hydra.ui.menu.MenuView;

public class RestoMenuWidgetProvider extends AppWidgetProvider {
	private RemoteViews views;
	private Context context;
	private AppWidgetManager appWidgetManager;
	private int[] appWidgetIds;
	
	public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
		this.context=context;
		this.appWidgetManager=appWidgetManager;
		this.appWidgetIds=appWidgetIds;
        
        // Get the layout for the App Widget
        views = new RemoteViews(context.getPackageName(), R.layout.widget_restomenu);
        
        // Send intent to retrieve Menu data for today
        Intent menuIntent = new Intent(context, MenuService.class);
        menuIntent.putExtra(MenuService.RESULT_RECEIVER_EXTRA, new RestoMenuWidgetResultReceiver());
        menuIntent.putExtra(MenuService.DATE_EXTRA, Calendar.getInstance());
        context.startService(menuIntent);
        
        // Add action to widget to start the RestoMenu activity
        Intent intent = new Intent(context, RestoMenu.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);
        views.setOnClickPendingIntent(R.id.widget_image, pendingIntent);
    }
	
	private class RestoMenuWidgetResultReceiver extends ResultReceiver {

		public RestoMenuWidgetResultReceiver() {
			super(null);
		}
		
		@Override
        protected void onReceiveResult(int code, Bundle data) {
			if (code == MenuService.STATUS_FINISHED) {
				// Read today's Menu
				Menu menu = (be.ugent.zeus.hydra.data.Menu) data.getSerializable(MenuService.MENU);
				
				final int N = appWidgetIds.length;
				// Perform this loop procedure for each App Widget that belongs to this provider
		        for (int i=0; i<N; i++) {
		            int appWidgetId = appWidgetIds[i];
		            
		            // Since the widget only contains static content, it can be made with this
		            // simple trick without having to remake the complete View
		            View view=new MenuView(context, menu);
		            view.measure(350, 600);
		            view.layout(0, 0, 350, 600);
		            view.setDrawingCacheEnabled(true);
		            Bitmap bitmap=view.getDrawingCache();
		            views.setImageViewBitmap(R.id.widget_image, bitmap);
		            
		            // Tell the AppWidgetManager to perform an update on the current app widget
		            appWidgetManager.updateAppWidget(appWidgetId, views);
		        }
			}
		}
		
	}
}

package be.ugent.zeus.resto.client.data;

import java.util.List;

import android.content.Context;
import android.widget.ArrayAdapter;

public class NewsList extends ArrayAdapter<NewsItem> {

	public NewsList(Context context, int resource, int textViewResourceId,
			List<NewsItem> objects) {
		super(context, resource, textViewResourceId, objects);
		// TODO Auto-generated constructor stub
	}

	
}

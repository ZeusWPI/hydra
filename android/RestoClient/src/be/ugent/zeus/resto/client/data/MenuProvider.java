package be.ugent.zeus.resto.client.data;

import android.util.Log;
import java.io.IOException;
import java.util.Date;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONObject;

/**
 *
 * @author Thomas Meire
 */
public class MenuProvider {

  private static String URL = "http://zeus.ugent.be/~blackskad/resto/today/menu.json";

  public MenuProvider(Date today) {
  }

  private String fetch () throws Exception {
    HttpClient httpclient = new DefaultHttpClient();
    HttpGet request = new HttpGet(URL);

    return httpclient.execute(request, new BasicResponseHandler());
  }

  public Menu getMenu(int offset) {
    try {
      String json = fetch();
      JSONObject menu = new JSONObject(json);

      Log.i("[]", menu.getJSONObject("Dinsdag").getJSONArray("meat").getJSONObject(0).getString("name"));

    } catch (Exception e) {
      e.printStackTrace();
    }
    return null;
  }
}

package be.ugent.zeus.resto.client.data;

import android.util.Log;
import java.io.File;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Thomas Meire
 */
public class MenuProvider {

  private static String URL = "http://zeus.ugent.be/~blackskad/resto/api/0.1/week/6.json";

  private Cache<Menu> cache;

  public MenuProvider(File cacheDir) {
    cache = new Cache<Menu>(cacheDir);
  }

  private static final SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

  public Menu getMenu (Date day) {
    Menu menu = cache.get(format.format(day));
    if (menu == null) {
      Thread fetcher = new MenuFetcherThread(URL);
      fetcher.start();
    }
    return menu;
  }

  private class MenuFetcherThread extends Thread {

    private String url;

    public MenuFetcherThread(String url) {
      this.url = url;
    }

    private String fetch() throws Exception {
      HttpClient httpclient = new DefaultHttpClient();
      HttpGet request = new HttpGet(URL);

      return httpclient.execute(request, new BasicResponseHandler());
   }

    private <T> T parseJsonObject(JSONObject object, Class<T> klass) throws Exception {
      T instance = klass.newInstance();

      for (Field f : klass.getDeclaredFields()) {
        if (object.has(f.getName())) {
          Object o = object.get(f.getName());
          if (o.getClass().equals(JSONObject.class)) {
            f.set(instance, parseJsonObject((JSONObject) o, f.getType()));
          } else if (o.getClass().equals(JSONArray.class)) {
            f.set(instance, parseJsonArray((JSONArray) o, f.getType().getComponentType()));
          } else {
            f.set(instance, o);
          }
        }
      }
      return instance;
    }

    private <T> T[] parseJsonArray(JSONArray array, Class<T> klass) throws Exception {
      T[] instance = (T[]) Array.newInstance(klass, array.length());

      for (int i = 0; i < array.length(); i++) {
        Object o = array.get(i);
        if (o.getClass().equals(JSONObject.class)) {
          instance[i] = parseJsonObject((JSONObject) o, klass);
        } else if (o.getClass().equals(JSONArray.class)) {
          instance[i] = (T) parseJsonArray((JSONArray) o, klass.getComponentType());
        } else {
          instance[i] = (T) o;
        }
      }
      return instance;
    }

    @Override
    public void run() {
      try {
        JSONObject tmp = new JSONObject(fetch());

        Iterator<String> it = tmp.keys();
        while (it.hasNext()) {
          String name = it.next();
          cache.put(name, parseJsonObject(tmp.getJSONObject(name), Menu.class));
        }
      } catch (Exception e) {
        Log.i("[RestoMenu]", e.toString());
        e.printStackTrace();
      }
    }
  }
}

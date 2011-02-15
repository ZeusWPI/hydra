package be.ugent.zeus.resto.client.data;

import android.util.Log;
import java.io.File;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.Calendar;
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

  private static String URL = "http://zeus.ugent.be/~blackskad/resto/api/0.1/week/%s.json";

  private Cache<Menu> cache;

  public MenuProvider(File cacheDir) {
    cache = new Cache<Menu>(cacheDir);
  }
  private static final SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

  public Menu getMenu(Date day) {
    Calendar c = Calendar.getInstance();
    c.setTime(day);


    if (c.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY) {
      // saturday? show the menu for next monday
      c.add(Calendar.DATE, 2);
    } else if (c.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
      // sunday? show the menu for next monday
      c.add(Calendar.DATE, 1);
    }

    Menu menu = cache.get(format.format(c.getTime()));

    if (menu == null) {
      Log.i("[MenuProvider]", "Menu was null!");
      Thread fetcher = new MenuFetcherThread(URL, c.get(Calendar.WEEK_OF_YEAR));
      fetcher.start();
    } else {
      Log.i("[MenuProvider]", menu.toString());
    }
    return menu;
  }

  private class MenuFetcherThread extends Thread {

    private String url;

    public MenuFetcherThread(String url, int week) {
      this.url = String.format(url, week);
      Log.i("[MenuFetcherThread]", "Downloading menu from " + this.url);
    }

    private String fetch() throws Exception {
      HttpClient httpclient = new DefaultHttpClient();
      HttpGet request = new HttpGet(url);

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
        String content = fetch();
        JSONObject tmp = new JSONObject(content);

        Iterator<String> it = tmp.keys();
        while (it.hasNext()) {
          String name = it.next();
          cache.put(name, parseJsonObject(tmp.getJSONObject(name), Menu.class));
        }
      } catch (Exception e) {
        Log.i("[MenuFetcherThread]", e.getMessage());
        e.printStackTrace();
      }
    }
  }
}

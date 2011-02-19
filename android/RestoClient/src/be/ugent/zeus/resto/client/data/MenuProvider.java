package be.ugent.zeus.resto.client.data;

import android.util.Log;
import java.io.File;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
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

  private static String MENU_URL = "http://zeus.ugent.be/~blackskad/resto/api/0.1/week/%s.json";

  private static String RESTO_URL = "http://zeus.ugent.be/~blackskad/resto/api/0.1/list.json";

  private Cache<Menu> menuCache;
  private Cache<Resto> restoCache;

  public MenuProvider(File cacheDir) {
    File menuCacheDir = new File(cacheDir, "menu");
    menuCache = new Cache<Menu>(menuCacheDir);

    File restoCacheDir = new File(cacheDir, "resto");
    restoCache = new Cache<Resto>(restoCacheDir);
  }
  private static final SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

  public Menu getMenu(Calendar c) {
    Menu menu = menuCache.get(format.format(c.getTime()));

    if (menu == null) {
      Log.i("[MenuProvider]", "Menu was null!");
      Thread fetcher = new MenuFetcherThread(MENU_URL, c.get(Calendar.WEEK_OF_YEAR));
      fetcher.start();
    } else {
      Log.i("[MenuProvider]", menu.toString());
    }
    return menu;
  }

  public List<Resto> getRestos() {
    List<Resto> restos = restoCache.getAll();
    if (restos.isEmpty()) {
      RestoFetcherThread fetcher = new RestoFetcherThread();
      fetcher.start();
    }
    return restos;
  }

  private String fetch(String url) throws Exception {
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

  private class RestoFetcherThread extends Thread {

    @Override
    public void run() {
      try {
        Log.i("[RestoFetcherThread]", "Fetching resto's from " + RESTO_URL);
        JSONArray data = new JSONArray(fetch(RESTO_URL));

        for (Resto r : parseJsonArray(data, Resto.class)) {
          restoCache.put(r.name, r);
        }
      } catch (Exception e) {
        Log.i("[RestoFetcherThread]", e.getMessage());
        e.printStackTrace();
      }
    }
  }

  private class MenuFetcherThread extends Thread {

    private String url;

    public MenuFetcherThread(String url, int week) {
      this.url = String.format(url, week);
    }

    @Override
    public void run() {
      try {
        String content = fetch(url);
        JSONObject tmp = new JSONObject(content);

        Iterator<String> it = tmp.keys();
        while (it.hasNext()) {
          String name = it.next();
          menuCache.put(name, parseJsonObject(tmp.getJSONObject(name), Menu.class));
        }
      } catch (Exception e) {
        Log.i("[MenuFetcherThread]", e.getMessage());
        e.printStackTrace();
      }
    }
  }
}

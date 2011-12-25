
package be.ugent.zeus.resto.client.data.services;

import android.app.IntentService;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
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
public abstract class HTTPIntentService extends IntentService {
  public HTTPIntentService (String name) {
    super(name);
  }
  
  protected String fetch(String url) throws Exception {
    HttpClient httpclient = new DefaultHttpClient();
    HttpGet request = new HttpGet(url);

    return httpclient.execute(request, new BasicResponseHandler());
  }

  protected <T> T parseJsonObject(JSONObject object, Class<T> klass) throws Exception {
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

  protected <T> T[] parseJsonArray(JSONArray array, Class<T> klass) throws Exception {
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
}

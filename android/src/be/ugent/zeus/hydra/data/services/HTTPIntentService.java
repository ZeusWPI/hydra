package be.ugent.zeus.hydra.data.services;

import android.app.IntentService;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.util.Date;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.HttpResponseException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.cookie.DateUtils;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Thomas Meire
 */
public abstract class HTTPIntentService extends IntentService {

    public static final int STATUS_STARTED = 0x1;
    public static final int STATUS_ERROR = 0x2;
    public static final int STATUS_FINISHED = 0x3;
    public static final String FORCE_UPDATE = "force-update";
    public static final String RESULT_RECEIVER_EXTRA = "result-receiver";
    protected static final String HYDRA_BASE_URL = "http://golive.myverso.com/ugent/";

    public HTTPIntentService(String name) {
        super(name);
    }

    protected String fetch(String url) throws Exception {
        HttpClient httpclient = new DefaultHttpClient();
        HttpGet request = new HttpGet(url);

        return httpclient.execute(request, new BasicResponseHandler());
    }

    /**
     * Fetch content from a url, but only if it's more recent than the lastModified parameter, which
     * is a unix timestamp.
     *
     * @param url
     * @param lastModified
     * @return the content or null if the content hasn't been changed
     * @throws Exception if something goes wrong or status code is > 300 && != 304
     */
    protected String fetch(String url, long lastModified) throws Exception {
        HttpGet request = new HttpGet(url);
        request.setHeader("If-Modified-Since", DateUtils.formatDate(new Date(lastModified)));

        HttpClient httpclient = new DefaultHttpClient();
        HttpResponse response = httpclient.execute(request);

        StatusLine status = response.getStatusLine();
        if (200 <= status.getStatusCode() && status.getStatusCode() < 300) {
            HttpEntity entity = response.getEntity();
            return entity == null ? null : EntityUtils.toString(entity, "UTF-8");
        } else if (status.getStatusCode() == 304) {
            return null;
        } else {
            throw new HttpResponseException(status.getStatusCode(), status.getReasonPhrase());
        }
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

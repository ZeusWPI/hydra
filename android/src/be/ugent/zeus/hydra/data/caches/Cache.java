package be.ugent.zeus.hydra.data.caches;

import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * TODO: - purge old entries from the cache
 *
 * @author Thomas Meire
 */
public class Cache<T extends Serializable> {

    private File dir;

    public Cache(File dir) {
        Log.i("[Cache]", dir.getAbsolutePath());
        if (!dir.exists()) {
            dir.mkdirs();
        }
        this.dir = dir;
        for (File f : dir.listFiles()) {
            Log.i("[Cache]", "Found cached file " + f.getAbsolutePath());
        }
    }

    /**
     *
     * @param key
     * @return the last modification date as milliseconds since 1970 or -1 of not found
     */
    public long lastModified(String key) {
        File cached = new File(dir, key);
        if (cached.exists()) {
            return cached.lastModified();
        }
        return -1;
    }

    public T get(String key) {
        long start = System.currentTimeMillis();
        Log.i("[Cache]", "Retrieving item: " + key);
        File cached = new File(dir, key);

        ObjectInputStream stream = null;

        try {
            stream = new ObjectInputStream(new FileInputStream(cached));
            T value = (T) stream.readObject();
            stream.close();
            Log.i("[Cache]", "Retrieval took " + (System.currentTimeMillis() - start));
            return value;
        } catch (Exception ex) {
            Log.i("[Cache]", "Error reading object to cache " + key);
            Log.i("[Cache]", ex.toString());
        }
        return null;
    }

    public void put(String key, T value) {
        Log.i("[Cache]", "Putting new item: " + key);
        File cached = new File(dir, key);

        ObjectOutputStream stream = null;
        try {
            stream = new ObjectOutputStream(new FileOutputStream(cached));
            stream.writeObject(value);
            stream.close();
        } catch (IOException ex) {
            Log.i("[Cache]", "Error writing object to cache " + key);
            Log.i("[Cache]", ex.getMessage());
        }
    }

    public List<T> getAll() {
        List<T> cached = new ArrayList<T>();
        for (File f : dir.listFiles()) {
            T item = get(f.getName());
            if (item != null) {
                cached.add(item);
            }
        }
        return cached;
    }

    public void invalidate(String key) {
        File cached = new File(dir, key);
        if (cached.exists()) {
            cached.delete();
        }
    }

    public boolean exists(String key) {
        File cached = new File(dir, key);
        return cached.exists();
    }

    public void clear() {
        for (File f : dir.listFiles()) {
            f.delete();
        }
    }
}

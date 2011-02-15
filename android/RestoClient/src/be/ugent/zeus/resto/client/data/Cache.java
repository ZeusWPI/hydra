package be.ugent.zeus.resto.client.data;

import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

/**
 * TODO:
 *  - purge old entries from the cache
 * 
 * @author Thomas Meire
 */
public class Cache<T extends Serializable> {

  private File dir;

  public Cache(File dir) {
    Log.i("[Cache]", dir.getAbsolutePath());
    for (File f : dir.listFiles()) {
      Log.i("[Cache]", "Found cached file " + f.getAbsolutePath());
      //f.delete();
    }
    this.dir = dir;
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
      Log.i("[Cache]", ex.getMessage());
    }
    return null;
  }

  public void put(String key, T value) {
    Log.i("[SoftCache]", "Putting new item: " + key);
    File cached = new File(dir, key);

    ObjectOutputStream stream = null;
    try {
      stream = new ObjectOutputStream(new FileOutputStream(cached));
      stream.writeObject(value);
      stream.close();
    } catch (IOException ex) {
      Log.i("[RestoMenuCache]", "Error writing object to cache " + key);
      Log.i("[RestoMenuCache]", ex.getMessage());
    }
  }
}

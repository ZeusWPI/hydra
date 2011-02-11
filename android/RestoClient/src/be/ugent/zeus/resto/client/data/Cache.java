package be.ugent.zeus.resto.client.data;

import android.util.Log;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OptionalDataException;
import java.io.Serializable;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Thomas Meire
 */
public class Cache<T extends Serializable> {

  private File dir;

  public Cache(File dir) {
    Log.i("[SoftCache]", dir.getAbsolutePath());
    for(File f : dir.listFiles()) {
      Log.i("[RestoMenuCache]", "Found cached file " + f.getAbsolutePath());
    }
    this.dir = dir;
  }

  public T get(String key) {
    long start = System.currentTimeMillis();
    Log.i("[SoftCache]", "Retrieving item: " + key);
    File cached = new File(dir, key);
    
    ObjectInputStream stream = null;
    
    try {
      stream = new ObjectInputStream(new FileInputStream(cached));
      T value = (T) stream.readObject();
      stream.close();
      Log.i("RestoMenuCache", "Retrieval took " + (System.currentTimeMillis() - start));
      return value;
    } catch (Exception ex) {
      Log.i("[RestoMenuCache]", "Error reading object to cache " + key);
      Log.i("[RestoMenuCache]", ex.getMessage());
    } finally {
      try {
        stream.close();
      } catch (IOException ex) {}
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

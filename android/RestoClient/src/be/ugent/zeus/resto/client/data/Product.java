
package be.ugent.zeus.resto.client.data;

import java.io.Serializable;

/**
 *
 * @author Thomas Meire
 */
public class Product implements Serializable {
  public String name;
  public String price;

  @Override
  public String toString () {
    return name + ": " + price;
  }
}

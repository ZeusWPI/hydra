
package be.ugent.zeus.resto.client.data;

/**
 *
 * @author Thomas Meire
 */
public class Product {
  public String name;
  public Double price;

  @Override
  public String toString () {
    return name + ": " + price;
  }
}

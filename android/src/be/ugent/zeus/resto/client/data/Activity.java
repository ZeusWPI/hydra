
package be.ugent.zeus.resto.client.data;

import java.io.Serializable;

/**
 *
 * @author Thomas Meire
 */
public class Activity implements Serializable {
  public String association_id;
  public String title;
  public String description;
  public String location;
  // FIXME: use Date object here
  public String date;
  public String start;
  public String end;
}
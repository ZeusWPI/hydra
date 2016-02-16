package be.ugent.zeus.hydra.data;

import java.io.Serializable;
import java.util.Date;

/**
 *
 * @author Thomas Meire
 */
public class Activity implements Serializable {

    public String title;
    public Association association;
    public int highlighted;
    public String start;
    public Date startDate;
    public String end;
    public Date endDate;
    public String location;
    public double latitude;
    public double longitude;
    public String description;
    public String url;
    public String facebook_id;
    public String[] categories;
}

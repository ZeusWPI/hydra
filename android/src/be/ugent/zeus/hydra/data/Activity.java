package be.ugent.zeus.hydra.data;

import java.io.Serializable;
import java.util.Date;

/**
 *
 * @author Thomas Meire
 */
public class Activity implements Serializable {

    public String title;
    public Date date;
    public String start;
    public String end;
    public String location;
    public String description;
    public String url;
    public String facebook_id;
    public String[] categories;
    public int highlighted;
    public Association association;
}
package be.ugent.zeus.hydra.data;

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
    // TODO: use Date object here
    public String date;
    public String start;
    public String end;
}
package be.ugent.zeus.hydra.data.rss;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author Thomas Meire
 */
public class Item implements Serializable {

    public String title;
    public String link;
    public String description;
    public String comments;
    public Date pubDate;
    public String creator;
    public List<Category> categories = new ArrayList<Category>();

    @Override
    public String toString() {
        return "'" + title + "' by " + creator;
    }
}

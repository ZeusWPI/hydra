package be.ugent.zeus.hydra.data.rss;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Thomas Meire
 */
public class Channel implements Serializable {

    public String title;
    public String link;
    public String description;
    public String language;
    public List<Item> items = new ArrayList<Item>();

    @Override
    public String toString() {
        String result = "Channel '" + title + "' (" + language + ", " + items.size() + " items): \n" + link + "\n" + description;

        for (Item item : items) {
            result += "\n" + item;
        }
        return result;
    }
}

package be.ugent.zeus.hydra.data;

import java.io.Serializable;
import java.util.Date;

public class NewsItem implements Serializable {

    public final Date date;
    public final String club;
    public final String title;
    public final String description;

    public NewsItem(Date date, String club, String title, String description) {
        super();
        this.date = date;
        this.club = club;
        this.title = title;
        this.description = description;
    }
}

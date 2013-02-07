package be.ugent.zeus.hydra.data;

import java.io.Serializable;

public class NewsItem implements Serializable {

    public String title;
    public String content;
    public String date;
    public Association association;
    public int highlighted;

}

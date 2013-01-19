package be.ugent.zeus.hydra.data;

import java.io.Serializable;

/**
 *
 * @author Thomas Meire
 */
public class Product implements Serializable {

    public String name;
    public String price;
    public Boolean recommended;

    @Override
    public String toString() {
        String str = name + ": " + price;
        if (recommended) {
            str += " (recommended)";
        }
        return str;
    }
}

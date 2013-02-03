package be.ugent.zeus.hydra.data;

import java.io.Serializable;

/**
 *
 * @author Thomas Meire
 */
public class Menu implements Serializable {

    public boolean open;
    public Product soup;
    public Product[] meat;
    public String[] vegetables;
}

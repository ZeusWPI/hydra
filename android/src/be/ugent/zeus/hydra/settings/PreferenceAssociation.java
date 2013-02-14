/**
 *
 * @author Tom Naessens 
 * Tom.Naessens@UGent.be 
 * 3de Bachelor Informatica
 * Universiteit Gent
 *
 */

package be.ugent.zeus.hydra.settings;

public class PreferenceAssociation {

    private String name;
    private String parentAssociation;
    private boolean selected;

    public PreferenceAssociation(String name, String parentAssociation, boolean selected) {
        this.name = name;
        this.parentAssociation = parentAssociation;
        this.selected = selected;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getParentAssociation() {
        return parentAssociation;
    }

    public void setParentAssociation(String parentAssociation) {
        this.parentAssociation = parentAssociation;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }
    
    
    
}

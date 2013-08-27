/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.settings;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersAdapter;
import java.util.ArrayList;
import java.util.HashSet;

public class AssociationsFilterListAdapter extends BaseAdapter implements StickyListHeadersAdapter {

    private ArrayList<PreferenceAssociation> assocations;
    private LayoutInflater inflater;
    private AssociationsCache cache;

    public AssociationsFilterListAdapter(Context context, ArrayList<PreferenceAssociation> assocations) {
        inflater = LayoutInflater.from(context);
        this.assocations = assocations;

         cache = AssociationsCache.getInstance(context);
    }

    @Override
    public int getCount() {
        return assocations.size();
    }

    @Override
    public Object getItem(int position) {
        return assocations.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;

        if (convertView == null) {
            holder = new ViewHolder();
            convertView = inflater.inflate(R.layout.settings_filter_list_item, parent, false);
            holder.checkBox = (CheckBox) convertView.findViewById(R.id.checkBox);
            convertView.setTag(holder);

            holder.checkBox.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    CheckBox cb = (CheckBox) v;
                    PreferenceAssociation association = (PreferenceAssociation) cb.getTag();
                    association.setSelected(cb.isChecked());

                    HashSet<String> checked = cache.get("associations");;
                    if(checked == null) {
                        checked = new HashSet<String>();
                    }

                    if(cb.isChecked()) {
                        checked.add(association.getInternalName());
                    } else {
                        checked.remove(association.getInternalName());
                    }

                    cache.put("associations", checked);
                }
            });

        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        PreferenceAssociation preferenceAssociation = assocations.get(position);

        holder.checkBox.setText(preferenceAssociation.getName());
        holder.checkBox.setChecked(preferenceAssociation.isSelected());
        holder.internalName = preferenceAssociation.getInternalName();
        holder.checkBox.setTag(preferenceAssociation);

        return convertView;
    }

    @Override
    public View getHeaderView(int position, View convertView, ViewGroup parent) {
        HeaderViewHolder holder;
        if (convertView == null) {
            holder = new HeaderViewHolder();
            convertView = inflater.inflate(R.layout.activity_list_header, parent, false);
            holder.header_text = (TextView) convertView.findViewById(R.id.header_text);
            convertView.setTag(holder);
        } else {
            holder = (HeaderViewHolder) convertView.getTag();
        }

        holder.header_text.setText(assocations.get(position).getParentAssociation());
        return convertView;
    }

    //remember that these have to be static, postion=1 should walys return the same Id that is.
    @Override
    public long getHeaderId(int position) {
        return assocations.get(position).getParentAssociation().hashCode();
    }

    class HeaderViewHolder {

        TextView header_text;
    }

    class ViewHolder {
        CheckBox checkBox;
        String internalName;
    }
}

/**
 *
 * @author Tom Naessens Tom.Naessens@UGent.be 3de Bachelor Informatica
 * Universiteit Gent
 *
 */
package be.ugent.zeus.hydra.settings;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;
import be.ugent.zeus.hydra.R;
import be.ugent.zeus.hydra.data.caches.AssociationsCache;
import com.emilsjolander.components.stickylistheaders.StickyListHeadersAdapter;
import java.util.ArrayList;
import java.util.HashSet;

public class AssociationsFilterListAdapter extends BaseAdapter implements StickyListHeadersAdapter, Filterable {

    private ArrayList<PreferenceAssociation> assocations;
    private ArrayList<PreferenceAssociation> filteredList;
    private LayoutInflater inflater;
    private AssociationsCache cache;
    private AssociationFilter filter;

    public AssociationsFilterListAdapter(Context context, ArrayList<PreferenceAssociation> assocations) {
        inflater = LayoutInflater.from(context);

        this.filteredList = assocations;
        this.assocations = assocations;

        cache = AssociationsCache.getInstance(context);
    }

    @Override
    public int getCount() {
        return filteredList.size();
    }

    @Override
    public Object getItem(int position) {
        return filteredList.get(position);
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

                    HashSet<String> checked = cache.get("associations");
                    if (checked == null) {
                        checked = new HashSet<String>();
                    }

                    if (cb.isChecked()) {
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

        PreferenceAssociation preferenceAssociation = filteredList.get(position);

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

        holder.header_text.setText(filteredList.get(position).getParentAssociation());
        return convertView;
    }

    //remember that these have to be static, postion=1 should walys return the same Id that is.
    @Override
    public long getHeaderId(int position) {
        return filteredList.get(position).getParentAssociation().hashCode();
    }

    public Filter getFilter() {
        if (filter == null) {
            filter = new AssociationFilter();
        }
        return filter;
    }

    private class HeaderViewHolder {

        TextView header_text;
    }

    private class ViewHolder {

        CheckBox checkBox;
        String internalName;
    }

    private class AssociationFilter extends Filter {

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            FilterResults results = new FilterResults();
            if (constraint == null || constraint.length() == 0) {
                results.values = assocations;
                results.count = assocations.size();
            } else {
                ArrayList<PreferenceAssociation> preferenceAssociationList = new ArrayList<PreferenceAssociation>();
                for (PreferenceAssociation assocation : assocations) {

                    // If the name or the name of the konvent contains the search string: display it
                    if (assocation.getName().toUpperCase().contains(constraint.toString().toUpperCase())
                        || assocation.getParentAssociation().toUpperCase().contains(constraint.toString().toUpperCase())) {
                        preferenceAssociationList.add(assocation);
                    }
                }
                results.values = preferenceAssociationList;
                results.count = preferenceAssociationList.size();
            }
            return results;
        }

        protected void publishResults(CharSequence constraint, FilterResults results) {
            if (results.count == 0) {
                notifyDataSetInvalidated();
            } else {
                filteredList = (ArrayList<PreferenceAssociation>) results.values;
                notifyDataSetChanged();
            }
        }
    }
}

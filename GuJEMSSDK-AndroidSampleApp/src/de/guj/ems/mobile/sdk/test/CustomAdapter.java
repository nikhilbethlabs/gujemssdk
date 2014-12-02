package de.guj.ems.mobile.sdk.test;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSNativeListAdView;

/**
 * Custom listview adapter fore the ListViewTest and NativeListTest
 * activities
 * 
 * @author stein16
 *
 */
public class CustomAdapter extends BaseAdapter {
	 
    
	private ArrayList<?> _data;
    Context _c;
    
    CustomAdapter (ArrayList<?> data, Context c){
        _data = data;
        _c = c;
    }
   
    public void remove(Object o) {
    	_data.remove(o);
    }
    
    public int getCount() {
        return _data.size();
    }
    
    public Object getItem(int position) {
        return _data.get(position);
    }
 
    public long getItemId(int position) {
        return position;
    }
   
    public View getView(int position, View convertView, ViewGroup parent) {
         View v = convertView;

         Object item = getItem(position);
         // if the current view is no adview we fill it
         // via /res/layout/list_item_default.xml
         if (v == null && !(item.getClass().equals(GuJEMSListAdView.class) || item.getClass().equals(GuJEMSNativeListAdView.class)))
         {
            LayoutInflater vi = (LayoutInflater)_c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            v = vi.inflate(R.layout.list_item_default, null);
            ((TextView)v.findViewById(R.id.textView1)).setText((String)item);
            
            return v;
         }
         // otherwise we return the adview
         else if (v == null) {
        	 return (View)getItem(position);
         }
                                     
        return v;
    }

}
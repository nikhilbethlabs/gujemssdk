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
/*         
         System.out.println("---");
         for (int i = 0; i < getCount(); i++) {
        	 System.out.println(getItem(i));
         }
         System.out.println("---");
*/         
         Object item = getItem(position);
         if (v == null && !(item.getClass().equals(GuJEMSListAdView.class) || item.getClass().equals(GuJEMSNativeListAdView.class)))
         {
            LayoutInflater vi = (LayoutInflater)_c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            v = vi.inflate(R.layout.list_item_default, null);
            ((TextView)v.findViewById(R.id.textView1)).setText((String)item);
            
            return v;
         }
         else if (v == null) {
        	 return (View)getItem(position);
         }
                                     
        return v;
    }

}
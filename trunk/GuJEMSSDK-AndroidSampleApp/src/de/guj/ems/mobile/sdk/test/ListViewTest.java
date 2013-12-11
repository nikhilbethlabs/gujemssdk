/*  Copyright (c) 2012 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.ListView;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;

/** Sample activity with list view. The list contains two web based adviews.
 * 
 * @author stein16
 *
 */
public class ListViewTest extends Activity {

	private final static String TAG = "ListViewTest";
	
	CustomAdapter ca;
	
    ArrayList <Object> data = new ArrayList<Object>();
	
	@SuppressLint("SetJavaScriptEnabled")
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
		// set layout resource to /res/layout/list.xml
		setContentView(R.layout.list);
        // create custom params for both views, setting the
		// "as" (adspace) parameter manually
		Map<String, Object> customParams = new HashMap<String, Object>();
        customParams.put("as", Integer.valueOf(15224));
        Map<String, Object> customParams2 = new HashMap<String, Object>();
        customParams2.put("as", Integer.valueOf(16542));
        // obtain the list view
        final ListView l = (ListView)findViewById(R.id.testList);
        // create one adview with deferred loading
        final GuJEMSListAdView av1 = new GuJEMSListAdView(this,
                customParams,
                R.layout.generic_adview,
                false);
        // set unique id
        av1.setId(12615);
        // ad listener callbacks
        // upon the success callback, the adview
        // is added to the list view
        // this prevents flickering list views
        av1.setOnAdSuccessListener(new IOnAdSuccessListener() {
			
			private static final long serialVersionUID = 6459396127068144820L;

			@Override
			public void onAdSuccess() {
				// only add adview if not already present
				// i.e. upon reload
				if (!data.contains(av1)) {
					data.add(5, av1);
					runOnUiThread(new Runnable() {
						public void run() {
							SdkLog.d(TAG, "Adding adview to listview");
							l.setAdapter(ca);		
						}
					});
				}
			}
		});
        // create second adview in a similiar way
        final GuJEMSListAdView av2 = new GuJEMSListAdView(this,
                customParams2,
                R.layout.generic_adview,
                false);
        av2.setId(12616);
        av2.setOnAdSuccessListener(new IOnAdSuccessListener() {

        	private static final long serialVersionUID = 2245301798591417990L;

			@Override
			public void onAdSuccess() {
				if (!data.contains(av2)) {
					data.add(2, av2);
					runOnUiThread(new Runnable() {
						public void run() {
							SdkLog.d(TAG, "Adding adview to listview");
							l.setAdapter(ca);					
						}
					});
				}
			}
		});
		// add data to the list adapter
        data.add("hello");
		data.add("world");
		data.add("I");
		data.add("am");
		data.add("a");
		data.add("list");
		data.add("yeah");
		data.add("and");
		data.add("I");
		data.add("am");
		data.add("long");
		data.add("yeah");
		// this custom adapters knows which
		// views are adviews and which are not
		this.ca = new CustomAdapter(data, this);
		
		l.setAdapter(ca);

		// deferred loading / triggering of an ad request
		av1.load();
		av2.load();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.menu, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.adReload) {
			// if a user presses "AdReload" we iterate
			// through the adapter data and if we find
			// an adview we call reload() on it
			for (int i = 0; i < data.size(); i++) {
				if (data.get(i) != null && GuJEMSListAdView.class.equals(data.get(i).getClass())) {
					((GuJEMSListAdView)data.get(i)).reload();
				}
			}
		}
		else { 
			// other menu actions, i.e. activities
			// before each activity we try to show an interstitial
			Intent target = MenuItemHelper.getTargetIntent(
					getApplicationContext(),
					item.getItemId());
			if (target != null) {
				sendBroadcast(target);
			}
		} 
		return true;
	}

	public void onInterstitialAdError(String msg) {
		System.out.println(msg);
	}
	
	public void onInterstitialAdError(String msg, Throwable t) {
		System.out.println(t.toString());
	}	
}
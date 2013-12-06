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
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;

public class ListViewTest extends Activity {

	CustomAdapter ca;
	
    ArrayList <Object> data = new ArrayList<Object>();
	
	@SuppressLint("SetJavaScriptEnabled")
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.list);
        Map<String, Object> customParams = new HashMap<String, Object>();
        customParams.put("as", Integer.valueOf(15224));
        Map<String, Object> customParams2 = new HashMap<String, Object>();
        customParams2.put("as", Integer.valueOf(16542));
        final ListView l = (ListView)findViewById(R.id.testList);
        final GuJEMSListAdView av1 = new GuJEMSListAdView(this,
                customParams,
                R.layout.generic_adview);
        
        av1.setId(12615);
        av1.setOnAdSuccessListener(new IOnAdSuccessListener() {
			
			private static final long serialVersionUID = 6459396127068144820L;

			@Override
			public void onAdSuccess() {
				data.add(5, av1);
				runOnUiThread(new Runnable() {
					public void run() {
						l.setAdapter(ca);		
					}
				});
			}
		});
        
        final GuJEMSListAdView av2 = new GuJEMSListAdView(this,
                customParams2,
                R.layout.generic_adview);
        av2.setId(12616);
        av2.setOnAdSuccessListener(new IOnAdSuccessListener() {

        	private static final long serialVersionUID = 2245301798591417990L;

			@Override
			public void onAdSuccess() {
				data.add(2, av2);
				runOnUiThread(new Runnable() {
					public void run() {
						l.setAdapter(ca);					
					}
				});
			}
		});
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
		this.ca = new CustomAdapter(data, this);
		
		l.setAdapter(ca);
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
			Object ad1 = ca.getItem(2);
			Object ad2 = ca.getItem(5);
			if (ad1 != null && GuJEMSListAdView.class.equals(ad1.getClass())) {
				((GuJEMSListAdView)ad1).reload();
			}
			if (ad2 != null && GuJEMSListAdView.class.equals(ad2.getClass())) {
				((GuJEMSListAdView)ad2).reload();
			}			
		}
		else { 
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
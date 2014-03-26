/*  Copyright (c) 2012 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import java.util.HashMap;
import java.util.Map;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.ViewGroup;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;


@SuppressLint("SetJavaScriptEnabled")
/**
 * This is a simple activity with a boxed layout
 * and two programmatically added adviews
 * 
 *  The campaigns running on these adviews are targeted on:
 *  - the keyword "ems"
 *  - Geo Location Hamburg or Düsseldorf
 *  - mobile provider "Vodafone"
 *  
 *  adviews are created with deferred loading because
 *  we also add callback listeners programmatically
 *  
 * @author stein16
 *
 */
public class TargetingTest extends Activity {

	// private final static String TAG = "GuJEMSSDKTestTargeting";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.targeting);

		
		ViewGroup main = (ViewGroup)findViewById(R.id.main);
		
		// Adding custom parameters to the request
		Map<String,Object> customParams = new HashMap<String,Object>();
		customParams.put("tm", Integer.valueOf(-11));

		// Adding a keyword to the request
		String [] kws = {"ems","is","super"};

		// create one adview with deferred loading
        String[] matchingKeywords = {"ems"};
        final GuJEMSListAdView adView = new GuJEMSListAdView(
        		this,
        		matchingKeywords,
        		null,
                R.layout.targeting_adview_top,
                false);
		
		// Programmatically add listeners
		adView.setOnAdSuccessListener(new IOnAdSuccessListener() {
			
			private static final long serialVersionUID = -9160587495885653766L;

			@Override
			public void onAdSuccess() {
				
				System.out.println("I received an ad. [Targeting-Top]");
			}
		});
		adView.setOnAdEmptyListener(new IOnAdEmptyListener() {
			
			private static final long serialVersionUID = -3891758300923903713L;

			@Override
			public void onAdEmpty() {
				
				System.out.println("I received no ad! [Targeting-Top]");
			}
		});

		// Programmatically add adview
		main.addView(adView, main.indexOfChild(findViewById(R.id.imageView1)));

		// Adding a keyword to the request
		Map<String,Object> customParams2 = new HashMap<String,Object>();
		customParams2.put("as", 15224);		
		// Create second adview with deferred loading
		GuJEMSAdView adView2 = new GuJEMSAdView(
				TargetingTest.this,
				customParams2, //customParams2,
				null, //kws2,
				null,
				R.layout.targeting_adview_bottom,
				false
		);
		
		
		// Programmatically add listeners
		adView2.setOnAdSuccessListener(new IOnAdSuccessListener() {
			
			private static final long serialVersionUID = -9160587495885653766L;

			@Override
			public void onAdSuccess() {
				
				System.out.println("I received an ad. [Targeting-Bottom]");
			}
		});
		adView2.setOnAdEmptyListener(new IOnAdEmptyListener() {
			
			private static final long serialVersionUID = -3891758300923903713L;

			@Override
			public void onAdEmpty() {
				
				System.out.println("I received no ad! [Targeting-Bottom]");
			}
		});

		// Programmatically add adview
		
		main.addView(adView2,main.indexOfChild(findViewById(R.id.sampleText)) + 1);
		
		// perform the actual ad request
		adView.load();
		adView2.load();
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.menu, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		Intent target = MenuItemHelper.getTargetIntent(
				getApplicationContext(), item.getItemId());
		if (target != null) {
			sendBroadcast(target);
		}
		return true;
	}

}
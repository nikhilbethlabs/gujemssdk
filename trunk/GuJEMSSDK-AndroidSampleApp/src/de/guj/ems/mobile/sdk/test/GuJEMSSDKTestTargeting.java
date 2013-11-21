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


@SuppressLint("SetJavaScriptEnabled")
public class GuJEMSSDKTestTargeting extends Activity {

	// private final static String TAG = "GuJEMSSDKTestTargeting";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.targeting);
		/*
		WebView webView = (WebView) findViewById(R.id.webView1);
		webView.setBackgroundColor(0);
		webView.getSettings().setJavaScriptEnabled(true);
		webView.setScrollContainer(false);
		webView.setVerticalScrollBarEnabled(false);
		webView.setHorizontalScrollBarEnabled(false);
		webView.loadUrl("http://m.ems.guj.de//#uid2686");
		*/
		// Adding custom parameters to the request
		ViewGroup main = (ViewGroup)findViewById(R.id.main);
		
		Map<String,Object> customParams = new HashMap<String,Object>();
		customParams.put("tm", Integer.valueOf(-11));

		// Adding a keyword to the request
		String [] kws = {"ems"};

		GuJEMSAdView adView = new GuJEMSAdView(
				GuJEMSSDKTestTargeting.this,
				customParams,
				kws,
				null,
				R.layout.targeting_adview_top
		);
		
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
		/*
		// Adding custom parameters to the request
		Map<String,Object> customParams2 = new HashMap<String,Object>();
		customParams.put("tm", Integer.valueOf(-11));

		// Adding a keyword to the request
		String [] kws2 = {"ems"};
		*/
		GuJEMSAdView adView2 = new GuJEMSAdView(
				GuJEMSSDKTestTargeting.this,
				null, //customParams2,
				null, //kws2,
				null,
				R.layout.targeting_adview_bottom
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
/*
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
	}
*/
}
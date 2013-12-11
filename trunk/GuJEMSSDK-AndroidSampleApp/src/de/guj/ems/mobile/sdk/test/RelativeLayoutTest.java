/*  Copyright (c) 2012 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.Toast;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;

/** This is an activity
 * displaying a relative layout with
 * one embedded adview
 * 
 * The adview is defined in /res/layout/relative_layout.xml
 * 
 * @author stein16
 *
 */
public class RelativeLayoutTest extends Activity {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.relative_layout);
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
			((GuJEMSAdView)findViewById(R.id.ad15312)).reload();		
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
	
	/**
	 * ems_onAdEmpty is defined in the xml
	 * This is the actual callback method
	 * Invoked when no ad was received
	 */
	public void onAdEmpty() {
		Toast.makeText(this, "Ad is empty", Toast.LENGTH_SHORT).show();
	}
	
	/**
	 * ems_onAdError is defined in the xml
	 * This is the actual callback method
	 */
	public void onAdError(String msg) {
		Toast.makeText(this, "Ad error: " + msg, Toast.LENGTH_SHORT).show();
	}
	
	/**
	 * ems_onAdError is defined in the xml
	 * This is the actual callback method
	 * Invoked if an exception occurs
	 */
	public void onAdError(String msg, Throwable t) {
		Toast.makeText(this, "Ad error: " + msg + " (" + t.getCause() + ")", Toast.LENGTH_SHORT).show();
	}
	
	/**
	 * ems_onAdSuccess is defined in the xml
	 * This is the actual callback method
	 * Invoked when we successfully receive an ad
	 */
	public void onAdSuccess() {
		Toast.makeText(this, "Ad displayed.", Toast.LENGTH_SHORT).show();
	}
}
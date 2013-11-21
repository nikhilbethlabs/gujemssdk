/*  Copyright (c) 2012 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.webkit.WebView;
import de.guj.ems.mobile.sdk.util.SdkLog;

public class GuJEMSSDKTestConnectAd extends Activity {

	private final static String TAG = "GuJEMSSDKConnectAd";

	@SuppressLint("SetJavaScriptEnabled")
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		SdkLog.i(TAG, "G+J CONNECT AD ACTIVITY.");
		setContentView(R.layout.cad);
		WebView webView = (WebView) findViewById(R.id.webView1);
		webView.setBackgroundColor(0);
		webView.getSettings().setJavaScriptEnabled(true);
		webView.setScrollContainer(false);
		webView.setVerticalScrollBarEnabled(false);
		webView.setHorizontalScrollBarEnabled(false);
		webView.loadUrl("http://m.ems.guj.de//#uid2697_oid84");
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
			//sendBroadcast(target);
			startActivity(target);
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
	public void adSuccess() {
		System.out.println("I (ConnectAd) received an ad.");
	}
	
	public void adEmpty() {
		System.out.println("I (ConnectAd) received no ad!");
	}

}
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

/**
 * This samples uses a scrollable layout
 * with various adviews
 * 
 * The top adview shows a 320x50 Mobile App Banner
 * 
 * @author mrbungle
 *
 */
@SuppressLint("SetJavaScriptEnabled")
public class XLBannerTest extends Activity {

	// private final static String TAG = "GuJEMSSDKTestXL";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.xl);
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
				getApplicationContext(),
				item.getItemId());
		if (target != null) {
			sendBroadcast(target);
		}
		return true;
	}

}
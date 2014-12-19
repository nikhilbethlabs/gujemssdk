/*  Copyright (c) 2012-2014-2014 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import de.guj.ems.mobile.sdk.util.SdkUtil;

/**
 * SImple activity with a webview displaying a webpage and one adview defined in
 * its layout xml (/res/layout/sowefo.xml)
 * 
 * @author stein16
 * 
 */
public class ORMMATest extends Fragment {

	// private final static String TAG = "GuJEMSSDKTestSoWeFo";
	
	boolean paused;

	@SuppressLint("SetJavaScriptEnabled")
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.ormma, container, false);
		getActivity().setTitle("ORMMA");
		WebView webView = (WebView) rootView.findViewById(R.id.webView1);
		webView.setBackgroundColor(0);
		webView.getSettings().setJavaScriptEnabled(true);
		webView.setScrollContainer(false);
		webView.setVerticalScrollBarEnabled(false);
		webView.setHorizontalScrollBarEnabled(false);
		webView.loadUrl("http://m.ems.guj.de//#uid2699");
		return rootView;
	}
	
	@Override
	public void onResume() {
		super.onResume();
		if (paused) {
			SdkUtil.reloadAds(getActivity());
		}
		paused = false;
	}
	
	@Override
	public void onPause() {
		super.onPause();
		paused = true;
	}	

}
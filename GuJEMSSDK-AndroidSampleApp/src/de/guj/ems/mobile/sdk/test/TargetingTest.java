/*  Copyright (c) 2012-2014-2014 G+J EMS GmbH.
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
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;

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
public class TargetingTest extends Fragment {

	GuJEMSAdView adView;

	GuJEMSAdView adView2;

	boolean paused;

	// private final static String TAG = "GuJEMSSDKTestTargeting";

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.targeting, container, false);
		ViewGroup main = (ViewGroup) rootView.findViewById(R.id.main);

		// Adding custom parameters to the request
		Map<String, Object> customParams = new HashMap<String, Object>();
		// customParams.put("tm", Integer.valueOf(-11));

		// Adding a keyword to the request
		String[] kws = { "ems", "is", "super" };

		// create one adview with deferred loading
		String[] matchingKeywords = { "ems" };
		adView = new GuJEMSAdView(getActivity(), customParams,
				matchingKeywords, null, R.layout.targeting_adview_top, false);

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
		main.addView(adView,
				main.indexOfChild(rootView.findViewById(R.id.imageView1)));

		// Adding a keyword to the request
		Map<String, Object> customParams2 = new HashMap<String, Object>();
		customParams2.put("as", 16542);
		// Create second adview with deferred loading
		adView2 = new GuJEMSAdView(getActivity(), customParams2, // customParams2,
				null, // kws2,
				null, R.layout.targeting_adview_bottom, false);

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

		main.addView(adView2,
				main.indexOfChild(rootView.findViewById(R.id.sampleText)) + 1);

		// perform the actual ad request
		adView.load();
		adView2.load();
		getActivity().setTitle("Targeting");
		return rootView;
	}

	@Override
	public void onResume() {
		super.onResume();
		if (paused) {
			adView.reload();
			adView2.reload();
		}
		paused = false;
	}

	@Override
	public void onPause() {
		super.onPause();
		paused = true;
	}

}
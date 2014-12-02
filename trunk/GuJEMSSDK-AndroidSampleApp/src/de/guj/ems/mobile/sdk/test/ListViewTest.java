/*  Copyright (c) 2012-2014-2014 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import java.util.ArrayList;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;

/**
 * Sample activity with list view. The list contains two web based adviews.
 * 
 * @author stein16
 * 
 */
public class ListViewTest extends Fragment {

	private final static String TAG = "ListViewTest";
	
	private boolean paused;

	CustomAdapter ca;

	ArrayList<Object> data = new ArrayList<Object>();
	
	GuJEMSListAdView av1;
	
	GuJEMSListAdView av2;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.list, container, false);
		getActivity().setTitle("ListView");

		// obtain the list view
		final ListView l = (ListView) rootView.findViewById(R.id.testList);
		// create one adview with deferred loading
		String[] matchingKeywords = { "ems" };
		av1 = new GuJEMSListAdView(getActivity()
				.getApplicationContext(), matchingKeywords, null,
				R.layout.generic_adview);
		// set unique id
		//av1.setId(SdkUtil.isLargerThanPhone() ? 19725 : 15306);
		av1.setId(15306);
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
					getActivity().runOnUiThread(new Runnable() {
						public void run() {
							SdkLog.d(TAG, "Adding adview to listview");
							l.setAdapter(ca);
						}
					});
				}
			}
		});
		// create second adview in a similiar way
		av2 = new GuJEMSListAdView(getActivity().getApplicationContext(),
		// customParams2,
				R.layout.generic_adview, false);
		//av1.setId(SdkUtil.isLargerThanPhone() ? 19725 : 12616);
		av2.setId(12616);
		av2.setOnAdSuccessListener(new IOnAdSuccessListener() {

			private static final long serialVersionUID = 2245301798591417990L;

			@Override
			public void onAdSuccess() {
				if (!data.contains(av2)) {
					data.add(2, av2);
					getActivity().runOnUiThread(new Runnable() {
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
		this.ca = new CustomAdapter(data, getActivity().getApplicationContext());

		l.setAdapter(ca);

		// deferred loading / triggering of an ad request
		av1.load();
		av2.load();

		return rootView;
	}

	public void onInterstitialAdError(String msg) {
		System.out.println(msg);
	}

	public void onInterstitialAdError(String msg, Throwable t) {
		System.out.println(t.toString());
	}
	
	@Override
	public void onResume() {
		super.onResume();
		if (paused) {
			av1.reload();
			av2.reload();
		}
		paused = false;
	}
	
	@Override
	public void onPause() {
		super.onPause();
		paused = true;
	}
}
/*  Copyright (c) 2012-2014-2014 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import de.guj.ems.mobile.sdk.util.SdkUtil;

/**
 * This is an activity displaying a relative layout with one embedded adview
 * 
 * The adview is defined in /res/layout/relative_layout.xml
 * 
 * @author stein16
 * 
 */
public class RelativeLayoutTest extends Fragment {
	
	private boolean paused;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.relative_layout, container,
				false);
		getActivity().setTitle("RelativeLayout");
		paused = false;
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
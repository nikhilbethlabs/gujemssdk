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
 * Simple sample activity with table layout The adview is defined in
 * /res/layout/table_layout.xml
 * 
 * @author stein16
 * 
 */
public class TableLayoutTest extends Fragment {

	boolean paused;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.table_layout, container,
				false);
		getActivity().setTitle("Table Layout");
		return rootView;
	}

	@Override
	public void onPause() {
		super.onPause();
		paused = true;
	}

	@Override
	public void onResume() {
		super.onResume();
		if (paused) {
			SdkUtil.reloadAds(getActivity());
		}
		paused = false;
	}

}

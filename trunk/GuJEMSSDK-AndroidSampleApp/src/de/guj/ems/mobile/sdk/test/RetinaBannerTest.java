/*  Copyright (c) 2012-2014-2014 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import de.guj.ems.mobile.sdk.views.GuJEMSAdView;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

public class RetinaBannerTest extends Fragment {

	// private final static String TAG = "GuJEMSSDKTestXL";
	
	boolean paused;
	
	 @Override
     public View onCreateView(LayoutInflater inflater, ViewGroup container,
             Bundle savedInstanceState) {
         View rootView = inflater.inflate(R.layout.retina, container, false);
         getActivity().setTitle("Retina Ads");
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
				((GuJEMSAdView) getView().findViewById(R.id.ad15298)).reload();
				((GuJEMSAdView) getView().findViewById(R.id.ad15298_2)).reload();
		  }
		  paused = false;
	  }

}
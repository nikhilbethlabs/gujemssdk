package de.guj.ems.mobile.sdk.controllers.backfill;

import java.util.Map;

import android.graphics.drawable.Drawable;
import android.location.Location;
import android.view.ViewGroup;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.moceanmobile.mast.MASTAdView;

import de.guj.ems.mobile.sdk.util.SdkLog;

/**
 * Simple wrapper class to handle Google ads
 * 
 * @author stein16
 *
 */
public final class GoogleDelegator {

	private final static String TAG = "GoogleDelegator";

	AdView admobView;

	AdRequest admobRequest;

	private String pubId;

	/**
	 * Constructor
	 * 
	 * @param delegator optimobile delegator
	 * @param parameters mOcean 3rd party parameters
	 * @param lp view layout
	 * @param bk view background
	 * @param andId view android id
	 */
	public GoogleDelegator(final OptimobileDelegator delegator,
			Map<String, String> parameters, ViewGroup.LayoutParams lp,
			Drawable bk, int andId) {

		final MASTAdView adView = delegator.getOptimobileView();
		final ViewGroup parent = (ViewGroup) adView.getParent();
		
		if (adView == null || parent == null) {
			if (delegator.getSettings().getOnAdErrorListener() != null) {
				delegator.getSettings().getOnAdErrorListener().onAdError("AdView is no longer attached / has no parent. Google request dismissed.");
			}
		}
		else {
			this.mkGoogleRequest(parameters);

			admobView = new AdView(delegator.getContext());
			admobView.setAdSize(AdSize.BANNER);
			admobView.setAdUnitId(pubId);
			admobView.setId(andId);

			admobView.setLayoutParams(lp);
			// setBackground requires API level 16
			admobView.setBackgroundDrawable(bk);
			
			
			final int index = parent.indexOfChild(adView);
	
			parent.removeView(adView);
			adView.removeAllViews();
	
			admobView.setAdListener(new AdListener() {
	
				@Override
				public void onAdFailedToLoad(int errorCode) {
					SdkLog.d(TAG, "No Google ad available.");
					if (delegator.getSettings().getOnAdEmptyListener() != null) {
						delegator.getSettings().getOnAdEmptyListener().onAdEmpty();
					}
				}
	
				@Override
				public void onAdLoaded() {
					SdkLog.d(TAG, "Google Ad viewable.");
					parent.addView(admobView, index);
					if (delegator.getSettings().getOnAdSuccessListener() != null) {
						delegator.getSettings().getOnAdSuccessListener()
								.onAdSuccess();
					}
				}
			});
		}
	}

	private void mkGoogleRequest(Map<String, String> parameters) {

		String zip = parameters.get("zip");
		String lon = parameters.get("long");
		String lat = parameters.get("lat");
		this.pubId = parameters.get("publisherid");
		Location location = new Location("gps");
		try {
			double dlon = Double.valueOf(lon);
			double dlat = Double.valueOf(lat);
			location.setLatitude(dlat);
			location.setLongitude(dlon);
		} catch (Exception e) {
			location = null;
		}

		if (location != null) {
			this.admobRequest = new AdRequest.Builder()
					.addTestDevice(AdRequest.DEVICE_ID_EMULATOR)
					.setLocation(location).build();
		} else {
			this.admobRequest = new AdRequest.Builder().addTestDevice(
					AdRequest.DEVICE_ID_EMULATOR).build();
		}

		SdkLog.i(TAG, "Request settings [" + zip + ", " + lat + ", " + lon
				+ ", " + pubId + "]");
	}

	/**
	 * Perform the actual admob request
	 */
	public void load() {
		
		if (admobView != null && admobRequest != null) {
			SdkLog.i(TAG, "Performing google ad request...");
			admobView.loadAd(admobRequest);
		}
		else {
			SdkLog.w(TAG, "Google ad request cancelled.");
		}
		
	}

}

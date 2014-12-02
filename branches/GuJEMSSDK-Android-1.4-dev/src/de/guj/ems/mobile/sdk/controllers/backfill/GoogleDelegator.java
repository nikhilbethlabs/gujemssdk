package de.guj.ems.mobile.sdk.controllers.backfill;

import android.graphics.drawable.Drawable;
import android.location.Location;
import android.view.ViewGroup;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;

import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;

/**
 * Simple wrapper class to handle Google ads
 * 
 * @author stein16
 *
 */
public final class GoogleDelegator {

	private final static String TAG = "GoogleDelegator";

	AdView googleAdView;

	AdRequest googleAdRequest;

	private String pubId;

	/**
	 * Constructor
	 * 
	 * @param delegator mOcean delegator
	 * @param parameters mOcean 3rd party parameters
	 * @param lp view layout
	 * @param bk view background
	 * @param andId view android id
	 */
	public GoogleDelegator(final GuJEMSAdView adView, final IAdServerSettingsAdapter settings, ViewGroup.LayoutParams lp,
			Drawable bk, int andId) {

		final ViewGroup parent = adView != null ? (ViewGroup) adView.getParent() : null;
		
		if (adView == null || parent == null) {
			if (settings.getOnAdErrorListener() != null) {
				settings.getOnAdErrorListener().onAdError("Parent adview no longer present, ignoring Google backfill request.");
			}
			else {
				SdkLog.w(TAG, "Parent adview no longer present, ignoring Google backfill request.");
			}
		}
		else {
			final int index = parent.indexOfChild(adView);
			
			parent.removeView(adView);
			adView.removeAllViews();
	
			this.mkGoogleRequest(settings);

			googleAdView = new AdView(adView.getContext());
			googleAdView.setAdSize(AdSize.BANNER);
			googleAdView.setAdUnitId(pubId);
			googleAdView.setId(andId);

			googleAdView.setLayoutParams(lp);
			// setBackground requires API level 16
			googleAdView.setBackgroundDrawable(bk);
	
			googleAdView.setAdListener(new AdListener() {
	
				@Override
				public void onAdFailedToLoad(int errorCode) {
					SdkLog.d(TAG, "No Google ad available.");
					if (settings.getOnAdEmptyListener() != null) {
						settings.getOnAdEmptyListener().onAdEmpty();
					}
				}
	
				@Override
				public void onAdLoaded() {
					SdkLog.d(TAG, "Google Ad viewable.");
					parent.addView(googleAdView, index);
					if (settings.getOnAdSuccessListener() != null) {
						settings.getOnAdSuccessListener()
								.onAdSuccess();
					}
				}
			});
		}
	}

	private void mkGoogleRequest(IAdServerSettingsAdapter settings) {
		this.pubId = settings.getGooglePublisherId();
		Location location = new Location("gps");
		try {
			double [] loc = SdkUtil.getLocation();
			if (loc != null) {
				location.setLatitude(loc[0]);
				location.setLongitude(loc[1]);
			}
		} catch (Exception e) {
			location = null;
		}

		if (location != null) {
			this.googleAdRequest = new AdRequest.Builder()
					.addTestDevice(AdRequest.DEVICE_ID_EMULATOR)
					.setLocation(location).build();
		} else {
			this.googleAdRequest = new AdRequest.Builder().addTestDevice(
					AdRequest.DEVICE_ID_EMULATOR).build();
		}

	}

	/**
	 * Perform the actual google request
	 */
	public void load() {
		
		if (googleAdView != null && googleAdRequest != null) {
			SdkLog.i(TAG, "Performing google ad request...");
			googleAdView.loadAd(googleAdRequest);
		}
		else {
			SdkLog.w(TAG, "Google ad request cancelled.");
		}
		
	}

}

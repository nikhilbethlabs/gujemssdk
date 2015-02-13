package de.guj.ems.mobile.sdk.controllers.backfill;

import android.graphics.drawable.Drawable;
import android.location.Location;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

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

	private AdView googleAdView;

	private AdRequest googleAdRequest;

	private String pubId;

	private LinearLayout container;

	private int viewIndex;

	private GuJEMSAdView gujEmsAdView;

	/**
	 * Constructor
	 * 
	 * @param delegator
	 *            mOcean delegator
	 * @param parameters
	 *            mOcean 3rd party parameters
	 * @param lp
	 *            view layout
	 * @param bk
	 *            view background
	 * @param andId
	 *            view android id
	 */
	public GoogleDelegator(final GuJEMSAdView adView,
			final IAdServerSettingsAdapter settings, ViewGroup.LayoutParams lp,
			Drawable bk) {

		if (adView == null || adView.getParent() == null) {
			if (settings.getOnAdErrorListener() != null) {
				settings.getOnAdErrorListener()
						.onAdError(
								"Parent or adview no longer present, ignoring Google backfill request.");
			} else {
				SdkLog.w(TAG,
						"Parent or adview no longer present, ignoring Google backfill request.");
			}
		} else {
			gujEmsAdView = adView;
			viewIndex = ((ViewGroup) adView.getParent()).indexOfChild(adView);
			this.mkGoogleRequest(settings);
			googleAdView = new AdView(adView.getContext());
			googleAdView.setAdSize(AdSize.BANNER);
			googleAdView.setAdUnitId(pubId);
			// setBackground requires API level 16
			googleAdView.setBackgroundDrawable(bk);
			googleAdView.setAdListener(new AdListener() {

				@Override
				public void onAdFailedToLoad(int errorCode) {
					if (errorCode == AdRequest.ERROR_CODE_NO_FILL
							&& settings.getOnAdEmptyListener() != null) {
						SdkLog.d(TAG, "No ad received from Google.");
						settings.getOnAdEmptyListener().onAdEmpty();
					} else if (errorCode != AdRequest.ERROR_CODE_NO_FILL
							&& settings.getOnAdErrorListener() != null) {
						settings.getOnAdErrorListener().onAdError(
								"Error loading Google ad [" + errorCode + "]");
					} else if (errorCode != AdRequest.ERROR_CODE_NO_FILL) {
						SdkLog.w(TAG,  "Error loading Google ad [" + errorCode + "]");
					}
					else {
						SdkLog.w(TAG, "No Google ad available. [" + errorCode
								+ "]");
					}
				}

				@Override
				public void onAdLoaded() {
					container.setVisibility(View.VISIBLE);
					if (settings.getOnAdSuccessListener() != null) {
						settings.getOnAdSuccessListener().onAdSuccess();
					}
					SdkLog.d(TAG, "Google ad visible");
				}
			});

			adView.setVisibility(View.GONE);
			ViewGroup parent = (ViewGroup) adView.getParent();
			parent.removeView(adView);
			container = new LinearLayout(adView.getContext());
			container.setVisibility(View.GONE);
			container.setId(adView.getId());
			container.setLayoutParams(lp);
			container.addView(adView);
			container.addView(googleAdView);
			container.setGravity(Gravity.CENTER);
			
			
			parent.addView(container, viewIndex);
		}
	}

	public AdView getAdView() {
		return googleAdView;
	}

	/**
	 * Perform the actual google request
	 */
	public void load() {

		if (googleAdView != null && googleAdRequest != null) {
			SdkLog.i(TAG, "Performing google ad request...");

			googleAdView.loadAd(googleAdRequest);
		} else {
			SdkLog.w(TAG, "Google ad request cancelled.");
		}

	}

	private void mkGoogleRequest(IAdServerSettingsAdapter settings) {
		this.pubId = settings.getGooglePublisherId();
		Location location = new Location("gps");
		try {
			double[] loc = SdkUtil.getLocation();
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

	public void reset() {
		ViewGroup parent = ((ViewGroup) container.getParent());
		if (parent != null) {
			container.removeView(gujEmsAdView);
			parent.removeView(container);
			parent.addView(gujEmsAdView, viewIndex);
		}
		googleAdView.destroy();
		container = null;
		googleAdView = null;

	}

}

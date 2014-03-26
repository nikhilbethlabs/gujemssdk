package de.guj.ems.mobile.sdk.controllers.backfill;

import java.util.Map;

import android.view.View;
import android.view.ViewGroup;

import com.moceanmobile.mast.MASTAdView;
import com.moceanmobile.mast.MASTAdViewDelegate.RequestListener;

import de.guj.ems.mobile.sdk.controllers.adserver.OptimobileAdResponse;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSNativeAdView;

/**
 * G+J specific implementation of an mOcean request listener.
 * The listener handles view management and possible backfill via Google Admob.
 * 
 * @author stein16
 *
 */
public final class OptimobileListener implements RequestListener {

	private boolean display = false;

	private OptimobileDelegator delegator;

	private final static String TAG = "OptimobileListener";

	/**
	 * Constructor
	 * @param delegator optimobile delegator which uses this listener
	 */
	public OptimobileListener(OptimobileDelegator delegator) {
		this.delegator = delegator;
	}

	@Override
	public void onReceivedThirdPartyRequest(final MASTAdView adView,
			Map<String, String> properties, final Map<String, String> parameters) {
		String type = properties.get("type");

		if (type != null && "admob".equals(type)) {
			delegator.getHandler().post(new Runnable() {

				final GuJEMSAdView emsMobileView = delegator.getEmsMobileView();

				@Override
				public void run() {
					if (emsMobileView != null
							&& !GuJEMSListAdView.class.equals(emsMobileView
									.getClass())) {
						//TODO check admob availability via reflection? 
						(new AdmobDelegator(delegator, parameters, emsMobileView
								.getLayoutParams(), emsMobileView
								.getBackground(), emsMobileView.getId()))
								.load();

					} else {
						SdkLog.w(TAG,
								"AdMob cannot be loaded in native or list ad views.");
					}
				}
			});

		} else {
			SdkLog.w(TAG, "Unknown third party ad stream detected [" + type
					+ "]");
		}

	}

	@Override
	public void onReceivedAd(final MASTAdView adView) {

		SdkLog.d(TAG, "optimobile Ad loaded.");

		final String response = adView.getAdDescriptor().getContent();
		final GuJEMSAdView emsMobileView = delegator.getEmsMobileView();
		final GuJEMSNativeAdView emsNativeMobileView = delegator
				.getEmsNativeMobileView();

		if (response != null
				&& (response.indexOf("thirdparty") >= 0 || response
						.indexOf("richmedia") >= 0)) {
			if (emsNativeMobileView != null
					|| (emsMobileView != null && GuJEMSListAdView.class
							.equals(emsMobileView.getClass()))) {
				SdkLog.w(TAG,
						"Received third party response for non compatible optimobile view (list).");
			}
		}
		if (emsMobileView != null
				&& GuJEMSListAdView.class.equals(emsMobileView.getClass())) {
			SdkLog.d(TAG,
					"Primary adView is list view, replacing content with secondary adview's.");
			SdkLog.i(TAG, "optimobile view unused, will be destroyed.");
			adView.removeAllViews();

			delegator.getHandler().post(new Runnable() {
				public void run() {
					emsMobileView.processResponse(new OptimobileAdResponse(
							response.indexOf("richmedia") >= 0
									|| response.indexOf("thirdparty") >= 0 ? null
									: response));
				}
			});

		} else if (emsNativeMobileView != null) {
			SdkLog.d(TAG,
					"Primary adView is native view, replacing content with secondary adview's.");
			SdkLog.i(TAG, "optimobile view unused, will be destroyed.");
			adView.removeAllViews();

			if (delegator.getHandler() != null) {
				delegator.getHandler().post(new Runnable() {
					public void run() {
						emsNativeMobileView.processResponse(new OptimobileAdResponse(
								response.indexOf("richmedia") >= 0
										|| response.indexOf("thirdparty") >= 0 ? null
										: response));
					}
				});
			} else {
				// TODO off ui thread without handler?
				emsNativeMobileView.processResponse(new OptimobileAdResponse(
						response.indexOf("thirdparty") >= 0 ? null : response));
			}

		} else {
			display = true;
		}
		delegator.getHandler().post(new Runnable() {
			@Override
			public void run() {
				if (display) {
					adView.setVisibility(View.VISIBLE);
				}
				SdkLog.d(TAG, "optimobile Ad viewable.");
				if (delegator.getSettings().getOnAdSuccessListener() != null) {
					delegator.getSettings().getOnAdSuccessListener()
							.onAdSuccess();
				}
			}
		});
	}

	@Override
	public void onFailedToReceiveAd(final MASTAdView adView, final Exception ex) {
		if (delegator.getHandler() != null) {
			final String s = ex != null ? ex.toString() : "No ads available";
			delegator.getHandler().post(new Runnable() {
				@Override
				public void run() {
					ViewGroup parent = (ViewGroup) adView.getParent();
					if (parent != null) {
						SdkLog.d(TAG, "Removing optimobile view.");
						parent.removeView(adView);
					}
					if (s != null && s.startsWith("No ads")) {
						if (delegator.getSettings().getOnAdEmptyListener() != null) {
							delegator.getSettings().getOnAdEmptyListener()
									.onAdEmpty();
						} else {
							SdkLog.i(TAG, "optimobile: " + s);
						}
					} else {
						if (delegator.getSettings().getOnAdErrorListener() != null) {
							delegator.getSettings().getOnAdErrorListener()
									.onAdError("optimobile: " + s, ex);
						} else {
							SdkLog.e(TAG, "optimobile: " + s, ex);
						}
					}
					adView.setVisibility(View.GONE);
				}
			});
		}
	}
}

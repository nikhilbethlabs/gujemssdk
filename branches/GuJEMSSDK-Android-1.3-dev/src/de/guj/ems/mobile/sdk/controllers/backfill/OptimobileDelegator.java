package de.guj.ems.mobile.sdk.controllers.backfill;

import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.location.Location;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.moceanmobile.mast.MASTAdView;
import com.moceanmobile.mast.MASTAdViewDelegate;

import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.adserver.OptimobileAdResponse;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSNativeAdView;

/**
 * Delegates requests to optimobile and possibly other networks if a premium
 * campaign is not available for the current adview/slot.
 * 
 * Backfill is initially configured with GuJEMSAdView by adding an additional
 * optimobile site and zone ID to the view
 * 
 * If 3rd party network backfill like admob is configured in optimobile, the
 * request is also handled here by passing the metadata returned from optimobile
 * to the admob sdk.
 * 
 * @author stein16
 * 
 */
public class OptimobileDelegator {

	private final static String TAG = "OptimobileDelegator";

	private MASTAdView optimobileView;

	private GuJEMSAdView emsMobileView;

	private GuJEMSNativeAdView emsNativeMobileView;

	private Handler handler;

	private Context context;

	private IAdServerSettingsAdapter settings;

	/**
	 * Default constructor
	 * 
	 * Initially creates an optimobile adview which an be added to the layout.
	 * The optimobile view uses callbacks for error handling etc. and also for a
	 * possible backfill. If a 3rd party network is active, the optimobile ad
	 * view will actually be removed and replaced by the network's view.
	 * 
	 * @param context
	 *            App/Activity context
	 * @param adView
	 *            original (first level) adview
	 * @param settings
	 *            settings of original adview
	 */
	public OptimobileDelegator(final Context context,
			final GuJEMSAdView adView, final IAdServerSettingsAdapter settings) {
		this.context = context;
		this.emsMobileView = adView;
		this.handler = this.emsMobileView.getHandler();
		this.settings = settings;
		if (handler != null) {
			handler.post(new Runnable() {
				@Override
				public void run() {
					optimobileView = initOptimobileView(context, settings, 0);

					if (adView.getParent() != null
							&& !GuJEMSListAdView.class.equals(adView.getClass())) {
						ViewGroup parent = (ViewGroup) adView.getParent();
						int index = parent.indexOfChild(adView);
						optimobileView.setLayoutParams(adView.getLayoutParams()); // lp
						parent.addView(optimobileView, index + 1);
					} else {
						SdkLog.d(TAG, "Primary view initialized off UI.");
					}

					optimobileView.update();
				}
			});
		} else {
			optimobileView = initOptimobileView(context, settings, 0);
			optimobileView.update();
		}
	}

	/**
	 * Constructor for native views
	 * 
	 * Initially creates an optimobile adview which an be added to the layout.
	 * The optimobile view uses callbacks for error handling etc. and also for a
	 * possible backfill. If a 3rd party network is active, the optimobile ad
	 * view will actually be removed and replaced by the network's view.
	 * 
	 * @param context
	 *            App/Activity context
	 * @param adView
	 *            original (first level) adview
	 * @param settings
	 *            settings of original adview
	 */
	public OptimobileDelegator(final Context context,
			GuJEMSNativeAdView adView, final IAdServerSettingsAdapter settings) {
		this.context = context;
		this.emsNativeMobileView = adView;
		this.settings = settings;
		this.handler = this.emsNativeMobileView.getHandler();
		if (handler != null) {
			handler.post(new Runnable() {
				@Override
				public void run() {
					optimobileView = initOptimobileView(context, settings, 0);
					optimobileView.update();
				}
			});
		} else {
			optimobileView = initOptimobileView(context, settings, 0);
			optimobileView.update();
		}

	}

	@SuppressWarnings("deprecation")
	private MASTAdView initOptimobileView(final Context context,
			final IAdServerSettingsAdapter settings, int color) {

		final MASTAdView view = new MASTAdView(context);
		view.setZone(Integer.valueOf(settings.getDirectBackfill().getZoneId()));
		view.setId(emsMobileView != null ? emsMobileView.getId()
				: emsNativeMobileView.getId());
		view.setBackgroundDrawable(emsMobileView != null ? emsMobileView
				.getBackground() : emsNativeMobileView.getBackground());
		view.setLocationDetectionEnabled(true);
		view.setVisibility(View.GONE);
		view.setUseInternalBrowser(true);
		view.setUpdateInterval(0);

		if (emsMobileView != null
				&& !GuJEMSListAdView.class.equals(emsMobileView.getClass())) {
			view.setRequestListener(new MASTAdViewDelegate.RequestListener() {
				private boolean display = false;
				
				private String pubId;
				
				private AdRequest adRequest;
				
				@Override
				public void onReceivedThirdPartyRequest(MASTAdView adView,
						Map<String, String> properties, Map<String, String> parameters) {
					String type = properties.get("type");

					if (type != null && "admob".equals(type)) {
						String zip = parameters.get("zip");
						String lon = parameters.get("long");
						String lat = parameters.get("lat");
						Location location = new Location("gps");
						try {
							double dlon = Double.valueOf(lon);
							double dlat = Double.valueOf(lat);
							location.setLatitude(dlat);
							location.setLongitude(dlon);
						} catch (Exception e) {
							location = null;
						}
						this.pubId = parameters.get("publisherid");
						SdkLog.i(TAG, "optimobile: AdMob backfill detected. [" + zip
								+ ", " + lat + ", " + lon + ", " + pubId + "]");
						
						
						if (location != null) {
							this.adRequest = new AdRequest.Builder().addTestDevice(AdRequest.DEVICE_ID_EMULATOR).setLocation(location).build();
						}
						else {
							this.adRequest = new AdRequest.Builder().addTestDevice(AdRequest.DEVICE_ID_EMULATOR).build();
						}
						handler.post(new Runnable() {

							@SuppressWarnings("deprecation")
							@Override
							public void run() {
								if (emsMobileView != null
										&& !GuJEMSListAdView.class.equals(emsMobileView
												.getClass())) {
									SdkLog.i(TAG, "Performing google admob request...");
									final AdView admobAdView = new AdView(
											(Activity) context);
									admobAdView.setAdSize(AdSize.BANNER);
									admobAdView.setAdUnitId(pubId);
									admobAdView
											.setId(emsMobileView != null ? emsMobileView
													.getId() : emsNativeMobileView
													.getId());
									/*admobAdView.setGravity(Gravity.CENTER_HORIZONTAL);*/
									admobAdView
											.setLayoutParams(emsMobileView != null ? emsMobileView
													.getLayoutParams()
													: emsNativeMobileView
															.getLayoutParams());
									admobAdView
											.setBackgroundDrawable(emsMobileView != null ? emsMobileView
													.getBackground()
													: emsNativeMobileView
															.getBackground());

									final ViewGroup parent = (ViewGroup) optimobileView
											.getParent();

									final int index = parent
											.indexOfChild(optimobileView);
									parent.removeView(optimobileView);
									optimobileView.removeAllViews();
									optimobileView = null;

									admobAdView.setAdListener(new AdListener() {

										@Override
										public void onAdFailedToLoad(int errorCode) {
											SdkLog.d(TAG, "No Admob ad available.");
											admobAdView.removeAllViews();
											admobAdView.destroy();
											if (settings.getOnAdEmptyListener() != null) {
												settings.getOnAdEmptyListener()
														.onAdEmpty();
											}
										}

										@Override
										public void onAdLoaded() {
											SdkLog.d(TAG, "Admob Ad viewable.");
											parent.addView(admobAdView, index);
											if (settings.getOnAdSuccessListener() != null) {
												settings.getOnAdSuccessListener()
														.onAdSuccess();
											}
										}
									});
									admobAdView.loadAd(adRequest);

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
				public void onReceivedAd(MASTAdView adView) {
					// TODO Auto-generated method stub
					SdkLog.d(TAG, "optimobile Ad loaded.");
					
					final String response = optimobileView.getAdDescriptor().getContent();
					SdkLog.w(TAG, "OPTIMOBILE RESPONSE " + response);
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
							&& GuJEMSListAdView.class.equals(emsMobileView
									.getClass())) {
						SdkLog.d(TAG,
								"Primary adView is list view, replacing content with secondary adview's.");
						SdkLog.i(TAG, "optimobile view unused, will be destroyed.");
						optimobileView.removeAllViews();
						optimobileView = null;
						handler.post(new Runnable() {
							public void run() {
								emsMobileView
										.processResponse(new OptimobileAdResponse(
												response.indexOf("richmedia") >= 0 || response.indexOf("thirdparty") >= 0 ? null
														: response));
							}
						});

					} else if (emsNativeMobileView != null) {
						SdkLog.d(TAG,
								"Primary adView is native view, replacing content with secondary adview's.");
						SdkLog.i(TAG, "optimobile view unused, will be destroyed.");
						optimobileView.removeAllViews();
						optimobileView = null;
						if (handler != null) {
							handler.post(new Runnable() {
								public void run() {
									emsNativeMobileView
											.processResponse(new OptimobileAdResponse(
													response.indexOf("richmedia") >= 0 || response.indexOf("thirdparty") >= 0 ? null
															: response));
								}
							});
						} else {
							// TODO off ui thread without handler?
							emsNativeMobileView
									.processResponse(new OptimobileAdResponse(
											response.indexOf("thirdparty") >= 0 ? null
													: response));
						}

					} else {
						display = true;
					}
					handler.post(new Runnable() {
						@Override
						public void run() {
							if (display) {
								optimobileView.setVisibility(View.VISIBLE);
							}
							SdkLog.d(TAG, "optimobile Ad viewable.");
							if (settings.getOnAdSuccessListener() != null) {
								settings.getOnAdSuccessListener().onAdSuccess();
							}
						}
					});						
				}
				
				@Override
				public void onFailedToReceiveAd(MASTAdView adView, final Exception ex) {
					if (handler != null) {
						final String s = ex != null ? ex.toString() : "No ads available";
						handler.post(new Runnable() {
							@Override
							public void run() {
								ViewGroup parent = (ViewGroup) optimobileView
										.getParent();
								if (parent != null) {
									SdkLog.d(TAG, "Removing optimobile view.");
									parent.removeView(optimobileView);
								}
								if (s != null && s.startsWith("No ads")) {
									if (settings.getOnAdEmptyListener() != null) {
										settings.getOnAdEmptyListener().onAdEmpty();
									} else {
										SdkLog.i(TAG, "optimobile: " + s);
									}
								} else {
									if (settings.getOnAdErrorListener() != null) {
										settings.getOnAdErrorListener().onAdError(
												"optimobile: " + s, ex);
									} else {
										SdkLog.e(TAG, "optimobile: " + s, ex);
									}
								}
								view.setVisibility(View.GONE);
							}
						});
					}
				}
			});
		} else {
			SdkLog.d(TAG,
					"3rd party requests disabled for native optimobile view");
		}
		

		return view;
	}

	/**
	 * Get an instance of the initially created optimobile adview for
	 * backfilling
	 * 
	 * @return mOcean/optimobile adview
	 */
	public MASTAdView getOptimobileView() {
		return this.optimobileView;
	}


}

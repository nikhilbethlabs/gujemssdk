package de.guj.ems.mobile.sdk.controllers.backfill;

import android.content.Context;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;

import com.moceanmobile.mast.MASTAdView;
import com.moceanmobile.mast.MASTAdView.LogLevel;

import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSNativeAdView;

/**
 * Delegates requests to mOcean and possibly other networks if a premium
 * campaign is not available for the current adview/slot.
 * 
 * Backfill is initially configured with GuJEMSAdView by adding an additional
 * mOcean site and zone ID to the view
 * 
 * If 3rd party network backfill like Google is configured in mOcean, the
 * request is also handled here by passing the metadata returned from mOcean
 * to the Google SDK.
 * 
 * @author stein16
 * 
 */
public final class MOceanDelegator {

	private final static String TAG = "MOceanDelegator";

	private MASTAdView mastAdView;

	private GuJEMSAdView emsMobileView;

	private GuJEMSNativeAdView emsNativeMobileView;

	private Handler handler;

	private Context context;

	private IAdServerSettingsAdapter settings;

	/**
	 * Default constructor
	 * 
	 * Initially creates an mOcean adview which an be added to the layout.
	 * The mOcean view uses callbacks for error handling etc. and also for a
	 * possible backfill (MOceanListener). If a 3rd party network is active, the mOcean ad
	 * view will actually be removed and replaced by the network's view.
	 * 
	 * @param context
	 *            App/Activity context
	 * @param adView
	 *            original (first level) adview
	 * @param settings
	 *            settings of original adview
	 */
	public MOceanDelegator(final Context context,
			final GuJEMSAdView adView, final IAdServerSettingsAdapter settings) {
		this.context = context;
		this.emsMobileView = adView;
		this.handler = this.emsMobileView.getHandler();
		this.settings = settings;
		if (handler != null) {
			handler.post(new Runnable() {
				@Override
				public void run() {
					mastAdView = initMastAdView(context, settings, 0);

					if (adView.getParent() != null
							&& !GuJEMSListAdView.class.equals(adView.getClass())) {
						ViewGroup parent = (ViewGroup) adView.getParent();
						int index = parent.indexOfChild(adView);
						parent.addView(mastAdView, index + 1);
					} else {
						SdkLog.d(TAG, "Primary view initialized off UI.");
					}

					mastAdView.update();
				}
			});
		} else {
			mastAdView = initMastAdView(context, settings, 0);
			mastAdView.update();
		}
	}

	/**
	 * Constructor for native views
	 * 
	 * Initially creates an mOcean adview which an be added to the layout.
	 * The mOcean view uses callbacks for error handling etc.
	 * 
	 * @param context
	 *            App/Activity context
	 * @param adView
	 *            original (first level) adview
	 * @param settings
	 *            settings of original adview
	 */
	public MOceanDelegator(final Context context,
			GuJEMSNativeAdView adView, final IAdServerSettingsAdapter settings) {
		this.context = context;
		this.emsNativeMobileView = adView;
		this.settings = settings;
		this.handler = this.emsNativeMobileView.getHandler();
		if (handler != null) {
			handler.post(new Runnable() {
				@Override
				public void run() {
					mastAdView = initMastAdView(context, settings, 0);
					mastAdView.update();
				}
			});
		} else {
			mastAdView = initMastAdView(context, settings, 0);
			mastAdView.update();
		}

	}

	@SuppressWarnings("deprecation")
	private MASTAdView initMastAdView(final Context context,
			final IAdServerSettingsAdapter settings, int color) {

		final MASTAdView view = new MASTAdView(context);
		view.setLogLevel(SdkLog.isTestLogLevel() ? LogLevel.Debug : LogLevel.Error);
		view.setZone(Integer.valueOf(settings.getDirectBackfill().getZoneId()));
		view.setId(emsMobileView != null ? emsMobileView.getId()
				: emsNativeMobileView.getId());
		view.setBackgroundDrawable(emsMobileView != null ? emsMobileView
				.getBackground() : emsNativeMobileView.getBackground());
		view.setLocationDetectionEnabled(true);
		view.setVisibility(View.GONE);
		view.setUseInternalBrowser(true);
		view.setUpdateInterval(0);
		//TODO adseen
		
		view.getAdRequestParameters().put("udid", SdkUtil.getDeviceId());
		if (SdkUtil.getIdForAdvertiser() != null) {
			view.getAdRequestParameters().put("androidaid", SdkUtil.getDeviceId());	
		}
		
		if (emsMobileView != null
				&& !GuJEMSListAdView.class.equals(emsMobileView.getClass())) {
			view.setRequestListener(new MOceanListener(this));
		} else {
			SdkLog.d(TAG,
					"3rd party requests disabled for native mOcean view");
		}
		

		return view;
	}

	/**
	 * Get an instance of the initially created mOcean adview for
	 * backfilling
	 * 
	 * @return mOcean adview
	 */
	protected MASTAdView getMastAdView() {
		return this.mastAdView;
	}

	/**
	 * Returns the original web adview
	 * @return original web adview
	 */
	protected GuJEMSAdView getEmsMobileView() {
		return emsMobileView;
	}

	/**
	 * Return a native original adview
	 * @return native original adview
	 */
	protected GuJEMSNativeAdView getEmsNativeMobileView() {
		return emsNativeMobileView;
	}

	/**
	 * Handler for tasks running on UI thread
	 * @return UI thread handler
	 */
	protected Handler getHandler() {
		return handler;
	}

	/**
	 * Get the application context
	 * @return application context
	 */
	protected Context getContext() {
		return context;
	}

	/**
	 * Get original adview's settings
	 * @return original adview settings
	 */
	protected IAdServerSettingsAdapter getSettings() {
		return settings;
	}


}

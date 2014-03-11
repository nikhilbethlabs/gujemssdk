package de.guj.ems.mobile.sdk.controllers.backfill;

import android.content.Context;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;

import com.moceanmobile.mast.MASTAdView;
import com.moceanmobile.mast.MASTAdView.LogLevel;

import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;
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
						//optimobileView.setLayoutParams(adView.getLayoutParams()); // lp
						//SdkLog.d(TAG, "Original view's layout params " + adView.getLayoutParams());
						//SdkLog.d(TAG, "Original view's layout params height " + adView.getLayoutParams().height);
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
	 * The optimobile view uses callbacks for error handling etc.
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
		view.setLogLevel(LogLevel.Debug);
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
			view.setRequestListener(new OptimobileListener(this));
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
	protected MASTAdView getOptimobileView() {
		return this.optimobileView;
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

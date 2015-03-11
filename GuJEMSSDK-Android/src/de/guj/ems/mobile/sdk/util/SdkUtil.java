package de.guj.ems.mobile.sdk.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import android.Manifest.permission;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ReceiverCallNotAllowedException;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.BatteryManager;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.view.Surface;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.ads.identifier.AdvertisingIdClient.Info;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;

import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.AdResponseReceiver;
import de.guj.ems.mobile.sdk.controllers.adserver.AdRequest;
import de.guj.ems.mobile.sdk.controllers.adserver.AmobeeAdRequest;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;

/**
 * Various global static methods for initialization, configuration of sdk plus
 * targeting parameters.
 * 
 * @author stein16
 * 
 */
public class SdkUtil {
	
	protected SdkUtil() { 
		SdkLog.d(TAG, "SdkUtil CXT");
		SdkLog.d(TAG, "IDFA: " + SdkUtil.getIdForAdvertiser());
	}

	/**
	 * Create an ad request object with url and response handler
	 * 
	 * @param handler
	 *            response handler
	 * @return initialized ad request
	 */
	public static Intent adRequest(AdResponseReceiver handler,
			IAdServerSettingsAdapter settings) {
		Intent i = new Intent(getContext(), AmobeeAdRequest.class);
		if (settings.doProcess()) {
			boolean remote = SdkUtil.getContext()
					.getResources().getBoolean(R.bool.ems_remote_cfg);
			IAdServerSettingsAdapter nSet = SdkVariables.SINGLETON
					.getJsonVariables().process(
							 remote ? SdkConfig.SINGLETON.getJsonConfig().process(
									settings) : settings);
			i.putExtra(AdRequest.ADREQUEST_URL_EXTRA, nSet.getRequestUrl());
		} else {
			i.putExtra(AdRequest.ADREQUEST_URL_EXTRA, settings.getRequestUrl());
		}

		i.putExtra("handler", handler);
		return i;
	}

	/**
	 * Create an ad request object with url and response handler
	 * 
	 * @param handler
	 *            response handler
	 * @return initialized ad request
	 */
	public static Intent adRequest(AdResponseReceiver handler, String url) {
		Intent i = new Intent(getContext(), AmobeeAdRequest.class);
		i.putExtra(AdRequest.ADREQUEST_URL_EXTRA, url);
		i.putExtra("handler", handler);
		return i;
	}

	/**
	 * Helper method to determine the correct way to execute javascript in a
	 * webview. Starting from Android 4.4, the Android webview is a chrome
	 * webview and the method to execute javascript has changed from loadUrl to
	 * evaluateJavascript
	 * 
	 * @param webView
	 *            The webview to exeute the script in
	 * @param javascript
	 *            the actual script
	 */
	public static void evaluateJavascript(WebView webView, String javascript) {
		if (KITKAT_JS_METHOD == null && Build.VERSION.SDK_INT >= 19) {
			KITKAT_JS_METHOD = getKitKatJsMethod();
			SdkLog.i(TAG,
					"G+J EMS SDK AdView: Running in KITKAT mode with new Chromium webview!");

		}

		if (Build.VERSION.SDK_INT < 19) {
			webView.loadUrl("javascript:" + javascript);
		} else
			try {
				KITKAT_JS_METHOD.invoke(webView, javascript, null);
			} catch (Exception e) {
				SdkLog.e(
						TAG,
						"FATAL ERROR: Could not invoke Android 4.4 Chromium WebView method evaluateJavascript",
						e);
			}
	}

	private synchronized static Intent getBatteryIntent() {
		IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
		BATTERY_INTENT = getContext().getApplicationContext().registerReceiver(
				null, ifilter);
		return BATTERY_INTENT;
	}

	/**
	 * Get the battery charge level in percent
	 * 
	 * @return Integer value [0..100], indicating battery charge level in
	 *         percent
	 */
	public static int getBatteryLevel() {
		if (BATTERY_INTENT == null) {
			synchronized (BATTERY_INTENT) {
				try {
					BATTERY_INTENT = getBatteryIntent();
				} catch (ReceiverCallNotAllowedException e) {
					SdkLog.w(TAG,
							"Skipping start of phone status receivers from start interstitial.");
					BATTERY_INTENT = null;
					return 100;
				}
			}
		}
		int level = BATTERY_INTENT.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
		int scale = BATTERY_INTENT.getIntExtra(BatteryManager.EXTRA_SCALE, -1);

		return (int) (100.0f * (level / (float) scale));
	}

	/**
	 * Get local storage path for files
	 * 
	 * @return fodler where local files may be stored
	 */
	static File getConfigFileDir() {
		return getContext().getFilesDir();
	}

	/**
	 * Get android application context
	 * 
	 * @return context (if set before)
	 */
	public final static Context getContext() {
		return CONTEXT;
	}

	/**
	 * Returns an app specific unique id used as a cookie replacement
	 * 
	 * @return
	 */
	public synchronized static String getCookieReplStr() {
		if (COOKIE_REPL == null) {
			File fuuid = new File(SdkUtil.getContext().getFilesDir(), EMSUID);
			try {
				if (!fuuid.exists())
					writeUUID(fuuid);
				COOKIE_REPL = readUUID(fuuid);
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		return COOKIE_REPL;
	}

	/**
	 * Get screen density in dots per inch
	 * 
	 * @return screen density in dots per inch
	 */
	public static float getDensity() {
		return SdkUtil.getMetrics().density;
	}

	/**
	 * Get screen density (hdpi, mdpi, ldpi)
	 * 
	 * @return android screen density
	 */
	public static int getDensityDpi() {
		return SdkUtil.getMetrics().densityDpi;
	}

	/**
	 * Android device identifier
	 * 
	 * @return device identifier as string
	 */
	public static synchronized String getDeviceId() {
		if (DEVICE_ID == null) {
				DEVICE_ID = getCookieReplStr();
		}

		return DEVICE_ID;
	}

	private synchronized static Intent getHeadsetIntent() {
		HEADSET_INTENT = getContext().registerReceiver(null,
				new IntentFilter(Intent.ACTION_HEADSET_PLUG));
		return HEADSET_INTENT;
	}

	private static void getIdfaThread() {
		new Thread(new Runnable() {

			@Override
			public void run() {
				SdkLog.i(TAG,  "Start getting Google advertising identifier...");
				Info adInfo = null;
				FETCH_IDFA = false;
				try {
					adInfo = AdvertisingIdClient
							.getAdvertisingIdInfo(getContext());
				} catch (IOException e) {
					// Unrecoverable error connecting to Google Play services
					// (e.g.,
					// the old version of the service doesn't support getting
					// AdvertisingId).
					SdkLog.e(TAG, "Google Play services connection problem", e);

				} 
				catch (GooglePlayServicesRepairableException e) {
					SdkLog.e(
							TAG,
							"Google Play ID service problem, trying again later",
							e);
					FETCH_IDFA = true;
				}  catch (GooglePlayServicesNotAvailableException e) {
					// Google Play services is not available entirely.
					SdkLog.e(TAG, "Google Play services not available", e);
				} catch (Exception e) {
					SdkLog.w(TAG, "Problem with Google Play ID service, trying again later. Splash screens use broadcast receivers - if this is your splash screen, ignore the warning.");
					FETCH_IDFA = true;
				}

				IDFA = adInfo != null && !adInfo.isLimitAdTrackingEnabled() ? adInfo
						.getId() : null;
				if (IDFA != null) {
					SdkLog.i(TAG,  "Finished getting Google advertising identifier... [" + IDFA + "]");
				}
			}
		}).start();

	}

	/**
	 * Access Google Advertising Identifier
	 * 
	 * @return null if user chose to opt-out or id is not available, id
	 *         otherwise
	 */
	public static String getIdForAdvertiser() {
		if (FETCH_IDFA) {
			getIdfaThread();
		}
		return IDFA;
	}

	private synchronized static Method getKitKatJsMethod() {
		try {
			KITKAT_JS_METHOD = Class.forName("android.webkit.WebView")
					.getDeclaredMethod("evaluateJavascript",
							KITKAT_JS_PARAMTYPES);
			KITKAT_JS_METHOD.setAccessible(true);
		} catch (Exception e0) {
			SdkLog.e(
					TAG,
					"FATAL ERROR: Could not invoke Android 4.4 Chromium WebView method evaluateJavascript",
					e0);
		}
		return KITKAT_JS_METHOD;
	}

	/**
	 * Gets the location.
	 * 
	 * @return the location
	 */
	public static double[] getLocation() {
		LocationManager lm = (LocationManager) getContext().getSystemService(
				Context.LOCATION_SERVICE);
		List<String> providers = lm.getProviders(false);
		Iterator<String> provider = providers.iterator();
		Location lastKnown = null;
		double[] loc = new double[4];
		long age = 0;
		int maxage = getContext().getResources().getInteger(
				R.integer.ems_location_maxage_ms);
		while (provider.hasNext()) {
			lastKnown = lm.getLastKnownLocation(provider.next());
			if (lastKnown != null) {

				age = System.currentTimeMillis() - lastKnown.getTime();
				if (age <= maxage) {
					break;
				} else {
					SdkLog.d(TAG, "Location [" + lastKnown.getProvider()
							+ "] is " + (age / 60000) + " min old. [max = "
							+ (maxage / 60000) + "]");
				}
			}
		}

		if (lastKnown != null && age <= maxage) {
			loc[0] = lastKnown.getLatitude();
			loc[1] = lastKnown.getLongitude();
			loc[2] = lastKnown.getSpeed() * 3.6;
			loc[3] = lastKnown.getAltitude();
			if (getContext().getResources().getBoolean(
					R.bool.ems_shorten_location)) {
				SdkLog.d(TAG, "Shortening " + loc[0] + "," + loc[1]);
				loc[0] = Math.round( loc[0] * 100.0 ) / 100.0;
				loc[1] = Math.round( loc[1] * 100.0 ) / 100.0;
				SdkLog.d(TAG, "Geo location shortened to two digits.");
			}

			SdkLog.i(TAG, "Location [" + lastKnown.getProvider() + "] is "
					+ loc[0] + "x" + loc[1] + "," + loc[2] + "," + loc[3]);
			return loc;
		}

		return null;
	}

	private static DisplayMetrics getMetrics() {
		if (SdkUtil.WINDOW_MANAGER == null) {
			SdkUtil.WINDOW_MANAGER = getWinMgr();
		}
		SdkUtil.WINDOW_MANAGER.getDefaultDisplay().getMetrics(SdkUtil.METRICS);
		return METRICS;

	}

	/**
	 * Check the network subtype, i.e. carrier name
	 * 
	 * @return carrier name if available, "unknown" otherwise
	 */
	static String getNetworkName() {

		Context c = SdkUtil.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"Access Network State not granted in Manifest - unable to determine provider.");
			return "Unknown";
		}

		final ConnectivityManager conMgr = (ConnectivityManager) c
				.getSystemService(Context.CONNECTIVITY_SERVICE);

		try {
			return conMgr.getActiveNetworkInfo().getExtraInfo();
		} catch (Exception e) {
			SdkLog.w(TAG,
					"Exception in getNetworkInfo - unable to determine provider.");
			return "Unknown";
		}
	}

	/**
	 * Get screen width in pixels
	 * 
	 * @return screen width in pixels
	 */
	public static int getScreenHeight() {
		return SdkUtil.getMetrics().heightPixels;
	}

	/**
	 * Get screen height in pixels
	 * 
	 * @return screen height in pixels
	 */
	public static int getScreenWidth() {
		return SdkUtil.getMetrics().widthPixels;
	}

	private synchronized static TelephonyManager getTelephonyManager() {
		TELEPHONY_MANAGER = (TelephonyManager) SdkUtil.getContext()
				.getSystemService(Context.TELEPHONY_SERVICE);
		return TELEPHONY_MANAGER;
	}

	/**
	 * Returns a fixed user-agent if in debug mode, the device user agent if not
	 * 
	 * @return device or fixed user agent as string
	 */
	@SuppressLint("NewApi")
	public static String getUserAgent() {

		if (DEBUG) {
			SdkLog.w(TAG,
					"UserAgentHelper is in DEBUG mode. Do not deploy to production like this.");
		}
		if (USER_AGENT == null) {
			// determine user-agent
			if (Build.VERSION.SDK_INT < 17) {
				try {
					WebView w = new WebView(CONTEXT);
					USER_AGENT = w.getSettings().getUserAgentString();
					w.destroy();
					w = null;
				} catch (Exception e) {
					USER_AGENT = DEBUG_USER_AGENT;
				}
			} else {
				USER_AGENT = WebSettings.getDefaultUserAgent(CONTEXT);
			}
			SdkLog.i(TAG, "G+J EMS SDK UserAgent: " + USER_AGENT);
			getIdfaThread();
		}
		return DEBUG ? DEBUG_USER_AGENT : USER_AGENT;
	}

	private static WindowManager getWinMgr() {
		if (SdkUtil.WINDOW_MANAGER == null) {
			SdkUtil.WINDOW_MANAGER = (WindowManager) SdkUtil.getContext()
					.getSystemService(Context.WINDOW_SERVICE);
		}
		return WINDOW_MANAGER;
	}

	/**
	 * Perform a quick simple http request without processing the response
	 * 
	 * @param url
	 *            The url to request
	 */
	public static void httpRequest(final String url) {
		SdkUtil.httpRequests(new String[] { url });
	}

	/**
	 * Perform quick simple http requests without processing the response.
	 * Errors are written to log output.
	 * 
	 * @param url
	 *            An array of url strings
	 */
	public static void httpRequests(final String[] urls) {
		for (String url : urls) {
			Intent i = new Intent(getContext(), AmobeeAdRequest.class);
			i.putExtra(AdRequest.ADREQUEST_URL_EXTRA, url);
			getContext().startService(i);
		}
	}

	/**
	 * Check whether phone has mobile 3G connection
	 * 
	 * @return
	 */
	public static boolean is3G() {
		if (!isWifi()) {
			if (TELEPHONY_MANAGER == null) {
				TELEPHONY_MANAGER = getTelephonyManager();
			}
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
				if (TELEPHONY_MANAGER.getNetworkType() == TelephonyManager.NETWORK_TYPE_LTE) {
					return false;
				}
			}
			switch (TELEPHONY_MANAGER.getNetworkType()) {
			case TelephonyManager.NETWORK_TYPE_EDGE:
			case TelephonyManager.NETWORK_TYPE_GPRS:
			case TelephonyManager.NETWORK_TYPE_UNKNOWN:
				return false;
			}
			return true;
		}
		return false;
	}

	/**
	 * Check whether phone has mobile 4G connection
	 * 
	 * @return
	 */
	@SuppressLint("InlinedApi")
	public static boolean is4G() {
		if (!isWifi() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
			if (TELEPHONY_MANAGER == null) {
				TELEPHONY_MANAGER = (TelephonyManager) SdkUtil.getContext()
						.getSystemService(Context.TELEPHONY_SERVICE);
			}
			return TELEPHONY_MANAGER.getNetworkType() == TelephonyManager.NETWORK_TYPE_LTE;
		}
		return false;
	}

	/**
	 * Check whether a charger is connected to the device
	 * 
	 * @return true if a charger is connected
	 */
	public static boolean isChargerConnected() {
		if (BATTERY_INTENT == null) {
			try {
				BATTERY_INTENT = getBatteryIntent();
			} catch (ReceiverCallNotAllowedException e) {
				SdkLog.w(TAG,
						"Skipping start of phone status receivers from start interstitial.");
				BATTERY_INTENT = null;
				return false;
			}
		}
		int cp = BATTERY_INTENT.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);
		return cp == BatteryManager.BATTERY_PLUGGED_AC
		// || cp == BatteryManager.BATTERY_PLUGGED_WIRELESS
				|| cp == BatteryManager.BATTERY_PLUGGED_USB;
	}

	/**
	 * Check wheter GPS is active / allowed
	 * 
	 * @return
	 */
	public static boolean isGPSActive() {
		final LocationManager manager = (LocationManager) CONTEXT
				.getSystemService(Context.LOCATION_SERVICE);
		try {
			return manager.isProviderEnabled(LocationManager.GPS_PROVIDER);
		} catch (Exception e) {
			SdkLog.w(TAG,
					"Access fine location not allowed by app - assuming no GPS");
			return false;
		}
	}

	/**
	 * Check whether a headset is connected to the device
	 * 
	 * @return true if a headset is connected
	 */
	public static boolean isHeadsetConnected() {
		try {
			HEADSET_INTENT = getHeadsetIntent();
		} catch (Exception e) {
			SdkLog.e(TAG, "Error getting headset status.", e);
		}
		return HEADSET_INTENT != null ? HEADSET_INTENT.getIntExtra("state", 0) != 0
				: false;
	}

	/**
	 * Detect phablets and tablets
	 * 
	 * @return true if we are on device larger than a phone
	 */
	static boolean isLargerThanPhone() {
		return getContext().getResources().getBoolean(R.bool.largeDisplay);
	}

	/**
	 * Check whether device is offline. if
	 * android.Manifest.permission.ACCESS_NETWORK_STATE is not granted or the
	 * state cannot be determined, the device will alsways be assumed to be
	 * online.
	 * 
	 * @return true if device is not connected to any network
	 */
	public static boolean isOffline() {

		Context c = SdkUtil.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"Access Network State not granted in Manifest - assuming ONLINE.");
			return false;
		}

		final ConnectivityManager conMgr = (ConnectivityManager) c
				.getSystemService(Context.CONNECTIVITY_SERVICE);

		try {
			return conMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
					.getState() == NetworkInfo.State.DISCONNECTED
					&& conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
							.getState() == NetworkInfo.State.DISCONNECTED;
		} catch (Exception e) {
			SdkLog.w(TAG, "Exception in getNetworkInfo - assuming ONLINE.");
			return false;
		}
	}

	/**
	 * Check whether device is online. if
	 * android.Manifest.permission.ACCESS_NETWORK_STATE is not granted or the
	 * state cannot be determined, the device will alsways be assumed to be
	 * online.
	 * 
	 * @return true if device is connected to any network
	 */
	public static boolean isOnline() {

		Context c = SdkUtil.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"Access Network State not granted in Manifest - assuming ONLINE.");
			return true;
		}

		final ConnectivityManager conMgr = (ConnectivityManager) c
				.getSystemService(Context.CONNECTIVITY_SERVICE);

		try {
			return conMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
					.getState() == NetworkInfo.State.CONNECTED
					|| conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
							.getState() == NetworkInfo.State.CONNECTED
					|| conMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
							.getState() == NetworkInfo.State.CONNECTING
					|| conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
							.getState() == NetworkInfo.State.CONNECTING;
		} catch (Exception e) {
			SdkLog.w(TAG, "Exception in getNetworkInfo - assuming ONLINE.");
			return true;
		}
	}

	/**
	 * Check whether device is in portait mode
	 * 
	 * @return true if portrait mode, false if landscape mode
	 */
	public static boolean isPortrait() {
		int r = getWinMgr().getDefaultDisplay().getRotation();
		return r == Surface.ROTATION_0 || r == Surface.ROTATION_180;
	}

	/**
	 * Check whether device is connected via WiFi. if
	 * android.Manifest.permission.ACCESS_NETWORK_STATE is not granted or the
	 * state cannot be determined, the device will always be assumed to be
	 * online via a mobile concection.
	 * 
	 * @return true if device is connected via wifi
	 */
	public static boolean isWifi() {

		Context c = SdkUtil.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"Access Network State not granted in Manifest - assuming mobile connection.");
			return false;
		}

		final ConnectivityManager conMgr = (ConnectivityManager) c
				.getSystemService(Context.CONNECTIVITY_SERVICE);

		try {
			return conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
					.getState() == NetworkInfo.State.CONNECTED
					|| conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
							.getState() == NetworkInfo.State.CONNECTING;
		} catch (Exception e) {
			SdkLog.w(TAG,
					"Exception in getNetworkInfo - assuming mobile connection.");
			return false;
		}
	}

	private static String readUUID(File fuuid) throws IOException {
		RandomAccessFile f = new RandomAccessFile(fuuid, "r");
		byte[] bytes = new byte[(int) f.length()];
		f.readFully(bytes);
		f.close();
		return new String(bytes);
	}

	public static void reloadAds(Activity ac) {
		if (ac != null) {
			ViewGroup root = (ViewGroup) ac.findViewById(android.R.id.content);
			if (root != null) {
				reloadAdsInGroup(root);
			} else {
				SdkLog.w(TAG, "Could not access root view when reloading ads.");
			}
		} else {
			SdkLog.w(TAG, "Called reloadAds for null Activity.");
		}
	}

	private static void reloadAdsInGroup(ViewGroup vg) {
		if (vg != null) {
			for (int i = 0; i < vg.getChildCount(); i++) {
				if (GuJEMSAdView.class.equals(vg.getChildAt(i).getClass())) {
					GuJEMSAdView v = (GuJEMSAdView) vg.getChildAt(i);
					SdkLog.d(TAG, "Reload adview " + v);
					v.reload();
				} else if (vg.getChildAt(i) instanceof ViewGroup) {
					reloadAdsInGroup((ViewGroup) vg.getChildAt(i));
				}
				// TODO more view types
			}
		}
	}

	/**
	 * Set application context
	 * 
	 * @param c
	 *            android application context
	 */
	public final static void setContext(Context c) {
		CONTEXT = c;
	}

	private static void writeUUID(File fuuid) throws IOException {
		FileOutputStream out = new FileOutputStream(fuuid);
		String id = UUID.randomUUID().toString();
		out.write(id.getBytes());
		out.close();
	}

	private final static String TAG = "SdkUtil";

	private final static Class<?>[] KITKAT_JS_PARAMTYPES = new Class[] {
			String.class, ValueCallback.class };

	private volatile static Method KITKAT_JS_METHOD = null;

	private volatile static Intent BATTERY_INTENT = null;

	private volatile static Intent HEADSET_INTENT = null;

	private volatile static TelephonyManager TELEPHONY_MANAGER;

	private static DisplayMetrics METRICS = new DisplayMetrics();

	private static WindowManager WINDOW_MANAGER = null;

	private static String COOKIE_REPL;

	private static String DEVICE_ID;

	private static final String EMSUID = ".emsuid";

	private static Context CONTEXT;

	private static String USER_AGENT = null;

	private static String IDFA = null;

	private static boolean FETCH_IDFA = true;

	private final static boolean DEBUG = false;

	private final static String DEBUG_USER_AGENT = "Mozilla/5.0 (Linux; U; Android 4.3; de-de; GT-I9100 Build/GRH78) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1";

	/**
	 * major sdk version integer
	 */
	private final static int MAJOR_VERSION = 1;

	/**
	 * minor sdk version integer
	 */
	private final static int MINOR_VERSION = 4;

	/**
	 * revision sdk version integer
	 */
	private final static int REV_VERSION = 0;

	/**
	 * Version string containing major, minor and revision as string divided by
	 * underscores for passing it to the adserver
	 */
	public final static String VERSION_STR = MAJOR_VERSION + "_"
			+ MINOR_VERSION + "_" + REV_VERSION;

}

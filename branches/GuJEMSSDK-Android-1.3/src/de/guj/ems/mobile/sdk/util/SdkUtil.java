package de.guj.ems.mobile.sdk.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.UUID;

import android.Manifest.permission;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.view.WindowManager;
import android.webkit.WebView;

/**
 * Various global static methods for initialization, configuration of sdk
 * plus targeting parameters.
 * 
 * @author stein16
 *
 */
public class SdkUtil {

	private final static String TAG = "SdkUtil";

	private static DisplayMetrics METRICS = new DisplayMetrics();
	
	private static WindowManager WINDOW_MANAGER = null;
	
	private static String COOKIE_REPL;
	
	private static String DEVICE_ID;
	
	private static final String EMSUID = ".emsuid";
	
	private static Context CONTEXT;
	
	private static String USER_AGENT = null;
	
	private final static boolean DEBUG = false;
	
	private final static String DEBUG_USER_AGENT = "Mozilla/5.0 (Linux; U; Android 2.3; de-de; GT-I9100 Build/GRH78) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1";
	
	/**
	 * major sdk version integer
	 */
	public final static int MAJOR_VERSION = 1;
	
	/**
	 * minor sdk version integer
	 */
	public final static int MINOR_VERSION = 2;
	
	/**
	 * revision sdk version integer
	 */
	public final static int REV_VERSION = 5;
	
	/**
	 * Version string containing major, minor and revision as string divided by underscores for passing it to the adserver
	 */
	public final static String VERSION_STR = MAJOR_VERSION + "_" + MINOR_VERSION + "_" + REV_VERSION;
	
	/**
	 * Get android application context
	 * @return context (if set before)
	 */
	public final static Context getContext() {
		return CONTEXT;
	}

	/**
	 * Set application context
	 * @param c android application context
	 */
	public final static void setContext(Context c) {
		CONTEXT = c;
	}
	
	/**
	 * Check whether device is offline. if android.Manifest.permission.ACCESS_NETWORK_STATE is
	 * not granted or the state cannot be determined, the device will alsways be assumed to be online.
	 * @return true if device is not connected to any network
	 */
	public static boolean isOffline() {

		Context c = SdkUtil.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"ems_adcall: Access Network State not granted in Manifest - assuming ONLINE.");
			return false;
		}

		ConnectivityManager conMgr = (ConnectivityManager) c
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		
		try {
			return conMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
				.getState() == NetworkInfo.State.DISCONNECTED
				&& conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
						.getState() == NetworkInfo.State.DISCONNECTED;
		}
		catch (Exception e) {
			SdkLog.w(TAG,
					"ems_adcall: Exception in getNetworkInfo - assuming ONLINE.");
			return false;
		}
	}

	/**
	 * Check whether device is online. if android.Manifest.permission.ACCESS_NETWORK_STATE is
	 * not granted or the state cannot be determined, the device will alsways be assumed to be online.
	 * @return true if device is connected to any network
	 */
	public static boolean isOnline() {

		Context c = SdkUtil.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"ems_adcall: Access Network State not granted in Manifest - assuming ONLINE.");
			return true;
		}

		ConnectivityManager conMgr = (ConnectivityManager) c
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
		}
		catch (Exception e) {
			SdkLog.w(TAG,
					"ems_adcall: Exception in getNetworkInfo - assuming ONLINE.");
			return true;
		}
	}
	
	private static DisplayMetrics getMetrics() {
		if (SdkUtil.WINDOW_MANAGER == null) {
			SdkUtil.WINDOW_MANAGER = (WindowManager)SdkUtil.getContext().getSystemService(Context.WINDOW_SERVICE);
			SdkUtil.WINDOW_MANAGER.getDefaultDisplay().getMetrics(SdkUtil.METRICS);
			SdkLog.i(TAG, "Screen density " + SdkUtil.METRICS.density + "[ " + SdkUtil.METRICS.densityDpi + "]");
			SdkLog.i(TAG, "Screen resolution " + SdkUtil.METRICS.widthPixels + "x" + SdkUtil.METRICS.heightPixels);
		}
		
		return METRICS;
		
	}
	
	/**
	 * Get screen height in pixels
	 * @return screen height in pixels
	 */
	public static int getScreenWidth() {
		return SdkUtil.getMetrics().widthPixels;
	}
	
	/**
	 * Get screen width in pixels
	 * @return screen width in pixels
	 */
	public static int getScreenHeight() {
		return SdkUtil.getMetrics().heightPixels;
	}
	
	/**
	 * Get screen density (hdpi, mdpi, ldpi)
	 * @return android screen density 
	 */
	public static int getDensityDpi() {
		return SdkUtil.getMetrics().densityDpi;
	}
	
	/**
	 * Get screen density in dots per inch
	 * @return screen density in dots per inch
	 */
	public static float getDensity() {
		return SdkUtil.getMetrics().density;
	}

	/**
	 * Returns a fixed user-agent if in debug mode, the device user agent if not
	 * @return device or fixed user agent as string
	 */
	public static String getUserAgent() {
		if (DEBUG) {
			SdkLog.w(TAG, "UserAgentHelper is in DEBUG mode. Do not deploy to production like this.");
		}
		if (USER_AGENT == null) {
			// determine user-agent
			WebView w = new WebView(SdkUtil.getContext());
			USER_AGENT = w.getSettings().getUserAgentString();
			w.destroy();
			w = null;
		}
		return DEBUG ? DEBUG_USER_AGENT : USER_AGENT;
	}
	
	   private static String readUUID(File fuuid) throws IOException {
	        RandomAccessFile f = new RandomAccessFile(fuuid, "r");
	        byte[] bytes = new byte[(int) f.length()];
	        f.readFully(bytes);
	        f.close();
	        return new String(bytes);
	    }

	    private static void writeUUID(File fuuid) throws IOException {
	        FileOutputStream out = new FileOutputStream(fuuid);
	        String id = UUID.randomUUID().toString();
	        out.write(id.getBytes());
	        out.close();
	    }
	
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
	
	public static String getDeviceId() {
		if (DEVICE_ID == null) {
			TelephonyManager tm = (TelephonyManager)SdkUtil.getContext().getSystemService(Context.TELEPHONY_SERVICE);
			DEVICE_ID =  tm.getDeviceId();
		}
		
		return DEVICE_ID;
	}
	
}

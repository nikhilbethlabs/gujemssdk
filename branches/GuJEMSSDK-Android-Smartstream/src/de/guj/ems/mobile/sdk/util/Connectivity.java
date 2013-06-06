package de.guj.ems.mobile.sdk.util;

import android.Manifest.permission;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * Globally available interface to determine device connectivity
 * @author stein16
 *
 */
public class Connectivity {
	
	private final static String TAG = "Connectivity";
	
	/**
	 * Check whether device is offline. if android.Manifest.permission.ACCESS_NETWORK_STATE is
	 * not granted, the device will alsways be assumed to be online.
	 * @return true if device is not connected to any network
	 */
	public static boolean isOffline() {

		Context c = AppContext.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"ems_adcall: Access Network State not granted in Manifest - assuming ONLINE.");
			return false;
		}

		ConnectivityManager conMgr = (ConnectivityManager) c
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		return conMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
				.getState() == NetworkInfo.State.DISCONNECTED
				&& conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
						.getState() == NetworkInfo.State.DISCONNECTED;
	}

	/**
	 * Check whether device is online. if android.Manifest.permission.ACCESS_NETWORK_STATE is
	 * not granted, the device will alsways be assumed to be online.
	 * @return true if device is connected to any network
	 */
	public static boolean isOnline() {

		Context c = AppContext.getContext();
		if (c.getPackageManager().checkPermission(
				permission.ACCESS_NETWORK_STATE, c.getPackageName()) != PackageManager.PERMISSION_GRANTED) {
			SdkLog.w(TAG,
					"ems_adcall: Access Network State not granted in Manifest - assuming ONLINE.");
			return true;
		}

		ConnectivityManager conMgr = (ConnectivityManager) c
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		return conMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
				.getState() == NetworkInfo.State.CONNECTED
				|| conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
						.getState() == NetworkInfo.State.CONNECTED
				|| conMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
						.getState() == NetworkInfo.State.CONNECTING
				|| conMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
						.getState() == NetworkInfo.State.CONNECTING;
	}
}

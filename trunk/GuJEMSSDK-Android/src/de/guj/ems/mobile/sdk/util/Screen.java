package de.guj.ems.mobile.sdk.util;

import android.content.Context;
import android.util.DisplayMetrics;
import android.view.WindowManager;

/**
 * Globally available interface to determine screen metrics of an android device
 * @author stein16
 *
 */
public class Screen {
	
	private static DisplayMetrics METRICS = new DisplayMetrics();
	
	private static WindowManager WINDOW_MANAGER = null;
	
	private final static String TAG = "Screen";
	
	private static DisplayMetrics getMetrics() {
		if (Screen.WINDOW_MANAGER == null) {
			Screen.WINDOW_MANAGER = (WindowManager)AppContext.getContext().getSystemService(Context.WINDOW_SERVICE);
			Screen.WINDOW_MANAGER.getDefaultDisplay().getMetrics(Screen.METRICS);
			SdkLog.i(TAG, "Screen density " + Screen.METRICS.density + "[ " + Screen.METRICS.densityDpi + "]");
			SdkLog.i(TAG, "Screen resolution " + Screen.METRICS.widthPixels + "x" + Screen.METRICS.heightPixels);
		}
		
		return METRICS;
		
	}
	
	/**
	 * Get screen height in pixels
	 * @return screen height in pixels
	 */
	public static int getScreenWidth() {
		return Screen.getMetrics().widthPixels;
	}
	
	/**
	 * Get screen width in pixels
	 * @return screen width in pixels
	 */
	public static int getScreenHeight() {
		return Screen.getMetrics().heightPixels;
	}
	
	/**
	 * Get screen density (hdpi, mdpi, ldpi)
	 * @return android screen density 
	 */
	public static int getDensityDpi() {
		return Screen.getMetrics().densityDpi;
	}
	
	/**
	 * Get screen density in dots per inch
	 * @return screen density in dots per inch
	 */
	public static float getDensity() {
		return Screen.getMetrics().density;
	}

}

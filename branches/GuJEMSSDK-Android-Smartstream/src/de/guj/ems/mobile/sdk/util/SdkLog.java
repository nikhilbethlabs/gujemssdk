package de.guj.ems.mobile.sdk.util;

import android.util.Log;

/**
 * Globally available interface for logging from the sdk.
 * SdkLog distinguishes between three log levels:
 * TEST - allows log levels up to verbose
 * PROD - allows log levels upt to info
 * OFF  - switches all logging off
 * Uses android logging utility. 
 * @author stein16
 *
 */
public final class SdkLog {
	
	public static int LOG_LEVEL = SdkLog.LOG_LEVEL_TEST;
	
	private final static int LOG_LEVEL_TEST = 0;
	
	private final static int LOG_LEVEL_PROD = 1;
	
	private final static int LOG_LEVEL_OFF = 2;
	
	private static boolean TESTING = (SdkLog.LOG_LEVEL == SdkLog.LOG_LEVEL_TEST);
	
	private static boolean OFF = (SdkLog.LOG_LEVEL == SdkLog.LOG_LEVEL_OFF);
	
	/**
	 * Sets log level to production (max = info)
	 */
	public static void setProductionLogLevel() {
		SdkLog.LOG_LEVEL = SdkLog.LOG_LEVEL_PROD;
		SdkLog.OFF = false;
		SdkLog.TESTING = false;
	}
	
	/**
	 * Sets log level to test (max = verbose)
	 */
	public static void setTestLogLevel() {
		SdkLog.LOG_LEVEL = SdkLog.LOG_LEVEL_TEST;
		SdkLog.TESTING = true;
		SdkLog.OFF = false;
	}
	
	/**
	 * Turns all logging off
	 */
	public static void setLogLevelOff() {
		SdkLog.LOG_LEVEL = SdkLog.LOG_LEVEL_OFF;
		SdkLog.OFF = true;
	}
	
	/**
	 * @see android.util.Log.d(String, String)
	 * @param tag Log tag
	 * @param message Log message
	 */
	public static void d(String tag, String message) {
		if (SdkLog.TESTING && !SdkLog.OFF) {
			Log.d(tag, message);
		}
	}
	
	/**
	 * @see android.util.Log.i(String, String)
	 * @param tag Log tag
	 * @param message Log message
	 */
	public static void i(String tag, String message) {
		if (!SdkLog.OFF) {
			Log.i(tag, message);
		}
	}
	
	/**
	 * @see android.util.Log.v(String, String)
	 * @param tag Log tag
	 * @param message Log message
	 */
	public static void v(String tag, String message) {
		if (SdkLog.TESTING && !SdkLog.OFF) {
			Log.v(tag, message);
		}
	}
	
	/**
	 * @see android.util.Log.e(String, String)
	 * @param tag Log tag
	 * @param message Log message
	 */
	public static void e(String tag, String message) {
		Log.e(tag, message);
	}
	
	/**
	 * @see android.util.Log.e(String, String, Throwable)
	 * @param tag Log tag
	 * @param message Log message
	 * @param t Thrown exception
	 */
	public static void e(String tag, String message, Throwable t) {
		Log.e(tag, message, t);
	}
	
	/**
	 * @see android.util.Log.w(String, String)
	 * @param tag Log tag
	 * @param message Log message
	 */
	public static void w(String tag, String message) {
		if (!SdkLog.OFF) {
			Log.w(tag, message);
		}
	}

}

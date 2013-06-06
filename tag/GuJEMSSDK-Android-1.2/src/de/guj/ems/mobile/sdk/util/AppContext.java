package de.guj.ems.mobile.sdk.util;

import android.content.Context;

/**
 * Globally available helper to access android
 * application context from non-android classes
 * 
 * Needs to be initialized with AppContext.setContext(..),
 * which is done internally from the SDK to prevent
 * exceptions.
 * @author stein16
 *
 */
public class AppContext {
	

	private static Context context;
	
	/**
	 * Get android application context
	 * @return context (if set before)
	 */
	public final static Context getContext() {
		return context;
	}

	/**
	 * Set application context
	 * @param c android application context
	 */
	public final static void setContext(Context c) {
		context = c;
	}

}

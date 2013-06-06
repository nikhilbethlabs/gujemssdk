package de.guj.ems.mobile.sdk.util;

import android.webkit.WebView;

public final class UserAgentHelper {
	
	private static String USER_AGENT = null;
	
	private final static boolean DEBUG = false;
	
	private final static String DEBUG_USER_AGENT = "Mozilla/5.0 (Linux; U; Android 4.0; xx-xx; Galaxy Nexus Build/ITL41F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30";
	
	public static String getUserAgent() {
		if (USER_AGENT == null) {
			// determine user-agent
			WebView w = new WebView(AppContext.getContext());
			USER_AGENT = w.getSettings().getUserAgentString();
			w.destroy();
			w = null;
		}
		return DEBUG ? DEBUG_USER_AGENT : USER_AGENT;
	}

}

package de.guj.ems.mobile.sdk.controllers.adserver;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;

/**
 * Simple settings instance for plain http requests without further settings and
 * without json processing
 * 
 * This is basically a simple http request
 * 
 * @author stein16
 *
 */
public class TrackingSettingsAdapter extends AdServerSettingsAdapter {

	private String url;

	/**
	 * Constructed directly with full URL
	 * 
	 * @param url
	 *            tracking request url
	 */
	public TrackingSettingsAdapter(String url) {
		super();
		setup(null, (AttributeSet) null, null);
		setBaseUrlString(url);
	}

	@Override
	public boolean doProcess() {
		// tracking requests should no be manipulated (contrary to ad requests)
		return false;
	}

	@Override
	public String getBaseQueryString() {
		return null;
	}

	@Override
	public String getBaseUrlString() {
		return url;
	}

	@Override
	public String getGooglePublisherId() {
		return null;
	}

	@Override
	public void setBaseUrlString(String baseUrl) {
		this.url = baseUrl;
	}

	@Override
	public void setup(Context context, Class<?> viewClass, AttributeSet set) {
	}

	@Override
	public void setup(Context context, Class<?> viewClass, AttributeSet set,
			String[] kws, String[] nkws) {
	}

	@Override
	public void setup(Context context, Class<?> viewClass, Bundle savedInstance) {
	}

	@Override
	public void setup(Context context, Class<?> viewClass,
			Bundle savedInstance, String[] kws, String[] nkws) {
	}

}

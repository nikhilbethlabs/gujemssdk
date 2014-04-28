package de.guj.ems.mobile.sdk.controllers.adserver;

import android.util.AttributeSet;

/**
 * Simple settings instance for plain http requests without
 * further settings and without json processing
 * 
 * This is basically a simple http request
 * 
 * @author stein16
 *
 */
public class TrackingSettingsAdapter extends AdServerSettingsAdapter {

	private String url;
	
	private static final long serialVersionUID = 5306862767558725868L;

	/**
	 * Constructed directly with full URL
	 * @param url tracking request url
	 */
	public TrackingSettingsAdapter(String url) {
		super(null, (AttributeSet)null, null);
		setBaseUrlString(url);
	}

	@Override
	public String getBaseUrlString() {
		return url;
	}

	@Override
	public String getBaseQueryString() {
		return null;
	}

	@Override
	public void setBaseUrlString(String baseUrl) {
		this.url = baseUrl;
	}
	
	@Override
	public boolean doProcess() {
		// tracking requests should no be manipulated (contrary to ad requests)
		return false;
	}

}

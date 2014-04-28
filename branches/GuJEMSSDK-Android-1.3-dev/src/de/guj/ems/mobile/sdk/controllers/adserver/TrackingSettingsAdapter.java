package de.guj.ems.mobile.sdk.controllers.adserver;

import android.util.AttributeSet;

public class TrackingSettingsAdapter extends AdServerSettingsAdapter {

	private String url;
	private static final long serialVersionUID = 5306862767558725868L;

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

}

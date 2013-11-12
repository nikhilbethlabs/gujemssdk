package de.guj.ems.mobile.sdk.util;

public class OptimobileXmlParser extends AdResponseParser {

	private final static String TAG = "OptimobileXmlParser";
	
	public OptimobileXmlParser(String response) {
		super(response);
	}

	private OptimobileXmlParser(String response, boolean xml) {
		super(response, xml);
	}
	
	private void parseClickUrl() {
		String c = getResponse().substring(getResponse().indexOf("<url><![CDATA") + 14);
		setClickUrl(c.substring(0, c.indexOf("]")));
		SdkLog.i(TAG, "Ad Click URL = " + getClickUrl());
	}

	private void parseImageUrl() {
		String i = getResponse().substring(getResponse().indexOf("<img>![CDATA") +14);
		setImageUrl(i.substring(0, i.indexOf("]")));
		SdkLog.i(TAG, "Ad Image URL = " + getImageUrl());
	}
	
	private void parseTrackingUrl() {
		String i = getResponse().substring(getResponse().indexOf("<track>![CDATA") + 16);
		if (i != null) {
			setTrackingImageUrl(i.substring(0, i.indexOf("]")));
			SdkLog.i(TAG, "Ad Tracking URL = " + getTrackingImageUrl());
		}
		else {
			SdkLog.d(TAG,  "No tracking image in optimobile XML");
		}
	}	

	@Override
	protected void process() {
		try {
			parseClickUrl();
			parseImageUrl();
			parseTrackingUrl();
		}
		catch (Exception e) {
			SdkLog.e(TAG, "Error parsing optimoble XML.", e);
			setInvalid();
		}

	}

}

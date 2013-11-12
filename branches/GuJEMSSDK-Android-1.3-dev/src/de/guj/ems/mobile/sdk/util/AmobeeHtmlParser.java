package de.guj.ems.mobile.sdk.util;

public class AmobeeHtmlParser extends AdResponseParser {

	private final static String TAG = "AmobeeHtmlParser";
	
	public AmobeeHtmlParser(String response) {
		super(response);
	}

	private AmobeeHtmlParser(String response, boolean xml) {
		super(response, xml);
	}
	
	private void parseClickUrl() {
		String c = getResponse().substring(getResponse().indexOf("href=") + 6);
		setClickUrl(c.substring(0, c.indexOf("\"")));
		SdkLog.i(TAG, "Ad Click URL = " + getClickUrl());
	}

	private void parseImageUrl() {
		String i = getResponse().substring(getResponse().indexOf("src=") + 5);
		setImageUrl(i.substring(0, i.indexOf("\"")));
		SdkLog.i(TAG, "Ad Image URL = " + getImageUrl());
	}
	
	private void parseTrackingUrl() {
		String i = getResponse().substring(getResponse().lastIndexOf("notification"));
		setTrackingImageUrl("http://vfdeprod.amobee.com/upsteed/" + i.substring(0, i.indexOf("\"")));
		SdkLog.i(TAG, "Ad Tracking URL = " + getTrackingImageUrl());
	}	

	@Override
	protected void process() {
		try {
			parseClickUrl();
			parseImageUrl();
			parseTrackingUrl();
		}
		catch (Exception e) {
			SdkLog.e(TAG, "Error parsing Amobee HTML.", e);
			setInvalid();
		}

	}

}

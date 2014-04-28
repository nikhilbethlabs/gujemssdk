package de.guj.ems.mobile.sdk.controllers.adserver;

import de.guj.ems.mobile.sdk.util.SdkLog;


public abstract class AdResponse implements IAdResponse {

	private String response;

	private boolean isRich;

	private boolean isTest;

	private boolean isEmpty;

	private String htmlResponse;

	private AdResponseParser parser;
	
	private final static String TAG = "AdResponse";

	public AdResponse(String resp) {
		if (resp != null && resp.startsWith("<?xml")) {
			SdkLog.d(TAG, "Removing xml doc declaration from response");
			this.response = resp.replaceFirst("\\<\\?xml(.+?)\\?\\>", "").trim();
		}
		else {
			this.response = resp;
		}
	}

	@Override
	public String getResponse() {
		return response;
	}

	@Override
	public boolean isImageAd() {
		return !isRich && !isEmpty;
	}

	@Override
	public boolean isRichAd() {
		return isRich && !isEmpty;
	}

	@Override
	public boolean isEmpty() {
		return isEmpty;
	}

	@Override
	public boolean isTest() {
		return isTest;
	}

	@Override
	public AdResponseParser getParser() {
		return parser;
	}

	protected void setIsRich(boolean rich) {
		this.isRich = rich;
	}

	protected void setParser(AdResponseParser parser) {
		this.parser = parser;
	}

	protected void setEmpty(boolean empty) {
		isEmpty = empty;
	}

	@Override
	public String getResponseAsHTML() {
		if (htmlResponse == null) {
			String cUrl = getParser().getClickUrl();
			htmlResponse = "<div style=\"width: 100%; margin: 0; padding: 0;\" id=\"ems_ad_container\">"
					+ (cUrl != null ? "<a href=\"" + getParser().getClickUrl() + "\">" : "")
					+ "<img onload=\"document.getElementById('ems_ad_container').style.height=this.height+'px'\" src=\""
					+ getParser().getImageUrl()
					+ "\">" + (cUrl != null ? "</a>" : "")
					+ (getParser().getTrackingImageUrl() != null ? "<img src=\""
							+ getParser().getTrackingImageUrl()
							+ "\" style=\"width: 0px; height: 0px; display: none;\">"
							: "") + "</div>";
		}
		return htmlResponse;
	}
}

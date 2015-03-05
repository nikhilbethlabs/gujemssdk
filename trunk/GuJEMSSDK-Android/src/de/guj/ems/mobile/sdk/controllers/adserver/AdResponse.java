package de.guj.ems.mobile.sdk.controllers.adserver;

import de.guj.ems.mobile.sdk.util.SdkLog;

abstract class AdResponse implements IAdResponse {

	private static final long serialVersionUID = -2217817771087072480L;

	private String response;

	private boolean isRich;

	private boolean isTest;

	private boolean isEmpty;

	private String htmlResponse;

	private AdResponseParser parser;

	private final static String TAG = "AdResponse";

	AdResponse(String resp) {
		if (resp != null && resp.startsWith("<?xml")) {
			SdkLog.d(TAG, "Removing xml doc declaration from response");
			this.response = resp.replaceFirst("\\<\\?xml(.+?)\\?\\>", "")
					.trim();
		} else {
			this.response = resp;
		}
	}

	@Override
	public AdResponseParser getParser() {
		return parser;
	}

	@Override
	public String getResponse() {
		return response;
	}

	@Override
	public String getResponseAsHTML() {
		if (htmlResponse == null) {
			String cUrl = getParser().getClickUrl();
			htmlResponse = "<div style=\"width: 100%; margin: 0; padding: 0;\" id=\"ems_ad_container\">"
					+ (cUrl != null ? "<a href=\"" + getParser().getClickUrl()
							+ "\">" : "")
					+ "<img onload=\"document.getElementById('ems_ad_container').style.height=this.height+'px'\" src=\""
					+ getParser().getImageUrl()
					+ "\">"
					+ (cUrl != null ? "</a>" : "")
					+ (getParser().getTrackingImageUrl() != null ? "<img src=\""
							+ getParser().getTrackingImageUrl()
							+ "\" style=\"width: 0px; height: 0px; display: none;\">"
							: "") + "</div>";
		}
		return htmlResponse;
	}

	@Override
	public boolean isEmpty() {
		return isEmpty;
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
	public boolean isTest() {
		return isTest;
	}

	protected void setEmpty(boolean empty) {
		isEmpty = empty;
	}

	protected void setIsRich(boolean rich) {
		this.isRich = rich;
	}

	protected void setParser(AdResponseParser parser) {
		this.parser = parser;
	}
}

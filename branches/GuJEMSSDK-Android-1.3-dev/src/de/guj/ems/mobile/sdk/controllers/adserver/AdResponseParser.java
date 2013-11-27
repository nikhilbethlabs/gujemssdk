package de.guj.ems.mobile.sdk.controllers.adserver;

/**
 * Generic class handling different types of ad responses, i.e.
 * extracting click URLs, image URLs and tracking URLs
 *
 * The parser is used in conjunction with native ad views
 * which use native android components instead of a webview
 * 
 * @author stein16
 *
 */
public abstract class AdResponseParser {
	
	private String response;
	
	private boolean xml;
	
	private String imageUrl;
	
	private String clickUrl;
	
	private String trackingImageUrl;
	
	private boolean valid;

	/**
	 * Creates a new ad response parser for HTML responses
	 * @param response plain response from adserver
	 */
	public AdResponseParser(String response) {
		this(response, false);
	}
	
	/**
	 * Creates a new ad response parser
	 * @param response plain response from adserver
	 * @param xml parser expects XML if true, (X)HTML if false
	 */
	public AdResponseParser(String response, boolean xml) {
		this.response = response;
		this.xml = xml;
		this.valid = true;
		this.process();
	}
	
	protected abstract void process();
	
	protected String getResponse() {
		return response;
	}
	
	protected boolean isXml() {
		return xml;
	}

	public String getImageUrl() {
		return imageUrl;
	}

	public String getClickUrl() {
		return clickUrl;
	}

	public String getTrackingImageUrl() {
		return trackingImageUrl;
	}

	protected void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}

	protected void setClickUrl(String clickUrl) {
		this.clickUrl = clickUrl;
	}

	protected void setTrackingImageUrl(String trackingImageUrl) {
		this.trackingImageUrl = trackingImageUrl;
	}
	
	protected void setInvalid() {
		valid = false;
	}
	
	public boolean isValid() {
		return valid;
	}

}

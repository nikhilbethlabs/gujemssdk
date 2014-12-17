package de.guj.ems.mobile.sdk.controllers.adserver;

/**
 * Generic class handling different types of ad responses, i.e. extracting click
 * URLs, image URLs and tracking URLs
 * 
 * The parser is used in conjunction with native ad views which use native
 * android components instead of a webview
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

	private boolean processed;

	/**
	 * Creates a new ad response parser for HTML responses
	 * 
	 * @param response
	 *            plain response from adserver
	 */
	AdResponseParser(String response) {
		this(response, false);
	}

	/**
	 * Creates a new ad response parser
	 * 
	 * @param response
	 *            plain response from adserver
	 * @param xml
	 *            parser expects XML if true, (X)HTML if false
	 */
	AdResponseParser(String response, boolean xml) {
		this.response = response;
		this.xml = xml;
		this.valid = true;
	}

	/**
	 * Get the click URL associated with the ad
	 * 
	 * @return click URL string
	 */
	public String getClickUrl() {
		if (!processed) {
			process();
		}
		return clickUrl;
	}

	/**
	 * Get the URL to the ad's image
	 * 
	 * @return image URL string
	 */
	public String getImageUrl() {
		if (!processed) {
			process();
		}
		return imageUrl;
	}

	protected String getResponse() {
		return response;
	}

	/**
	 * Get a tracking pixel URL if present
	 * 
	 * @return Pixel tracking URL String
	 */
	public String getTrackingImageUrl() {
		if (!processed) {
			process();
		}
		return trackingImageUrl;
	}

	public boolean isValid() {
		if (!processed) {
			process();
		}
		return valid;
	}

	public boolean isXml() {
		return xml;
	}

	protected void process() {
		processed = true;
	}

	protected void setClickUrl(String clickUrl) {
		this.clickUrl = clickUrl;
	}

	protected void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}

	protected void setInvalid() {
		valid = false;
		processed = false;
	}

	protected void setTrackingImageUrl(String trackingImageUrl) {
		this.trackingImageUrl = trackingImageUrl;
	}

}

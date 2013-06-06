package de.guj.ems.mobile.sdk.controllers;


/**
 * Interface for the handling of data and settings
 * to finally construct an adserver request.
 * 
 * @author stein16
 *
 */
public interface IAdServerSettingsAdapter {
	
	/**
	 * 
	 * @return the adserver's base url
	 */
	public String getBaseUrlString();
	
	/**
	 * Returns the final request URL
	 * @return the string of the final request URL 
	 */
	public String getRequestUrl();
	
	/**
	 * Returns the base query string, i.e. with constant values already mapped 
	 * @return
	 */
	public String getBaseQueryString();
	
	/**
	 * The final query string
	 * @return querystring constructed from settings and available data
	 */
	public String getQueryString();
	
	/**
	 * Maps a settings attribute to an adserver parameter. For example
	 * the intern parameter "uid" may mapped to the adserver's parameter
	 * name "u".
	 * @param attr the attribute name
	 * @param param the adserver's parameter name
	 */
	public void putAttrToParam(String attr, String param);
	
	/**
	 * Puts a value to an attribute. E.g. the value "999" to
	 * the attribute "zoneId"
	 * @param attr the attribute name
	 * @param value the value
	 */
	public void putAttrValue(String attr, String value);
	
	/**
	 * Returns a hashed deviceId if available
	 * @return hashed deviceId
	 */
	public String getDeviceId();
	
	/**
	 * Add any custom parameter to the ad request
	 * @warn  this may override existing parameters so use with caution 
	 * @param param name of http parameter
	 * @param value value of http parameter
	 */
	public void addCustomRequestParameter(String param, String value);
	
	/**
	 * Add any custom parameter to the ad request
	 * @warn  this may override existing parameters so use with caution 
	 * @param param name of http parameter
	 * @param value value of http parameter
	 */
	public void addCustomRequestParameter(String param, int value);
	
	/**
	 * Add any custom parameter to the ad request
	 * @warn  this may override existing parameters so use with caution 
	 * @param param name of http parameter
	 * @param value value of http parameter
	 */
	public void addCustomRequestParameter(String param, double value);	
	
}

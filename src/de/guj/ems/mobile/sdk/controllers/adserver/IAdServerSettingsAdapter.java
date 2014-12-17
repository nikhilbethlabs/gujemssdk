package de.guj.ems.mobile.sdk.controllers.adserver;

import java.util.Map;

import org.json.JSONArray;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.controllers.backfill.BackfillDelegator;

/**
 * Interface for the handling of data and settings to finally construct an
 * adserver request.
 * 
 * @author stein16
 * 
 */
public interface IAdServerSettingsAdapter {

	/**
	 * Add a map of custom params to the request. Only String, Integer, Double
	 * allowed.
	 * 
	 * @param params
	 *            Map of parameter names and values
	 */
	public void addCustomParams(Map<String, ?> params);

	/**
	 * Add any custom parameter to the ad request
	 * 
	 * @warn this may override existing parameters so use with caution
	 * @param param
	 *            name of http parameter
	 * @param value
	 *            value of http parameter
	 */
	public void addCustomRequestParameter(String param, double value);

	/**
	 * Add any custom parameter to the ad request
	 * 
	 * @warn this may override existing parameters so use with caution
	 * @param param
	 *            name of http parameter
	 * @param value
	 *            value of http parameter
	 */
	public void addCustomRequestParameter(String param, int value);

	/**
	 * Add any custom parameter to the ad request
	 * 
	 * @warn this may override existing parameters so use with caution
	 * @param param
	 *            name of http parameter
	 * @param value
	 *            value of http parameter
	 */
	public void addCustomRequestParameter(String param, String value);

	/**
	 * Add a predefined string which is appended to the servlet url
	 * 
	 * @param str
	 *            query string extension
	 */
	public void addQueryAppendix(String str);

	/**
	 * Add an array of regular expressions which should be applied to the
	 * resulting ad request
	 * 
	 * @param regexp
	 *            json array with regular expressions
	 */
	public void addRegexp(JSONArray regexp);

	/**
	 * Mark settings as processed
	 */
	public void dontProcess();

	/**
	 * Determine whether the settings may be overridden by local json config
	 * 
	 * @return
	 */
	public boolean doProcess();

	/**
	 * Returns the base query string, i.e. with constant values already mapped
	 * 
	 * @return
	 */
	public String getBaseQueryString();

	/**
	 * 
	 * @return the adserver's base url
	 */
	public String getBaseUrlString();

	/**
	 * Returns a hashed deviceId if available
	 * 
	 * @return hashed deviceId
	 */
	public String getCookieRepl();

	/**
	 * Returns data for a direct, sdk controlled backfill
	 * 
	 * @return backfill data
	 */
	public BackfillDelegator.BackfillData getDirectBackfill();

	/**
	 * From v1.4 on each ad view can have a Google publisher id for backfill
	 * with admob/ad exchange and the like
	 * 
	 * @return Google publisher ID as string
	 */
	public String getGooglePublisherId();

	/**
	 * Returns a listener object if defined
	 * 
	 * @return listener which reacts to non existant ad
	 */
	public IOnAdEmptyListener getOnAdEmptyListener();

	/**
	 * Returns a listener object if defined
	 * 
	 * @return listener which reacts to ad server errors
	 */
	public IOnAdErrorListener getOnAdErrorListener();

	/**
	 * Returns a listener object if defined
	 * 
	 * @return listener which reacts to successfully loaded ad
	 */
	public IOnAdSuccessListener getOnAdSuccessListener();

	/**
	 * Retrieve a map of all actual request params defined in the settings
	 * 
	 * @return map with all configured param values
	 */
	public Map<String, String> getParams();

	/**
	 * Returns an appending string to the query string
	 * 
	 * @return query string extension
	 */
	public String getQueryAppendix();

	/**
	 * The final query string
	 * 
	 * @return querystring constructed from settings and available data
	 */
	public String getQueryString();

	/**
	 * Returns the final request URL
	 * 
	 * @return the string of the final request URL
	 */
	public String getRequestUrl();

	/**
	 * Maps a settings attribute to an adserver parameter. For example the
	 * intern parameter "uid" may mapped to the adserver's parameter name "u".
	 * 
	 * @param attr
	 *            the attribute name
	 * @param param
	 *            the adserver's parameter name
	 */
	public void putAttrToParam(String attr, String param);

	/**
	 * Puts a value to an attribute. E.g. the value "999" to the attribute
	 * "zoneId"
	 * 
	 * @param attr
	 *            the attribute name
	 * @param value
	 *            the value
	 */
	public void putAttrValue(String attr, String value);

	/**
	 * Override the initial base url for the request
	 * 
	 * @param baseUrl
	 *            new base url for ad request servlet
	 */
	public void setBaseUrlString(String baseUrl);

	/**
	 * Set data for a direct, sdk controlled backfill
	 * 
	 * @param directBackfill
	 *            backfill data
	 */
	public void setDirectBackfill(BackfillDelegator.BackfillData directBackfill);

	/**
	 * Override the listener class
	 * 
	 * @param l
	 *            implementation of listener which reacts to empty ad responses
	 */
	public void setOnAdEmptyListener(IOnAdEmptyListener l);

	/**
	 * Override the listener class
	 * 
	 * @param l
	 *            implementation of listener which reacts to ad server errors
	 */
	public void setOnAdErrorListener(IOnAdErrorListener l);

	/**
	 * Override the listener class
	 * 
	 * @param l
	 *            implementation of listener which reacts to successful ad
	 *            loading
	 */
	public void setOnAdSuccessListener(IOnAdSuccessListener l);

	/**
	 * Initialize view type and declaration specific settings
	 * 
	 * @param context
	 *            app context
	 * @param viewClass
	 *            type of ad view
	 * @param set
	 *            attributes from xml
	 */
	public void setup(Context context, Class<?> viewClass, AttributeSet set);

	/**
	 * Initialize view type and declaration specific settings with additional
	 * keywords for view
	 * 
	 * @param context
	 *            app context
	 * @param viewClass
	 *            type of ad view
	 * @param set
	 *            attributes from xml
	 * @param kws
	 *            positive keywords
	 * @param nkws
	 *            negative keywords
	 */
	public void setup(Context context, Class<?> viewClass, AttributeSet set,
			String[] kws, String[] nkws);

	/**
	 * Initialize view type and declaration specific settings
	 * 
	 * @param context
	 *            app context
	 * @param viewClass
	 *            type of ad view
	 * @param savedInstance
	 *            saved attributes
	 */
	public void setup(Context context, Class<?> viewClass, Bundle savedInstance);

	/**
	 * Initialize view type and declaration specific settings
	 * 
	 * @param context
	 *            app context
	 * @param viewClass
	 *            type of ad view
	 * @param savedInstance
	 *            saved attributes
	 * @param kws
	 *            positive keywords
	 * @param nkws
	 *            negative keywords
	 */
	public void setup(Context context, Class<?> viewClass,
			Bundle savedInstance, String[] kws, String[] nkws);
}

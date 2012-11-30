package de.guj.ems.mobile.sdk.controllers;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.provider.Settings.Secure;
import android.util.AttributeSet;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.util.AppContext;
import de.guj.ems.mobile.sdk.util.SdkLog;

/**
 * Base class for mapping various available data to adserver parameters.
 * 
 * @see de.guj.ems.mobile.sdk.controllers.IAdServerSettingsAdapter
 * 
 * @author stein16
 * 
 */
public abstract class AdServerSettingsAdapter implements
		IAdServerSettingsAdapter {

	private final static String TAG = "AdServerSettingsAdapter";
	
	private final static long EMS_LOCATION_MAXAGE_MS = 3600000;
	
	private final static long EMS_LOCATION_MAXAGE_MIN = EMS_LOCATION_MAXAGE_MS / 60000;

	public final static String EMS_ATTRIBUTE_PREFIX = AppContext.getContext()
			.getString(R.string.attributePrefix);

	/**
	 * Global attribute name for identifying a site
	 */
	public final static String EMS_SITEID = AppContext.getContext()
			.getString(R.string.siteId);

	protected final static int EMS_SITEID_ID = R.styleable.GuJEMSAdView_ems_siteId;

	/**
	 * Global attribute name for identifying a placement
	 */
	public final static String EMS_ZONEID = AppContext.getContext()
			.getString(R.string.zoneId);

	protected final static int EMS_ZONEID_ID = R.styleable.GuJEMSAdView_ems_zoneId;

	/**
	 * Global attribute name for identifying a unique user/device id
	 */
	public final static String EMS_UUID = AppContext.getContext()
			.getString(R.string.deviceId);

	protected final static int EMS_UUID_ID = R.styleable.GuJEMSAdView_ems_uid;

	/**
	 * Global attribute name for identifying keywords add to the request
	 */
	public final static String EMS_KEYWORDS = AppContext.getContext()
			.getString(R.string.keyword);

	protected final static int EMS_KEYWORDS_ID = R.styleable.GuJEMSAdView_ems_kw;

	/**
	 * Global attribute name for identifying non-keywords to the request
	 */
	public final static String EMS_NKEYWORDS = AppContext.getContext()
			.getString(R.string.nkeyword);

	protected final static int EMS_NKEYWORDS_ID = R.styleable.GuJEMSAdView_ems_nkw;

	/**
	 * Global attribute name for allowing geo localization for a placement
	 */
	public final static String EMS_GEO = AppContext.getContext()
			.getString(R.string.geo);

	protected final static int EMS_GEO_ID = R.styleable.GuJEMSAdView_ems_geo;

	/**
	 * Global attribute name for the geographical latitude
	 */
	public final static String EMS_LAT = AppContext.getContext()
			.getString(R.string.latitude);

	protected final static int EMS_LAT_ID = R.styleable.GuJEMSAdView_ems_lat;

	/**
	 * Global attribute name for the geographical longitude
	 */
	public final static String EMS_LON = AppContext.getContext()
			.getString(R.string.longitude);

	protected final static int EMS_LON_ID = R.styleable.GuJEMSAdView_ems_lon;

	private final Map<String, String> attrsToParams;

	private final Map<String, String> paramValues;

	/**
	 * Constructor when creating the settings in an Android View
	 * 
	 * @param context
	 *            application context
	 * @param set
	 *            inflated layout parameters
	 */
	public AdServerSettingsAdapter(Context context, AttributeSet set) {
		this.paramValues = new HashMap<String, String>();
		this.attrsToParams = this.init(set);
	}

	/**
	 * Constructor when creating the settings from an Android Activity
	 * 
	 * @param context
	 *            application context
	 * @param savedInstance
	 *            saved instance state
	 */
	public AdServerSettingsAdapter(Context context, Bundle savedInstance) {
		this.paramValues = new HashMap<String, String>();
		this.attrsToParams = this.init(savedInstance);
	}

	@SuppressWarnings("unused")
	private AdServerSettingsAdapter() {
		this.paramValues = new HashMap<String, String>();
		this.attrsToParams = new HashMap<String, String>();
	}

	@Override
	public String getQueryString() {
		String qStr = "";
		Iterator<String> keys = getAttrsToParams().keySet().iterator();
		while (keys.hasNext()) {
			String key = keys.next();
			String val = paramValues.get(key);
			String param = attrsToParams.get(key);
			if (val != null) {
				SdkLog.d(TAG, "Adding: \"" + val + "\" as \"" + param + "\" for "
						+ key);
				qStr += "&" + param + "=" + val;
			}
		}
		return qStr;
	}

	protected final Map<String, String> init(AttributeSet attrs) {
		Map<String, String> map = new HashMap<String, String>();
		if (attrs != null) {
			for (int i = 0; i < attrs.getAttributeCount(); i++) {
				String attr = attrs.getAttributeName(i);
				if (attr != null
						&& attr.startsWith(AdServerSettingsAdapter.EMS_ATTRIBUTE_PREFIX)) {
					map.put(attr.substring(4), attr.substring(4));
					SdkLog.d(TAG, "Found AdView attribute " + attr.substring(4));
				}
			}
		}
		return map;
	}

	protected final Map<String, String> init(Bundle savedInstance) {

		Map<String, String> map = new HashMap<String, String>();
		if (savedInstance != null && !savedInstance.isEmpty()) {
			Iterator<String> iterator = savedInstance.keySet().iterator();
			while (iterator.hasNext()) {
				String key = iterator.next();
				if (key.startsWith(AdServerSettingsAdapter.EMS_ATTRIBUTE_PREFIX)) {
					map.put(key.substring(4), key.substring(4));
					SdkLog.d(TAG, "Found AdView attribute " + key.substring(4));
				}
			}
		}
		return map;
	}

	protected Map<String, String> getAttrsToParams() {
		return this.attrsToParams;
	}

	@Override
	public void putAttrValue(String attr, String value) {
		this.paramValues.put(attr, value);
	}

	@Override
	public void putAttrToParam(String attr, String param) {
		this.attrsToParams.put(attr, param);
	}

	@Override
	public String getRequestUrl() {
		return getBaseUrlString() + getBaseQueryString() + getQueryString();
	};

	private final String md5Hash(String str) {
		MessageDigest md = null;
		String result = new String();
		try {
			md = java.security.MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return str;
		}
		md.reset();
		md.update(str.getBytes());
		byte[] digest = md.digest();
		for (int i = 0; i < digest.length; i++) {
			String hex = Integer.toHexString(0xFF & digest[i]);
			if (hex.length() == 1) {
				result = result + '0';
			}
			result = result + hex;
		}
		return result;
	}

	@Override
	public String getDeviceId() {
		return md5Hash(Secure.ANDROID_ID);
	}

	/**
	 * Gets the location.
	 *
	 * @return the location
	 */
	protected double [] getLocation() {
		LocationManager lm = (LocationManager) AppContext.getContext()
				.getSystemService(Context.LOCATION_SERVICE);
		List<String> providers = lm.getProviders(true);
		Iterator<String> provider = providers.iterator();
		Location lastKnown = null;
		double [] loc = new double[2];
		long age = 0;
		while (provider.hasNext()) {
			lastKnown = lm.getLastKnownLocation(provider.next());
			if (lastKnown != null) {
				age = System.currentTimeMillis() - lastKnown.getTime();
				if (age <= EMS_LOCATION_MAXAGE_MS) {
					break;
				}
				else {
					SdkLog.d(TAG, "Location [" + lastKnown.getProvider() + "] is " + (age / 60000) + " min old. [max = " + EMS_LOCATION_MAXAGE_MIN + "]");
				}
			}
		}

		if (lastKnown != null && age <= EMS_LOCATION_MAXAGE_MS) {
			loc[0] = lastKnown.getLatitude();
			loc[1] = lastKnown.getLongitude();
			SdkLog.i(TAG, "Location [" + lastKnown.getProvider() + "] is " + loc[0] + "x" + loc[1]);
			return loc;
		}

		return null;
	}

	@Override
	public void addCustomRequestParameter(String param, String value) {
		putAttrToParam(param, param);
		putAttrValue(param, value);
	}

	@Override
	public void addCustomRequestParameter(String param, int value) {
		addCustomRequestParameter(param, String.valueOf(value));
	}

	@Override
	public void addCustomRequestParameter(String param, double value) {
		addCustomRequestParameter(param, String.valueOf(value));
	}

}

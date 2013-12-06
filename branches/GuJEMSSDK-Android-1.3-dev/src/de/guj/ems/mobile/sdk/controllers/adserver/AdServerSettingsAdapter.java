package de.guj.ems.mobile.sdk.controllers.adserver;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import android.content.Context;
import android.content.res.TypedArray;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.AttributeSet;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.AdViewConfiguration;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.controllers.backfill.BackfillDelegator;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;

/**
 * Base class for mapping various available data to adserver parameters.
 * 
 * @see de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter
 * 
 * @author stein16
 * 
 */
public abstract class AdServerSettingsAdapter implements
		IAdServerSettingsAdapter {

	private static final long serialVersionUID = 314048983271226769L;

	private final static DecimalFormat TWO_DIGITS_DECIMAL = new DecimalFormat(
			"#.##");

	protected final static long EMS_LOCATION_MAXAGE_MS = 7200000;
	
	protected final static long EMS_LOCATION_MAXAGE_MIN = EMS_LOCATION_MAXAGE_MS / 60000;

	public final static String EMS_ATTRIBUTE_PREFIX = SdkUtil.getContext()
			.getString(R.string.attributePrefix);
	
	private final static String EMS_LISTENER_PREFIX = EMS_ATTRIBUTE_PREFIX
			+ "onAd";

	/**
	 * Global attribute name for listener which reacts to empty ad
	 */
	private final static String EMS_ERROR_LISTENER = SdkUtil.getContext()
			.getString(R.string.onAdError);

	/**
	 * Global attribute name for listener which reacts to empty ad
	 */
	private final static String EMS_EMPTY_LISTENER = SdkUtil.getContext()
			.getString(R.string.onAdEmpty);

	/**
	 * Global attribute name for allowing geo localization for a placement
	 */
	public final static String EMS_GEO = SdkUtil.getContext().getString(
			R.string.geo);

	/**
	 * Global attribute name for identifying keywords add to the request
	 */
	public final static String EMS_KEYWORDS = SdkUtil.getContext().getString(
			R.string.keyword);

	/**
	 * Global attribute name for the geographical latitude
	 */
	public final static String EMS_LAT = SdkUtil.getContext().getString(
			R.string.latitude);
	/**
	 * Global attribute name for the geographical longitude
	 */
	public final static String EMS_LON = SdkUtil.getContext().getString(
			R.string.longitude);

	/**
	 * Global attribute name for identifying non-keywords to the request
	 */
	public final static String EMS_NKEYWORDS = SdkUtil.getContext().getString(
			R.string.nkeyword);

	/**
	 * Global attribute name for identifying a site
	 */
	public final static String EMS_SITEID = SdkUtil.getContext().getString(
			R.string.siteId);

	/**
	 * Global attribute name for identifying a site for backfill
	 */
	public final static String EMS_BACKFILL_SITEID = SdkUtil.getContext()
			.getString(R.string.backfillSiteId);

	private final static String EMS_SUCCESS_LISTENER = SdkUtil.getContext()
			.getString(R.string.onAdSuccess);

	/**
	 * Global attribute name for identifying a unique user/device id
	 */
	public final static String EMS_UUID = SdkUtil.getContext().getString(
			R.string.deviceId);

	/**
	 * Global attribute name for identifying a placement
	 */
	public final static String EMS_ZONEID = SdkUtil.getContext().getString(
			R.string.zoneId);

	/**
	 * Global attribute name for identifying a placement for backfill
	 */
	public final static String EMS_BACKFILL_ZONEID = SdkUtil.getContext()
			.getString(R.string.backfillZoneId);


	private final static String EMS_SECURITY_HEADER_NAME = SdkUtil.getContext()
			.getString(R.string.securityHeaderName);

	private final static String TAG = "AdServerSettingsAdapter";

	private final Map<String, String> attrsToParams;

	private BackfillDelegator.BackfillData directBackfill;

	private IOnAdEmptyListener onAdEmptyListener = null;

	private IOnAdSuccessListener onAdSuccessListener = null;

	private IOnAdErrorListener onAdErrorListener = null;

	private final Map<String, String> paramValues;
	
	private Context context;
	
	protected Class<?> viewClass;

	@SuppressWarnings("unused")
	private AdServerSettingsAdapter() {
		this.context = null;
		this.viewClass = null;
		this.paramValues = new HashMap<String, String>();
		this.attrsToParams = new HashMap<String, String>();
	}

	/**
	 * Constructor when creating the settings in an Android View
	 * 
	 * @param context
	 *            application context
	 * @param set
	 *            inflated layout parameters
	 */
	public AdServerSettingsAdapter(Context context, AttributeSet set, Class<?> viewClass) {
		this.context = context;
		this.viewClass = viewClass;
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
	public AdServerSettingsAdapter(Context context, Bundle savedInstance, Class<?> viewClass) {
		this.context = context;
		this.viewClass = viewClass;
		this.paramValues = new HashMap<String, String>();
		this.attrsToParams = this.init(savedInstance);
	}

	@Override
	public void addCustomRequestParameter(String param, double value) {
		addCustomRequestParameter(param, String.valueOf(value));
	}

	@Override
	public void addCustomRequestParameter(String param, int value) {
		addCustomRequestParameter(param, String.valueOf(value));
	}

	@Override
	public void addCustomRequestParameter(String param, String value) {
		putAttrToParam(param, param);
		putAttrValue(param, value);
	}

	private final void createEmptyListener(final String lMethodName) {
		this.onAdEmptyListener = new IOnAdEmptyListener() {

			private static final long serialVersionUID = 1L;

			@Override
			public void onAdEmpty() {
				try {
					Class<?>[] noParams = null;
					Object[] noArgs = null;
					Method lMethod = context.getClass()
							.getMethod(lMethodName, noParams);
					lMethod.invoke(context, noArgs);
				} catch (NoSuchMethodException nsme) {
					SdkLog.e(TAG, "OnAdEmptyListener " + lMethodName
							+ " not found. Check your xml.", nsme);

				} catch (InvocationTargetException ivte) {
					SdkLog.e(TAG, "OnAdEmptyListener could not be invoked",
							ivte);
				} catch (IllegalAccessException iae) {
					SdkLog.e(TAG, "OnAdEmptyListener could not be accessed",
							iae);
				}

			}
		};
		SdkLog.d(TAG, "Created onEmptyListener \"" + lMethodName + "\"");
	}

	private final void createEmptyListener(final Object listener) {
		try {
			this.onAdEmptyListener = (IOnAdEmptyListener) listener;
		} catch (Exception e) {
			SdkLog.e(TAG, "Error setting onAdEmptyListener", e);
		}
	}

	private final void createErrorListener(final Object listener) {
		try {
			this.onAdErrorListener = (IOnAdErrorListener) listener;
		} catch (Exception e) {
			SdkLog.e(TAG, "Error setting onAdErrorListener", e);
		}
	}

	private final void createSuccessListener(final Object listener) {
		try {
			this.onAdSuccessListener = (IOnAdSuccessListener) listener;
		} catch (Exception e) {
			SdkLog.e(TAG, "Error setting onAdSuccessListener", e);
		}
	}

	private final void createSuccessListener(final String lMethodName) {
		this.onAdSuccessListener = new IOnAdSuccessListener() {

			private static final long serialVersionUID = 2L;

			@Override
			public void onAdSuccess() {
				try {
					Class<?>[] noParams = null;
					Object[] noArgs = null;
					Method lMethod = context.getClass()
							.getMethod(lMethodName, noParams);
					lMethod.invoke(context, noArgs);
				} catch (NoSuchMethodException nsme) {
					SdkLog.e(TAG, "OnAdSuccessListener " + lMethodName
							+ " not found. Check your xml.", nsme);

				} catch (InvocationTargetException ivte) {
					SdkLog.e(TAG, "OnAdSuccessListener could not be invoked",
							ivte);
				} catch (IllegalAccessException iae) {
					SdkLog.e(TAG, "OnAdSuccessListener could not be accessed",
							iae);
				}

			}
		};
		SdkLog.d(TAG, "Created onSuccessListener \"" + lMethodName + "\"");
	}

	private final void createErrorListener(final String lMethodName) {
		this.onAdErrorListener = new IOnAdErrorListener() {

			private static final long serialVersionUID = 3L;

			@Override
			public void onAdError(String msg, Throwable t) {
				try {
					Method lMethod = context
							.getClass()
							.getMethod(lMethodName, String.class,
									Throwable.class);
					lMethod.invoke(context, msg, t);
				} catch (NoSuchMethodException nsme) {
					SdkLog.e(TAG, "OnAdErrorListener " + lMethodName
							+ " not found. Check your xml.", nsme);

				} catch (InvocationTargetException ivte) {
					SdkLog.e(TAG, "OnAdErrorListener could not be invoked",
							ivte);
				} catch (IllegalAccessException iae) {
					SdkLog.e(TAG, "OnAdErrorListener could not be accessed",
							iae);
				}

			}

			@Override
			public void onAdError(String msg) {
				try {
					Method lMethod = context.getClass()
							.getMethod(lMethodName, String.class);
					lMethod.invoke(context, msg);
				} catch (NoSuchMethodException nsme) {
					SdkLog.e(TAG, "OnAdErrorListener " + lMethodName
							+ " not found. Check your xml.", nsme);

				} catch (InvocationTargetException ivte) {
					SdkLog.e(TAG, "OnAdErrorListener could not be invoked",
							ivte);
				} catch (IllegalAccessException iae) {
					SdkLog.e(TAG, "OnAdErrorListener could not be accessed",
							iae);
				}

			}
		};
		SdkLog.d(TAG, "Created onErrorListener \"" + lMethodName + "\"");
	}

	protected Map<String, String> getAttrsToParams() {
		return this.attrsToParams;
	}

	@Override
	public String getCookieRepl() {
		return SdkUtil.getCookieReplStr();
	}

	/**
	 * Gets the location.
	 * 
	 * @return the location
	 */
	protected double[] getLocation() {
		LocationManager lm = (LocationManager) context
				.getSystemService(Context.LOCATION_SERVICE);
		List<String> providers = lm.getProviders(false);
		Iterator<String> provider = providers.iterator();
		Location lastKnown = null;
		double[] loc = new double[2];
		long age = 0;
		while (provider.hasNext()) {
			lastKnown = lm.getLastKnownLocation(provider.next());
			if (lastKnown != null) {
				age = System.currentTimeMillis() - lastKnown.getTime();
				if (age <= EMS_LOCATION_MAXAGE_MS) {
					break;
				} else {
					SdkLog.d(TAG, "Location [" + lastKnown.getProvider()
							+ "] is " + (age / 60000) + " min old. [max = "
							+ EMS_LOCATION_MAXAGE_MIN + "]");
				}
			}
		}

		if (lastKnown != null && age <= EMS_LOCATION_MAXAGE_MS) {
			loc[0] = lastKnown.getLatitude();
			loc[1] = lastKnown.getLongitude();

			if (context.getResources()
					.getBoolean(R.bool.ems_shorten_location)) {
				loc[0] = Double.valueOf(TWO_DIGITS_DECIMAL.format(loc[0]));
				loc[1] = Double.valueOf(TWO_DIGITS_DECIMAL.format(loc[1]));
				SdkLog.d(TAG, "Geo location shortened to two digits.");
			}

			SdkLog.i(TAG, "Location [" + lastKnown.getProvider() + "] is "
					+ loc[0] + "x" + loc[1]);
			return loc;
		}

		return null;
	}

	@Override
	public IOnAdEmptyListener getOnAdEmptyListener() {
		return this.onAdEmptyListener;
	};

	@Override
	public IOnAdSuccessListener getOnAdSuccessListener() {
		return this.onAdSuccessListener;
	}

	@Override
	public IOnAdErrorListener getOnAdErrorListener() {
		return this.onAdErrorListener;
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
				SdkLog.d(TAG, "Adding: \"" + val + "\" as \"" + param
						+ "\" for " + key);
				qStr += "&" + param + "=" + val;
			}
		}

		return qStr;
	}

	@Override
	public String getRequestUrl() {
		return getBaseUrlString() + getBaseQueryString() + getQueryString();
	}

	protected final Map<String, String> init(AttributeSet attrs) {
		Map<String, String> map = new HashMap<String, String>();
		if (attrs != null) {
			for (int i = 0; i < attrs.getAttributeCount(); i++) {
				String attr = attrs.getAttributeName(i);
				if (attr != null
						&& attr.startsWith(AdServerSettingsAdapter.EMS_ATTRIBUTE_PREFIX)) {
					if (attr.startsWith(AdServerSettingsAdapter.EMS_LISTENER_PREFIX)) {
						String lName = attr.substring(4);
						TypedArray tVals = viewClass.equals(GuJEMSAdView.class) ? context
								.obtainStyledAttributes(attrs,
										R.styleable.GuJEMSAdView) : context
										.obtainStyledAttributes(attrs,
												R.styleable.GuJEMSNativeAdView);
						if (lName
								.equals(AdServerSettingsAdapter.EMS_SUCCESS_LISTENER)) {
							createSuccessListener(tVals
									.getString(AdViewConfiguration.getConfig(viewClass).getSuccessListenerId()));
						} else if (lName
								.equals(AdServerSettingsAdapter.EMS_EMPTY_LISTENER)) {
							createEmptyListener(tVals
									.getString(AdViewConfiguration.getConfig(viewClass).getEmptyListenerId()));
						} else if (lName
								.equals(AdServerSettingsAdapter.EMS_ERROR_LISTENER)) {
							createErrorListener(tVals
									.getString(AdViewConfiguration.getConfig(viewClass).getErrorListenerId()));
						}

						else {
							SdkLog.w(TAG, "Unknown listener type name: "
									+ lName);
						}
						tVals.recycle();

					} else {
						map.put(attr.substring(4), attr.substring(4));
						SdkLog.d(TAG,
								"Found AdView attribute " + attr.substring(4));
					}

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
					if (key.startsWith(AdServerSettingsAdapter.EMS_LISTENER_PREFIX)) {
						String lName = key.substring(4);
						if (lName
								.equals(AdServerSettingsAdapter.EMS_SUCCESS_LISTENER)) {
							Object l = savedInstance
									.get(AdServerSettingsAdapter.EMS_ATTRIBUTE_PREFIX
											+ AdServerSettingsAdapter.EMS_SUCCESS_LISTENER);
							if (String.class.equals(l.getClass())) {
								createSuccessListener((String) l);
							} else {
								createSuccessListener(l);
							}
						} else if (lName
								.equals(AdServerSettingsAdapter.EMS_EMPTY_LISTENER)) {
							Object l = savedInstance
									.get(AdServerSettingsAdapter.EMS_ATTRIBUTE_PREFIX
											+ AdServerSettingsAdapter.EMS_EMPTY_LISTENER);
							if (String.class.equals(l.getClass())) {
								createEmptyListener((String) l);
							} else {
								createEmptyListener(l);
							}
						} else if (lName
								.equals(AdServerSettingsAdapter.EMS_ERROR_LISTENER)) {
							Object l = savedInstance
									.get(AdServerSettingsAdapter.EMS_ATTRIBUTE_PREFIX
											+ AdServerSettingsAdapter.EMS_ERROR_LISTENER);
							if (String.class.equals(l.getClass())) {
								createErrorListener((String) l);
							} else {
								createErrorListener(l);
							}
						} else {
							SdkLog.w(TAG, "Unknown listener type name: "
									+ lName);
						}
					} else {
						map.put(key.substring(4), key.substring(4));
						SdkLog.d(TAG,
								"Found AdView attribute " + key.substring(4));
					}

				}
			}
		}
		return map;
	}

	@Override
	public void putAttrToParam(String attr, String param) {
		this.attrsToParams.put(attr, param);
	}

	@Override
	public void putAttrValue(String attr, String value) {
		this.paramValues.put(attr, value);
	}

	@Override
	public void setOnAdEmptyListener(IOnAdEmptyListener l) {
		this.onAdEmptyListener = l;
	}

	@Override
	public void setOnAdSuccessListener(IOnAdSuccessListener l) {
		this.onAdSuccessListener = l;

	}

	@Override
	public void setOnAdErrorListener(IOnAdErrorListener l) {
		this.onAdErrorListener = l;

	}

	@Override
	public BackfillDelegator.BackfillData getDirectBackfill() {
		return directBackfill;
	}

	@Override
	public void setDirectBackfill(BackfillDelegator.BackfillData directBackfill) {
		this.directBackfill = directBackfill;
	}

	@Override
	public String getSecurityHeaderName() {
		return EMS_SECURITY_HEADER_NAME;
	}

	@Override
	public void addCustomParams(Map<String, ?> params) {
		if (params != null) {
			Iterator<String> mi = params.keySet().iterator();
			while (mi.hasNext()) {
				String param = mi.next();
				Object value = params.get(param);
				if (value.getClass().equals(String.class)) {
					addCustomRequestParameter(param,
							(String) value);
				} else if (value.getClass().equals(Double.class)) {
					addCustomRequestParameter(param,
							((Double) value).doubleValue());
				} else if (value.getClass().equals(Integer.class)) {
					addCustomRequestParameter(param,
							((Integer) value).intValue());
				} else {
					SdkLog.e(TAG,
							"Unknown object in custom params. Only String, Integer, Double allowed.");
				}
			}
		} else {
			SdkLog.w(TAG, "Custom params constructor used with null-array.");
		}		
	}


	
}

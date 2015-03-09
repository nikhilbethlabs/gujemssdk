package de.guj.ems.mobile.sdk.controllers.adserver;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.json.JSONArray;

import android.content.Context;
import android.content.res.TypedArray;
import android.os.Bundle;
import android.util.AttributeSet;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.AdViewConfiguration;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.controllers.backfill.BackfillDelegator;
import de.guj.ems.mobile.sdk.util.SdkGlobals;
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
abstract class AdServerSettingsAdapter implements IAdServerSettingsAdapter {

	private final static String TAG = "AdServerSettingsAdapter";

	private String queryAppendix;

	private Map<String, String> attrsToParams;

	private BackfillDelegator.BackfillData directBackfill;

	private IOnAdEmptyListener onAdEmptyListener = null;

	private IOnAdSuccessListener onAdSuccessListener = null;

	private IOnAdErrorListener onAdErrorListener = null;

	private Map<String, String> paramValues;

	private JSONArray regExps;

	private transient Class<?> viewClass;

	private boolean processed;

	public AdServerSettingsAdapter() {
		this.viewClass = null;
		this.paramValues = null;
		this.attrsToParams = null;
		this.processed = false;
	}

	@Override
	public void addCustomParams(Map<String, ?> params) {
		if (params != null) {
			Iterator<String> mi = params.keySet().iterator();
			while (mi.hasNext()) {
				String param = mi.next();
				Object value = params.get(param);
				if (value.getClass().equals(String.class)) {
					addCustomRequestParameter(param, (String) value);
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

	@Override
	public void addQueryAppendix(String str) {
		if (this.queryAppendix != null) {
			this.queryAppendix = this.queryAppendix.concat(str);
		} else {
			this.queryAppendix = str;
		}
	}

	@Override
	public void addRegexp(JSONArray regexp) {
		this.regExps = regexp;
	}

	private final void createEmptyListener(final Context context,
			final String lMethodName) {
		this.onAdEmptyListener = new IOnAdEmptyListener() {

			private static final long serialVersionUID = 1L;

			@Override
			public void onAdEmpty() {
				try {
					Class<?>[] noParams = null;
					Object[] noArgs = null;
					Method lMethod = context.getClass().getMethod(lMethodName,
							noParams);
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

	private final void createErrorListener(final Context context,
			final String lMethodName) {
		this.onAdErrorListener = new IOnAdErrorListener() {

			private static final long serialVersionUID = 3L;

			@Override
			public void onAdError(String msg) {
				try {
					Method lMethod = context.getClass().getMethod(lMethodName,
							String.class);
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

			@Override
			public void onAdError(String msg, Throwable t) {
				try {
					Method lMethod = context.getClass().getMethod(lMethodName,
							String.class, Throwable.class);
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
		};
		SdkLog.d(TAG, "Created onErrorListener \"" + lMethodName + "\"");
	}

	private final void createErrorListener(final Object listener) {
		try {
			this.onAdErrorListener = (IOnAdErrorListener) listener;
		} catch (Exception e) {
			SdkLog.e(TAG, "Error setting onAdErrorListener", e);
		}
	}

	private final void createSuccessListener(final Context context,
			final String lMethodName) {
		this.onAdSuccessListener = new IOnAdSuccessListener() {

			private static final long serialVersionUID = 2L;

			@Override
			public void onAdSuccess() {
				try {
					Class<?>[] noParams = null;
					Object[] noArgs = null;

					Method lMethod = context.getClass().getMethod(lMethodName,
							noParams);
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

	private final void createSuccessListener(final Object listener) {
		try {
			this.onAdSuccessListener = (IOnAdSuccessListener) listener;
		} catch (Exception e) {
			SdkLog.e(TAG, "Error setting onAdSuccessListener", e);
		}
	};

	@Override
	public void dontProcess() {
		this.processed = true;
	}

	@Override
	public boolean doProcess() {
		return !this.processed;
	}

	protected Map<String, String> getAttrsToParams() {
		return this.attrsToParams;
	}

	@Override
	public String getCookieRepl() {
		return SdkUtil.getCookieReplStr();
	}

	@Override
	public BackfillDelegator.BackfillData getDirectBackfill() {
		return directBackfill;
	}

	@Override
	public IOnAdEmptyListener getOnAdEmptyListener() {
		return this.onAdEmptyListener;
	}

	@Override
	public IOnAdErrorListener getOnAdErrorListener() {
		return this.onAdErrorListener;
	}

	@Override
	public IOnAdSuccessListener getOnAdSuccessListener() {
		return this.onAdSuccessListener;
	}

	@Override
	public Map<String, String> getParams() {
		return this.paramValues;
	}

	@Override
	public String getQueryAppendix() {
		return this.queryAppendix;
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

		if (regExps != null) {
			String backup = qStr;
			try {
				for (int i = 0; i < regExps.length(); i++) {
					JSONArray regexpn = regExps.getJSONArray(i);
					if (regexpn.length() > 1) {
						qStr = qStr.replaceAll(regexpn.getString(0),
								regexpn.getString(1));
					} else {
						SdkLog.w(TAG, "No valid regular expression found in "
								+ regExps);
					}
				}
			} catch (Exception e) {
				SdkLog.e(TAG,
						"Error applying regular expressions to query string.",
						e);
				return backup;
			}
		}

		return qStr;
	}

	@Override
	public String getRequestUrl() {
		String query = getBaseQueryString();
		String app = getQueryAppendix();
		return getBaseUrlString() + (query != null ? query : "")
				+ getQueryString() + (app != null ? app : "");
	}

	private final Map<String, String> init(Bundle savedInstance) {

		Map<String, String> map = new HashMap<String, String>();
		if (savedInstance != null && !savedInstance.isEmpty()) {
			Iterator<String> iterator = savedInstance.keySet().iterator();
			while (iterator.hasNext()) {
				String key = iterator.next();
				if (key.startsWith(SdkGlobals.EMS_ATTRIBUTE_PREFIX)) {
					if (key.startsWith(SdkGlobals.EMS_LISTENER_PREFIX)) {
						String lName = key.substring(4);
						if (lName.equals(SdkGlobals.EMS_SUCCESS_LISTENER)) {
							Object l = savedInstance
									.get(SdkGlobals.EMS_ATTRIBUTE_PREFIX
											+ SdkGlobals.EMS_SUCCESS_LISTENER);
							if (String.class.equals(l.getClass())) {
								createSuccessListener(l);
							} else {
								createSuccessListener(l);
							}
						} else if (lName.equals(SdkGlobals.EMS_EMPTY_LISTENER)) {
							Object l = savedInstance
									.get(SdkGlobals.EMS_ATTRIBUTE_PREFIX
											+ SdkGlobals.EMS_EMPTY_LISTENER);
							if (String.class.equals(l.getClass())) {
								createEmptyListener(l);
							} else {
								createEmptyListener(l);
							}
						} else if (lName.equals(SdkGlobals.EMS_ERROR_LISTENER)) {
							Object l = savedInstance
									.get(SdkGlobals.EMS_ATTRIBUTE_PREFIX
											+ SdkGlobals.EMS_ERROR_LISTENER);
							if (String.class.equals(l.getClass())) {
								createErrorListener(l);
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

	private final Map<String, String> init(Context context, AttributeSet attrs) {
		Map<String, String> map = new HashMap<String, String>();
		if (attrs != null) {
			for (int i = 0; i < attrs.getAttributeCount(); i++) {
				String attr = attrs.getAttributeName(i);
				if (attr != null
						&& attr.startsWith(SdkGlobals.EMS_ATTRIBUTE_PREFIX)) {
					if (attr.startsWith(SdkGlobals.EMS_LISTENER_PREFIX)) {
						String lName = attr.substring(4);
						TypedArray tVals = viewClass.equals(GuJEMSAdView.class) ? context
								.obtainStyledAttributes(attrs,
										R.styleable.GuJEMSAdView) : context
								.obtainStyledAttributes(attrs,
										R.styleable.GuJEMSNativeAdView);
						if (lName.equals(SdkGlobals.EMS_SUCCESS_LISTENER)) {
							createSuccessListener(context,
									tVals.getString(AdViewConfiguration
											.getConfig(viewClass)
											.getSuccessListenerId()));
						} else if (lName.equals(SdkGlobals.EMS_EMPTY_LISTENER)) {
							createEmptyListener(context,
									tVals.getString(AdViewConfiguration
											.getConfig(viewClass)
											.getEmptyListenerId()));
						} else if (lName.equals(SdkGlobals.EMS_ERROR_LISTENER)) {
							createErrorListener(context,
									tVals.getString(AdViewConfiguration
											.getConfig(viewClass)
											.getErrorListenerId()));
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

	@Override
	public void putAttrToParam(String attr, String param) {
		this.attrsToParams.put(attr, param);
	}

	@Override
	public void putAttrValue(String attr, String value) {
		this.paramValues.put(attr, value);
	}

	@Override
	public void setDirectBackfill(BackfillDelegator.BackfillData directBackfill) {
		this.directBackfill = directBackfill;
	}

	@Override
	public void setOnAdEmptyListener(IOnAdEmptyListener l) {
		this.onAdEmptyListener = l;
	}

	@Override
	public void setOnAdErrorListener(IOnAdErrorListener l) {
		this.onAdErrorListener = l;

	}

	@Override
	public void setOnAdSuccessListener(IOnAdSuccessListener l) {
		this.onAdSuccessListener = l;

	}

	/**
	 * Constructor when creating the settings in an Android View
	 * 
	 * @param context
	 *            application context
	 * @param set
	 *            inflated layout parameters
	 */
	void setup(Context context, AttributeSet set, Class<?> viewClass) {
		if (SdkUtil.getContext() == null) {
			SdkUtil.setContext(context);
		}

		this.viewClass = viewClass;
		this.paramValues = new HashMap<String, String>();
		this.attrsToParams = this.init(context, set);
	}

	/**
	 * Constructor when creating the settings from an Android Activity
	 * 
	 * @param context
	 *            application context
	 * @param savedInstance
	 *            saved instance state
	 */
	void setup(Context context, Bundle savedInstance, Class<?> viewClass) {
		if (SdkUtil.getContext() == null) {
			SdkUtil.setContext(context);
		}
		this.viewClass = viewClass;
		this.paramValues = new HashMap<String, String>();
		this.attrsToParams = this.init(savedInstance);
	}

	@Override
	public String toString() {
		return getQueryString();
	}
}

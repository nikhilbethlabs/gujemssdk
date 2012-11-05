package de.guj.ems.mobile.sdk.views;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;

import org.ormma.view.OrmmaView;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Xml;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import de.guj.ems.mobile.sdk.controllers.AdServerAccess;
import de.guj.ems.mobile.sdk.controllers.AmobeeSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.EMSInterface;
import de.guj.ems.mobile.sdk.controllers.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.util.Connectivity;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.UserAgentHelper;

/**
 * The webview uses as container to display an ad. Derived from the ORMMA
 * refernce implementaton of an ad view container.
 * 
 * This class adds folowing capabilites to the reference implementation:
 * - loading data with an asynchronous HTTP request
 * - initializing the view from XML by passing a resource ID
 * - adding custom view-specific parameters to a placement's ad request (runtime)
 * - adding matching or non-matching keywords to a placement's ad request (runtime)
 * - adding the javascript interface EMSInterface to the view
 * 
 * ONLY USE THIS CLASS IF YOU WANT TO ADD THE VIEW PROGRAMMATICALLY INSTEAD
 * OF DEFINING IT WITHIN A LAYOUT.XML FILE!
 * 
 * @author stein16
 *
 */
public class GuJEMSAdView extends OrmmaView implements OnGlobalLayoutListener {

	private IAdServerSettingsAdapter settings;

	private final String TAG = "GuJEMSAdView";

	/**
	 * Initialize view without configuration 
	 * @param context android application context
	 */
	public GuJEMSAdView(Context context) {
		super(context);
		this.preLoadInitialize(context, null);
	}

	/**
	 * Initialize view with attribute set (this is the common constructor)
	 * @param context android application context
	 * @param resId resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, AttributeSet set) {
		super(context, set);
		this.preLoadInitialize(context, set);
		this.load();
	}

	/**
	 * Initialize view from XML
	 * @param context android application context
	 * @param resId resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, int resId) {
		super(context);
		this.preLoadInitialize(context, inflate(resId));
		this.load();
	}

	/**
	 * Initialize view from XML and add any custom parameters to the request
	 * @param context android application context
	 * @param customParams map of custom param names and thiur values
	 * @param resId resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, Map<String, ?> customParams, int resId) {
		super(context);
		this.preLoadInitialize(context, inflate(resId));
		this.addCustomParams(customParams);
		this.load();
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords as
	 * well as any custom parameters to the request
	 * @param context android application context
	 * @param customParams map of custom param names and thiur values
	 * @param kws matching keywords
	 * @param nkws non-matching keywords
	 * @param resId resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, Map<String, ?> customParams,
			String[] kws, String nkws[], int resId) {
		super(context);
		this.preLoadInitialize(context, inflate(resId), kws, nkws);
		this.addCustomParams(customParams);
		this.load();
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords
	 * @param context android application context
	 * @param kws matching keywords
	 * @param nkws non-matching keywords
	 * @param resId resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, String[] kws, String nkws[], int resId) {
		super(context);
		this.preLoadInitialize(context, inflate(resId), kws, nkws);
		this.load();
	}

	private void addCustomParams(Map<String, ?> params) {
		Iterator<String> mi = params.keySet().iterator();
		while (mi.hasNext()) {
			String param = mi.next();
			Object value = params.get(param);
			if (value.getClass().equals(String.class)) {
				this.settings.addCustomRequestParameter(param, (String) value);
			} else if (value.getClass().equals(Double.class)) {
				this.settings.addCustomRequestParameter(param,
						((Double) value).doubleValue());
			} else if (value.getClass().equals(Integer.class)) {
				this.settings.addCustomRequestParameter(param,
						((Integer) value).intValue());
			} else {
				SdkLog.e(TAG,
						"Unknown object in custom params. Only String, Integer, Double allowed.");
			}
		}
	}

	private AttributeSet inflate(int resId) {
		AttributeSet as = null;
		Resources r = getResources();
		XmlResourceParser parser = r.getLayout(resId);

		int state = 0;
		do {
			try {
				state = parser.next();
			} catch (XmlPullParserException e1) {
				e1.printStackTrace();
			} catch (IOException e1) {
				e1.printStackTrace();
			}
			if (state == XmlPullParser.START_TAG) {
				if (parser.getName().equals(
						"de.guj.ems.mobile.sdk.views.GuJEMSAdView")) {
					as = Xml.asAttributeSet(parser);
					break;
				} else {
					SdkLog.d(TAG, parser.getName());
				}
			}
		} while (state != XmlPullParser.END_DOCUMENT);

		return as;
	}

	private final void load() {

		if (settings != null) {

			// Construct request URL
			final String url = this.settings.getRequestUrl();
			// Run off main UI thread if Android > 4.0
			if (Connectivity.isOnline() && Build.VERSION.SDK_INT > 10) {
				
				SdkLog.i(TAG, "ems_adcall: START async. AdServer request");
				SdkLog.d(TAG, "ems_adcall: url = " + url);
				AdServerAccess mAdFetcher = (AdServerAccess) (new AdServerAccess(
						UserAgentHelper.getUserAgent()))
						.execute(new String[] { url });
				try {
					loadData(mAdFetcher.get(), "text/html", "utf-8");
					setTimeoutRunnable(new TimeOutRunnable());					
				} catch (Exception e) {
					SdkLog.e(TAG, "Error loading ads...", e);
				}
				SdkLog.i(TAG, "ems_adcall: FINISH async. AdServer request");
			}
			// default behaviour Android < 4.0
			else if (Connectivity.isOnline()) {
				this.loadUrl(url);
			}
			// Do nothing if offline
			else if (Connectivity.isOffline()) {
				SdkLog.i(TAG,
						"ems_adcall: No network connection - not requesting ads.");
			}
		}
	}

	private void preLoadInitialize(Context context, AttributeSet set) {
		this.addJavascriptInterface(new EMSInterface(), "emsmobile");
		if (set != null) {
			this.settings = new AmobeeSettingsAdapter(context, set);
		}
	}

	private void preLoadInitialize(Context context, AttributeSet set,
			String[] kws, String[] nkws) {
		this.addJavascriptInterface(new EMSInterface(), "emsmobile");
		if (set != null) {
			this.settings = new AmobeeSettingsAdapter(context, set, kws, nkws);
		}
	}

}

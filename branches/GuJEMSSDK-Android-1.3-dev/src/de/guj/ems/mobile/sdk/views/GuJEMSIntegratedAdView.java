package de.guj.ems.mobile.sdk.views;

import java.io.IOException;
import java.util.Map;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.graphics.Color;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Xml;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.IAdResponseHandler;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.controllers.adserver.AmobeeSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdResponse;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;

public class GuJEMSIntegratedAdView extends RelativeLayout implements IAdResponseHandler {

	private static final long serialVersionUID = -9099438955013226163L;

	private transient Handler handler = new Handler();

	private boolean testMode = false;

	private transient IAdServerSettingsAdapter settings;

	private final String TAG = "GuJEMSIntegratedAdView";
	
	/**
	 * Initialize view without configuration
	 * 
	 * @param context
	 *            android application context
	 */
	public GuJEMSIntegratedAdView(Context context) {
		super(context);
		this.preLoadInitialize(context, null);
	}

	/**
	 * Initialize view with attribute set (this is the common constructor)
	 * 
	 * @param context
	 *            android application context
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSIntegratedAdView(Context context, AttributeSet set) {
		this(context, set, true);
	}

	/**
	 * Initialize view with attribute set (this is the common constructor)
	 * 
	 * @param context
	 *            android application context
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 * @param load
	 *            if set to true, the adview loads implicitly, if false, call
	 *            load by yourself
	 */
	public GuJEMSIntegratedAdView(Context context, AttributeSet set, boolean load) {
		super(context, set);
		this.preLoadInitialize(context, set);
		if (load) {
			this.load();
		}
	}

	/**
	 * Initialize view from XML
	 * 
	 * @param context
	 *            android application context
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSIntegratedAdView(Context context, int resId) {
		this(context, resId, true);
	}

	/**
	 * Initialize view from XML
	 * 
	 * @param context
	 *            android application context
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 * @param load
	 *            if set to true, the adview loads implicitly, if false, call
	 *            load by yourself
	 */
	public GuJEMSIntegratedAdView(Context context, int resId, boolean load) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs);
		this.handleInflatedLayout(attrs);
		if (load) {
			this.load();
		}
	}

	/**
	 * Initialize view from XML and add any custom parameters to the request
	 * 
	 * @param context
	 *            android application context
	 * @param customParams
	 *            map of custom param names and thiur values
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSIntegratedAdView(Context context, Map<String, ?> customParams, int resId) {
		this(context, customParams, resId, true);
	}

	/**
	 * Initialize view from XML and add any custom parameters to the request
	 * 
	 * @param context
	 *            android application context
	 * @param customParams
	 *            map of custom param names and thiur values
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 * @param load
	 *            if set to true, the adview loads implicitly, if false, call
	 *            load by yourself
	 */
	public GuJEMSIntegratedAdView(Context context, Map<String, ?> customParams,
			int resId, boolean load) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs);
		this.settings.addCustomParams(customParams);
		this.handleInflatedLayout(attrs);
		if (load) {
			this.load();
		}
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords as
	 * well as any custom parameters to the request
	 * 
	 * @param context
	 *            android application context
	 * @param customParams
	 *            map of custom param names and their values
	 * @param kws
	 *            matching keywords
	 * @param nkws
	 *            non-matching keywords
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSIntegratedAdView(Context context, Map<String, ?> customParams,
			String[] kws, String nkws[], int resId) {
		this(context, customParams, kws, nkws, resId, true);
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords as
	 * well as any custom parameters to the request
	 * 
	 * @param context
	 *            android application context
	 * @param customParams
	 *            map of custom param names and their values
	 * @param kws
	 *            matching keywords
	 * @param nkws
	 *            non-matching keywords
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 * @param load
	 *            if set to true, the adview loads implicitly, if false, call
	 *            load by yourself
	 */
	public GuJEMSIntegratedAdView(Context context, Map<String, ?> customParams,
			String[] kws, String nkws[], int resId, boolean load) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs, kws, nkws);
		this.settings.addCustomParams(customParams);
		this.handleInflatedLayout(attrs);
		if (load) {
			this.load();
		}
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords
	 * 
	 * @param context
	 *            android application context
	 * @param kws
	 *            matching keywords
	 * @param nkws
	 *            non-matching keywords
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSIntegratedAdView(Context context, String[] kws, String nkws[], int resId) {
		this(context, kws, nkws, resId, true);
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords
	 * 
	 * @param context
	 *            android application context
	 * @param kws
	 *            matching keywords
	 * @param nkws
	 *            non-matching keywords
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 * @param load
	 *            if set to true, the adview loads implicitly, if false, call
	 *            load by yourself
	 */
	public GuJEMSIntegratedAdView(Context context, String[] kws, String nkws[],
			int resId, boolean load) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs, kws, nkws);
		this.handleInflatedLayout(attrs);
		if (load) {
			this.load();
		}
	}
	
	private void handleInflatedLayout(AttributeSet attrs) {
		int w = attrs.getAttributeIntValue(
				"http://schemas.android.com/apk/res/android", "layout_width",
				ViewGroup.LayoutParams.MATCH_PARENT);
		int h = attrs.getAttributeIntValue(
				"http://schemas.android.com/apk/res/android", "layout_height",
				ViewGroup.LayoutParams.WRAP_CONTENT);
		String bk = attrs.getAttributeValue(
				"http://schemas.android.com/apk/res/android", "background");
		if (getLayoutParams() != null) {
			getLayoutParams().width = w;
			getLayoutParams().height = h;
		} else {
			setLayoutParams(getNewLayoutParams(w, h));
		}

		if (bk != null) {
			setBackgroundColor(Color.parseColor(bk));
		}
	}

	public ViewGroup.LayoutParams getNewLayoutParams(int w, int h) {
		return new ViewGroup.LayoutParams(w, h);
	}

	@Override
	public Handler getHandler() {
		return handler;
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
						"de.guj.ems.mobile.sdk.views.GuJEMSAdView")
						|| parser.getName().equals(
								"de.guj.ems.mobile.sdk.views.GuJEMSListAdView")) {
					as = Xml.asAttributeSet(parser);
					break;
				} else {
					SdkLog.d(TAG, parser.getName());
				}
			}
		} while (state != XmlPullParser.END_DOCUMENT);

		return as;
	}

	/**
	 * Perform the actual request. Should only be invoked if a constructor with
	 * the boolean load flag was used and it was false
	 */
	public final void load() {
		if (settings != null && !this.testMode) {

			// Construct request URL

			if (SdkUtil.isOnline()) {

				SdkLog.i(TAG, "START async. AdServer request [" + this.getId()
						+ "]");
				//TODO rebuild
				// getContext().startService(SdkUtil.adRequest(this, settings));
				
			}
			// Do nothing if offline
			else {
				SdkLog.i(TAG, "No network connection - not requesting ads.");
				setVisibility(GONE);
				processError("No network connection.");
			}
		} else {
			SdkLog.w(TAG, "AdView has no settings or is in test mode.");
			setLayoutParams(getNewLayoutParams(
					(int) (300.0 * SdkUtil.getDensity()),
					(int) (50.0 * SdkUtil.getDensity())));
			setVisibility(VISIBLE);
			if (this.settings != null
					&& this.settings.getOnAdSuccessListener() != null) {
				this.settings.getOnAdSuccessListener().onAdSuccess();
			}
		}
	}

	private void preLoadInitialize(Context context, AttributeSet set) {
		this.testMode = getResources().getBoolean(R.bool.ems_test_mode);
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		inflater.inflate(R.layout.integrated_ad, this, true);
		if (set != null && !isInEditMode()) {
			this.settings = new AmobeeSettingsAdapter();
			this.settings.setup(context, getClass(), set);
		}
		if (isInEditMode() || this.testMode) {
			// TODO set test content?
		}

	}

	private void preLoadInitialize(Context context, AttributeSet set,
			String[] kws, String[] nkws) {
		this.testMode = getResources().getBoolean(R.bool.ems_test_mode);
		
		if (set != null) {
			this.settings = new AmobeeSettingsAdapter();
			this.settings.setup(context, getClass(), set,
					kws, nkws);
		}
		if (isInEditMode() || this.testMode) {
			// TODO set test content?
		}

	}

	@Override
	public void processError(String msg) {
		SdkLog.w(
				TAG,
				"The following error occured and is being handled by the appropriate listener if available.");
		SdkLog.e(TAG, msg);
		if (this.settings.getOnAdErrorListener() != null) {
			this.settings.getOnAdErrorListener().onAdError(msg);
		}
	}

	@Override
	public void processError(String msg, Throwable t) {
		SdkLog.w(
				TAG,
				"The following error occured and is being handled by the appropriate listener if available.");
		if (msg != null && msg.length() > 0) {
			SdkLog.e(TAG, msg, t);
		} else {
			SdkLog.e(TAG, "Exception: ", t);
		}
		if (this.settings.getOnAdErrorListener() != null) {
			this.settings.getOnAdErrorListener().onAdError(msg, t);
		}
	}

	@Override
	public final void processResponse(IAdResponse response) {
		try {
			if (response != null && !response.isEmpty()) {
				//TODO process ad server response
				if (this.settings.getOnAdSuccessListener() != null) {
					this.settings.getOnAdSuccessListener().onAdSuccess();
				}
				SdkLog.i(TAG, "Ad found and loading... [" + this.getId() + "]");

			} else {
				setVisibility(GONE);
				if (response == null || response.isEmpty()) {
					if (this.settings.getOnAdEmptyListener() != null) {
						this.settings.getOnAdEmptyListener().onAdEmpty();
					} else {
						SdkLog.i(TAG, "No valid ad found. [" + this.getId()
								+ "]");
					}
				}
			}
			SdkLog.i(TAG, "FINISH async. AdServer request [" + this.getId()
					+ "]");
		} catch (Exception e) {
			processError("Error loading ad [" + this.getId() + "]", e);
		}
	}

	public void reload() {
		if (settings != null && !this.testMode) {
			setVisibility(View.GONE);
			load();

		} else {
			SdkLog.w(
					TAG,
					"AdView has no settings or is in test mode. ["
							+ this.getId() + "]");
			setVisibility(View.VISIBLE);
		}
	}

	/**
	 * Add a listener to the view which responds to empty ad responses
	 * 
	 * @param l
	 *            Implemented listener
	 */
	public void setOnAdEmptyListener(IOnAdEmptyListener l) {
		this.settings.setOnAdEmptyListener(l);
	}

	/**
	 * Add a listener to the view which responds to errors while requesting ads
	 * 
	 * @param l
	 *            Implemented listener
	 */
	public void setOnAdErrorListener(IOnAdErrorListener l) {
		this.settings.setOnAdErrorListener(l);
	}

	/**
	 * Add a listener to the view which responds to successful ad requests
	 * 
	 * @param l
	 *            Implemented listener
	 */
	public void setOnAdSuccessListener(IOnAdSuccessListener l) {
		this.settings.setOnAdSuccessListener(l);
	}	

}

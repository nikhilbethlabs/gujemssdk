package de.guj.ems.mobile.sdk.views;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.util.Locale;
import java.util.Map;

import org.json.JSONObject;
import org.ormma.view.Browser;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Movie;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Xml;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.AdResponseReceiver;
import de.guj.ems.mobile.sdk.controllers.AdResponseReceiver.Receiver;
import de.guj.ems.mobile.sdk.controllers.IAdResponseHandler;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.controllers.adserver.AmobeeSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdResponse;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;

public class GuJEMSIntegratedAdView extends RelativeLayout implements Receiver, IAdResponseHandler {

	private static final long serialVersionUID = -9099438955013226163L;

	private transient Handler handler = new Handler();

	private boolean testMode = false;

	private transient IAdServerSettingsAdapter settings;

	private final String TAG = "GuJEMSIntegratedAdView";
	
	private AdResponseReceiver responseReceiver;
	
	private Bitmap stillImage;

	private Movie animatedGif;
	
	private JSONObject adContent;
	
	private class DownloadImageTask extends AsyncTask<String, Void, Object> {
		private final WeakReference<ImageView> viewRef;

		public DownloadImageTask(ImageView view) {
			this.viewRef = new WeakReference<ImageView>(view);
		}

		@Override
		protected Object doInBackground(String... urls) {
			String urldisplay = urls[0];

			setTag(urldisplay);

			InputStream in = null;
			try {
				in = new java.net.URL(urldisplay).openStream();

				if (urldisplay.toLowerCase(Locale.getDefault()).endsWith("gif")) {
					byte[] raw = streamToBytes(in);
					animatedGif = Movie.decodeByteArray(raw, 0, raw.length);
				} else {
					stillImage = BitmapFactory.decodeStream(in);
				}

			} catch (Exception e) {
				SdkLog.e(TAG, e.getMessage(), e);
			} finally {
				if (in != null) {
					try {
						in.close();
					} catch (Exception e) {
						SdkLog.e(TAG, "Error closing image input stream.", e);
					}
				}
			}
			return stillImage != null ? stillImage : animatedGif;
		}

		private byte[] streamToBytes(InputStream is) {
			ByteArrayOutputStream os = new ByteArrayOutputStream(1024);
			byte[] buffer = new byte[1024];
			int len;
			try {
				while ((len = is.read(buffer)) >= 0) {
					os.write(buffer, 0, len);
				}
			} catch (java.io.IOException e) {
				SdkLog.e(TAG, "Error streaming image to bytes.", e);
			}
			return os.toByteArray();
		}
		
		@Override
		protected void onPostExecute(Object result) {
			Movie movie = null;
			Bitmap bitmap = null;
			String url = null;
			
			if (result != null) {

				if (Movie.class.equals(result.getClass())) {
					movie = (Movie) result;
					//play = true;
					SdkLog.d(TAG, "Animation downloaded. [" + movie.width()
							+ "x" + movie.height() + ", " + movie.duration()
							+ "s]");
				} else {
					bitmap = (Bitmap) result;
					SdkLog.d(TAG, "Image downloaded. [" + bitmap.getWidth()
							+ "x" + bitmap.getHeight() + "]");
				}

				ImageView view = viewRef.get();

				
				try {
					url = (String)adContent.get("click");
				}
				catch (Exception e) {
					SdkLog.w(TAG, "Could not get click URL from ad config for integrated ad.");
				}
				
				if (view != null) {
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB
							&& movie != null) {
						disableHWAcceleration();
					} else if (bitmap != null) {
						Drawable d = view.getDrawable();
						if (d instanceof BitmapDrawable) {
							BitmapDrawable bd = (BitmapDrawable) d;
							Bitmap bm = bd.getBitmap();
							if (bm != null) {
								bm.recycle();
							}
							SdkLog.i(TAG,
									"Recycled bitmap of view " + view.getId());
						}
						
						view.setImageBitmap(bitmap);
						//scaleImage(view);
					}
					setVisibility(View.VISIBLE);
					if (url != null) {
						final String _url = url;
						view.setOnClickListener(new OnClickListener() {
							
							@Override
							public void onClick(View v) {
								if (adContent != null && _url != null) {
									Intent i = new Intent(getContext(),
											Browser.class);
									SdkLog.d(TAG, "open:" + _url);
									i.putExtra(Browser.URL_EXTRA,
											_url);
									i.putExtra(Browser.SHOW_BACK_EXTRA, true);
									i.putExtra(Browser.SHOW_FORWARD_EXTRA, true);
									i.putExtra(Browser.SHOW_REFRESH_EXTRA, true);
									getContext().startActivity(i);
								}
							}
						});
					}
					else {
						SdkLog.d(TAG, "Not setting click listener, no click url provided.");
					}
					
					
				}
			}

		}
	}	
	
	/**
	 * Initialize view without configuration
	 * 
	 * @param context
	 *            android application context
	 */
	public GuJEMSIntegratedAdView(Context context) {
		super(context);
		responseReceiver = new AdResponseReceiver(new Handler());
		responseReceiver.setReceiver(this);
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
		responseReceiver = new AdResponseReceiver(new Handler());
		responseReceiver.setReceiver(this);
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
		responseReceiver = new AdResponseReceiver(new Handler());
		responseReceiver.setReceiver(this);		
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
		responseReceiver = new AdResponseReceiver(new Handler());
		responseReceiver.setReceiver(this);		
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
		responseReceiver = new AdResponseReceiver(new Handler());
		responseReceiver.setReceiver(this);		
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
		responseReceiver = new AdResponseReceiver(new Handler());
		responseReceiver.setReceiver(this);		
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
						"de.guj.ems.mobile.sdk.views.GuJEMSIntegratedAdView")) {
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
				getContext().startService(
						SdkUtil.adRequest(responseReceiver, settings));
				
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
		else {
			setVisibility(View.GONE);
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
		else {
			setVisibility(View.GONE);
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
		SdkLog.d(TAG, "" + response);
		try {
			if (response != null && !response.isEmpty()) {
				SdkLog.i(TAG, "Ad found and loading... [" + this.getId() + "]");
				
				try {
					adContent = new JSONObject(response.getResponse());
					if (adContent.get("image") != null) {
						new DownloadImageTask((ImageView)findViewById(R.id.adthumb)).execute((String)adContent.get("image"));
					}
					((TextView)findViewById(R.id.adheader)).setText((String)adContent.get("header"));
					((TextView)findViewById(R.id.adkicker)).setText((String)adContent.get("kicker"));
					if (adContent.get("cp") != null) {
						SdkUtil.httpRequest((String)adContent.get("cp"));
					}
					if (this.settings.getOnAdSuccessListener() != null) {
						this.settings.getOnAdSuccessListener().onAdSuccess();
					}
				}
				catch (Exception e) {
					SdkLog.e(TAG, "Could not fill integrated ad with content", e);
				}

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
	
	@Override
	public void onReceiveResult(int resultCode, Bundle resultData) {
		Throwable lastError = (Throwable) resultData.get("lastError");
		IAdResponse response = (IAdResponse) resultData.get("response");
		SdkLog.d(TAG, "onReceive " + response);
		if (lastError != null) {
			processError("Received error", lastError);
		}
		processResponse(response);
	}
	
	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	private void disableHWAcceleration() {
		setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		SdkLog.d(TAG,
				"HW Acceleration disabled for AdView (younger than Gingerbread).");
	}	

}

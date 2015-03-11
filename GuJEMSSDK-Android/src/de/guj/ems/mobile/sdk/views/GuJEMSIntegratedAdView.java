package de.guj.ems.mobile.sdk.views;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.util.Locale;
import java.util.Map;

import org.json.JSONException;
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
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Movie;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Xml;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.ImageView;
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

/**
 * An adview with a layout defined by the developer.
 * 
 * @author stein16
 *
 */
public class GuJEMSIntegratedAdView extends RelativeLayout implements Receiver,
		IAdResponseHandler, OnTouchListener {

	public static class AdThumbnailView extends ImageView {

		private final static String TAG = "AdThumbnailView";
		
		private Matrix matrix = new Matrix();
		
		private Movie animatedGif;
		
		private long movieStart;
		
		private boolean play;
		
		public AdThumbnailView(Context context) {
			super(context);
			setScaleType(ScaleType.FIT_CENTER);
		}

		public AdThumbnailView(Context context, AttributeSet attrs,
				int defStyleAttr) {
			super(context, attrs, defStyleAttr);
			setScaleType(ScaleType.FIT_CENTER);
			SdkLog.d(TAG, "AdThumbnailView with style attr " + defStyleAttr);
		}

		public AdThumbnailView(Context context, AttributeSet attrs) {
			super(context, attrs);
			setScaleType(ScaleType.FIT_CENTER);
		}
		
		public void setAnimation(Movie m) {
			this.animatedGif = m;
			this.play = true;
			this.movieStart = 0;
			init();
			/*getLayoutParams().width = m.width();
			getLayoutParams().height = m.height();*/
		}
		
		private void init() {
	        RectF src = new RectF(0.0f, 0.0f,  (float)animatedGif.width(), (float)animatedGif.height());
	        RectF dst = new RectF(0.0f, 0.0f, (float)getMeasuredWidth(), (float)getMeasuredHeight());
	                        
	        matrix.setRectToRect(src, dst, Matrix.ScaleToFit.CENTER);			
		}

		@Override
		protected void onDraw(Canvas canvas) {
			canvas.drawColor(Color.TRANSPARENT);

			if (animatedGif != null && play) {
				long now = android.os.SystemClock.uptimeMillis();
				int saveCount = canvas.save();
				canvas.drawColor(Color.TRANSPARENT);

				if (movieStart == 0) {
					movieStart = now;
				}

				if (animatedGif.duration() > 0) {
					int relTime = (int) ((now - movieStart) % animatedGif
							.duration());
					animatedGif.setTime(relTime);
				}
				
		        canvas.concat(matrix);
		        animatedGif.draw(canvas, 0.0f, 0.0f);
		        invalidate();
		        canvas.restoreToCount(saveCount);
			}
			else {
				super.onDraw(canvas);
			}
		}		
	}
	
	private class DownloadImageTask extends AsyncTask<String, Void, Object> {
		
		private final WeakReference<AdThumbnailView> viewRef;

		public DownloadImageTask(AdThumbnailView view) {
			this.viewRef = new WeakReference<AdThumbnailView>(view);
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

		@Override
		protected void onPostExecute(Object result) {
			Movie movie = null;
			Bitmap bitmap = null;

			if (result != null) {

				if (Movie.class.equals(result.getClass())) {
					movie = (Movie) result;
					SdkLog.d(TAG, "Animation downloaded. [" + movie.width()
							+ "x" + movie.height() + ", " + movie.duration()
							+ "s]");
				} else {
					bitmap = (Bitmap) result;
					SdkLog.d(TAG, "Image downloaded. [" + bitmap.getWidth()
							+ "x" + bitmap.getHeight() + "]");
				}

				AdThumbnailView view = viewRef.get();

				if (view != null) {
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB
							&& movie != null) {
						disableHWAcceleration();
						view.setAnimation(animatedGif);
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

					}
					setVisibility(View.VISIBLE);
				}
			}

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
	}

	private boolean startClick;

	private static final long serialVersionUID = -9099438955013226163L;

	private transient Handler handler = new Handler();

	private boolean testMode = false;

	private transient IAdServerSettingsAdapter settings;

	private final String TAG = "GuJEMSIntegratedAdView";

	private AdResponseReceiver responseReceiver;

	private Bitmap stillImage;

	private Movie animatedGif;

	private JSONObject adContent;

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
		setOnTouchListener(this);
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
	public GuJEMSIntegratedAdView(Context context, AttributeSet set,
			boolean load) {
		super(context, set);
		responseReceiver = new AdResponseReceiver(new Handler());
		responseReceiver.setReceiver(this);
		this.preLoadInitialize(context, set);
		setOnTouchListener(this);

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
		setOnTouchListener(this);

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
	public GuJEMSIntegratedAdView(Context context, Map<String, ?> customParams,
			int resId) {
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

		setOnTouchListener(this);
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


		setOnTouchListener(this);
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
	public GuJEMSIntegratedAdView(Context context, String[] kws, String nkws[],
			int resId) {
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

		setOnTouchListener(this);
		if (load) {
			this.load();
		}
	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	private void disableHWAcceleration() {
		setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		SdkLog.d(TAG,
				"HW Acceleration disabled for AdView (younger than Gingerbread).");
	}

	@Override
	public Handler getHandler() {
		return handler;
	}

	public ViewGroup.LayoutParams getNewLayoutParams(int w, int h) {
		return new ViewGroup.LayoutParams(w, h);
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

	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		if (startClick && ev.getAction() == MotionEvent.ACTION_UP) {
			startClick = false;
			return performClick();
		} else {
			startClick = ev.getAction() == MotionEvent.ACTION_DOWN;
			return false;
		}
	}

	@Override
	public void onReceiveResult(int resultCode, Bundle resultData) {
		Throwable lastError = (Throwable) resultData.get("lastError");
		IAdResponse response = (IAdResponse) resultData.get("response");

		if (lastError != null) {
			processError("Received error", lastError);
		}
		processResponse(response);
	}

	@Override
	public boolean onTouch(View v, MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			startClick = true;
			break;
		case MotionEvent.ACTION_UP:
			if (startClick) {
				startClick = false;
				v.performClick();
			}
			break;
		default:
			break;
		}
		return true;
	}

	@Override
	public boolean performClick() {
		try {
			if (adContent != null && adContent.get("click") != null) {
				Intent i = new Intent(getContext(), Browser.class);
				SdkLog.d(TAG, "open:" + adContent.get("click"));
				i.putExtra(Browser.URL_EXTRA, adContent.getString("click"));
				i.putExtra(Browser.SHOW_BACK_EXTRA, true);
				i.putExtra(Browser.SHOW_FORWARD_EXTRA, true);
				i.putExtra(Browser.SHOW_REFRESH_EXTRA, true);
				getContext().startActivity(i);
			} else {
				SdkLog.w(TAG, "No click in ad json, cannot redirect.");
			}
		} catch (JSONException e) {
			SdkLog.e(TAG, "Error executing ad click!", e);
		}
		return super.performClick();
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
			setVisibility(View.VISIBLE);
		} else {
			setVisibility(View.GONE);
		}

	}

	private void preLoadInitialize(Context context, AttributeSet set,
			String[] kws, String[] nkws) {

		this.testMode = getResources().getBoolean(R.bool.ems_test_mode);

		if (set != null) {
			this.settings = new AmobeeSettingsAdapter();
			this.settings.setup(context, getClass(), set, kws, nkws);
		}
		if (isInEditMode() || this.testMode) {
			setVisibility(View.VISIBLE);
		} else {
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

		try {
			if (response != null && !response.isEmpty()) {
				SdkLog.i(TAG, "Ad found and loading... [" + this.getId() + "]");

				try {
					adContent = new JSONObject(response.getResponse());
					if (adContent.get("image") != null) {
						new DownloadImageTask(
								(AdThumbnailView) findViewById(R.id.adthumb))
								.execute((String) adContent.get("image"));
					}
					((TextView) findViewById(R.id.adheader))
							.setText((String) adContent.get("header"));
					((TextView) findViewById(R.id.adkicker))
							.setText((String) adContent.get("kicker"));
					findViewById(R.id.adthumb).setOnTouchListener(this);
					findViewById(R.id.adheader).setOnTouchListener(this);
					findViewById(R.id.adkicker).setOnTouchListener(this);
					if (adContent.get("cp") != null) {
						SdkUtil.httpRequest((String) adContent.get("cp"));
					}
					if (this.settings.getOnAdSuccessListener() != null) {
						this.settings.getOnAdSuccessListener().onAdSuccess();
					}
				} catch (Exception e) {
					SdkLog.e(TAG, "Could not fill integrated ad with content",
							e);
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

}

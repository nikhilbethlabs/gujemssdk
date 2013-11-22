package de.guj.ems.mobile.sdk.views;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;

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
import android.graphics.Movie;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Xml;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import de.guj.ems.mobile.sdk.controllers.AdServerAccess;
import de.guj.ems.mobile.sdk.controllers.AmobeeSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.controllers.OptimobileDelegator;
import de.guj.ems.mobile.sdk.util.AdResponseParser;
import de.guj.ems.mobile.sdk.util.AdResponseParserFactory;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;

public class GuJEMSNativeAdView extends ImageView implements AdResponseHandler {

	private Bitmap stillImage;

	private Movie animatedGif;

	private long movieStart = 0;

	private boolean play = false;

	private class DownloadImageTask extends AsyncTask<String, Void, Object> {
		//private final WeakReference<ImageView> viewRef;
		private final ImageView viewRef;

		public DownloadImageTask(ImageView view) {
			this.viewRef = view;
		}

		protected Object doInBackground(String... urls) {
			String urldisplay = urls[0];

			setTag(urldisplay);
			
			InputStream in = null;
			try {
				in = new java.net.URL(urldisplay).openStream();

				if (urldisplay.toLowerCase(Locale.getDefault()).endsWith("gif")) {
					byte [] raw = streamToBytes(in);
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

		protected void onPostExecute(Object result) {
			Movie movie = null;
			Bitmap bitmap = null;
			if (result != null) {

				if (Movie.class.equals(result.getClass())) {
					movie = (Movie) result;
					play = true;
					SdkLog.d(TAG, "Animation downloaded. [" + movie.width()
							+ "x" + movie.height() + ", " + movie.duration() + "s]");
				} else {
					bitmap = (Bitmap) result;
					SdkLog.d(TAG, "Image downloaded. [" + bitmap.getWidth()
							+ "x" + bitmap.getHeight() + "]");
				}

				//ImageView view = viewRef.get();
				if (viewRef != null) {
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB
							&& movie != null) {
						disableHWAcceleration();
					} else if (bitmap != null && viewRef.getTag().equals(parser.getImageUrl())) {
						Drawable d = viewRef.getDrawable();
						if (d instanceof BitmapDrawable) {
							BitmapDrawable bd = (BitmapDrawable)d;
							Bitmap bm = bd.getBitmap();
							if (bm != null) {
								bm.recycle();
							}
							SdkLog.i(TAG, "Recycled bitmap of view " + viewRef.getId());
						}
						//viewRef.setImageBitmap(bitmap);
					}

					viewRef.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							Intent i = new Intent(getContext(), Browser.class);
							SdkLog.d(TAG, "open:" + parser.getClickUrl());
							i.putExtra(Browser.URL_EXTRA, parser.getClickUrl());
							i.putExtra(Browser.SHOW_BACK_EXTRA, true);
							i.putExtra(Browser.SHOW_FORWARD_EXTRA, true);
							i.putExtra(Browser.SHOW_REFRESH_EXTRA, true);
							getContext().startActivity(i);
						}
					});

					LayoutParams lp = viewRef.getLayoutParams();
					if (movie != null) {
						lp.height = (int) ((float) movie.height() * SdkUtil
								.getDensity());
					} else {
						lp.height = (int) ((float) bitmap.getHeight() * SdkUtil
								.getDensity());
					}
					viewRef.setLayoutParams(lp);
					viewRef.setVisibility(VISIBLE);

				}
			}

		}
	}

	private AdResponseParser parser;

	private IAdServerSettingsAdapter settings;

	private final String TAG = "GuJEMSNativeAdView";

	public GuJEMSNativeAdView(Context context) {
		super(context);
		this.preLoadInitialize(context, null);
	}

	public GuJEMSNativeAdView(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.preLoadInitialize(context, attrs);
		this.load();

	}

	public GuJEMSNativeAdView(Context context, int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs);
		this.handleInflatedLayout(attrs);
		this.load();

	}

	/**
	 * Initialize view from XML and add any custom parameters to the request
	 * 
	 * @param context
	 *            android application context
	 * @param customParams
	 *            map of custom param names and their values
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSNativeAdView(Context context, Map<String, ?> customParams,
			int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs);
		this.addCustomParams(customParams);
		this.handleInflatedLayout(attrs);
		this.load();
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
	public GuJEMSNativeAdView(Context context, Map<String, ?> customParams,
			String[] kws, String nkws[], int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs, kws, nkws);
		this.addCustomParams(customParams);
		this.handleInflatedLayout(attrs);
		this.load();
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
	public GuJEMSNativeAdView(Context context, String[] kws, String nkws[],
			int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs, kws, nkws);
		this.handleInflatedLayout(attrs);
		this.load();
	}

	private void addCustomParams(Map<String, ?> params) {
		if (params != null) {
			Iterator<String> mi = params.keySet().iterator();
			while (mi.hasNext()) {
				String param = mi.next();
				Object value = params.get(param);
				if (value.getClass().equals(String.class)) {
					this.settings.addCustomRequestParameter(param,
							(String) value);
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
		} else {
			SdkLog.w(TAG, "Custom params constructor used with null-array.");
		}
	}

	protected ViewGroup.LayoutParams getNewLayoutParams(int w, int h) {
		return new ViewGroup.LayoutParams(w, h);
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

	private final void load() {

		if (settings != null) {

			// Construct request URL
			final String url = this.settings.getRequestUrl();
			if (SdkUtil.isOnline()) {

				SdkLog.i(TAG, "START async. AdServer request [" + this.getId()
						+ "]");
				new AdServerAccess(SdkUtil.getUserAgent(),
						settings.getSecurityHeaderName(),
						settings.getSecurityHeaderValueHash(), this)
						.execute(new String[] { url });
			}
			// Do nothing if offline
			else {
				SdkLog.i(TAG, "No network connection - not requesting ads.");
				setVisibility(GONE);
				processError("No network connection.");
			}
		} else {
			SdkLog.w(TAG, "AdView has no settings.");
		}
	}

	private void loadEditorAsset() {
		String path = "file://android_asset/defaultad.png";
		InputStream is = null;
		try {
			is = getContext().getAssets().open(path);
			Bitmap bitmap = BitmapFactory.decodeStream(is);
			setImageBitmap(bitmap);
		} catch (Exception io) {
			SdkLog.w(TAG, "Error loading standard asset in edit mode.");
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (Exception f) {
					;
				}
			}
		}
		setVisibility(VISIBLE);
	}

	private void preLoadInitialize(Context context, AttributeSet set) {
		if (SdkUtil.getContext() == null) {
			SdkUtil.setContext(context);
		}
		//setImageDrawable(null);

		if (set != null && !isInEditMode()) {
			this.settings = new AmobeeSettingsAdapter(context, set);
		} else if (isInEditMode()) {
			loadEditorAsset();
		} else {
			SdkLog.e(TAG, "No attribute set found from resource id?");
		}
		
		

	}

	private void preLoadInitialize(Context context, AttributeSet set,
			String[] kws, String[] nkws) {
		if (SdkUtil.getContext() == null) {
			SdkUtil.setContext(context);
		}
		setImageDrawable(null);
		if (set != null && !isInEditMode()) {
			this.settings = new AmobeeSettingsAdapter(context, set, kws, nkws);
		} else if (isInEditMode()) {
			loadEditorAsset();
		}

	}

	@Override
	public void processError(String msg) {
		if (this.settings.getOnAdErrorListener() != null) {
			this.settings.getOnAdErrorListener().onAdError(msg);
		} else {
			SdkLog.e(TAG, msg);
		}
	}

	@Override
	public void processError(String msg, Throwable t) {
		if (this.settings.getOnAdErrorListener() != null) {
			this.settings.getOnAdErrorListener().onAdError(msg, t);
		} else {
			SdkLog.e(TAG, msg, t);
		}
	}

	@Override
	public void processResponse(String response) {
		try {
			this.parser = AdResponseParserFactory.getParser(response);
			SdkLog.d(TAG, "Native view response parser is " + parser + " ["
					+ (parser != null ? parser.isValid() : false) + "]");
			if (parser != null && parser.isValid()) {
				new DownloadImageTask(this).execute(parser.getImageUrl());
				if (parser.getTrackingImageUrl() != null) {
					new AdServerAccess(SdkUtil.getUserAgent(), null)
							.execute(parser.getTrackingImageUrl());
				}
				SdkLog.i(TAG, "Ad found and loading... [" + this.getId() + "]");
				if (this.settings.getOnAdSuccessListener() != null) {
					this.settings.getOnAdSuccessListener().onAdSuccess();
				}
			} else {
				setVisibility(GONE);

				if (this.settings.getDirectBackfill() != null) {
					try {
						SdkLog.i(TAG, "Passing to optimobile delegator. ["
								+ this.getId() + "]");
						OptimobileDelegator optimobileDelegator = new OptimobileDelegator(
								getContext(), this, settings);
						if (getParent() != null) {
							((ViewGroup) getParent()).addView(
									optimobileDelegator.getOptimobileView(),
									((ViewGroup) getParent())
											.indexOfChild(this) + 1);
						} else {
							SdkLog.d(TAG, "Primary view initialized off UI.");
						}
						optimobileDelegator.getOptimobileView().update();

					} catch (Exception e) {
						processError("Error delegating to optimobile.", e);
					}

				} else {
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
		if (settings != null) {
			setVisibility(GONE);
			setImageDrawable(null);

			// Construct request URL
			final String url = this.settings.getRequestUrl();
			if (SdkUtil.isOnline()) {

				SdkLog.i(TAG, "START async. AdServer request [" + this.getId()
						+ "]");
				new AdServerAccess(SdkUtil.getUserAgent(),
						settings.getSecurityHeaderName(),
						settings.getSecurityHeaderValueHash(), this)
						.execute(new String[] { url });
			}
			// Do nothing if offline
			else {
				SdkLog.i(TAG, "No network connection - not requesting ads.");
				setVisibility(GONE);
				processError("No network connection.");
			}
		} else {
			SdkLog.w(TAG, "AdView has no settings. [" + this.getId() + "]");
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
	protected void onDetachedFromWindow() {
		super.onDetachedFromWindow();
		setImageBitmap(null);
		play = false;
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		
		if (animatedGif != null && play) {
			long now = android.os.SystemClock.uptimeMillis();
			float dens = SdkUtil.getDensity();
			
			canvas.drawColor(Color.TRANSPARENT);
			canvas.scale(dens, dens);

			if (movieStart == 0) {
				movieStart = now;
			}

			if (animatedGif.duration() > 0) {
				int relTime = (int) ((now - movieStart) % animatedGif.duration());
				animatedGif.setTime(relTime);
			}
			//SdkLog.d(TAG, "agif view width: " + getWidth() + ", agif width: " + animatedGif.width() + ", density: " + dens);
			//animatedGif.draw(canvas, (getWidth() / dens - animatedGif.width()) / 2.0f,	0.0f);
			this.invalidate();
		}
	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	private void disableHWAcceleration() {
		setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		SdkLog.d(TAG,
				"HW Acceleration disabled for AdView (younger than Gingerbread).");
	}

}

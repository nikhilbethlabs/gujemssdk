package de.guj.ems.mobile.sdk.activities;

import java.io.IOException;
import java.io.StringReader;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.util.Xml;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;

/**
 * This activity is executed when a VAST for video interstitial was
 * delivered from the adserver.
 * 
 * The activity displays a html 5 video player with a text hinting at
 * the playtime.
 * 
 * Additionally there is a close button (after the defined skip time of the video).
 *  
 * When the close button is pressed, a target activity is launched if the
 * intent for this activity is passed as an extra called "target".
 * Otherwise the video interstitial activity just finishes.
 * 
 * This activity may not be executed directly but via the
 * InterstitialSwitchActivity which determines whether there actually is a
 * video interstitial booked, first.
 * 
 * @author stein16
 * 
 */
public final class VideoInterstitialActivity extends Activity {

	static class InterstitialThread extends Thread {

		static volatile boolean PAUSED = false;

		static volatile boolean SHOW = true;

		public InterstitialThread(Runnable r, String name) {
			super(r, name);
		}

		public void beforeStart() {
			unpause();
			SHOW = true;
		}

		public void beforeStop() {
			SHOW = false;
		}

		public void pause() {
			PAUSED = true;
		}

		public void unpause() {
			PAUSED = false;
		}
	}

	private final static int CLOSED = 1;

	private final static int FINISHED = 3;

	private final static int SUSPENDED = 2;

	private final static String TAG = "VideoInterstitialActivity";

	private GuJEMSAdView adView;

	private RelativeLayout root;

	private ProgressBar spinner;

	private int status = -1;

	private Intent target;

	private InterstitialThread updateThread;

	private void createView(Bundle savedInstanceState) {

		// (1) set view layout
		setContentView(R.layout.interstitial_noprogress);

		// (2) get views for display and hiding
		this.spinner = (ProgressBar) findViewById(R.id.emsIntSpinner2);
		this.root = (RelativeLayout) findViewById(R.id.emsIntLayout);
		((Button)findViewById(R.id.emsIntCloseButton2)).setVisibility(View.GONE);
		
		this.adView = new GuJEMSAdView(VideoInterstitialActivity.this);

		// (3) configure interstitial adview
		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(new StringReader(getIntent().getExtras().getString("data")));
			parser.nextTag();
			parseVAST(parser);
		}
		catch (Exception e) {
			SdkLog.e(TAG, "Error parsing VAST from adserver", e);
			if (this.target != null) {
				startActivity(target);
			}
			finish();			
		}

		// load predefined html with replacements from VAST xml
		adView.loadData("", "text/html",
				"utf-8");
		
		
		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(
				RelativeLayout.LayoutParams.MATCH_PARENT,
				RelativeLayout.LayoutParams.WRAP_CONTENT);
		lp.addRule(RelativeLayout.BELOW, R.id.emsIntCloseButton2);
		adView.setLayoutParams(lp);

		// (4) configure close button
		ImageButton b = (ImageButton) findViewById(R.id.emsIntCloseButton2);
		b.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				if (updateThread != null && updateThread.isAlive()) {
					try {
						updateThread.beforeStop();
						updateThread.join(100);
						status = CLOSED;
					} catch (InterruptedException e) {
						;
					}
				} else {
					if (target != null) {
						startActivity(target);
					} else {
						SdkLog.d(TAG,
								"Video interstitial without target. Returning to previous view.");
					}
					finish();
				}
			}
		});

	}
	
	private void parseVAST(XmlPullParser p) throws XmlPullParserException, IOException {
		p.require(XmlPullParser.START_TAG, null, "VAST");
	    while (p.next() != XmlPullParser.END_TAG) {
	        if (p.getEventType() != XmlPullParser.START_TAG) {
	            continue;
	        }
	        String name = p.getName();
	        // Starts by looking for the entry tag
	        if (name.equals("entry")) {

	        } else {

	        }
	    }  
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (status < 0) {
			this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
			this.requestWindowFeature(Window.FEATURE_NO_TITLE);
			this.target = (Intent) getIntent().getExtras().get("target");
			createView(savedInstanceState);
		}
	}

	@Override
	protected void onPause() {
		super.onPause();

		if (updateThread != null && updateThread.isAlive()
				&& !InterstitialThread.PAUSED) {
			updateThread.pause();
		}
		if (status != CLOSED && status != SUSPENDED) {
			status = SUSPENDED;
			SdkLog.i(TAG, "Suspending video interstitial activity.");
		}
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
	}

	@Override
	protected void onResume() {
		super.onResume();

		if (status == SUSPENDED) {
			if (target != null) {
				SdkLog.d(TAG,
						"Video interstitial resume from suspended mode with target set.");
				startActivity(target);
			} else {
				SdkLog.d(
						TAG,
						"Video interstitial resume from suspended mode without target. Returning to previous view.");
			}
			status = FINISHED;
			if (this.updateThread != null && this.updateThread.isAlive()) {
				try {
					updateThread.beforeStop();
					updateThread.join(100);
				} catch (InterruptedException e) {
					;
				}
			}
			finish();
		} else if (updateThread != null && updateThread.isAlive() && status > 0) {
			SdkLog.d(TAG, "Video interstitial resume with paused thread.");
			updateThread.unpause();
		}
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
	}

	@Override
	protected void onStart() {
		super.onStart();

		if (status < 0) {
			SdkLog.d(TAG, "Create and start new control thread.");
			this.updateThread = new InterstitialThread(new Runnable() {

				public void run() {
					boolean loaded = false;
					while (InterstitialThread.SHOW) {
						if (!loaded && adView.isPageFinished()) {
							
							if (root == null) {
								SdkLog.e(TAG, "This should not happen... interstitial layout is null");
								SdkLog.w(TAG, "Interstitial Thread = " + InterstitialThread.PAUSED + "/" + InterstitialThread.SHOW);
								SdkLog.w(TAG, "status = " + status);
								break;
							}
							
							loaded = true;
							//TODO NPE when rotating device while loading 
							root.getHandler().post(new Runnable() {
								@Override
								public void run() {
									SdkLog.w(
											TAG,
											"root is " + root);
									root.removeView(spinner);
									root.addView(adView);
									SdkLog.d(
											TAG,
											"Video Interstitial loaded, starting progress bar.");
								}
							});
						} else if (loaded && !InterstitialThread.PAUSED) {
							SdkLog.d(TAG,
									"Video interstitial display without timer.");
							return;
						} else {
							Thread.yield();
						}
					}
					SdkLog.d(TAG, "Terminating control thread.");
					if (target != null) {
						startActivity(target);
					} else {
						SdkLog.d(TAG,
								"Video interstitial without target. Returning to previous view.");
					}
					finish();
				}
			}, "Video Interstitial-[" + target + "]");

			updateThread.beforeStart();
			updateThread.start();
			SdkLog.d(TAG, "Video interstitial timer started.");
		}

	}

	@Override
	protected void onStop() {
		super.onStop();

		if (updateThread != null && updateThread.isAlive()
				&& status != SUSPENDED && !InterstitialThread.PAUSED) {
			try {
				updateThread.beforeStop();
				updateThread.join(100);
			} catch (InterruptedException e) {
				;
			}
		}
		if (status == FINISHED || status == CLOSED) {
			SdkLog.i(TAG, "Finishing interstitial activity.");
		}
	}
	
	@Override
	public void onBackPressed() {
		if (updateThread != null && updateThread.isAlive()) {
			try {
				updateThread.beforeStop();
				updateThread.join(100);
				status = CLOSED;
			} catch (InterruptedException e) {
				;
			}
		}
		super.onBackPressed();
	}
	

}

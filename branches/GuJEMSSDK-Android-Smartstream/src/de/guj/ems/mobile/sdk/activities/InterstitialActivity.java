package de.guj.ems.mobile.sdk.activities;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.util.AppContext;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;


/**
 * This activity is executed when an interstitial was delivered from the
 * adserver.
 * 
 * The activity displays the iterstitial html and optionally
 * launches a progress bar which runs for "time" seconds.
 * 
 * Additionally there is a close button.
 * 
 * When the progressbar finishes or the close button is pressed, a target
 * activity is launches. The intent for this activity is passed as an extra
 * called "target".
 * 
 * This activity may not be executed directly but via the
 * InterstitialSwitchActivity which determines whether there actually is an
 * interstitial booked, first.
 * 
 * @see de.guj.ems.mobile.sdk.activities.InterstititalActivity
 * 
 * @author stein16
 * 
 */
public final class InterstitialActivity extends Activity {

	ProgressBar progressBar;
	
	private final static String TAG = "InterstitialActivity";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		
		Integer time = (Integer) getIntent().getExtras().get("timeout");
		if (time != null) {
			SdkLog.d(TAG, "Creating interstitial with " + time.intValue() + " ms progess bar.");
			createView(savedInstanceState, time.intValue());
		} else {
			SdkLog.d(TAG, "Creating interstitial without progess bar.");
			createView(savedInstanceState, -1);
		}

	}

	private void createView(Bundle savedInstanceState, int time) {
		final long t0 = System.currentTimeMillis();
		final int t = time;
		final InterstitialThread updateThread = new InterstitialThread(new Runnable() {
			public void run() {
				while (InterstitialThread.SHOW) {
					int t1 = (int) (System.currentTimeMillis() - t0);
					if (progressBar != null) {
						progressBar.setProgress(t1);
					}
					if (t1 >= t) {
						break;
					}
				}
				Intent target = (Intent) getIntent().getExtras().get(
						"target");
				startActivity(target);
				
				finish();
			}
		});
		
		setContentView(time > 0 ? R.layout.interstitial_progress : R.layout.interstitial_noprogress);
		
		GuJEMSAdView adView = new GuJEMSAdView(
				AppContext.getContext());
		
		adView.loadData(getIntent().getExtras().getString("data"), "text/html",
				"utf-8");
		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		lp.addRule(RelativeLayout.BELOW,time > 0 ? R.id.emsIntCloseButton : R.id.emsIntCloseButton2);
		adView.setLayoutParams(lp);
		
		RelativeLayout root = (RelativeLayout)findViewById(time > 0 ? R.id.emsIntProgLayout : R.id.emsIntLayout);
		root.addView(adView);
		
		ImageButton b = (ImageButton)findViewById(time > 0 ? R.id.emsIntCloseButton : R.id.emsIntCloseButton2);
		b.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				if (updateThread != null && updateThread.isAlive()) {
					try {
						updateThread.beforeStop();
						updateThread.join(100);
					} catch (InterruptedException e) {
						;
					}
				}
				else {
					Intent target = (Intent) getIntent().getExtras().get(
							"target");
					startActivity(target);
					finish();					
				}
			}
		});

		if (time >= 0) {
			progressBar = (ProgressBar)findViewById(R.id.emsIntProgBar);
			progressBar.setMax(time);
		}
		
		if (time >= 0) {
			updateThread.beforeStart();
			updateThread.start();
		}
	}
	
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
	}
		
	static class InterstitialThread extends Thread {
		static boolean SHOW = true;
		
		public void beforeStop() {
			SHOW = false;
		}
		
		public void beforeStart() {
			SHOW = true;
		}
		
		public InterstitialThread(Runnable r) {
			super(r);
		}
	}

}

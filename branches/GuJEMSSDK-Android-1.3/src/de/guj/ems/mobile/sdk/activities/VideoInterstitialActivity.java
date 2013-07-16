package de.guj.ems.mobile.sdk.activities;

import org.ormma.view.Browser;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.VideoView;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;
import de.guj.ems.mobile.sdk.util.VASTXmlParser;
import de.guj.ems.mobile.sdk.util.VASTXmlParser.Tracking;

/**
 * This activity is executed when a VAST for video interstitial was delivered
 * from the adserver.
 * 
 * The activity displays native video player with a text hinting at the
 * playtime.
 * 
 * Additionally there is a close button (after the defined skip time of the
 * video).
 * 
 * When the close button is pressed, a target activity is launched if the intent
 * for this activity is passed as an extra called "target". Otherwise the video
 * interstitial activity just finishes.
 * 
 * This activity may not be executed directly but via the
 * InterstitialSwitchReceiver which determines whether there actually is a video
 * interstitial booked, first.
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

	private TextView videoText;

	private MediaPlayer mediaPlayer;

	private boolean muted;

	private VASTXmlParser vastXml;

	private volatile boolean videoReady = false;

	private final static int CLOSED = 1;

	private final static int FINISHED = 3;

	private final static int SUSPENDED = 2;

	private final static String TAG = "VideoInterstitialActivity";

	private VideoView videoView;

	private RelativeLayout root;

	private ProgressBar spinner;

	private int status = -1;

	private Intent target;

	private InterstitialThread updateThread;

	private void initFromVastXml() {
		// (3) configure video interstitial adview
		this.videoView = (VideoView) findViewById(R.id.emsVideoView);

		this.videoView
				.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {

					@Override
					public void onPrepared(MediaPlayer mp) {
						mediaPlayer = mp;
						mediaPlayer.setVolume(muted ? 0.0f : 1.0f, muted ? 0.0f : 1.0f);
						videoReady = true;
					}
				});
		this.videoView
				.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {

					@Override
					public void onCompletion(MediaPlayer mp) {
						String tx = vastXml
								.getTrackingByType(Tracking.EVENT_COMPLETE);
						if (tx != null) {
							SdkUtil.httpRequest(tx);
						}

						if (target != null) {
							startActivity(target);
						} else {
							SdkLog.d(TAG,
									"Video interstitial without target. Returning to previous view.");
						}
						finish();
					}
				});
		try {
			// parse VAST xml
			this.vastXml = new VASTXmlParser(getIntent().getExtras().getString(
					"data"));
			if (this.vastXml.getImpressionTrackerUrl() != null) {
				SdkUtil.httpRequest(this.vastXml.getImpressionTrackerUrl());
			}
		} catch (Exception e) {
			SdkLog.e(TAG, "Error parsing VAST xml from adserver", e);
			if (this.target != null) {
				startActivity(target);
			}
			finish();

		}
		this.videoView.setVideoURI(Uri.parse(this.vastXml.getMediaFileUrl()));

		// onClick handler for video
		videoView.setOnTouchListener(new View.OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent e) {

				if (e.getAction() == MotionEvent.ACTION_UP) {
					if (vastXml.getClickThroughUrl() != null) {
						Intent i = new Intent(VideoInterstitialActivity.this,
								Browser.class);
						SdkLog.d(TAG, "open:" + vastXml.getClickThroughUrl());
						i.putExtra(Browser.URL_EXTRA,
								vastXml.getClickThroughUrl());
						i.putExtra(Browser.SHOW_BACK_EXTRA, true);
						i.putExtra(Browser.SHOW_FORWARD_EXTRA, true);
						i.putExtra(Browser.SHOW_REFRESH_EXTRA, true);
						i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
						startActivity(i);
					} else {
						SdkLog.w(TAG, "Video is not clickable.");
					}
				}
				return true;
			}
		});
		
	}
	
	@SuppressWarnings("deprecation")
	private void createView(Bundle savedInstanceState) {
		boolean muteTest = getIntent().getExtras().getBoolean("unmuted");
		SdkLog.d(TAG, "Sound settings forced=" + muteTest + ", headset=" + ((AudioManager)getApplicationContext().getSystemService(AUDIO_SERVICE)).isWiredHeadsetOn());
		this.muted = !(muteTest || ((AudioManager)getApplicationContext().getSystemService(AUDIO_SERVICE)).isWiredHeadsetOn());

		// (1) set view layout
		setContentView(R.layout.video_interstitial);

		// (2) get views for display and hiding
		this.spinner = (ProgressBar) findViewById(R.id.emsVidIntSpinner);
		this.root = (RelativeLayout) findViewById(R.id.emsVidIntLayout);

		// (3) init video
		this.initFromVastXml();
				
		// (4) configure close button
		ImageButton b = (ImageButton) findViewById(R.id.emsVidIntButton);
		b.setVisibility(View.INVISIBLE);
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

		// configure sound button
		final ImageButton s = (ImageButton) findViewById(R.id.emsVidIntSndButton);
		s.setVisibility(View.INVISIBLE);
		s.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				muted = !muted; // switch
				mediaPlayer.setVolume(muted ? 0.0f : 1.0f, muted ? 0.0f : 1.0f);
				s.setImageResource(muted ? R.drawable.sound_button_off
						: R.drawable.sound_button_on);
				String tr = muted ? vastXml
						.getTrackingByType(VASTXmlParser.Tracking.EVENT_MUTE)
						: vastXml
								.getTrackingByType(VASTXmlParser.Tracking.EVENT_UNMUTE);
				if (tr != null) {
					SdkUtil.httpRequest(tr);
				}
			}
		});

		// configure text
		videoText = (TextView) findViewById(R.id.emsVideoText);

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
			try {
				mediaPlayer.pause();
			}
			catch (IllegalStateException e) {
				SdkLog.w(TAG, "MediaPlayer already released.");
			}
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

			if (mediaPlayer != null && (mediaPlayer.isPlaying())) {
				mediaPlayer.pause();
				SdkLog.d(TAG, "MediaPlayer stopped.");
			}
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
			if (mediaPlayer != null) {
				mediaPlayer.start();
				SdkLog.d(TAG, "MediaPlayer resumed.");				
			}
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
				boolean q1 = false;
				boolean q2 = false;
				boolean q3 = false;
				double vl;

				private void videoInit() {
					
					root.getHandler().post(new Runnable() {
						@Override
						public void run() {
							ImageButton sndButton = (ImageButton) root
									.findViewById(R.id.emsVidIntSndButton); 
							spinner.setVisibility(View.GONE);

							SdkUtil.httpRequest(vastXml
									.getTrackingByType(Tracking.EVENT_START));

							if (muted) {
								String tr = vastXml.getTrackingByType(VASTXmlParser.Tracking.EVENT_MUTE);
								if (tr != null) {
									SdkUtil.httpRequest(tr);
								}
							}

							vl = (double) videoView.getDuration();
							if (mediaPlayer != null) {
								mediaPlayer.start();
								SdkLog.d(TAG, "MediaPlayer started.");
							}
							sndButton.setImageResource(muted ? R.drawable.sound_button_off
									: R.drawable.sound_button_on);
							sndButton
									.setVisibility(View.VISIBLE);
							if (vastXml.getSkipOffset() <= 0) {
								((ImageButton) root
										.findViewById(R.id.emsVidIntButton))
										.setVisibility(View.VISIBLE);
							}
							SdkLog.d(TAG,
									"Video Interstitial loaded, starting video ["
											+ vl + " ms]");
						}
					});
				}
				
				private void updateView(final boolean canClose, final String bottomText) {
					root.getHandler().post(new Runnable() {

						@Override
						public void run() {
							if (canClose
									&& ((ImageButton) root
											.findViewById(R.id.emsVidIntButton))
											.getVisibility() == View.INVISIBLE) {
								SdkLog.i(TAG,
										"Enabling video cancel button.");
								((ImageButton) root
										.findViewById(R.id.emsVidIntButton))
										.setVisibility(View.VISIBLE);
							}
							videoText.setText(bottomText);
						}
					});					
				}
				
				private void trackEvent(double percentPlayed) {
					if (percentPlayed >= 25.0 && !q1) {
						String tx = vastXml
								.getTrackingByType(Tracking.EVENT_FIRSTQ);
						q1 = true;
						if (tx != null) {
							SdkUtil.httpRequest(tx);
						}
					}
					if (percentPlayed >= 50.0 && !q2) {
						String tx = vastXml
								.getTrackingByType(Tracking.EVENT_MID);
						q2 = true;
						if (tx != null) {
							SdkUtil.httpRequest(tx);
						}
					}
					if (percentPlayed >= 75.0 && !q3) {
						String tx = vastXml
								.getTrackingByType(Tracking.EVENT_THIRDQ);
						q3 = true;
						if (tx != null) {
							SdkUtil.httpRequest(tx);
						}
						return;
					}					
				}
				
				public void run() {
					boolean loaded = false;
					while (InterstitialThread.SHOW) {
						if (!loaded && videoReady) {
							videoInit();
							loaded = true;
						} else if (loaded && !InterstitialThread.PAUSED) {
							double p = ((double) videoView
									.getCurrentPosition() / vl) * 100.0d;
							String text = "-w-";
							boolean close = false;
							if (vastXml.getSkipOffset() > 0) {
								close = (p >= vastXml.getSkipOffset());
								if (!close) {
									text = "-w- Abbrechbar in "
											+ ((int) ((vastXml.getSkipOffset() - p) / 100.0 * (vl / 1000)) + " Sekunden");
								}
							} else {
								close = true;
							}

							updateView(close, text);
							trackEvent(p);

						}
						try {
							Thread.sleep(250);
						} catch (InterruptedException e) {
							SdkLog.e(TAG, "Sleep interrupted while sleeping.",
									e);
						}
					}
					SdkLog.d(TAG, "Terminating control thread.");
					
					if (mediaPlayer != null) {
						mediaPlayer.pause();
						SdkLog.d(TAG, "MediaPlayer paused.");						
					}
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
	

}

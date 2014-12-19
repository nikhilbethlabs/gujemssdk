package de.guj.ems.mobile.sdk.test;

import android.app.Activity;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.net.Uri;
import android.os.Bundle;
import android.widget.MediaController;
import android.widget.VideoView;

/**
 * SImple activity showing a video player
 * Used to demonstrate pre-roll video ads
 * implemented by VideoInterstitialActivity
 * 
 * The actual logic of calling the PreRoll
 * is handled in MainActivity
 * 
 * @author stein16
 *
 */
public class VideoPlayer extends Activity {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.vplayer);
		VideoView videoView = (VideoView) findViewById(R.id.videoView);
		MediaController mediaController = new MediaController(this);
		mediaController.setAnchorView(videoView);
		Uri uri = Uri.parse("http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4");
		videoView.setMediaController(mediaController);
		videoView.setVideoURI(uri);
		videoView.setOnCompletionListener(new OnCompletionListener() {

			@Override
			public void onCompletion(MediaPlayer mp) {
				try {
					mp.release();
				}
				catch (Exception e) {
					;
				}
				finally {
					finish();
				}
			}
			
		});
		videoView.requestFocus();
		videoView.start();
	}
	
}
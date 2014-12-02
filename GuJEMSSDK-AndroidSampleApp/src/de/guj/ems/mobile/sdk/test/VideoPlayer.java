package de.guj.ems.mobile.sdk.test;

import android.app.Fragment;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.MediaController;
import android.widget.VideoView;

/**
 * SImple activity showing a video player
 * Used to demonstrate pre-roll video ads
 * implemented by VideoInterstitialActivity
 * 
 * The actual logic of calling the PreRoll
 * is handled in MenuItemHelper
 * 
 * @author stein16
 *
 */
public class VideoPlayer extends Fragment {

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.vplayer, container,
				false);
		VideoView videoView = (VideoView) rootView.findViewById(R.id.videoView);
		MediaController mediaController = new MediaController(getActivity());
		mediaController.setAnchorView(videoView);
		Uri uri = Uri.parse("http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4");
		videoView.setMediaController(mediaController);
		videoView.setVideoURI(uri);
		videoView.requestFocus();
		videoView.start();
		return rootView;
	}
	
}
package de.guj.ems.mobile.sdk.test;

import de.guj.ems.mobile.sdk.controllers.InterstitialSwitchReceiver;
import de.guj.ems.mobile.sdk.util.SdkUtil;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

/**
 * Splash screen / start interstitial sample activity
 * The activity starts an interstitial receiver with the
 * actual application start as a target intent
 * 
 * If no interstitial is available, the application starts
 * directly. Otherwise, a splashscreen is shown
 * 
 * @author stein16
 *
 */
public class StartInterstitial extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		// Actual application start activity
		Intent target = new Intent(getApplicationContext(), ListViewTest.class);
    	// Interstitial receiver
		Intent i = new Intent(getApplicationContext(), InterstitialSwitchReceiver.class);
    	// set a 7 seconds timeout for the splash screen
		i.putExtra("timeout", Integer.valueOf(7000));
    	// the adSpaceId for the start interstitial
		i.putExtra("ems_zoneId", "15310");
    	// transmit a userId
		i.putExtra("ems_uid", Boolean.valueOf(true));
    	// transmit geolocation data
		i.putExtra("ems_geo",Boolean.valueOf(true));
    	// no keywords
		i.putExtra("ems_kw", Boolean.valueOf(false));
    	// no non matching keywords
		i.putExtra("ems_nkw", Boolean.valueOf(false));
    	// the activity to display after the splash screen
		i.putExtra("target", target);
    	
    	// this is important - if the application is not set,
    	// the interstitial might fail because it needs
    	// an android context to succeed
    	SdkUtil.setContext(getApplicationContext());
    	
    	// start the interstitial receiver broadcast
    	sendBroadcast(i);
    	
		
	}
	
	

}

package de.guj.ems.mobile.sdk.test;

import de.guj.ems.mobile.sdk.controllers.InterstitialSwitchReceiver;
import de.guj.ems.mobile.sdk.util.SdkUtil;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class StartInterstitial extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		Intent target = new Intent(getApplicationContext(), ListViewTest.class);
    	
		Intent i = new Intent(getApplicationContext(), InterstitialSwitchReceiver.class);
    	i.putExtra("timeout", Integer.valueOf(7000));
    	i.putExtra("ems_zoneId", "15310");
    	i.putExtra("ems_uid", Boolean.valueOf(true));
    	i.putExtra("ems_geo",Boolean.valueOf(true));
    	i.putExtra("ems_kw", Boolean.valueOf(false));
    	i.putExtra("ems_nkw", Boolean.valueOf(false));
    	i.putExtra("target", target);
    	sendBroadcast(i);
    	
		SdkUtil.setContext(getApplicationContext());
		startActivity(target);
	}
	
	

}

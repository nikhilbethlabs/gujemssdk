package de.guj.ems.mobile.sdk.test;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import de.guj.ems.mobile.sdk.activities.InterstitialSwitchActivity;
import de.guj.ems.mobile.sdk.controllers.InterstitialSwitchReceiver;


public class MenuItemHelper {
	
	private final static String TAG = "MenuItemHelper";
	
	public static Intent getTargetIntent(Context context, int menuId) {

		if (menuId == R.id.video) {
			double rand = Math.random();
			Log.i(TAG, rand >= 0.5 ? "Wrapped Video Interstitial" : "Video Interstitial");
			Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	i.putExtra("ems_zoneId", rand >= 0.5 ? "9002" : "9001");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	//i.putExtra("unmuted", Boolean.valueOf(true));
	    	return i;			
		}
		else if (menuId == R.id.table) {
			Log.i(TAG, "GuJEMSAdView in TableView");
			Intent target = new Intent(context, TableLayoutTest.class);
	    	Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	i.putExtra("timeout", Integer.valueOf(5000));
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
			i.putExtra("target", target);
	    	return i;
		}
		else if (menuId == R.id.list) {
			Log.i(TAG, "GuJEMSListAdView in ListView with custom adapter");
			Intent target = new Intent(context, ListViewTest.class);
	    	Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	i.putExtra("timeout", Integer.valueOf(5000));
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
			i.putExtra("target", target);
	    	return i;
		}
		else if (menuId == R.id.cad) {
			Log.i(TAG, "G+J EMS ConnectAd");
			Intent target = new Intent(context, GuJEMSSDKTestConnectAd.class);
	    	Intent i = new Intent(context, InterstitialSwitchActivity.class);
	    	i.putExtra("timeout", Integer.valueOf(15000));
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
	    	i.putExtra("target", target);
	    	return i;
		}
		else if (menuId == R.id.relative) {
			Log.i(TAG, "GuJEMSAdView in Relative Layout");
			Intent i = new Intent(context, InterstitialSwitchReceiver.class);
			Intent target = new Intent(context, RelativeLayoutTest.class);
	    	i.putExtra("timeout", Integer.valueOf(5000));
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
	    	i.putExtra("target", target);
/*
	    	i.putExtra("ems_onAdSuccess", new IOnAdSuccessListener() {
				
				private static final long serialVersionUID = 1L;

				@Override
				public void onAdSuccess() {
					SdkLog.i(TAG, "InterstitialSwitchReceiver ADSUCCESS");
					
				}
			});
	    	i.putExtra("ems_onAdError", new IOnAdErrorListener() {
				
				private static final long serialVersionUID = 2L;

				@Override
				public void onAdError(String msg) {
					SdkLog.e(TAG, "InterstitialSwitchReceiver ADERROR " + msg);
					
				}
				@Override
				public void onAdError(String msg, Throwable t) {
					SdkLog.e(TAG, "InterstitialSwitchReceiver ADERROR " + msg, t);
					
				}				
			});
	    	i.putExtra("ems_onAdEmpty", new IOnAdEmptyListener() {
				
				private static final long serialVersionUID = 3L;

				@Override
				public void onAdEmpty() {
					SdkLog.w(TAG, "InterstitialSwitchReceiver ADEMPTY");
					
				}
			});
*/			
	    	return i;
		}
		else if (menuId == R.id.targeting) {
			Log.i(TAG, "G+J EMS Targeting");
			Intent target = new Intent(context, GuJEMSSDKTestTargeting.class);
	    	Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
	    	i.putExtra("target", target);
	    	return i;
		}		
		else if (menuId == R.id.xl) {
			Log.i(TAG, "G+J EMS XL");
			Intent target = new Intent(context, GuJEMSSDKTestXL.class);
	    	Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
	    	i.putExtra("target", target);
	    	return i;
		}
		else if (menuId == R.id.sowefo) {
			Log.i(TAG, "G+J EMS SoWeFo");
			Intent target = new Intent(context, GuJEMSSDKTestSoWeFo.class);
	    	Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
	    	i.putExtra("target", target);
	    	return i;
		}
		else if (menuId == R.id.adReload) {
			
		}
		else if (menuId == R.id.preRoll) {
			Log.i(TAG, "G+J EMS PreRolls");
			double rand = Math.random();
			Intent target = new Intent(context, VideoPlayer.class);
			Log.i(TAG, rand >= 0.5 ? "Wrapped Video Interstitial" : "Video Interstitial");
			Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	i.putExtra("ems_zoneId", rand >= 0.5 ? "9002" : "9001");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("unmuted", Boolean.valueOf(true));
	    	i.putExtra("target", target);
	    	return i;						
		}
		
		return null;

	}


}
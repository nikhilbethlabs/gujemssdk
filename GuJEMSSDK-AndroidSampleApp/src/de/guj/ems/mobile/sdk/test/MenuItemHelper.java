package de.guj.ems.mobile.sdk.test;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import de.guj.ems.mobile.sdk.controllers.InterstitialSwitchReceiver;

/**
 * This is a helper class for the menu
 * Each menu entry triggers an activity,
 * but before showing it we try to 
 * fetch an interstitial
 * 
 * @author stein16
 *
 */
public class MenuItemHelper {
	
	private final static String TAG = "MenuItemHelper";
	
	public static Intent getTargetIntent(Context context, int menuId) {

		if (menuId == R.id.video) {
			double rand = Math.random();
			Log.i(TAG, rand >= 0.5 ? "Wrapped Video Interstitial" : "Video Interstitial");
			// get the interstitial receiver's intent
			Intent i = new Intent(context, InterstitialSwitchReceiver.class);
	    	// configure it, this interstitial has no target,
			// i.e. it returns to the previous activity when finishing
			i.putExtra("ems_zoneId", rand >= 0.5 ? "9002" : "9001");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	//i.putExtra("unmuted", Boolean.valueOf(true));
	    	return i;			
		}
		else if (menuId == R.id.table) {
			Log.i(TAG, "GuJEMSAdView in TableView");
			// add a target activity to the interstitial
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
		else if (menuId == R.id.list_native) {
			Log.i(TAG, "G+J EMS ListView (native)");
			Intent target = new Intent(context, NativeListViewTest.class);
	    	Intent i = new Intent(context, InterstitialSwitchReceiver.class);
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
	    	return i;
		}
		else if (menuId == R.id.relative_native) {
			Log.i(TAG, "GuJEMSAdView in Relative Layout");
			Intent i = new Intent(context, InterstitialSwitchReceiver.class);
			Intent target = new Intent(context, NativeRelativeLayoutTest.class);
	    	i.putExtra("timeout", Integer.valueOf(5000));
	    	i.putExtra("ems_zoneId", "15310");
	    	i.putExtra("ems_uid", Boolean.valueOf(true));
	    	i.putExtra("ems_geo",Boolean.valueOf(true));
	    	i.putExtra("ems_kw", Boolean.valueOf(true));
	    	i.putExtra("ems_nkw", Boolean.valueOf(true));
	    	i.putExtra("target", target);
	    	return i;
		}
		else if (menuId == R.id.targeting) {
			Log.i(TAG, "G+J EMS Targeting");
			Intent target = new Intent(context, TargetingTest.class);
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
			Intent target = new Intent(context, XLBannerTest.class);
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
			Intent target = new Intent(context, ORMMATest.class);
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
			// ignored because it is handled by the current activity
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

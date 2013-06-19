package de.guj.ems.mobile.sdk.util;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;

public class Targeting {

	private final static String TAG = "Targeting";
	
	private int batteryPercent;
	
	private boolean hasBatteryStatus;
	
	private boolean headsetConnected;
	
	private boolean hasHeadsetStatus;
	
	private BroadcastReceiver batteryInfoReceiver = new BroadcastReceiver() {
		
		public void onReceive(Context c, Intent intent) {
			batteryPercent = intent.getIntExtra(BatteryManager.EXTRA_LEVEL,0);
			hasBatteryStatus = true;
		}
		
	};
	
	private BroadcastReceiver headsetInfoReceiver = new BroadcastReceiver() {
		
		public void onReceive (Context c, Intent intent) {
			headsetConnected = intent.getIntExtra("status", 0) == 1;
			hasHeadsetStatus = true;
		}
		
	};
	
	public Targeting (Context c) {
		register(c);
	}
	
	private void register(Context c) {
		c.registerReceiver(this.batteryInfoReceiver, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
		c.registerReceiver(this.headsetInfoReceiver, new IntentFilter(Intent.ACTION_HEADSET_PLUG));
	}
	
	public void unregister(Context c) {
		c.unregisterReceiver(this.batteryInfoReceiver);
		c.unregisterReceiver(this.headsetInfoReceiver);
	}
	
	/**
	 * Returns the Android battery level received from BatteryManager
	 * @return battery level or -1 if nothing was received yet
	 */
	public int getBatteryPercent() {
		SdkLog.i(TAG, "ems_battery: status requested.");
		if (this.hasBatteryStatus) {
			return this.batteryPercent;
		}
		else  {
			SdkLog.w(TAG, "ems_battery: no status receveived yet.");
			return -1;
		}
	}
	
	/**
	 * Returns boolean indicating whether headset is connected to phone
	 * @return true if headset is connected, false if not
	 */
	public boolean headsetConnected() {
		SdkLog.i(TAG, "ems_headset: status requested.");
		if (this.hasHeadsetStatus) {
			return this.headsetConnected;
		}
		else  {
			SdkLog.w(TAG, "ems_headset: no status receveived yet.");
			return false;
		}		
	}
	
}

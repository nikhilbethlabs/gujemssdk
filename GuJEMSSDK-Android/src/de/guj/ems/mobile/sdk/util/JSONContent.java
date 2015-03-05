package de.guj.ems.mobile.sdk.util;

import org.json.JSONObject;

import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;

/**
 * Singleton that holds the data fetched from a remote json file
 * 
 * 
 * @author stein16
 * 
 */
abstract class JSONContent {

	private JSONObject json;

	JSONContent() {
		init();
	}

	synchronized protected void feed(JSONObject j) {
		this.json = j;
	}

	synchronized JSONObject getJSON() {
		return this.json;
	}

	String getRemotePath() {
		return SdkUtil.getContext().getPackageName().replaceAll("\\.", "/")
				+ (SdkUtil.isLargerThanPhone() ? "/xl/" : "/");
	}

	abstract void init();

	public abstract IAdServerSettingsAdapter process(
			IAdServerSettingsAdapter settings);

}

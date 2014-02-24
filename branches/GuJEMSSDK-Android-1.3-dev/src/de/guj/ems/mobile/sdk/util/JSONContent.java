package de.guj.ems.mobile.sdk.util;

import org.json.JSONObject;

/**
 * Singleton that holds the data fetched from a remote json file
 * 
 * 
 * @author stein16
 * 
 */
public abstract class JSONContent {

	private JSONObject json;

	JSONContent() {
		if (json == null) {
			init();
		}
	}

	String getRemotePath() {
		return SdkUtil.getContext().getPackageName().replaceAll("\\.", "/")
				+ "/";
	}

	abstract void init();

	synchronized protected void feed(JSONObject j) {
		this.json = j;
	}

	public abstract String process(String url);

}

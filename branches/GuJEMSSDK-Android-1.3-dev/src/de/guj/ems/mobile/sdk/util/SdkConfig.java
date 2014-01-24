package de.guj.ems.mobile.sdk.util;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import de.guj.ems.mobile.sdk.R;

public enum SdkConfig {
	SINGLETON;
	
	private final static String TAG = "SdkConfig";
	
	private JSONObject jsonSdkConfig;
	
	SdkConfig() {
		if (jsonSdkConfig == null) {
			init();
		}
	}
	
	String getRemotePath() {
		return SdkUtil.getContext().getPackageName().replaceAll("\\.", "/") + "/";
	}
	
	void init() {
		SdkConfigFetcher fetcher = new SdkConfigFetcher(SdkUtil.getContext().getResources().getString(R.string.ems_remote_config_root) + getRemotePath() + "config.json",  SdkUtil.getConfigFileDir());
		feed(fetcher.getLocalConfig());
		fetcher.execute();
	}
	
	synchronized protected void feed(JSONObject jsonConfig) {
		jsonSdkConfig = jsonConfig;
	}
	
	public String process(String url) {
		if (jsonSdkConfig != null) {
			try {
				JSONArray regexp = jsonSdkConfig.getJSONArray("urlReplace");
				String nURL = url.replaceAll(SdkUtil.getContext().getString(
						R.string.baseUrl), jsonSdkConfig.getString("baseUrl"));
				SdkLog.d(TAG, "Processing URL " + url);
				for (int i = 0; i < regexp.length(); i++) {
					JSONArray regexpn = regexp.getJSONArray(i);
					nURL = nURL.replaceAll(regexpn.getString(0),regexpn.getString(1));
				}
				
				return jsonSdkConfig.getString("urlAppend") != null ? nURL.concat(jsonSdkConfig.getString("urlAppend")) : nURL;
				//TODO additional keywords?
				/*
				if (jsonSdkConfig.getString("additionalKeyword") != null) {
					if nURL.indexOf("kw)
				}
				*/
			}
			catch (JSONException e) {
				SdkLog.e(TAG, "Error processing json config", e);
			
			}			
		}
		else {
			SdkLog.w(TAG, "JSON config not yet loaded upon processing " + url);
		}
		
		return url;		
		
	}
	
}



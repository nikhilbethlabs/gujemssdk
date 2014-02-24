package de.guj.ems.mobile.sdk.util;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import de.guj.ems.mobile.sdk.R;

/**
 * Singleton that holds the data fetched from a remote json file
 * 
 * The json contains: alternative base url for adserver URL manipulation based
 * on regular expressions URL manipulation based on simple concatenation URL
 * manipulation based on additional keywords
 * 
 * @author stein16
 * 
 */
public enum SdkConfig {
	SINGLETON;

	private JSONObject jsonSdkConfig;

	public class JSONConfig extends JSONContent {

		@Override
		void init() {
			JsonFetcher fetcher = new JsonFetcher(this, SdkUtil.getContext()
					.getResources().getString(R.string.ems_jws_root)
					+ getRemotePath() + "config.json",
					SdkUtil.getConfigFileDir());
			feed(fetcher.getJson());
			fetcher.execute();
		}

		@Override
		public String process(String url) {
			if (jsonSdkConfig != null) {
				try {
					JSONArray regexp = jsonSdkConfig.getJSONArray("urlReplace");
					String nURL = url.replaceAll(SdkUtil.getContext()
							.getString(R.string.baseUrl), jsonSdkConfig
							.getString("baseUrl"));
					SdkLog.d(TAG, "Processing URL " + url);
					// process regexp replacements
					for (int i = 0; i < regexp.length(); i++) {
						JSONArray regexpn = regexp.getJSONArray(i);
						nURL = nURL.replaceAll(regexpn.getString(0),
								regexpn.getString(1));
					}
					// additional keywords
					// TODO debug / check whether works correctly
					// TODO &kw= is amobee specific
					if (jsonSdkConfig.getString("additionalKeyword") != null) {
						if (nURL.indexOf("&kw=") >= 0) {
							nURL = nURL
									.replaceAll(
											"(&kw=)(.*&)",
											"$1"
													+ jsonSdkConfig
															.getString("additionalKeyword")
													+ "|$2");
						} else {
							nURL = nURL.concat("&kw="
									+ jsonSdkConfig
											.getString("additionalKeyword"));
						}
					}
					// query extensions
					return jsonSdkConfig.getString("urlAppend") != null ? nURL
							.concat(jsonSdkConfig.getString("urlAppend"))
							: nURL;

				} catch (JSONException e) {
					SdkLog.e(TAG, "Error processing json config", e);

				}
			} else {
				SdkLog.w(TAG, "JSON config not yet loaded upon processing "
						+ url);
			}

			return url;
		}
		
	}

	private final static String TAG = "SdkConfig";

	private JSONConfig jsonConfig;

	SdkConfig() {
		this.jsonConfig = new JSONConfig();
	}

	public JSONConfig getJsonConfig() {
		return this.jsonConfig;
	}

	String getRemotePath() {
		return SdkUtil.getContext().getPackageName().replaceAll("\\.", "/")
				+ "/";
	}

}

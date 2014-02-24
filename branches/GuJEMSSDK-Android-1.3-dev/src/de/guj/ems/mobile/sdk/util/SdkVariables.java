package de.guj.ems.mobile.sdk.util;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import de.guj.ems.mobile.sdk.R;

/**
 * Singleton that holds the data fetched from a remote json file
 * 
 * The json contains: variables returned from a webservive which are added to the adserver request
 * 
 * @author stein16
 * 
 */
public enum SdkVariables {
	SINGLETON;

	private JSONObject jsonSdkVariables;

	public class JSONVariables extends JSONContent {

		@Override
		void init() {
			JsonFetcher fetcher = new JsonFetcher(this, SdkUtil.getContext()
					.getResources().getString(R.string.ems_jws_root)
					+ getRemotePath() + "config.json", "variables.json",
					SdkUtil.getConfigFileDir(), 1800000);
			feed(fetcher.getJson());
			fetcher.execute();
		}

		@Override
		public String process(String url) {
			if (jsonSdkVariables != null) {
				try {
					JSONArray regexp = jsonSdkVariables
							.getJSONArray("urlReplace");
					String nURL = url.replaceAll(SdkUtil.getContext()
							.getString(R.string.baseUrl), jsonSdkVariables
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
					if (jsonSdkVariables.getString("additionalKeyword") != null) {
						if (nURL.indexOf("&kw=") >= 0) {
							nURL = nURL
									.replaceAll(
											"(&kw=)(.*&)",
											"$1"
													+ jsonSdkVariables
															.getString("additionalKeyword")
													+ "|$2");
						} else {
							nURL = nURL.concat("&kw="
									+ jsonSdkVariables
											.getString("additionalKeyword"));
						}
					}
					// query extensions
					return jsonSdkVariables.getString("urlAppend") != null ? nURL
							.concat(jsonSdkVariables.getString("urlAppend"))
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

	private final static String TAG = "SdkVariables";

	private JSONVariables jsonVariables;

	SdkVariables() {
		this.jsonVariables = new JSONVariables();
	}

	public JSONVariables getJsonVariables() {
		return this.jsonVariables;
	}

	String getRemotePath() {
		return SdkUtil.getContext().getPackageName().replaceAll("\\.", "/")
				+ "/";
	}

}

package de.guj.ems.mobile.sdk.util;

import java.util.Map;

import org.json.JSONException;

import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;

/**
 * Singleton that holds the data fetched from a remote json file
 * 
 * The json contains: variables returned from a webservice which are added to
 * the adserver request
 * 
 * @author stein16
 * 
 */
enum SdkVariables {
	SINGLETON;

	public class JSONVariables extends JSONContent {

		@Override
		void init() {
			fetcher = new JSONFetcher(this, SdkUtil.getContext().getResources()
					.getString(R.string.ems_jws_root)
					+ SdkUtil.getContext().getResources()
							.getString(R.string.jsonVariablesScript), SdkUtil
					.getContext()
					.getString(R.string.jsonLocalVariablesFileName),
					SdkUtil.getConfigFileDir(),
					SdkConfig.SINGLETON.getVarsRefreshCap() * 60000);
			// feed initially available json
			feed(fetcher.getJson());
			// add query string to variables service
			fetcher.addQueryString(getQueryString());
			// check for newer remote json
			fetcher.execute();

			lastFetched = System.currentTimeMillis();
		}

		@Override
		public IAdServerSettingsAdapter process(
				IAdServerSettingsAdapter settings) {
			if (getJSON() != null) {
				try {
					// TODO "additionalParams" applied twice for request?
					synchronized (settings) {
						// check additional keywords
						SdkLog.d(TAG, "Adding keywords and params to "
								+ settings);
						String kw = getJSON().getString(
								SdkUtil.getContext().getString(
										R.string.jsonKeyword));
						if (kw != null) {
							Map<String, String> params = settings.getParams();
							if (params.get(SdkGlobals.EMS_KEYWORDS) != null) {
								settings.addCustomRequestParameter(
										SdkGlobals.EMS_KEYWORDS, (params
												.get(SdkGlobals.EMS_KEYWORDS)
												.concat("|")).concat(kw));
							} else {
								settings.addCustomRequestParameter(
										SdkGlobals.EMS_KEYWORDS, kw);
							}

						}
						// query extensions
						String append = getJSON().getString(
								SdkUtil.getContext().getString(
										R.string.jsonUrlAppend));
						if (append != null) {
							settings.addQueryAppendix(append);
						}
					}

				} catch (JSONException e) {
					SdkLog.e(TAG, "Error processing json config", e);

				}
			} else {
				SdkLog.w(TAG, "JSON config not yet loaded upon processing "
						+ settings.getRequestUrl());
			}

			if (lastFetched > 0) {
				timeCheck();
			}

			settings.dontProcess();
			return settings;
		}

	}

	private long lastFetched;

	private JSONFetcher fetcher;

	private final static String TAG = "SdkVariables";

	private JSONVariables jsonVariables;

	SdkVariables() {
		this.jsonVariables = new JSONVariables();
	}

	/**
	 * Returns the complete fetched json object
	 * 
	 * @return json variables
	 */
	public JSONVariables getJsonVariables() {
		return this.jsonVariables;
	}

	private String getQueryString() {
		double[] loc = SdkUtil.getLocation();
		if (loc != null) {
			char[] encTable = { 'z', 'y', 'x', 'w', 'v', 'u', 't', 's', 'r',
					'q' };
			String str = loc[0] < 0.0 ? "1" : "0";
			int off = loc[0] < 0.0 ? 1 : 0;
			String l0d = String.valueOf((int) loc[0]);
			String l0f = String
					.valueOf((int) ((loc[0] - (int) loc[0]) * 100.0));
			String l1d = String.valueOf((int) loc[1]);
			String l1f = String
					.valueOf((int) ((loc[1] - (int) loc[1]) * 100.0));
			for (int l0 = 3; l0 > l0d.length(); l0--)
				str += encTable[0];
			for (int i = off; i < l0d.length(); i++) {
				str += encTable[l0d.charAt(i) - 48];
			}
			if ((int) ((loc[0] - (int) loc[0]) * 100.0) < 0) {
				l0f = l0f.substring(1);
			}
			if ((int) ((loc[0] - (int) loc[0]) * 100.0) < 10) {
				l0f = "0" + l0f;
			}
			str += encTable[l0f.charAt(0) - 48];
			str += encTable[l0f.charAt(1) - 48];
			str += loc[1] < 0.0 ? "1" : "0";
			off = loc[1] < 0.0 ? 1 : 0;
			for (int l1 = 3; l1 > l1d.length(); l1--)
				str += encTable[0];
			for (int j = off; j < l1d.length(); j++) {
				str += encTable[l1d.charAt(j) - 48];
			}
			if ((int) ((loc[1] - (int) loc[1]) * 100.0) < 0) {
				l1f = l1f.substring(1);
			}
			if ((int) ((loc[1] - (int) loc[1]) * 100.0) < 10) {
				l1f = "0" + l1f;
			}
			str += encTable[l1f.charAt(0) - 48];
			str += encTable[l1f.charAt(1) - 48];

			String idfa = SdkUtil.getIdForAdvertiser();
			if (idfa != null) {
				str += "&" + R.string.pIdForAdvertiser + "=" + idfa;
				str += "&" + R.string.pGuJIdForAdvertiser + "=" + idfa;
			}

			return str;

		}

		return null;
	}

	private void timeCheck() {
		long t = System.currentTimeMillis() - lastFetched;
		if (t > SdkConfig.SINGLETON.getVarsRefreshCap() * 60000l) {
			SdkLog.d(TAG, "Reinitializing variables after " + (t / 60000l)
					+ " minutes. [t = " + t + "]");
			jsonVariables.init();
		}
	}

}

package de.guj.ems.mobile.sdk.util;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;

import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;

/**
 * Singleton that holds the data fetched from a remote json file
 * 
 * The json contains: alternative base url for adserver URL manipulation based
 * on regular expressions, URL manipulation based on simple concatenation, URL
 * manipulation based on additional keywords, different adserver servlets for
 * different apns, a refresh cap for the variables service
 * 
 * @author stein16
 * 
 */
enum SdkConfig {
	SINGLETON;

	public class JSONConfig extends JSONContent {

		private void checkApn() {
			String nName = SdkUtil.getNetworkName();
			if (nName.indexOf("vodafone") >= 0) {
				apn = VODAFONE_APN;
			} else if (nName.indexOf("o2") >= 0) {
				apn = TELEFONICA_APN;
			} else {
				apn = UNKNOWN_APN;
			}
		}

		@Override
		void init() {
			SdkLog.i(TAG, (SdkUtil.isLargerThanPhone() ? "" : "Not ")
					+ "assuming tablet or larger device.");
			if (SdkUtil.getContext()
					.getResources().getBoolean(R.bool.ems_remote_cfg)) {
				JSONFetcher fetcher = new JSONFetcher(this, SdkUtil.getContext()
						.getResources().getString(R.string.ems_jws_root)
						+ getRemotePath()
						+ SdkUtil.getContext().getString(
								R.string.jsonRemoteConfigFileName), SdkUtil
						.getContext().getString(R.string.jsonLocalConfigFileName),
						SdkUtil.getConfigFileDir());
				// feed initially available json
				feed(fetcher.getJson());
				// try fetching newer json
				fetcher.execute();
			}
		}

		@Override
		public IAdServerSettingsAdapter process(
				IAdServerSettingsAdapter settings) {
			if (getJSON() != null) {
				try {
					// parse variables service refresh cap
					try {
						varsRefreshCapMin = getJSON().getInt(
								SdkUtil.getContext().getString(
										R.string.jsonRefreshCapVariables));
					} catch (Exception e) {
						SdkLog.w(TAG,
								"Variables refresh cap is not set in config json.");
						varsRefreshCapMin = 30;
					}
					// set base url by apn
					try {
						setBaseUrl(settings);
					} catch (Exception e) {
						SdkLog.e(TAG, "Could not set baseUrl!", e);
					}
					// TODO process JSON reading only once?
					// add regular expressions for query string replacements
					JSONArray reg = getJSON().getJSONArray(
							SdkUtil.getContext().getString(
									R.string.jsonUrlReplace));
					if (reg != null) {
						settings.addRegexp(reg);
					}
					// check additional keywords
					String kw = getJSON().getString(
							SdkUtil.getContext()
									.getString(R.string.jsonKeyword));
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

				} catch (JSONException e) {
					SdkLog.e(TAG, "Error processing json config", e);

				}
			} else {
				SdkLog.w(TAG, "JSON config not yet loaded upon processing "
						+ settings.getRequestUrl());
			}

			return settings;
		}

		private void setBaseUrl(IAdServerSettingsAdapter settings)
				throws Exception {
			if (apn < 0) {
				checkApn();
			}
			switch (apn) {
			case VODAFONE_APN:
				SdkLog.i(TAG, "Found Vodafone APN.");
				try {
					String vfUrl = getJSON().getString(
							SdkUtil.getContext().getString(
									R.string.jsonBaseUrlVodafone));
					if (vfUrl != null) {
						settings.setBaseUrlString(vfUrl);
					}
				} catch (Exception e) {
					SdkLog.w(TAG, "Could not set base URL for Vodafone.");
				}
				break;
			case TELEFONICA_APN:
				try {
					SdkLog.i(TAG, "Found Telefonica APN.");
					String o2Url = getJSON().getString(
							SdkUtil.getContext().getString(
									R.string.jsonBaseUrlTelefonica));
					if (o2Url != null) {
						settings.setBaseUrlString(o2Url);
					}
				} catch (Exception e) {
					SdkLog.w(TAG, "Could not set base URL for Telefonica.");
				}
				break;
			default:
				SdkLog.i(TAG, "Found unknown APN.");
				try {
					String defUrl = getJSON().getString(
							SdkUtil.getContext().getString(
									R.string.jsonBaseUrlDefault));
					settings.setBaseUrlString(defUrl);
				} catch (Exception e) {
					SdkLog.w(TAG, "Could not set base URL.");
				}
			}
		}
	}

	private static final int VODAFONE_APN = 0;

	private static final int TELEFONICA_APN = 1;

	private static final int UNKNOWN_APN = 2;

	private int varsRefreshCapMin = 0;

	private int apn = -1;

	private final static String TAG = "SdkConfig";

	private JSONConfig jsonConfig;

	SdkConfig() {
		this.jsonConfig = new JSONConfig();
	}

	/**
	 * Returns the complete fetched json object
	 * 
	 * @return json config
	 */
	public JSONConfig getJsonConfig() {
		return this.jsonConfig;
	}

	/**
	 * Returns the refresh cap value for variables in fetching in minutes
	 * 
	 * @return refresh cap in minutes
	 */
	public int getVarsRefreshCap() {
		return varsRefreshCapMin > 0 ? varsRefreshCapMin : 30;
	}

}

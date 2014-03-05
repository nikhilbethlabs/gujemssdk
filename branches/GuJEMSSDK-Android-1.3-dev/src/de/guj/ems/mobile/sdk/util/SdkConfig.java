package de.guj.ems.mobile.sdk.util;

import java.util.Map;

import org.json.JSONException;

import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;

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

	private static final int VODAFONE_APN = 0;

	private static final int TELEFONICA_APN = 1;

	private static final int UNKNOWN_APN = 2;

	private int apn = -1;

	public class JSONConfig extends JSONContent {

		@Override
		void init() {
			JSONFetcher fetcher = new JSONFetcher(this, SdkUtil.getContext()
					.getResources().getString(R.string.ems_jws_root)
					+ getRemotePath()
					+ SdkUtil.getContext().getString(
							R.string.jsonRemoteConfigFileName), SdkUtil
					.getContext().getString(R.string.jsonLocalConfigFileName),
					SdkUtil.getConfigFileDir());
			feed(fetcher.getJson());
			fetcher.execute();
		}

		private void checkApn() {
			String nName = SdkUtil.getNetworkName();
			if (nName.indexOf("vodafone") >= 0) {
				apn = VODAFONE_APN;
			}
			else if ("internet".equals(nName)) {
				apn = TELEFONICA_APN;
			}
			else {
				apn = UNKNOWN_APN;
			}
		}
		
		private void setBaseUrl(IAdServerSettingsAdapter settings) throws Exception {
			if (apn < 0) {
				checkApn();
				switch (apn) {
				case VODAFONE_APN:
						SdkLog.i(TAG, "Found Vodafone APN.");
						break;
				case TELEFONICA_APN:
					SdkLog.i(TAG, "Found Telefonica APN.");
					break;						
				default:
					SdkLog.i(TAG, "Found unknown APN.");
				}
			}
			if (getJSON().getString(
					SdkUtil.getContext().getString(
							R.string.jsonBaseUrlVodafone)) != null && apn == VODAFONE_APN) {
				settings.setBaseUrlString(getJSON().getString(
						SdkUtil.getContext().getString(
								R.string.jsonBaseUrlVodafone)));
			}
			else if (getJSON().getString(
					SdkUtil.getContext().getString(
							R.string.jsonBaseUrlTelefonica)) != null && apn == TELEFONICA_APN) {
				settings.setBaseUrlString(getJSON().getString(
						SdkUtil.getContext().getString(
								R.string.jsonBaseUrlTelefonica)));
			}
			else if (getJSON().getString(
					SdkUtil.getContext().getString(
							R.string.jsonBaseUrlDefault)) != null) {
				settings.setBaseUrlString(getJSON().getString(
						SdkUtil.getContext().getString(
								R.string.jsonBaseUrlDefault)));
			}			
		}

		@Override
		public IAdServerSettingsAdapter process(
				IAdServerSettingsAdapter settings) {
			if (getJSON() != null) {
				try {
					
					try {
						setBaseUrl(settings);
					}
					catch (Exception e) {
						SdkLog.e(TAG, "Could not set baseUrl!", e);
					}

					settings.addRegexp(getJSON().getJSONArray(
							SdkUtil.getContext().getString(
									R.string.jsonUrlReplace)));

					if (getJSON().getString(
							SdkUtil.getContext()
									.getString(R.string.jsonKeyword)) != null) {
						Map<String, String> params = settings.getParams();
						if (params.get(SdkGlobals.EMS_KEYWORDS) != null) {
							String newKw = (params.get(SdkGlobals.EMS_KEYWORDS).concat("|"))
									.concat(getJSON().getString(
											SdkUtil.getContext().getString(
													R.string.jsonKeyword)));
							params.put(SdkGlobals.EMS_KEYWORDS, newKw);
						} else {
							params.put(
									SdkGlobals.EMS_KEYWORDS,
									getJSON().getString(
											SdkUtil.getContext().getString(
													R.string.jsonKeyword)));
						}
					}
					// query extensions
					if (getJSON().getString(
							SdkUtil.getContext().getString(
									R.string.jsonUrlAppend)) != null) {
						settings.setQueryAppendix(SdkUtil.getContext()
								.getString(R.string.jsonUrlAppend));
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

	}

	private final static String TAG = "SdkConfig";

	private JSONConfig jsonConfig;

	SdkConfig() {
		this.jsonConfig = new JSONConfig();
	}

	public JSONConfig getJsonConfig() {
		return this.jsonConfig;
	}

}

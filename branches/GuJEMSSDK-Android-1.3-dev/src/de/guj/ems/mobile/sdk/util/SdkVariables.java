package de.guj.ems.mobile.sdk.util;

import java.util.Map;

import org.json.JSONException;

import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.adserver.IAdServerSettingsAdapter;

/**
 * Singleton that holds the data fetched from a remote json file
 * 
 * The json contains: variables returned from a webservive which are added to
 * the adserver request
 * 
 * @author stein16
 * 
 */
public enum SdkVariables {
	SINGLETON;

	public class JSONVariables extends JSONContent {

		@Override
		void init() {
			JSONFetcher fetcher = new JSONFetcher(this, SdkUtil.getContext()
					.getResources().getString(R.string.ems_jws_root)
					+ SdkUtil.getContext().getResources()
							.getString(R.string.jsonVariablesScript), SdkUtil
					.getContext()
					.getString(R.string.jsonLocalVariablesFileName),
					SdkUtil.getConfigFileDir(), 1800000);
			feed(fetcher.getJson());
			fetcher.execute();
			
		}

		@Override
		public IAdServerSettingsAdapter process(IAdServerSettingsAdapter settings) {
			if (getJSON() != null) {
				try {
					// query extensions
					if (getJSON().getString(
							SdkUtil.getContext().getString(
									R.string.jsonUrlAppend)) != null) {
						settings.setQueryAppendix("&" + SdkUtil.getContext().getString(
									R.string.jsonUrlAppend));
					}

					if (getJSON().getString(
							SdkUtil.getContext()
									.getString(R.string.jsonKeyword)) != null) {
						Map<String,String> params = settings.getParams();
						if (params.get(SdkGlobals.EMS_KEYWORDS) != null) {
							String newKw = (params.get(SdkGlobals.EMS_KEYWORDS).concat("|")).concat(getJSON().getString(SdkUtil.getContext()
									.getString(R.string.jsonKeyword)));
							params.put(SdkGlobals.EMS_KEYWORDS, newKw);
						}
						else {
							params.put(SdkGlobals.EMS_KEYWORDS, getJSON().getString(SdkUtil.getContext()
									.getString(R.string.jsonKeyword)));						
						}
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

	private final static String TAG = "SdkVariables";

	private JSONVariables jsonVariables;

	SdkVariables() {
		this.jsonVariables = new JSONVariables();
	}

	public JSONVariables getJsonVariables() {
		return this.jsonVariables;
	}

	String getRemotePath() {
		return "";
	}

}

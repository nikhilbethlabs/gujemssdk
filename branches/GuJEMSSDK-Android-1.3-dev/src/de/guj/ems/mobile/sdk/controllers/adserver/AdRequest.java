package de.guj.ems.mobile.sdk.controllers.adserver;

import android.os.AsyncTask;
import android.os.Build;
import de.guj.ems.mobile.sdk.controllers.IAdResponseHandler;
import de.guj.ems.mobile.sdk.util.SdkConfig;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkVariables;

/**
 * Performs HTTP communication in the background, i.e. off the UI thread.
 * 
 * Pass the URL to the execute-Method when actually fetching an ad.
 * 
 * @author stein16
 * 
 */
public abstract class AdRequest extends AsyncTask<IAdServerSettingsAdapter, Void, IAdResponse> {

	private final String TAG = "AdRequest";

	private IAdResponseHandler responseHandler;

	private Throwable lastError;

	@SuppressWarnings("unused")
	private AdRequest() {

	}

	/**
	 * Standard constructor
	 * 
	 * @param handler
	 *            instance of a class handling ad server responses (like
	 *            GuJEMSAdView, InterstitialSwitchActivity)
	 * 
	 */
	public AdRequest(IAdResponseHandler handler) {
		this.responseHandler = handler;
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.FROYO) {
			System.setProperty("http.keepAlive", "false");
		}
	}

	protected abstract IAdResponse httpGet(String url);

	@Override
	protected IAdResponse doInBackground(IAdServerSettingsAdapter... settings) {
		IAdResponse response = null;
		for (IAdServerSettingsAdapter set : settings) {
			if (set.doProcess()) {
				IAdServerSettingsAdapter nSet = SdkVariables.SINGLETON.getJsonVariables().process(
						SdkConfig.SINGLETON.getJsonConfig().process(set));
				response = httpGet(nSet.getRequestUrl());
			}
			else {
				response = httpGet(set.getRequestUrl());
			}
		}
		return response;
	}

	@Override
	protected void onPostExecute(IAdResponse response) {
		SdkLog.d(TAG, "onPostExecute(" + response + ")");
		if (this.responseHandler != null && lastError == null) {
			SdkLog.d(TAG, "Passing to handler " + responseHandler);
			this.responseHandler.processResponse(response);
		} else if (this.responseHandler != null && lastError != null) {
			SdkLog.d(TAG, "Passing to handler " + responseHandler);
			this.responseHandler
					.processError(lastError.getMessage(), lastError);
		} else if (lastError != null) {
			SdkLog.e(TAG, "Error post processing request", lastError);
		} else {
			SdkLog.d(TAG, "No response handler");
		}
	}

	protected IAdResponseHandler getResponseHandler() {
		return this.responseHandler;
	}

	protected Throwable getLastError() {
		return this.lastError;
	}

	protected void setLastError(Throwable t) {
		this.lastError = t;
	}

}
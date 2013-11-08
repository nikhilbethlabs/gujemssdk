/**
 * 
 */
package de.guj.ems.mobile.sdk.activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import de.guj.ems.mobile.sdk.controllers.BackfillDelegator;
import de.guj.ems.mobile.sdk.controllers.BackfillDelegator.BackfillData;
import de.guj.ems.mobile.sdk.controllers.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.util.SdkLog;

/**
 * @author stein16
 *
 */
public class VideoAdSDKWrapperActivity extends Activity {
	
	private final String TAG = "VideoAdSDKWrapperActivity";
	
	private IAdServerSettingsAdapter settings;
	
	private BackfillData backfillData;
	
	private Intent target;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.settings = (IAdServerSettingsAdapter) getIntent().getExtras().get("settings");
		this.backfillData = (BackfillData) getIntent().getExtras().get("delegator");
		this.target = (Intent) getIntent().getExtras().get("target");
		
		try {

			BackfillDelegator.process(getApplicationContext(), backfillData,
					new BackfillDelegator.BackfillCallback() {
						@Override
						public void trackEventCallback(String arg0) {
							SdkLog.d(TAG, "Backfill: An event occured ["
									+ arg0 + "]");
						}

						@Override
						public void noAdCallback() {
							SdkLog.d(TAG, "Backfill: empty.");
							if (settings.getOnAdEmptyListener() != null) {
								settings.getOnAdEmptyListener().onAdEmpty();
							}
							if (target != null) {
								getApplicationContext().startActivity(target);
							} else {
								SdkLog.i(TAG,
										"No target. Back to previous view.");
							}
						}

						@Override
						public void finishedCallback() {
							if (target != null) {
								getApplicationContext().startActivity(target);
							} else {
								SdkLog.i(TAG,
										"No target. Back to previous view.");
							}
						}

						@Override
						public void adFailedCallback(Exception e) {

							if (settings.getOnAdErrorListener() != null) {
								settings.getOnAdErrorListener().onAdError(
										"Backfill exception", e);
							} else {
								SdkLog.e(TAG,
										"Backfill: An exception occured.",
										e);
							}
							if (target != null) {
								getApplicationContext().startActivity(target);
							} else {
								SdkLog.i(TAG,
										"No target. Back to previous view.");
							}
						}

						@Override
						public void receivedAdCallback() {
							if (settings.getOnAdSuccessListener() != null) {
								settings.getOnAdSuccessListener()
										.onAdSuccess();
							}
						}

					});

		} catch (BackfillDelegator.BackfillException bfE) {
			processError("Backfill error thrown.", bfE);
		}
	}
	
	public void processError(String msg, Throwable t) {
		if (this.settings.getOnAdErrorListener() != null) {
			this.settings.getOnAdErrorListener().onAdError(msg, t);
		} else {
			SdkLog.e(TAG, msg, t);
		}
		if (target != null) {
			getApplicationContext().startActivity(target);
		} else {
			SdkLog.i(TAG, "No target. Back to previous view.");
		}
	}	

}

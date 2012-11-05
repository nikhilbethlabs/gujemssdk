package de.guj.ems.mobile.sdk.activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.controllers.AdServerAccess;
import de.guj.ems.mobile.sdk.controllers.AmobeeSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.BackfillDelegator;
import de.guj.ems.mobile.sdk.controllers.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.util.Connectivity;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.UserAgentHelper;

/**
 * The IntestitialSwitchActivity acts as a switch when showing a new Android
 * Activity. It determines whether an interstitial should and can be shown. If
 * an interstitial is returned by the ad server, it is shown with the
 * InterstitialActivity. If not, the original target activity is shown.
 * 
 * When starting this activity, it is essential to add the original target
 * activity's intent, otherwise this activity will close immediately:
 * 
 * Intent i = new Intent(<calling activity class>,
 * InterstitialSwitchActivity.class); i.putExtra("target", <original target
 * activity's intent>); startActivity(i);
 * 
 * NEW Nov 1st 2012:
 * 
 * This version of the class also delegates the main adserver response to the
 * BackfillDelegator class and checks for backfill partners which might be
 * serving ads to dispaly within an interstitial.
 * 
 * @author stein16
 * 
 */
public final class InterstitialSwitchActivity extends Activity {

	private IAdServerSettingsAdapter settings;

	private String userAgentString;

	private final static String TAG = "InterstitialSwitch";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// if no target is set, close the activity
		if (getIntent().getExtras().get("target") == null) {
			SdkLog.e(
					TAG,
					"No target intent found! An interstitial needs to have the target intent set with putExtra under the key \"target\"");
			finish();
		}

		// determine user-agent
		this.userAgentString = UserAgentHelper.getUserAgent();

		// original target when interstitial not available
		final Intent target = (Intent) getIntent().getExtras().get("target");

		// ad space settings
		// TODO also allow with settings from custom xml (via resource ID)
		this.settings = new AmobeeSettingsAdapter(getApplicationContext(),
				getIntent().getExtras());

		// adserver request
		if (Connectivity.isOnline()) {
			final String url = this.settings.getRequestUrl();
			String data = null;
			SdkLog.i(TAG, "START AdServer request");
			AdServerAccess mAdFetcher = (AdServerAccess) (new AdServerAccess(
					this.userAgentString)).execute(new String[] { url });
			try {
				// store data
				data = mAdFetcher.get();
			} catch (Exception e) {
				e.printStackTrace();
			}
			SdkLog.i(TAG, "FINISH AdServer request");

			BackfillDelegator.BackfillData bfD;
			
			if (data != null && data.length() > 1
					&& (bfD = BackfillDelegator.isBackfill(
							(String) getIntent().getExtras().get(
									getString(R.string.amobeeAdSpace)), data)) != null) {
				SdkLog.d(TAG,
						"Possible backfill ad detected [id=" + bfD.getId()
								+ ", data=" + bfD.getData() + "]");
				try {
					BackfillDelegator.process(getApplicationContext(), bfD,
							new BackfillDelegator.BackfillCallback() {
								@Override
								public void trackEventCallback(String arg0) {
									SdkLog.d(TAG,
											"Backfill: An event occured ["
													+ arg0 + "]");
								}

								@Override
								public void noAdCallback() {
									SdkLog.d(TAG, "Backfill: empty.");
									startActivity(target);
								}

								@Override
								public void finishedCallback() {
									startActivity(target);
								}

								@Override
								public void adFailedCallback(Exception e) {
									SdkLog.e(TAG,
											"Backfill: An exception occured.",
											e);
									startActivity(target);
								}
							});
				} catch (BackfillDelegator.BackfillException bfE) {
					SdkLog.e(TAG, "Backfill error thrown.", bfE);
				}
			} else if (data == null || data.length() < 10) {
				// head to original intent
				SdkLog.d(TAG, "No interstitial -> starting original target.");
				startActivity(target);
			} else {
				// head to interstitial intent
				Intent i = new Intent(InterstitialSwitchActivity.this,
						InterstitialActivity.class);
				SdkLog.i(TAG, "Found interstitial -> show");
				// pass banner data and original intent to interstitial
				i.putExtra("data", data);
				i.putExtra("target", target);
				i.putExtra("timeout",
						(Integer) getIntent().getExtras().get("timeout"));
				startActivity(i);
			}

		} else if (Connectivity.isOffline()) {
			SdkLog.i(TAG, "No network connection - not requesting ads.");
			startActivity(target);
		}

		// Done
		this.finish();

	}

}

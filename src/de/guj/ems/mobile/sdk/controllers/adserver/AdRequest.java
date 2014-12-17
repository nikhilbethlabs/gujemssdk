package de.guj.ems.mobile.sdk.controllers.adserver;

import android.app.IntentService;
import android.content.Intent;
import android.os.Bundle;
import android.os.ResultReceiver;
import de.guj.ems.mobile.sdk.util.SdkLog;

public abstract class AdRequest extends IntentService {

	private final static String TAG = "AdRequest";

	public final static String ADREQUEST_URL_EXTRA = "url";

	private Throwable lastError;

	AdRequest(String name) {
		super(name);
	}

	protected Throwable getLastError() {
		return lastError;
	}

	protected abstract IAdResponse httpGet(String url);

	@Override
	protected void onHandleIntent(Intent intent) {
		IAdResponse response = null;
		String url = (String) intent.getExtras().get(ADREQUEST_URL_EXTRA);

		response = httpGet(url);

		SdkLog.d(TAG, "onHandleIntent response " + response);

		ResultReceiver rec = intent.getParcelableExtra("handler");
		if (rec != null) {
			Bundle b = new Bundle();
			if (response != null && !response.isEmpty()) {
				b.putSerializable("response", response);
			}
			if (lastError != null) {
				b.putSerializable("lastError", lastError);
			}
			rec.send(0, b);
		} else {
			SdkLog.d(TAG, "No response handler");
		}
	}

	protected void setLastError(Throwable t) {
		this.lastError = t;
	}

}

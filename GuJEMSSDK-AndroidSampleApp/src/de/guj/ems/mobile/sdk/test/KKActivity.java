package de.guj.ems.mobile.sdk.test;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.widget.FrameLayout;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;

public class KKActivity extends Activity implements IOnAdEmptyListener, IOnAdErrorListener, IOnAdSuccessListener {

	private static final long serialVersionUID = -4007635726098209139L;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_kk);
		
		FrameLayout root = (FrameLayout)findViewById(R.id.frameRoot);
		
		GuJEMSAdView adView = new GuJEMSAdView(this, R.layout.adview_kk, true);

        
        adView.setOnAdErrorListener(this);
        adView.setOnAdSuccessListener(this);
        adView.setOnAdEmptyListener(this);
        
        root.addView(adView);
		
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.kk, menu);
		return true;
	}

	@Override
	public void onAdSuccess() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onAdError(String msg, Throwable t) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onAdError(String msg) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onAdEmpty() {
		// TODO Auto-generated method stub
		
	}

}

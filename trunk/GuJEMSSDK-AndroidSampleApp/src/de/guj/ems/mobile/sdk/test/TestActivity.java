package de.guj.ems.mobile.sdk.test;

import de.guj.ems.mobile.sdk.views.GuJEMSAdView;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.Button;

public class TestActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_test);
		
		GuJEMSAdView adView = new GuJEMSAdView(this, R.layout.adbarguj);
		adView.setId(123455);
		ViewGroup v = (ViewGroup)findViewById(R.id.AdBar);
		v.addView(adView);
		
		Button b = (Button)findViewById(R.id.ButtonLoginExisting);
		b.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				((GuJEMSAdView)findViewById(123455)).reload();
			}
		});

	}
}

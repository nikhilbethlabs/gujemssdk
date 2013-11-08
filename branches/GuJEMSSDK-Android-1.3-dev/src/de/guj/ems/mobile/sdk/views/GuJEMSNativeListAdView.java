package de.guj.ems.mobile.sdk.views;

import java.util.Map;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.AbsListView;

public class GuJEMSNativeListAdView extends GuJEMSNativeAdView implements
		AdResponseHandler {

	public GuJEMSNativeListAdView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	public GuJEMSNativeListAdView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}

	public GuJEMSNativeListAdView(Context context, int resId) {
		super(context, resId);
		// TODO Auto-generated constructor stub
	}

	public GuJEMSNativeListAdView(Context context, Map<String, ?> customParams,
			int resId) {
		super(context, customParams, resId);
		// TODO Auto-generated constructor stub
	}

	public GuJEMSNativeListAdView(Context context, Map<String, ?> customParams,
			String[] kws, String[] nkws, int resId) {
		super(context, customParams, kws, nkws, resId);
		// TODO Auto-generated constructor stub
	}

	public GuJEMSNativeListAdView(Context context, String[] kws, String[] nkws,
			int resId) {
		super(context, kws, nkws, resId);
		// TODO Auto-generated constructor stub
	}
	
	@Override
	protected ViewGroup.LayoutParams getNewLayoutParams(int w, int h) {
		//SdkLog.i(TAG, getParent().getClass() + " is the parent view class");
		return new AbsListView.LayoutParams(w, 1);
	}

	@Override
	public void reload() {
		super.reload();
	}

}

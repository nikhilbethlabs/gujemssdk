/*  Copyright (c) 2011 The ORMMA.org project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package org.ormma.controller;

import org.ormma.controller.listeners.AccelListener;
import org.ormma.view.OrmmaView;

import android.content.Context;
import android.webkit.JavascriptInterface;
import de.guj.ems.mobile.sdk.util.SdkLog;

/**
 * The Class OrmmaSensorController. OrmmaController for interacting with sensors
 */
public class OrmmaSensorController extends OrmmaController {
	private static final String SdkLog_TAG = "OrmmaSensorController";
	final int INTERVAL = 1000;
	private AccelListener mAccel;
	private float mLastX = 0;
	private float mLastY = 0;
	private float mLastZ = 0;

	/**
	 * Instantiates a new ormma sensor controller.
	 * 
	 * @param adView
	 *            the ad view
	 * @param context
	 *            the context
	 */
	OrmmaSensorController(OrmmaView adView, Context context) {
		super(adView, context);
		mAccel = new AccelListener(context, this);
	}

	/**
	 * Gets the heading.
	 * 
	 * @return the heading
	 */
	@JavascriptInterface
	public float getHeading() {
		SdkLog.d(SdkLog_TAG, "getHeading: " + mAccel.getHeading());
		return mAccel.getHeading();
	}

	/**
	 * Gets the tilt.
	 * 
	 * @return the tilt
	 */
	@JavascriptInterface
	public String getTilt() {
		String tilt = "{ x : \"" + mLastX + "\", y : \"" + mLastY
				+ "\", z : \"" + mLastZ + "\"}";
		SdkLog.d(SdkLog_TAG, "getTilt: " + tilt);
		return tilt;
	}

	/**
	 * On heading change.
	 * 
	 * @param f
	 *            the f
	 */
	public void onHeadingChange(float f) {
		String script = "window.ormmaview.fireChangeEvent({ heading: "
				+ (int) (f * (180 / Math.PI)) + "});";
		SdkLog.d(SdkLog_TAG, script);
		mOrmmaView.injectJavaScript(script);
	}

	/**
	 * On shake.
	 */
	@JavascriptInterface
	public void onShake() {
		mOrmmaView.injectJavaScript("window.ormmaview.fireShakeEvent()");
	}

	/**
	 * On tilt.
	 * 
	 * @param x
	 *            the x
	 * @param y
	 *            the y
	 * @param z
	 *            the z
	 */
	public void onTilt(float x, float y, float z) {
		mLastX = x;
		mLastY = y;
		mLastZ = z;

		String script = "window.ormmaview.fireChangeEvent({ tilt: " + getTilt()
				+ "})";
		SdkLog.d(SdkLog_TAG, script);
		mOrmmaView.injectJavaScript(script);
	}

	/**
	 * Start heading listener.
	 */
	@JavascriptInterface
	void startHeadingListener() {
		mAccel.startTrackingHeading();
	}

	/**
	 * Start shake listener.
	 */
	@JavascriptInterface
	void startShakeListener() {
		mAccel.startTrackingShake();
	}

	/**
	 * Start tilt listener.
	 */
	@JavascriptInterface
	void startTiltListener() {
		mAccel.startTrackingTilt();
	}

	/**
	 * Stop.
	 */
	@JavascriptInterface
	void stop() {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.ormma.controller.OrmmaController#stopAllListeners()
	 */
	@Override
	public void stopAllListeners() {
		mAccel.stopAllListeners();
	}

	/**
	 * Stop heading listener.
	 */
	@JavascriptInterface
	void stopHeadingListener() {
		mAccel.stopTrackingHeading();
	}

	/**
	 * Stop shake listener.
	 */
	@JavascriptInterface
	void stopShakeListener() {
		mAccel.stopTrackingShake();
	}

	/**
	 * Stop tilt listener.
	 */
	@JavascriptInterface
	void stopTiltListener() {
		mAccel.stopTrackingTilt();
	}
}

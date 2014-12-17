package de.guj.ems.mobile.sdk.controllers;

import de.guj.ems.mobile.sdk.R;
import de.guj.ems.mobile.sdk.views.GuJEMSAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSListAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSNativeAdView;
import de.guj.ems.mobile.sdk.views.GuJEMSNativeListAdView;

public class AdViewConfiguration {

	private static class IntegratedViewConfiguration implements
			IAdViewConfiguration {

		@Override
		public int getBackfillSiteIdId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_bfSiteId;
		}

		@Override
		public int getBackfillZoneIdId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_bfZoneId;
		}

		@Override
		public int getEmptyListenerId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_onAdEmpty;
		}

		@Override
		public int getErrorListenerId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_onAdError;
		}

		@Override
		public int getGeoId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_geo;
		}

		@Override
		public int getGooglePublisherIdId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_gPubId;
		}

		@Override
		public int getKeywordsId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_kw;
		}

		@Override
		public int getLatId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_lat;
		}

		@Override
		public int getLonId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_lon;
		}

		@Override
		public int getNKeywordsId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_nkw;
		}

		@Override
		public int getSiteIdId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_siteId;
		}

		@Override
		public int getSuccessListenerId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_onAdSuccess;
		}

		@Override
		public int getUuidId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_uid;
		}

		@Override
		public int getZoneIdId() {
			return R.styleable.GuJEMSIntegratedAdView_ems_zoneId;
		}
	}

	private static class NativeViewConfiguration implements
			IAdViewConfiguration {

		@Override
		public int getBackfillSiteIdId() {
			return R.styleable.GuJEMSNativeAdView_ems_bfSiteId;
		}

		@Override
		public int getBackfillZoneIdId() {
			return R.styleable.GuJEMSNativeAdView_ems_bfZoneId;
		}

		@Override
		public int getEmptyListenerId() {
			return R.styleable.GuJEMSNativeAdView_ems_onAdEmpty;
		}

		@Override
		public int getErrorListenerId() {
			return R.styleable.GuJEMSNativeAdView_ems_onAdError;
		}

		@Override
		public int getGeoId() {
			return R.styleable.GuJEMSNativeAdView_ems_geo;
		}

		@Override
		public int getGooglePublisherIdId() {
			return R.styleable.GuJEMSNativeAdView_ems_gPubId;
		}

		@Override
		public int getKeywordsId() {
			return R.styleable.GuJEMSNativeAdView_ems_kw;
		}

		@Override
		public int getLatId() {
			return R.styleable.GuJEMSNativeAdView_ems_lat;
		}

		@Override
		public int getLonId() {
			return R.styleable.GuJEMSNativeAdView_ems_lon;
		}

		@Override
		public int getNKeywordsId() {
			return R.styleable.GuJEMSNativeAdView_ems_nkw;
		}

		@Override
		public int getSiteIdId() {
			return R.styleable.GuJEMSNativeAdView_ems_siteId;
		}

		@Override
		public int getSuccessListenerId() {
			return R.styleable.GuJEMSNativeAdView_ems_onAdSuccess;
		}

		@Override
		public int getUuidId() {
			return R.styleable.GuJEMSNativeAdView_ems_uid;
		}

		@Override
		public int getZoneIdId() {
			return R.styleable.GuJEMSNativeAdView_ems_zoneId;
		}
	}

	private static class WebViewConfiguration implements IAdViewConfiguration {

		@Override
		public int getBackfillSiteIdId() {
			return R.styleable.GuJEMSAdView_ems_bfSiteId;
		}

		@Override
		public int getBackfillZoneIdId() {
			return R.styleable.GuJEMSAdView_ems_bfZoneId;
		}

		@Override
		public int getEmptyListenerId() {
			return R.styleable.GuJEMSAdView_ems_onAdEmpty;
		}

		@Override
		public int getErrorListenerId() {
			return R.styleable.GuJEMSAdView_ems_onAdError;
		}

		@Override
		public int getGeoId() {
			return R.styleable.GuJEMSAdView_ems_geo;
		}

		@Override
		public int getGooglePublisherIdId() {
			return R.styleable.GuJEMSAdView_ems_gPubId;
		}

		@Override
		public int getKeywordsId() {
			return R.styleable.GuJEMSAdView_ems_kw;
		}

		@Override
		public int getLatId() {
			return R.styleable.GuJEMSAdView_ems_lat;
		}

		@Override
		public int getLonId() {
			return R.styleable.GuJEMSAdView_ems_lon;
		}

		@Override
		public int getNKeywordsId() {
			return R.styleable.GuJEMSAdView_ems_nkw;
		}

		@Override
		public int getSiteIdId() {
			return R.styleable.GuJEMSAdView_ems_siteId;
		}

		@Override
		public int getSuccessListenerId() {
			return R.styleable.GuJEMSAdView_ems_onAdSuccess;
		}

		@Override
		public int getUuidId() {
			return R.styleable.GuJEMSAdView_ems_uid;
		}

		@Override
		public int getZoneIdId() {
			return R.styleable.GuJEMSAdView_ems_zoneId;
		}
	}

	public final static IAdViewConfiguration getConfig(Class<?> viewClass) {
		if (viewClass.equals(GuJEMSAdView.class)
				|| viewClass.equals(GuJEMSListAdView.class)) {
			return WEBVIEWCONFIG;
		} else if (viewClass.equals(GuJEMSNativeAdView.class)
				|| viewClass.equals(GuJEMSNativeListAdView.class)) {
			return NATIVEVIEWCONFIG;
		}
		return INTEGRATEDVIEWCONFIG;
	}

	private final static WebViewConfiguration WEBVIEWCONFIG = new WebViewConfiguration();

	private final static NativeViewConfiguration NATIVEVIEWCONFIG = new NativeViewConfiguration();

	private final static IntegratedViewConfiguration INTEGRATEDVIEWCONFIG = new IntegratedViewConfiguration();

}

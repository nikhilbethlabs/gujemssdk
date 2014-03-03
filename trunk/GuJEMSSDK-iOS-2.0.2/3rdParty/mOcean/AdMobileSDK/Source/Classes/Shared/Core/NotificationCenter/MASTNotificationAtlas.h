//
//  Atlas.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import <Foundation/Foundation.h>

// ad Downloading
extern NSString* kStartAdDownloadNotification;
extern NSString* kGetAdServerResponseNotification;
extern NSString* kFinishAdDownloadNotification;
extern NSString* kFailAdDownloadNotification;
extern NSString* kCancelAdDownloadNotification;

// managing ad
extern NSString* kRegisterAdNotification;
extern NSString* kUnregisterAdNotification;

// displaying
extern NSString* kAdDisplayDefaultImage;
extern NSString* kStartAdDisplayNotification;
extern NSString* kReadyAdDisplayNotification;
extern NSString* kUpdateAdDisplayNotification;
extern NSString* kAdDisplayedNotification;
extern NSString* kFailAdDisplayNotification;
extern NSString* kInterstitialAdCloseNotification;

extern NSString* kOpenURLNotification;
extern NSString* kOpenInternalBrowserNotification;
extern NSString* kVerifyRequestNotification;
extern NSString* kOpenVerifiedRequestNotification;
extern NSString* kShouldOpenExternalAppNotification;
extern NSString* kShouldOpenInternalBrowserNotification;
extern NSString* kCloseInternalBrowserNotification;
extern NSString* kCantOpenInternalBrowserNotification;

extern NSString* kInvalidParamsServerResponseNotification;
extern NSString* kEmptyServerResponseNotification;
extern NSString* kInvalidParamsNotification;

// visibility
extern NSString* kAdViewBecomeVisibleNotification;
extern NSString* kAdViewFrameChangedNotification;
extern NSString* kAdViewBecomeInvisibleNotification;

// ua
extern NSString* kUaDetectedNotification;

// location
extern NSString* kLocationManagerStart;
extern NSString* kLocationManagerStop;
extern NSString* kLocationManagerError;
extern NSString* kLocationManagerLocationUpdate;
extern NSString* kLocationManagerHeadingUpdate;

// updateControll
extern NSString* kAdStartUpdateNotification;
extern NSString* kAdStopUpdateNotification;
extern NSString* kAdCancelUpdateNotification;
extern NSString* kAdUpdateNowNotification;
extern NSString* kAdChangeUpdateTimeIntervalNotification;

// loggingControll
extern NSString* kAdStartLoggingAllNotification;
extern NSString* kAdStartLoggingErrorsNotification;
extern NSString* kAdStopLoggingNotification;

// iAd
//extern NSString* kNoIAdAvailableNotification;

// track url
extern NSString* kTrackUrlNotification;

// other 
extern NSString* kORMMAEventNotification;
extern NSString* kThirdPartyNotification;
extern NSString* kPlayAudioNotification;
extern NSString* kPlayVideoNotification;
extern NSString* kCloseExpandNotification;
extern NSString* kORMMASetDefaultStateNotification;


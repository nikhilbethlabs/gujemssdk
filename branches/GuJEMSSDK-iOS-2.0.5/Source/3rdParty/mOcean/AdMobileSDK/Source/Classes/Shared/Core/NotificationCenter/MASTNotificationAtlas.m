//
//  Atlas.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import "MASTNotificationAtlas.h"

// ad Downloading
NSString* kStartAdDownloadNotification = @"Start Ad Download";
NSString* kGetAdServerResponseNotification = @"Get Server Response";
NSString* kFinishAdDownloadNotification = @"Finish Ad Download";
NSString* kFailAdDownloadNotification = @"Fail Ad Download";
NSString* kCancelAdDownloadNotification = @"Cancel Ad Download";

// managing ad
NSString* kRegisterAdNotification = @"Register new Ad";
NSString* kUnregisterAdNotification = @"Unregister Ad";

// displaying
NSString* kAdDisplayDefaultImage = @"Display defaultImage";
NSString* kStartAdDisplayNotification = @"Start Ad Display";
NSString* kReadyAdDisplayNotification = @"Start render Ad";
NSString* kUpdateAdDisplayNotification = @"Update 3rd party SDK Ad";
NSString* kAdDisplayedNotification = @"Ad Displayed";
NSString* kFailAdDisplayNotification = @"Fail Ad Display";
NSString* kInterstitialAdCloseNotification = @"Interstitial Ad Close";

NSString* kOpenURLNotification = @"Start opening Url";
NSString* kOpenInternalBrowserNotification = @"Open Internal Browser";
NSString* kVerifyRequestNotification = @"Start request verification";
NSString* kOpenVerifiedRequestNotification = @"Finish request verification";
NSString* kShouldOpenExternalAppNotification = @"SDK should open external application";
NSString* kShouldOpenInternalBrowserNotification = @"SDK should open Internal Browser";
NSString* kCloseInternalBrowserNotification = @"Close Internal Browser";
NSString* kCantOpenInternalBrowserNotification = @"Can't open internal browser";

NSString* kInvalidParamsServerResponseNotification = @"Server response with error - invalid site or zone property";
NSString* kEmptyServerResponseNotification = @"Server response with empty body (no ads)";
NSString* kInvalidParamsNotification = @"Validation error";

// visibility
NSString* kAdViewBecomeVisibleNotification = @"Ad Become Visible";
NSString* kAdViewFrameChangedNotification = @"Ad frame changed";
NSString* kAdViewBecomeInvisibleNotification = @"Ad Become Invisible";

// ua
NSString* kUaDetectedNotification = @"ua detected";

// location
NSString* kLocationManagerStart = @"Location Manager Start Update";
NSString* kLocationManagerStop = @"Location Manager Stop Update";
NSString* kLocationManagerError = @"Location Manager Error";
NSString* kLocationManagerLocationUpdate = @"Location Manager Location Update";
NSString* kLocationManagerHeadingUpdate = @"Location Manager Heading Update";

// install notification
NSString* kFinishInstallNotification = @"Finish install notifiaction";
NSString* kFailInstallNotification = @"Fail install notification";

// updateControll
NSString* kAdStartUpdateNotification = @"Ad Start Update";
NSString* kAdStopUpdateNotification = @"Ad Stop Update";
NSString* kAdCancelUpdateNotification = @"Cancel update for Ad";
NSString* kAdUpdateNowNotification = @"Ad Update Now";
NSString* kAdChangeUpdateTimeIntervalNotification = @"Ad Change Update Time Interval";

// loggingControll
NSString* kAdStartLoggingAllNotification = @"Start Logging all events";
NSString* kAdStartLoggingErrorsNotification = @"Start Logging errors";
NSString* kAdStopLoggingNotification = @"Stop Logg";

// iAd
//NSString* kNoIAdAvailableNotification = @"No iAd available at this time";

// track url
NSString* kTrackUrlNotification = @"External campaign track url";

// other 
NSString* kORMMAEventNotification = @"Process ORMMA event";
NSString* kThirdPartyNotification = @"Recieve Third Party";
NSString* kPlayAudioNotification = @"Play audio";
NSString* kPlayVideoNotification = @"play video";
NSString* kCloseExpandNotification = @"Close expand ad control";
NSString* kORMMASetDefaultStateNotification = @"ORMMA set default state";
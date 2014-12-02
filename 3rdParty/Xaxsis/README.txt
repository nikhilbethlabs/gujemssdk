Import/Settings
libAdSDKLib to the 3rd party SDK
Header VideoAdSDK.h
VideoAdLib.bundle, which includes the skip button image resources
(Under the Linking section in Build Settings, add to "Other Linker Flags" the flag "-ObjC")

Externals frameworks and libraries:
CoreLocation
AudioToolbox
AVFoundation
MediaPlayer
SystemConfiguration
CoreTelephony
libz

Implement VideoAds in 3rd party SDK
1) Import header 
#import "VideoAdSDK.h"

2) VideoAdSDKDelegate (required to receive events from inside the VideoAd)
// Extend a given class with the VideoAdSDKDelegate to receive the VideoAd notifications.
@interface AppDelegate : UIResponder <UIApplicationDelegate, VideoAdSDKDelegate>
// This can be set to nil and is optional, not required for ad delivery.

3) Initialization
// 3rd party SDK must push the placement ID (e.g. "xyz0-0%3D1") to the VideoAd instance and 
// set the delegate object to receive notifications from the VideoAd 
// (in the following example "self")
[VideoAdSDK registerWithPublisherID:[@"xyz0-0%3D1" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] delegate:self];

4) Additional Details and Targeting 
// Append details for targeted campaigns
//	use "-" as separator, e.g.
//	examples für det:
//		g_f for gender=female 
//		g_m for gender=male 
//		a_30 for age=30 
//		g_f-a_30 for gender=female and age=30 
[VideoAdSDK setUserAttribute:@"g_f-a_30" forKey:@"det"];
// Append context category ID for in-app content 
//	please contact us for a list of content category IDs
[VideoAdSDK setUserAttribute:@"321" forKey:@"tpc"];

5) Prefetching Ads (optional - in the background)
// Preload media files for ad delivery in mobile areas:
[VideoAdSDK prefetchAdvertising];
// OnComplete, the SDK calls the delegate object:
- (void)advertisingPrefetchingDidComplete;

6) Show VideoAd
// To play an advertising call:
[VideoAdSDK playAdvertising];

7) Tracking Listeners
// The VideoAd fires tracking events with its delegate object
// for 3rd party SDK integration (see .h)
- (void)advertisingWillShow;
- (void)advertisingDidHide;
- (void)advertisingClicked;
- (void)advertisingNotAvailable;
- (void)advertisingFailedToLoad:(NSError*)error;

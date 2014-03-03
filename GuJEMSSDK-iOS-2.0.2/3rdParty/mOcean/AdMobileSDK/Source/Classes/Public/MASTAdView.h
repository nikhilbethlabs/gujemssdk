//
//  MASTAdView.h
//  AdMobileSDK
//
//  version: 2.12.0
//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MASTAdDelegate.h"


typedef enum {
	AdPremiumNonPremium = 0,
	AdPremiumPremium,
	AdPremiumBoth,
} AdPremium;

typedef enum {
	AdTypeTextOnly = 1,
	AdTypeImagesOnly = 2,
	AdTypeImagesAndText = 3,
	AdTypeRichmedia = 4,
	AdTypeRichmediaAndText = 5,
	AdTypeRichmediaAndImages = 6,
	AdTypeAll = 7,
} AdType;

typedef enum {
	AdLogModeNone = 0,
	AdLogModeErrorsOnly = 1,
	AdLogModeAll = 2,
} AdLogMode;

/**
 Use the MASTAdView class to embed advertisement content in your application.  To do so, you simply create an instance of the MASTAdView object 
 and add it to a UIView.  An instance of MASTAdView is the means for displaying advertisements from an ad publisher's site.  To choose an ad 
 publisher site, set parameters in the initWithFrame:site:zone method or use properties site and zone. Use the adServerUrl property to choose
 an alternative ad publisher server.
 
 The MASTAdView handles the rendering of any content in its area: text, images or rich media.  The ad view also handles user interactions with
 the advertisement content.  Ads generally have links that allow users to visit web sites.  The internalOpenMode controls how these sites are
 visited.  To control all interactions implement the MASTAdViewDelegate protocol.
 
 After creating the ad view call update to initiate the initial load request.  The time interval between load requests is managed using the 
 property updateTimeInterval.  Use the isLoading property to determine if the ad is in the process of loading or not.  The MASTAdViewDelegate
 can also be used to get status on ad loading.
 
 To configure visual appearance use the properties defaultImage, autoCollapse, showPreviousAdOnError, textColor or contentAlignment. To manage
 the view animation, use the property isAdChangeAnimated.
 
 Advanced ad view customization is supported.  Ad content can be filtered using the premium property.  Use the properties minSize and maxSize
 to configure ad content size in server response.  Also you can set the search parameters or any other parameters using the keywords and 
 additionalParameters properties.
 
 To debug ad behavior use the properties testMode and logMode.
 
 Set the delegate property to an object conforming to the MASTAdViewDelegate protocol if you want to listen the processing of ad content.
 */
@interface MASTAdView : UIView {
	BOOL	_observerSet;
	id		_adModel;
}

/** @name Location Detection Configuration */

/**
 Configures and enables the SDK's location detection feature.  Refer to CLLocation iOS SDK documentation for specifics.
 
 This setting and enablement applies to ALL ads in the SDK.  Using this feature causes the latitude and longitude 
 properties to be updated as the device's location changes.  To stop SDK location detection use setLocationDetectionEnabled:.
 
 Not all devices support location services and the user may disable them for the device or for specific applications.  If 
 not available and these methods will not enable location detection.  Refer to CLLocation iOS documentation for details
 on determining if location services are available or authorized.
 
 @param purpose Message supplied to the device user if iOS prompts for location usage authorization, defaults nil
 @param significantUpdating Use significant location changes if available (better on battery and recommended), default YES
 @param headingUpdates Supply heading updates if available, default NO
 @param distanceFilter If not using significantUpdating, distance delta that triggers update, defaults 1000m
 @param desiredAccuracy If not using significantUpdating, location accuracy in meters, defaults kCLLocationAccuracyThreeKilometers
 @param headingFilter If using headingUpdates, degrees delta that triggers update, defaults 45 
 */
+ (void)setLocationDetectionEnabledWithPupose:(NSString*)purpose
                          significantUpdating:(BOOL)significantUpdating
                               headingUpdates:(BOOL)headingUpdates
                               distanceFilter:(CLLocationDistance)distanceFilter
                              desiredAccuracy:(CLLocationAccuracy)desiredAccuracy
                                headingfilter:(CLLocationDegrees)headingfilter;


/** 
 @name Location Detection Configuration
 
 Enables or disables the SDK's location detection feature.  If enabled is YES will use default values for configuration.
 Refer to setLocationDetectionEnabledWithPupose for default values.
 */
+ (void)setLocationDetectionEnabled:(BOOL)enabled;

/**
 Returns the enablement status of location detection.  May return NO even if either setLocationDetectionEnabled methods
 were called to enable location detection if iOS locaton services are unavailable or unauthorized.
 */
+ (BOOL)isLocationDetectionEnabled;


/** @name Initialization */

/**
 Initializes and returns an instance of MASTAdView having the given frame, site and zone.
 
 @param frame A rectangle that specifies the initial location and size of the ad view in its superview’s coordinates.
 @param site A value that specifies the id of ad publisher site.
 @param zone A value that specifies the id of ad publisher zone.
 
 @return Initialized MASTAdView object or nil if the object could not be successfully initialized.
 */
- (id)initWithFrame:(CGRect)frame
               site:(NSInteger)site
               zone:(NSInteger)zone;


/**
 Initializes and returns an instance of MASTAdView with the given frame.
 
 @param frame A rectangle that specifies the initial location and size of the ad view in its superview's coordinates.
 
 @note The site and zone properties MUST be set before calling update.
 */
- (id)initWithFrame:(CGRect)frame;


/** @name Content Updating */

/** 
 @name Loading Content
 
 A Boolean value that determines whether ad is in the process of loading. 
 */
@property (readonly) BOOL				isLoading;


/** 
 Starts to update the ad content immediately.
 
 Call this method if you want update the ad content immediately (for example, after setting site and zone or changing adServerUrl). If ad is 
 in the process of loading it will be interrupted.
 
 This method MUST be called sometime after calling init or stopEverythingAndNotifyDelegateOnCleanup to start ad loading.
 */
- (void)update;


/**
 Use this method, if you want to close the ad quickly and clear all resource.
 */
- (void)stopEverythingAndNotfiyDelegateOnCleanup;


/** @name Configuration */

/**
 Id of the publisher site.
 
 A value is required if not already set with initWithFrame:site:zone;
 */
@property (assign) NSInteger			site;


/** 
 Id of the publisher zone.
 
 A value is required if not already set with initWithFrame:site:zone;
 */
@property (assign) NSInteger			zone;


/** 
 Image to be displayed if there is no ad content available, error downloading content or failure to connect to the ad server.
 
 The default value is nil.
 */
@property (retain) UIImage*				defaultImage;


/** 
 A Boolean value that determines whether to hide ad on error depending on other properties.
 
 The default value is YES.
 */
@property BOOL                          autoCollapse;


/** 
 A Boolean value that determines whether to show a previous ad on error depending on other properties.
 
 The default value is YES.
 */
@property BOOL                          showPreviousAdOnError;


/** 
 Set this value to customize the close button appearance and behavior.
 
 By default a closed button is set by the SDK with hidden property YES.
 
 @warning *Note:* If a custom button is used then custom close logic MUST also be implemented.
 @warning *Note:* To dispaly the SDK provided close button set the hidden property of the default value to NO.
 */
@property (retain) UIButton*            closeButton;


/** 
 Show close button delay time interval, in seconds.
 
 Setting to -1 will show close button immediately.
 
 The default value is -1.
 */
@property NSTimeInterval                showCloseButtonTime;


/** 
 Auto close interstitial time interval, in seconds.
 
 Setting to -1 will disable auto closing interstitial.
 
 The default value is -1.
 */
@property NSTimeInterval                autocloseInterstitialTime;


/** 
 A Boolean value that determines whether ad transition animate mode is enabled.
 
 The default value is NO.
 */
@property BOOL							isAdChangeAnimated;


/** 
 Update time interval, in seconds.
 
 The value of this property determines time interval between ad load requests. The interval starts after an ad is loaded and does not include
 the time required to download and display the ad.
 
 Setting to 0 will stop updates. All positive values enable updates.  Values lower than 5 seconds are set to 5 seconds.
 
 The default value is 120.
 */
@property NSTimeInterval				updateTimeInterval;


/** 
 Publisher server URL.
 
 The default value is http://ads.AdMobile.mobi/ad
 */
@property (retain) NSString*			adServerUrl;


/** 
 Maximum server response time.
 
 Specify timeout of ad call. This tells the ad server the maximum time you are willing to wait for an ad response.
 
 The default value is 3000ms (milleseconds).
 
 The max value is 3000ms (milleseconds).
 */
@property (assign) NSInteger            adCallTimeout;

/**
 Customize the HTML (or javascript) code to be inserted into the HTML HEAD when creating webview for ad content.

 Defaults below if not set where ADVIEWWIDTH is the adview.frame.size.width.
 Non-Retina:
 <meta name=\"viewport\" content=\"width=ADVIEWWIDTH; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>
 Retina:
 <meta name=\"viewport\" content=\"width=ADVIEWWIDTH; initial-scale=0.5; maximum-scale=0.5; user-scalable=0;\"/>
 
 @note: To show non-retina ads scaled/zoomed on Retina devices you can use the following (for both device types):
 <meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>
 
 Also, the default header code adds the following style element to center content:
 <style>body{margin:0;padding:0;display:-webkit-box;-webkit-box-orient:horizontal;-webkit-box-pack:center;-webkit-box-align:center;}</style>
 
 */
@property (nonatomic, retain) NSString* injectionHeaderCode;

/** 
 Minimal size of the ad content can be shown.
 
 Use this property to set the minimal size of the ad content when requesting an ad from the server.  
 The content may be larger than this value.
 */
@property CGSize						minSize;


/** 
 Maximum size of the ad content can be shown.
 
 Use this property to set the maximum size of the ad content when requesting an ad from the server.  
 The content may be smaller than this value.
 */
@property CGSize						maxSize;


/** 
 A Boolean value that determines whether ad tracking is enabled.
 
 If set to YES, the ad server will send a client side impression tracking pixel with each ad regardless of the campaign configuration.
 Impressions will not increment if this pixel does not render on the device.
 
 The default value is NO.
 */
@property BOOL							track;


/** 
 A NSString value that supplies the application/device tracking identifier.
 
 If nil, a udid value will not be sent to the server. 
 iOS 5.1 SDK has deprecated using UIDevice's uniqueIdentifier method.
 The following documentation may be helpful if uniqueIdentifier behavior is desired:
 https://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIDevice_Class/DeprecationAppendix/AppendixADeprecatedAPI.html#//apple_ref/occ/instp/UIDevice/uniqueIdentifier
 
 The default value is nil.
 */
@property (retain) NSString* udid;


/** 
 A Boolean value that determines whether the internal browser is enabled.
 
 Set the value of this property to NO disables internal browser and to handle linking with Safari.
 
 To handle opening/closing the internal browser use MASTAdViewDelegate or viewWillAppear/viewWillDisappear methods of the controlling UIViewController.
 
 The default value is NO.
 */
@property BOOL							internalOpenMode;


/** 
 Color of ad text links.
 
 The default value is nil.
 
 @warning *Note:* Alpha value ignored.
 */
@property (retain) UIColor*             textColor;


/** Ad Content Selection */

/** 
 Ad premium filter.
 
 Use this property to filter the content of ad by premium status.
 
 The default value is AdPremiumNonPremium.
 */
@property AdPremium                     premium;


/**
 Ad type filter.
 
 Use this property to filter the content of ad by type.
 */
@property AdType                       type;


/** 
 Keywords for search ads.
 
 Use this property to search ads. The values are delimited by commas.
 
 The default value is nil.
 */
@property (retain) NSString*			keywords;


/** 
 Custom request parameters.
 
 Use this property to add custom request parameters.
 
 The default value is nil.
 
 @warning *Note:* All keys and objects is need to be kind of NSString Class. For example:
    [NSDictionary dictionaryWithObject:@"value" forKey:@"key"]
 */
@property (retain) NSDictionary*        additionalParameters;


/** 
 The country of visitor. It overrides the country detected by IP. Use ISO 3166 for country codes.
 
 The default value is nil.
 */
@property (retain) NSString*            country;


/** 
 Region of visitor.  Use ISO 3166-2 for United States and Canada and FIBS 10-4 ffor other countries.
 
 The default value is nil.
 */

@property (retain) NSString*            region;


/** 
 City of the device user (with state). For US only.
 
 The default value is nil.
 */
@property (retain) NSString*            city;


/** Area code of a user. For US only.
 
 The default value is nil.
 */
@property (retain) NSString*            area;


/**
 Metro code of a user. For US only.
 
 THIS PROPERTY IS DEPRICATED AND WILL BE REMOVED IN A FUTURE RELEASE.  Use dma instead.
 
 The default value is nil.
 */
@property (retain) NSString*            metro __attribute__((deprecated));


/** 
 DMA code of a user.  For US only.
 
 Replaces metro parameter.
 
 The default value is nil.
 */
@property (retain) NSString*            dma;


/** 
 User location latitude value.
 
 Use this property to set latitude.
 If locationDetection is enabled this value will be updated by location detection.
 
 The default value is nil.
 */

@property (retain) NSString*            latitude;


/** 
 User location longitude value.
 
 Use this property to set longitude.
 If locationDetection is enabled this value will be updated by location detection.
 
 The default value is nil.
 */
@property (retain) NSString*            longitude;


/** 
 Zip/Postal code of user.  For US only.
 
 The default value is nil.
 */
@property (retain) NSString*            zip;


/** 
 User carrier.
 
 The default value is nil.
 */
@property (retain) NSString*            carrier;


/** @name Debugging */

/** 
 A Boolean value that determines whether ad test mode is enabled.
 
 The default value is NO.
 */
@property BOOL							testMode;


/** AdLogMode value that determines log level.

 Setting the value of this property to AdLogModeNone disables ads logging. AdLogModeErrorsOnly - enables logging errors only. 
 AdLogModeAll - enables logging errors and info.
 
 The default value is AdLogModeErrorsOnly. 
 */
@property AdLogMode                     logMode;


/** @name Delegate */
 
/** 
 The receiver's delegate.
 
 The MASTAdView is sent messages when content is processing. The delegate must adopt the MASTAdViewDelegate protocol.
 The delegate is not retained.
 
 @warning *Important:* Before releasing an instance of MASTAdView for which you have set a delegate, you must first set its delegate property
 to nil. This can be done, for example, in your dealloc method.
 
 @see MASTAdViewDelegate Protocol Reference for the optional methods this delegate may implement.
 */
@property (assign) id <MASTAdViewDelegate>	delegate;


@end

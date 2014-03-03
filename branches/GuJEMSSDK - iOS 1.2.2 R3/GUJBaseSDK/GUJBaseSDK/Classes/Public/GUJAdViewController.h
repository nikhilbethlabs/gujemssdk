/*
 * BSD LICENSE
 * Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer .
 * Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The source code is just allowed for private use, not for commercial use.
 * 
 */
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> // import to serve compiler errors if the FW is not linked

@class GUJAdViewController;
/*!
 * The GUJAdView.
 * See GUJAdView(PrivateImplementation)
 */
//@interface GUJAdView :UIView @end /* removed in 1.2.1 */
@class GUJAdView; /* added in 1.2.1 */
/*!
 * The GUJAdViewEvent
 */
@interface GUJAdViewEvent :NSObject{
  @private
#ifndef __clang_analyzer__
    NSTimeInterval _timestamp;
#endif
}

/*!
 * GUJAdViewEventType
 @since 1.2.1
 */
typedef enum {
    GUJAdViewEventTypeUserInteraction,
    GUJAdViewEventTypeSystemMessage,
    GUJAdViewEventTypeTracking,
    GUJAdViewEventTypeExternalFramework
} GUJAdViewEventType;

@property(nonatomic,readonly) GUJAdViewEventType    type;
@property(nonatomic,readonly) NSObject              *attachment;
@property(nonatomic,readonly) NSString              *message;
@property(nonatomic,readonly) NSTimeInterval        timestamp;

@end

/*!
 * The GUJAdViewControllerDelegate Protocol defines the messages sent to the AdView and its Controller.
 *  
 */
@protocol GUJAdViewControllerDelegate<NSObject, UIApplicationDelegate>

/*!
 * Will be called if the current instance is not well configured
 *
 @param error the configuration error
 @since 1.2.1
 */
- (void)adViewController:(GUJAdViewController*)adViewController didConfigurationFailure:(NSError*)error;

/*!
 * Will be called if the current instance has allocated and created the AdView.
 * No Ad-Content is loaded at this time.
 *
 @param bannerView The adView object
 */
- (void)bannerViewDidLoad:(GUJAdView*)bannerView;

/*!
 * Will be called if the current instance:
 * + Performed an erroneous AdView-request.
 * + The Ad-Content is invalid or does not match the ad-type
 * + No Ad-Content is loaded.
 * + The AdView did an loading or configuration failure
 *
 @param bannerView The adView object
 @param error The adView error object
 */
- (void)bannerView:(GUJAdView*)bannerView didFialLoadingAdWithError:(NSError*)error;

@optional
/*!
 * deprecated since 1.2.1
 */
- (void)didConfigurationFailure:(NSError*)error __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_5_0);

/*!
 * Will notify the delegate when the Ad-View changes from hidden to visible
 */
- (void)bannerViewDidShow:(GUJAdView*)bannerView;

/*!
 * Will notify the delegate when the Ad-View changes from visible to hidden
 */
- (void)bannerViewDidHide:(GUJAdView*)bannerView;

/*!
 * Will be called if the current AdView will perform the ad-server request.
 *
 @param bannerView The adView object
 */
- (void)bannerViewWillLoadAdData:(GUJAdView*)bannerView;

/*!
 * Will be called if the current AdView did successfully performed the ad-server request
 *
 @param bannerView The adView object
 */
- (void)bannerViewDidLoadAdData:(GUJAdView*)bannerView;

/*!
 * Will called if the current ad receives an event.
 * An event can be a third party delegate notification or internal call.
 @since 1.2.1
 */
- (void)bannerView:(GUJAdView*)bannerView receivedEvent:(GUJAdViewEvent*)event;

#pragma mark Interstitial banner
/*!
 * Will be called if the current AdView did failed to load.
 *
 @param error The adView error object
 */
- (void)interstitialViewDidFailLoadingWithError:(NSError*)error;

/*!
 * Will be called if the current AdView will appear as interstitial view.
 */
- (void)interstitialViewWillAppear;

/*!
 * Will be called if the current AdView did appear as interstitial view.
 *  As usual, the view will be modal.
 */
- (void)interstitialViewDidAppear;

/*!
 * Will be called if the current AdView will disapper the interstitial view.
 */
- (void)interstitialViewWillDisappear;

/*!
 * Will be called if the current AdView did disappear.
 *  As usual, the modal view is hidden.
 */
- (void)interstitialViewDidDisappear;

/*!
 * Will called if the current ad receives an event.
 * An event can be a third party delegate notification or internal call.
 @since 1.2.1
 */
- (void)interstitialViewReceivedEvent:(GUJAdViewEvent*)event;

@end

/*!
 * The GUJAdViewController is designed to be
 * customized to support protocol-specific advertisement requests and acess
 * to native device functionalities.
 */
@interface GUJAdViewController : NSObject {
@public
    id<GUJAdViewControllerDelegate> delegate_;
}

/*!
 * Returns a GUJAdViewController instance. 
 * The instance has to be freed via freeInstance before creating a new.
 *
 @param Ad-Space-Id 
 @result A newly create GUJAdViewController instance
 */
+ (GUJAdViewController*)instanceForAdspaceId:(NSString*)adSpaceId;

/*!
 * Returns a GUJAdViewController instance. 
 * The instance has to be freed via freeInstance before creating a new.
 *
 @param Ad-Space-Id 
 @param delegate A class that implements the GUJAdViewControllerDelegate Protocol
 @result A newly create GUJAdViewController instance
 */
+ (GUJAdViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate;

/*!
 * Set the global reload interval for this instance.
 *
 @param reloadInterval Reload interval as NSTimeInterval 
 */
+ (void)setReloadInterval:(NSTimeInterval)reloadInterval;

/*!
 * Disables the location service 
 @result YES if the location service was disabled
 */
+ (BOOL)disableLocationService;

/*!
 * A static mobile banner view. Maybe animated. 
 * No media and multimedia interactions are predefined.
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adView;

/*!
 * A static mobile banner view. Maybe animated. No media and multimedia interactions are predefined.
 @param origin The origin of this AdView. origin.x will be ignored.
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adViewWithOrigin:(CGPoint)origin;

/*!
 * A static mobile banner view. Maybe animated. No media and multimedia interactions are predefined.
 * If no suitable Ad matchs the keyword(s) the instance stays inactive and no Ad will be shown.
 * The GUJAdView will stay allocated in any case until the instance is freed.
 @param keywords keywords that will be used for the ad-request
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adViewForKeywords:(NSArray*)keywords;

/*!
 * A static mobile banner view. Maybe animated. No media and multimedia interactions are predefined.
 * If no suitable Ad matchs the keyword(s) the instance stays inactive and no Ad will be shown.
 * The GUJAdView will stay allocated in any case until the instance is freed.
 @param keywords keywords that will be used for the ad-request 
 @param origin The origin of this AdView. origin.x will be ignored.
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin;

/*! 
 * Interstitial banner view. 
 *
 * The GUJAdViewControllerDelegate SHOULD be implemented in the caller class.
 *
 * + Multimedia related. 
 * + Fullscreen. 
 * + Min. visibility time
 */
- (void)interstitialAdView;

/*! 
 * Interstitial banner view. 
 *
 * The GUJAdViewControllerDelegate SHOULD be implemented in the caller class.
 *
 * + like interstitialAdView:
 * + Adds Keywords
 * If no suitable Ad matchs the keyword(s) the instance stays inactive and noi nterstitial Ad will be shown.
 @param keywords 
 */
- (void)interstitialAdViewForKeywords:(NSArray*)keywords;

/*!
 * Add an custom header field to the HTTP-Header of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestHeaderField:(NSString*)name value:(NSString*)value;

/*!
 * Add all custom header field that defined in the headerFields dictionary
 * to the HTTP-Header of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestHeaderFields:(NSDictionary*)headerFields;

/*!
 * Add an custom request parameter to the HTTP-Header of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestParameter:(NSString*)name value:(NSString*)value;

/*!
 * Add all custom request parameters that are defined in the requestParameters dictionary
 * to the HTTP-Request of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestParameters:(NSDictionary*)requestParameters;

/*!
 * Frees the current Instance.
 * The instance is not deallocate after this call.
 */
- (void)freeInstance;
@end

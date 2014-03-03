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
@protocol GUJAdViewControllerDelegate;

@interface GUJAdView : UIView @end

@interface GUJAdViewContext : NSObject

/*!
 * Enable / disable the mOcean BackFill.
 *
 * The mOcean back-fill will automatically deactivated if the mOcean zone and site-Id is missing.
 */
@property (assign, nonatomic) BOOL mOceanBackFill;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * Returns a GUJAdViewContext instance. 
 * The instance has to be freed via freeInstance before creating a new.
 *
 @param Ad-Space-Id 
 @result A newly create GUJAdViewContext instance
 */
+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * Returns a GUJAdViewContext instance. 
 * The instance has to be freed via freeInstance before creating a new.
 *
 @param Ad-Space-Id 
 @param delegate A class that implements the GUJAdViewControllerDelegate Protocol
 @result A newly create GUJAdViewContext instance
 */
+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate;

/*!
 * Overrides the SDK-Chain down to the GUJmOceanViewController.
 *
 * Returns a GUJAdViewContext instance. 
 * The instance has to be freed via freeInstance before creating a new.
 *
 @param Ad-Space-Id 
 @param siteId - mOcean SiteId
 @param zoneId - mOcean zoneId
 @result A newly create GUJAdViewContext instance
 */
+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId;

/*!
 * Overrides the SDK-Chain down to the GUJmOceanViewController.
 *
 * Returns a GUJAdViewContext instance. 
 * The instance has to be freed via freeInstance before creating a new.
 *
 @param Ad-Space-Id 
 @param siteId - mOcean SiteId
 @param zoneId - mOcean zoneId 
 @param delegate A class that implements the GUJAdViewControllerDelegate Protocol
 @result A newly create GUJAdViewContext instance
 */
+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate;


/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
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
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * A static mobile banner view. Maybe animated. 
 * No media and multimedia interactions are predefined.
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adView;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * A static mobile banner view. Maybe animated. No media and multimedia interactions are predefined.
 @param origin The origin of this AdView. origin.x will be ignored.
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adViewWithOrigin:(CGPoint)origin;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * A static mobile banner view. Maybe animated. No media and multimedia interactions are predefined.
 * If no suitable Ad matchs the keyword(s) the instance stays inactive and no Ad will be shown.
 * The GUJAdView will stay allocated in any case until the instance is freed.
 @param keywords keywords that will be used for the ad-request
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adViewForKeywords:(NSArray*)keywords;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * A static mobile banner view. Maybe animated. No media and multimedia interactions are predefined.
 * If no suitable Ad matchs the keyword(s) the instance stays inactive and no Ad will be shown.
 * The GUJAdView will stay allocated in any case until the instance is freed.
 @param keywords keywords that will be used for the ad-request 
 @param origin The origin of this AdView. origin.x will be ignored.
 @result A newly create static GUJAdView instance
 */
- (GUJAdView*)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin;

/*! 
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
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
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
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
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * Add an custom header field to the HTTP-Header of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestHeaderField:(NSString*)name value:(NSString*)value;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * Add all custom header field that defined in the headerFields dictionary
 * to the HTTP-Header of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestHeaderFields:(NSDictionary*)headerFields;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * Add an custom request parameter to the HTTP-Header of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestParameter:(NSString*)name value:(NSString*)value;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * Add all custom request parameters that are defined in the requestParameters dictionary
 * to the HTTP-Request of the upcoming Ad-Server request.
 */
- (void)addAdServerRequestParameters:(NSDictionary*)requestParameters;

/*!
 * Overrides the SDK-Chain down to the GUJAdViewController.
 *
 * Frees the current Instance.
 * The instance is not deallocate after this call.
 */
- (void)freeInstance;

@end



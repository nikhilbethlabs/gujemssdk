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
#import "GUJAdConfiguration.h"
#import "_GUJAdView.h"
#import "GUJAdData.h"
#import "GUJAdViewEvent.h"
// Native frameworks
#import "GUJNativeLocationManager.h"
#import "GUJAdViewController+PrivateImplementation.h"

@interface GUJAdView :UIView @end /* added in 2.0.1 */

@implementation GUJAdViewController (PrivateImplementation)

- (void)instanciate
{
    @autoreleasepool { // autorelease cause GUJAdConfiguration/error is not safe
        [GUJUtil applicationAdSpaceUUID]; // load or create AdSpace UUID
        if( ![[self adConfiguration] isValid] ) {
            if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(adViewController:didConfigurationFailure:)]) {
                [[self delegate] adViewController:self didConfigurationFailure:[[self adConfiguration] error]];
            }
        } else {
            [self performSelectorOnMainThread:@selector(initializeNativeInterfaces) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)initializeNativeInterfaces
{
    /*
     * Interfaces that depends on external Frameworks must load safely
     */
    // core location framework needed for startup
    if( ![[self adConfiguration] locationServiceDisabled] ) {
        [[GUJNativeLocationManager sharedInstance] startUpdatingLocation];
    }
    // Custom Initialization code or method calls
}

- (GUJAdView*)populateAdView:(_GUJAdView*)adView
{
    [adView setAdConfiguration:[self adConfiguration]];
    [self _setGUJAdView:(GUJAdView*)adView];
    
    // strong assign the completion block
    __strong gujAdViewCompletionHandler strongBlock = [self _gujAdViewCompletionBlock];
    [adView setAdViewCompletionHandler:strongBlock];
    
    /*
     * we need some time to initialize some native frame works and / or fetch data.
     * for example the CoreLocationFW needs a while to fire its first delegate with the
     * current user location.
     */
    dispatch_async(dispatch_get_main_queue(),  ^{
        if( ![[self adConfiguration] locationServiceDisabled] ) {
            if( [[GUJNativeLocationManager sharedInstance] locationServiceAvailable] ) {
                [((_GUJAdView*)[self _getGUJAdView]) __loadAd:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
                    BOOL result = (_loadingError == nil);
                    if( strongBlock != nil && !result ) {
                        strongBlock(_loadedAdView,_loadingError);
                    }
                    return result;
                }];
            } else {
                // otherwise (or) if loosing the locationObserver we load the ad after a delay of X
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kGUJTimeoutForLoadNotification * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                    [((_GUJAdView*)[self _getGUJAdView]) __loadAd:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
                        BOOL result = (_loadingError == nil);
                        if( strongBlock != nil && !result ) {
                            strongBlock(_loadedAdView,_loadingError);
                        }
                        return result;
                    }];
                });
            }
        } else {
            [((_GUJAdView*)[self _getGUJAdView]) __loadAd:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
                BOOL result = (_loadingError == nil);
                if( [self _gujAdViewCompletionBlock] != nil  && !result ) {
                    [self _gujAdViewCompletionBlock](_loadedAdView,_loadingError);
                }
                return result;
            }];
        }
    });
    
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial && [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewInitialized:)] ) {
        [[self delegate] interstitialViewInitialized:[self _getGUJAdView]];
    } else if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(bannerViewInitialized:)] ) {
        [[self delegate] bannerViewInitialized:[self _getGUJAdView]];
    }
    return [self _getGUJAdView];
}

- (GUJAdView*)adViewForType:(GUJBannerType)type frame:(CGRect)frame
{
    // making the type global
    [[self adConfiguration] setBannerType:type];
    return (GUJAdView*)[self populateAdView:[[_GUJAdView alloc] initWithFrame:frame delegate:(id)self]];
}

@end

/**!
 *
 * Public GUJAdViewController implementation
 *
 */
#import "GUJAdViewController.h"
#import "GUJNativeKeyboardObserver.h"
@implementation GUJAdViewController


#pragma mark public methods
+ (GUJAdViewController*)instanceForAdspaceId:(NSString*)adSpaceId
{
    return [GUJAdViewController instanceForAdspaceId:adSpaceId delegate:nil];
}

+ (GUJAdViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    GUJAdViewController *result = [[GUJAdViewController alloc] init];
    if( result != nil ) {
        if( delegate != nil ) {
            [result setDelegate:delegate];
        }
        result->reinitalizationCount_ = 0;
        [result setAdConfiguration:[[GUJAdConfiguration alloc] init]];
        [[result adConfiguration] setAdSpaceId:adSpaceId];
        [result instanciate];
    }
    return result;
}

- (void)setReloadInterval:(NSTimeInterval)reloadInterval
{
    [[self adConfiguration] setReloadInterval:reloadInterval];
}

- (BOOL)disableLocationService
{
    [[self adConfiguration] setDisableLocationService:YES];
    return [[self adConfiguration] locationServiceDisabled];
}

- (GUJAdView*)adView
{
    [[self adConfiguration] setRequestedBannerType:GUJBannerTypeDefault];
    return [self adViewForType:GUJBannerTypeDefault frame:kGUJAdViewDimensionDefault];
}

- (void)adView:(gujAdViewCompletionHandler)completion
{
    [self set_gujAdViewCompletionBlock:completion];
    [[self adConfiguration] setRequestedBannerType:GUJBannerTypeDefault];
    [self adView];
}

- (GUJAdView*)adViewWithOrigin:(CGPoint)origin
{
    if( origin.x > 0.0 ) {
        origin.x = 0.0;
    }
    [[self adConfiguration] setRequestedBannerType:GUJBannerTypeDefault];
    return [self adViewForType:GUJBannerTypeDefault frame:CGRectOffset(kGUJAdViewDimensionDefault, origin.x, origin.y)];
}

- (void)adViewWithOrigin:(CGPoint)origin completion:(gujAdViewCompletionHandler)completion
{
    [self set_gujAdViewCompletionBlock:completion];
    [self adViewWithOrigin:origin];
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords
{
    [[self adConfiguration] setKeywords:keywords];
    [[self adConfiguration] setRequestedBannerType:GUJBannerTypeDefault];
    return [self _getGUJAdView];
}

- (void)adViewForKeywords:(NSArray*)keywords completion:(gujAdViewCompletionHandler)completion
{
    [self set_gujAdViewCompletionBlock:completion];
    [self adViewForKeywords:keywords];
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin
{
    [[self adConfiguration] setKeywords:keywords];
    [[self adConfiguration] setRequestedBannerType:GUJBannerTypeDefault];
    return [self adViewWithOrigin:origin];
}

- (void)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin completion:(gujAdViewCompletionHandler)completion
{
    [self set_gujAdViewCompletionBlock:completion];
    [self adViewForKeywords:keywords origin:origin];
}

- (void)interstitialAdView // interstitial banner
{
    [self interstitialAdViewWithCompletionHandler:nil];
}

- (void)interstitialAdViewWithCompletionHandler:(gujAdViewCompletionHandler)completion
{
    if( [[self adConfiguration] isValid] ) {
        [self set_gujAdViewCompletionBlock:completion];
        [[self adConfiguration] setRequestedBannerType:GUJBannerTypeInterstitial];
        [[self adConfiguration] setReloadInterval:0.0];
        [self adViewForType:GUJBannerTypeInterstitial frame:kGUJAdViewDimensionDefault];
    } else {
        // check if VC is present
        if( [GUJUtil parentViewController] == nil ) {
            // try again interstitialAdView after time out
            if( (reinitalizationCount_ < [[self adConfiguration] initializationAttempts]) ) {
                if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
                    [[self delegate] interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeSystemMessage message:kGUJ_REINITIALIZATION_ATTEMPT]];
                }
                reinitalizationCount_++;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                    [self interstitialAdViewWithCompletionHandler:completion];
                });
            }
        }
    }
}

- (void)interstitialAdViewForKeywords:(NSArray*)keywords
{
    [[self adConfiguration] setKeywords:keywords];
    [self interstitialAdView];
}

- (void)interstitialAdViewForKeywords:(NSArray*)keywords completion:(gujAdViewCompletionHandler)completion
{
    [[self adConfiguration] setKeywords:keywords];
    [self interstitialAdViewWithCompletionHandler:completion];
}

- (void)addAdServerRequestHeaderField:(NSString*)name value:(NSString*)value
{
    [[self adConfiguration] addCustomAdServerHeaderField:name value:value];
}

- (void)addAdServerRequestHeaderFields:(NSDictionary*)headerFields
{
    [[self adConfiguration] setCustomAdServerHeaderField:headerFields];
}

- (void)addAdServerRequestParameter:(NSString*)name value:(NSString*)value
{
    [[self adConfiguration] addCustomAdServerRequestParameter:name value:value];
}

- (void)addAdServerRequestParameters:(NSDictionary*)requestParameters
{
    [[self adConfiguration] setCustomAdServerRequestParameters:requestParameters];
}

- (void)initalizationAttempts:(NSUInteger)attempts
{
    [[self adConfiguration] setInitializationAttempts:attempts];
}

-(void)freeInstance // free all native interfaces and sharedInstances
{
    [self setAdConfiguration:nil];
    [((_GUJAdView*)[self _getGUJAdView]) __free];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self _setGUJAdView:nil];
    _logd_tm(self, @"freeInstance",nil);
}

#pragma mark AdView delegate (+GUJAdViewControllerDelegate)
- (void)viewWillLoadAd:(GUJAdView *)adView
{
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewWillLoadAdData:)] ) {
            [[self delegate] interstitialViewWillLoadAdData:adView];
        }
    } else {
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(bannerViewWillLoadAdData:)] ) {
            [[self delegate] bannerViewWillLoadAdData:adView];
        }
    }
    _logd_tm(self,@"viewWillLoadAd:",adView ,nil);
}

- (void)view:(GUJAdView*)adView didLoadAd:(GUJAdData*)adData
{ 
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewDidLoadAdData:)] ) {
            [[self delegate] interstitialViewDidLoadAdData:adView];
        }
    } else {
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(bannerViewDidLoadAdData:)] ) {
            [[self delegate] bannerViewDidLoadAdData:adView];
        }
    }
    _logd_tm(self,@"view:didLoadAd:",[adData asNSUTF8StringRepresentation] ,nil);
}

- (void)view:(GUJAdView*)adView didFailToLoadAdWithUrl:(NSURL*)adUrl andError:(NSError*)error
{
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:)] ) {
            [[self delegate] interstitialView:adView didFailLoadingAdWithError:error];
        }
    } else {
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:)] ) {
            [[self delegate] bannerView:adView didFailLoadingAdWithError:error];
        }
    }
    _logd_tm(self,@"view:didFailToLoadAdWithUrl:andError:",error,[adUrl debugDescription],nil);
}

@end

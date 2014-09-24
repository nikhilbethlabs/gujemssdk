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
#import "GUJAdViewContext.h"
#import "GUJAdConfiguration.h"

#import "GUJXAXISViewController.h"

@implementation GUJAdViewContext

__strong GUJXAXISViewController *_GUJVCInstance_;

- (void)__initGUJAdViewController:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    if( delegate != nil && ![delegate conformsToProtocol:@protocol(GUJAdViewControllerDelegate)]) {
    [[NSException exceptionWithName:kGUJDelegateProtocolIsMissingException
                             reason:kGUJDelegateProtocolIsMissingMessage
                           userInfo:nil] raise];
    }
    if( siteId != -1 && zoneId != -1 ) {
        if( delegate != nil ) {
            _GUJVCInstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:delegate];
        } else {
            _GUJVCInstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId];
        }
    } else {
        if( delegate != nil ) {
            _GUJVCInstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId delegate:delegate];
        } else {
            _GUJVCInstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId];
        }
    }
    [((ORMMAViewController*)_GUJVCInstance_) shouldAutoShowInterstitialViewController:YES];
}

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId
{
    return [GUJAdViewContext instanceForAdspaceId:adSpaceId delegate:nil];
}

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    return [GUJAdViewContext instanceForAdspaceId:adSpaceId site:-1 zone:-1 delegate:delegate];
}

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId
{
    return [GUJAdViewContext instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:nil];
}

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    GUJADViewContextSDKDependencyCheck();
    GUJAdViewContext *result = [[GUJAdViewContext alloc] init];
    [result __initGUJAdViewController:adSpaceId site:siteId zone:zoneId delegate:delegate];
    return result;
}

- (void)setReloadInterval:(NSTimeInterval)reloadInterval
{
    [[_GUJVCInstance_ adConfiguration] setReloadInterval:reloadInterval];
}

- (BOOL)disableLocationService
{
    [[_GUJVCInstance_ adConfiguration] setDisableLocationService:YES];
    return [[_GUJVCInstance_ adConfiguration] locationServiceDisabled];
}

- (void)shouldAutoShowIntestitialView:(BOOL)show
{
    [((ORMMAViewController*)_GUJVCInstance_) shouldAutoShowInterstitialViewController:show];
}

- (void)adView:(adViewCompletion)completion
{
    if( completion != nil ) {
        [_GUJVCInstance_ adView:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
            return completion((GUJAdView*)_loadedAdView,_loadingError);
        }];
    } else {
        [_GUJVCInstance_ adView];
    }    
}

- (GUJAdView*)adView
{
    return [_GUJVCInstance_ adView];
}

- (GUJAdView*)adViewWithOrigin:(CGPoint)origin
{
    return [_GUJVCInstance_ adViewWithOrigin:origin];
}

- (void)adViewWithOrigin:(CGPoint)origin completion:(adViewCompletion)completion
{
    if( completion != nil ) {
        [_GUJVCInstance_ adViewWithOrigin:origin completion:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
            return completion((GUJAdView*)_loadedAdView,_loadingError);
        }];
    } else {
        [_GUJVCInstance_ adViewWithOrigin:origin];
    }
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords
{
    return [_GUJVCInstance_ adViewForKeywords:keywords];
}

- (void)adViewForKeywords:(NSArray*)keywords completion:(adViewCompletion)completion
{
    if( completion != nil ) {
        [_GUJVCInstance_ adViewForKeywords:keywords completion:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
            return completion((GUJAdView*)_loadedAdView,_loadingError);
        }];
    } else {
        [_GUJVCInstance_ adViewForKeywords:keywords];
    }
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin
{
    return [_GUJVCInstance_ adViewForKeywords:keywords origin:origin];
}

- (void)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin completion:(adViewCompletion)completion
{
    if( completion != nil ) {
        [_GUJVCInstance_ adViewForKeywords:keywords origin:origin completion:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
            return completion((GUJAdView*)_loadedAdView,_loadingError);
        }];
    } else {
        [_GUJVCInstance_ adViewForKeywords:keywords origin:origin];
    }
}

- (void)interstitialAdView
{
    [_GUJVCInstance_ interstitialAdView];
}

- (void)interstitialAdViewWithCompletionHandler:(adViewCompletion)completion
{
    if( completion != nil ) {
        [_GUJVCInstance_ interstitialAdViewWithCompletionHandler:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
            return completion((GUJAdView*)_loadedAdView,_loadingError);
        }];
    } else {
        [_GUJVCInstance_ interstitialAdView];
    }
}

- (void)interstitialAdViewForKeywords:(NSArray*)keywords
{
    [_GUJVCInstance_ interstitialAdViewForKeywords:keywords];
}

- (void)interstitialAdViewForKeywords:(NSArray*)keywords completion:(adViewCompletion)completion
{
    if( completion != nil ) {
        [_GUJVCInstance_ interstitialAdViewForKeywords:keywords completion:^BOOL(NSObject *_loadedAdView, NSError *_loadingError) {
            return completion((GUJAdView*)_loadedAdView,_loadingError);
        }];
    } else {
        [_GUJVCInstance_ interstitialAdViewForKeywords:keywords];
    }
}

- (void)addAdServerRequestHeaderField:(NSString*)name value:(NSString*)value
{
    [_GUJVCInstance_ addAdServerRequestHeaderField:name value:value];
}

- (void)addAdServerRequestHeaderFields:(NSDictionary*)headerFields
{
    [_GUJVCInstance_ addAdServerRequestHeaderFields:headerFields];
}

- (void)addAdServerRequestParameter:(NSString*)name value:(NSString*)value
{
    [_GUJVCInstance_ addAdServerRequestParameter:name value:value];
}

- (void)addAdServerRequestParameters:(NSDictionary*)requestParameters
{
    [_GUJVCInstance_ addAdServerRequestParameters:requestParameters];
}

- (void)initalizationAttempts:(NSUInteger)attempts
{
    [_GUJVCInstance_ initalizationAttempts:attempts];
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_GUJVCInstance_ freeInstance];
}
@end

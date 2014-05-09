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
#import "ORMMAViewController.h"
#import "ORMMAView.h"
#import "GUJAdData.h"
#import "GUJAdViewController+PrivateImplementation.h"

@interface ORMMAViewController(PrivateImplementation)<GUJAdViewDelegate,GUJAdViewControllerDelegate>

@end

@implementation ORMMAViewController

+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId
{
    return [ORMMAViewController instanceForAdspaceId:adSpaceId delegate:nil];
}

+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    ORMMAViewController *result = [[super alloc] init];
    if( result != nil ) {
        if( delegate != nil ) {
            [result setDelegate:delegate];
        }
        [result setAdConfiguration:[[GUJAdConfiguration alloc] init]];
        [[result adConfiguration] setAdSpaceId:adSpaceId];
        [result instanciate];
    }
    @synchronized(result) {
        return result;
    }
}

- (void)shouldAutoShowInterstitialViewController:(BOOL)show
{
    [self setAutoShowInterstitialViewController:show];
    if( [self _getGUJAdView] != nil ) {
        [((ORMMAView*)[self _getGUJAdView]) setAutoShowInterstitialViewController:[self autoShowInterstitialViewController]];
    }
}

// overrides super method
- (GUJAdView*)adViewForType:(GUJBannerType)type frame:(CGRect)frame
{
    // making the type global
    [[super adConfiguration] setBannerType:type];
    ORMMAView *_ormmaView = [[ORMMAView alloc] initWithFrame:frame delegate:self];
    [_ormmaView setAutoShowInterstitialViewController:[self autoShowInterstitialViewController]];
    return [super populateAdView:_ormmaView];
}

// overrides super method
-(void)freeInstance
{
    [[GUJNativeShakeObserver sharedInstance] stopObserver];
    [[GUJNativeShakeObserver sharedInstance] freeInstance];
    
    [[GUJNativeTiltObserver sharedInstance] stopObserver];
    [[GUJNativeTiltObserver sharedInstance] freeInstance];
    
    [[GUJNativeSizeObserver sharedInstance] stopObserver];
    [[GUJNativeSizeObserver sharedInstance] freeInstance];
    
    [[GUJNativeNetworkObserver sharedInstance] stopObserver];
    [[GUJNativeNetworkObserver sharedInstance] freeInstance];
    
    [[GUJNativeOrientationManager sharedInstance] stopObserver];
    [[GUJNativeOrientationManager sharedInstance] freeInstance];
    
    [[GUJNativeKeyboardObserver sharedInstance] stopObserver];
    [[GUJNativeKeyboardObserver sharedInstance] freeInstance];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super freeInstance];
    _logd_tm(self, @"freeInstance",nil);
}

#pragma mark GUJAdViewControllerDelegate
- (void)interstitialView:(GUJAdView *)interstitialView didFailLoadingAdWithError:(NSError *)error
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:)] ) {
        [[super delegate] interstitialView:interstitialView didFailLoadingAdWithError:error];
    } else if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] interstitialView:(GUJAdView*)self didFailLoadingAdWithError:error];
    }
}

- (void)interstitialViewWillAppear
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewWillAppear)] ) {
        [[super delegate] interstitialViewWillAppear];
    }
}

- (void)interstitialViewDidAppear
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewDidAppear)] ) {
        [[super delegate] interstitialViewDidAppear];
    }
}

- (void)interstitialViewWillDisappear
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewWillDisappear)] ) {
        [[super delegate] interstitialViewWillDisappear];
    }
}

- (void)interstitialViewDidDisappear
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewDidDisappear)] ) {
        [[super delegate] interstitialViewDidDisappear];
    }
}

- (void)interstitialViewReceivedEvent:(GUJAdViewEvent *)event
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
        [[super delegate] interstitialViewReceivedEvent:event];
    }
}

- (void)bannerView:(GUJAdView*)bannerView didFailLoadingAdWithError:(NSError *)error
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:)] ) {
        [[super delegate] bannerView:bannerView didFailLoadingAdWithError:error];
    }
}

- (void)bannerViewDidHide:(GUJAdView*)bannerView
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewDidHide:)] ) {
        [[super delegate] bannerViewDidHide:bannerView];
    }
}

- (void)bannerViewDidShow:(GUJAdView*)bannerView
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewDidShow:)] ) {
        [[super delegate] bannerViewDidShow:bannerView];
    }
}

- (void)bannerView:(GUJAdView*)bannerView receivedEvent:(GUJAdViewEvent*)event
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {
        [[super delegate] bannerView:bannerView receivedEvent:event];
    }
}

-(void)interstitialViewInitialized:(GUJAdView *)interstitialView
{
    _logd_tm(self, @"interstitialViewInitialized:",nil);
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial && [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewInitialized:)] ) {
        [[self delegate] interstitialViewInitialized:interstitialView];
    }
}

- (void)bannerViewInitialized:(GUJAdView *)bannerView
{
    if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewInitialized:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerViewInitialized:bannerView];
    } else if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewDidLoad:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerViewDidLoad:bannerView];
    }
}


- (void)adViewController:(GUJAdViewController *)adViewController didConfigurationFailure:(NSError *)error
{
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(adViewController:didConfigurationFailure:)] ) {
        [[super delegate] adViewController:self didConfigurationFailure:error];
    }
}

-(BOOL)adViewController:(GUJAdViewController *)adViewController canDisplayAdView:(GUJAdView *)adView
{
    BOOL result = YES;
    if( adViewController == nil ) {
        adViewController = self;
    }
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(adViewController:canDisplayAdView:)] ) {
        result = [[super delegate] adViewController:adViewController canDisplayAdView:adView];
    }
    return result;
}

@end

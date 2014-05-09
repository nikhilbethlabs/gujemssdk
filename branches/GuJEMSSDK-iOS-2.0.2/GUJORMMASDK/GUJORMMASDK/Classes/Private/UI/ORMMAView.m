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
#import "ORMMAView.h"
#import "ORMMAViewController.h"
#import "ORMMAView+OverriddenSuperMethods.h"
#import "ORMMAView+PrivateImplementation.h"
#import "ORMMAView+WebViewDelegate.h"

@implementation ORMMAView

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate
{
    self = [super initWithFrame:frame delegate:delegate];
    if (self) {
        [self setInitialAdViewFrame:frame];
        [self setBackgroundColor:[UIColor clearColor]];
        [self hide];
        [self changeState:kORMMAParameterValueForStateInit];
        [self setJavascriptBridge:[[ORMMAJavaScriptBridge alloc] initWithAdView:self]];
        [self setAutoShowInterstitialViewController:YES];
    }
    return self;
}

- (void)changeState:(NSString*)ormmaState
{
    [self setOrmmaViewState:ormmaState];
}

- (NSString*)state
{
    return [self ormmaViewState];
}

- (void)setWebViewFrame:(CGRect)frame
{
    if( [self webView] != nil ) {
        _logd_frame([self webView], frame);
        [[self webView] setFrame:frame];
        [[self webView] setCenter:self.center];
        [[self webView] setAutoresizingMask:( UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    }
}

- (CGRect)webViewFrame
{
    CGRect result = CGRectZero;
    if( [self webView] != nil ) {
        result = [self webView].frame;
    }
    return result;
}

- (void)show
{
    [self show:[self autoShowInterstitialViewController]];
}

- (void)show:(BOOL)showInterstitial
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [self setAlpha:1.0];
    [UIView commitAnimations];
    
    [self changeState:kORMMAParameterValueForStateDefault];
    [self setViewable:YES];
    
    if( [[super adConfiguration] willShowAdModal] ) {
        [self setInterstitialViewController:[[ORMMAInterstitialViewController alloc] initWithNibName:nil bundle:nil]];
        [[self interstitialViewController] setDelegate:self];
        [[self interstitialViewController] addSubviewInset:self];
        [((ORMMAInterstitialViewController*)[self interstitialViewController]) setDisableAutoCloseFeature:[[self adConfiguration] interstitialConnectAd]];
        if( showInterstitial ) {
            [self setViewable:[GUJUtil showPresentModalViewController:[self interstitialViewController]]];
        }
    }
    if( [self superview] != nil ) {
        [[self superview] bringSubviewToFront:self];
    }
    
    if( ![self isInterstitial] && [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewDidShow:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerViewDidShow:(GUJAdView*)self];
    }
}

- (void)showInterstitialView
{
    [self setAutoShowInterstitialViewController:YES];
    [self show];
}

- (void)hide
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [self setAlpha:0.0];
    [UIView commitAnimations];
    
    if( [self isInterstitial] ) {
        __weak ORMMAView *wekSelf = self;
        [self hideIinterstitialVC:^{
            [wekSelf changeState:kORMMAParameterValueForStateHidden];
            [wekSelf setViewable:NO];
        }];
    } else {
        [self changeState:kORMMAParameterValueForStateHidden];
        [self setViewable:NO];
    }
    
    if( (![self isInterstitial] && [[super adConfiguration] bannerType] != GUJBannerTypeUndefined) && [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewDidHide:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerViewDidHide:(GUJAdView*)self];
    }
}

- (BOOL)isInterstitial
{
    return ([[super adConfiguration] willShowAdModal] && [self interstitialViewController] != nil );
}

- (void)hideIinterstitialVC:(void(^)(void))completion
{
    if( [self isInterstitial] ) {
        [[self interstitialViewController] dismiss:completion];
    }
}

#pragma mark touch events
/*!
 * The touch event is only relevant for standard banner formats.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(( [[super adConfiguration] bannerType] == GUJBannerTypeMobile ) &&
       ( [self bannerXMLParser] != nil ) &&
       ( [[self bannerXMLParser] isValid] ) &&
       ( [[self bannerXMLParser] imageLink] != nil )
       ) {
        [self __openURL:[[self bannerXMLParser] imageLink]];
        if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:receivedEvent:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
            [[super delegate] bannerView:(GUJAdView*)self receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeUserInteraction]];
        }
    }
}

#pragma mark modalviewcontroller delegate
- (void)modalViewControllerWillAppear
{
    _logd_tm(self, @"modalViewControllerWillAppear:",nil);
    if([self isInterstitial] &&
       [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewWillAppear) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] interstitialViewWillAppear];
    }
}

- (void)modalViewControllerDidAppear:(GUJModalViewController *)modalViewController
{
    _logd_tm(self, @"modalViewControllerDidAppear:",modalViewController,nil);
    if([self isInterstitial] &&
       [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewDidAppear) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] interstitialViewDidAppear];
    }
}

- (void)modalViewControllerWillDisappear:(GUJModalViewController *)modalViewController
{
    _logd_tm(self, @"modalViewControllerWillHide:",modalViewController,nil);
    if([self isInterstitial] &&
       [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewWillDisappear) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] interstitialViewWillDisappear];
    }
}

- (void)modalViewControllerDidDisappear
{
    _logd_tm(self, @"modalViewControllerDidDisappear:",nil);
    if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewDidDisappear) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] interstitialViewDidDisappear];
    }
}

#pragma mark GUJAdViewControllerDelegate
-(void)interstitialViewInitialized:(GUJAdView *)interstitialView
{
    _logd_tm(self, @"interstitialViewInitialized:",nil);
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial && [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewInitialized:)] ) {
        [[self delegate] interstitialViewInitialized:interstitialView];
    }
}

- (void)bannerViewInitialized:(GUJAdView *)bannerView
{
    _logd_tm(self, @"bannerViewInitialized:",nil);
    if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewInitialized:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerViewInitialized:bannerView];
    } else if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerViewDidLoad:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerViewDidLoad:bannerView];
    }
}

- (void)interstitialView:(GUJAdView *)interstitialView didFailLoadingAdWithError:(NSError *)error
{
    if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] interstitialView:interstitialView didFailLoadingAdWithError:error];
    }
}

- (void)bannerView:(GUJAdView *)bannerView didFailLoadingAdWithError:(NSError *)error
{
    if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerView:bannerView didFailLoadingAdWithError:error];
    }
}

- (void)adViewController:(GUJAdViewController *)adViewController didConfigurationFailure:(NSError *)error
{
    if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(adViewController:didConfigurationFailure:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] adViewController:adViewController didConfigurationFailure:error];
    }
}

- (BOOL)adViewController:(GUJAdViewController *)adViewController canDisplayAdView:(GUJAdView *)adView
{
    BOOL result = YES;
    if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(adViewController:canDisplayAdView:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        result = [[super delegate] adViewController:adViewController canDisplayAdView:adView];
    }
    return result;
}

#pragma mark ORMMAWebBrowserDelegate
- (void)webBrowserWillShow
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__loadAd) object:nil];
}

- (void)webBrowserWillHide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if( ![[super adConfiguration] willShowAdModal] ) {
        
    }
}

- (void)webBrowserFailedStartLoadWithRequest:(NSURLRequest*)error
{
    // give time to unload and perform open requests
    [[self internalWebBrowser] performSelector:@selector(dismissModalViewControllerAnimated:) withObject:kEmptyString afterDelay:1.0];
}

@end

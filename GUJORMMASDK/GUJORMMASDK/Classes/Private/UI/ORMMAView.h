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
// commons
#import "GUJAdViewController.h"
#import "GUJAdConfiguration.h"
#import "_GUJAdView.h"
#import "ORMMAView.h"
#import "ORMMAJavaScriptBridge.h"
#import "GUJAdViewEvent.h"

// third party
#import "GUJAnimatedGif.h"

// util
#import "ORMMAHTMLTemplate.h"

// UI
#import "ORMMAInterstitialViewController.h"
#import "ORMMAWebBrowser.h"

// native interfaces without framework dependencies
#import "GUJNativeCamera.h"
#import "GUJNativeOrientationManager.h"
#import "GUJNativePhoneCall.h"
#import "GUJNativeSizeObserver.h"
#import "GUJNativeShakeObserver.h"
#import "GUJNativeTiltObserver.h"
#import "GUJBannerXMLParser.h"
#import "GUJNativeNetworkObserver.h"
#import "GUJNativeKeyboardObserver.h"

@interface UIWebView (JavaScriptAlert)

- (void)webView:(id*)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

@end

@implementation UIWebView (JavaScriptAlert)

- (void)webView:(id*)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView* dialogue = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [dialogue show];
}

@end

/*!
 * ORMMAView extends GUJAdView and implements the GUJModalViewControllerDelegate protocal
 * Holds an internal UIWebView for displaying HTML advertisements
 */
@interface ORMMAView : _GUJAdView<UIWebViewDelegate, GUJModalViewControllerDelegate, ORMMAWebBrowserDelegate,GUJAdViewControllerDelegate,GUJAdViewDelegate> {
@protected
    // Fallback to Animated GIF AdView
    UIImageView *adImage_;
}


@property (nonatomic, strong) GUJModalViewController    *interstitialViewController;
@property (nonatomic, strong) ORMMAJavaScriptBridge     *javascriptBridge;
@property (nonatomic, strong) GUJBannerXMLParser        *bannerXMLParser;
@property (nonatomic, strong) ORMMAWebBrowser           *internalWebBrowser;
@property (nonatomic, strong) NSString                  *ormmaViewState;
@property (nonatomic, strong) UIWebView                 *webView;
@property (nonatomic, strong) NSMutableString           *deviceCapabilities;
@property (nonatomic, assign) CGRect                    initialAdViewFrame;
@property (nonatomic, assign) BOOL                      viewable;
@property (nonatomic, assign) BOOL                      hasSuperView;
@property (nonatomic, assign) BOOL                      autoShowInterstitialViewController;

- (void)changeState:(NSString*)ormmaState;

- (NSString*)state;

/*!
 * set the current webView frame.
 * the webview will automaticly centered and autoresized.
 */
- (void)setWebViewFrame:(CGRect)frame;

/*!
 *
 @result the frame of the current webView. CGRectZero of the webView is nil
 */
- (CGRect)webViewFrame;

/*!
 * shows the view if hidden.
 */
- (void)show;

/*!
 * shows the adView if hidden.
 * if showInterstitial is False, the interstitial view will not appear.
 */
- (void)show:(BOOL)showInterstitial;

/*!
 * shows the interstital adView if hidden.
 */
- (void)showInterstitialView;

/*!
 * Hides the view without removing it.
 */
- (void)hide;

/*!
 *
 @result 1 if the view is configured as modal view.
 */
- (BOOL)isInterstitial;

/*!
 * forces the internal GUJModalViewController to disappear
 */
- (void)hideIinterstitialVC:(void(^)(void))completion;

@end

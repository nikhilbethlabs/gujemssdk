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
#import "GUJAdView.h"
#import "ORMMAView.h"
#import "ORMMAJavaScriptBridge.h"
#import "GUJAdViewEvent.h"

// third party
#import "GUJAnimatedGif.h"

// default observer
#import "ORMMAStateObserver.h"
#import "ORMMAViewableObserver.h"

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


/*!
 * ORMMAView extends GUJAdView and implements the GUJModalViewControllerDelegate protocal
 * Holds an internal UIWebView for displaying HTML advertisements
 */
@interface ORMMAView : GUJAdView<UIWebViewDelegate, GUJModalViewControllerDelegate, ORMMAWebBrowserDelegate> {
  @protected
    NSTimeInterval          timeLoaded_;
    UIImageView             *adImage_;
    UIWebView               *webView_;
    GUJModalViewController  *interstitialVC_;
    NSMutableString         *deviceCapabilities_;
    GUJBannerXMLParser      *bannerXMLParser_;
    CGRect                   defaultFrame_;
    BOOL                    isVisible_;
    BOOL                    hasSuperView_;
    BOOL                    canReload_;
}

/*!
 * allocates an new ORMMAView with frame and delegate.
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id<GUJAdViewDelegate>)delegate;

/*!
 * overrides the initial frame.
 */
- (void)setDefaultFrame:(CGRect)defaultFrame;

/*!
 *
 @result the initial frame of the View
 */
- (CGRect)defaultFrame;

/*!
 *
 @result the initial size of the view
 */
- (CGSize)defaultSize;

/*!
 *
 @result the initial origin of the view
 */
- (CGPoint)defaultOrigin;

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
 * 
 @result 1 when the ad is configured to reload and does not show the internal webBrowser.
 */
- (BOOL)canReload;

/*!
 * shows the view if hidden.
 */
- (void)show;

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
- (void)hideIinterstitialVC;

/*!
 * 
 @result the current webView object. nil if not loaded.
 */
- (UIWebView*)webView;
@end

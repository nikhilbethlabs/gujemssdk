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

@interface ORMMAView(PrivateImplementation)
- (id)__superDelegate;
- (void)__initializeDeviceCapabilities;
- (void)__initializeWebView;
- (void)__openURL:(NSURL*)url;
- (BOOL)__createRichMediaAdViewWithData:(GUJAdData*)adData;
- (BOOL)__createMobileAdViewWithData:(GUJAdData*)adData;
@end

@implementation ORMMAView(PrivateImplementation)

#pragma mark private methods
- (id)__superDelegate
{
    id result = nil;
    if( [super respondsToSelector:@selector(__adViewDelegate)] ) {
        result = [super performSelector:@selector(__adViewDelegate)];
    }
    return result;
}

- (void)__initializeDeviceCapabilities
{
    if( [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeRichMedia ||
       [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeInterstitial ) {
        // initalize ORMMA related native interfaces        
        /* 
         * Interfaces which has no dependencies to Frameworks instead of (UIkit and Foundation)
         * are safe to instantiate directly.
         */
        [GUJNativeOrientationManager sharedInstance];
        [GUJNativeSizeObserver sharedInstance];      
        [GUJNativePhoneCall sharedInstance];        
        [GUJNativeCamera sharedInstance];
        [GUJNativeShakeObserver sharedInstance];
        [GUJNativeTiltObserver sharedInstance];        
        [GUJNativeNetworkObserver sharedInstance];
        
        // create a string with all device capabilities
        deviceCapabilities_ = [[NSMutableString alloc] init];
        for (NSNumber *capId in [[GUJDeviceCapabilities sharedInstance] deviceCapabilities] ) {
            if( ![deviceCapabilities_ isEqualToString:kEmptyString] ) {
                [deviceCapabilities_ appendString:@", "];
            }
            [deviceCapabilities_ appendFormat:@"'%@'",GUJ_FORMAT_DEVICE_CAPABILITY_TO_NSSTRING([capId intValue])];
        }
        // formating and distribute the device capabilities as ormma support string
        deviceCapabilities_ = [NSMutableString stringWithFormat:@"[%@]",deviceCapabilities_];    
        [[ORMMAJavaScriptBridge sharedInstance] setORMMASupport:deviceCapabilities_];   
    }     
}


- (void)__initializeWebView
{
    self.frame = CGRectOffset(kGUJAdViewDimensionDefault, 0.0f, defaultFrame_.origin.y);
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    if( webView_ != nil ) {
        [webView_ removeFromSuperview];
        webView_ = nil;
    }
    webView_ = [[UIWebView alloc] initWithFrame:self.frame];
    [webView_ setBackgroundColor:[UIColor clearColor]];
    [webView_ setOpaque:NO];
    // disable scrolling on webview
    if( ![[GUJAdConfiguration sharedInstance] willShowAdModal] ) {
        id scrollView = [[webView_ subviews] lastObject];
       /* if([scrollView respondsToSelector:@selector(setScrollingEnabled:)]) {
            [scrollView performSelector:@selector(setScrollingEnabled:) withObject:nil];   
        }*/
        if( [scrollView isKindOfClass:[UIScrollView class]] ) {
            ((UIScrollView*)scrollView).scrollEnabled = NO;
            ((UIScrollView*)scrollView).showsHorizontalScrollIndicator = NO;
            ((UIScrollView*)scrollView).showsVerticalScrollIndicator = NO;
            ((UIScrollView*)scrollView).bounces = NO;
        }
    }
    
    [self addSubview:webView_];        
    
    if( [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeRichMedia ||
       [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeInterstitial ) { 
        [[ORMMAJavaScriptBridge sharedInstance] attachToAdView:self];
    } else {
        // Mobile Banner loaded with adData
        // no initial setup needed
    }
}

- (void)__openURL:(NSURL*)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (BOOL)__createRichMediaAdViewWithData:(GUJAdData*)adData
{
    BOOL result = NO;

    [self performSelectorOnMainThread:@selector(__initializeWebView) withObject:nil waitUntilDone:YES];
    [webView_ loadHTMLString:kEmptyString baseURL:nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kORMMAURLLocalhost,arc4random()]];
   
    [webView_ loadHTMLString:[ORMMAHTMLTemplate htmlTemplateWithAdData:adData] baseURL:url];

    if( [GUJUtil iosVersion] > __IPHONE_4_2 ) {
        result = ![webView_ canGoBack];
    } else {
        result = YES;
    }
    if( !result ) {
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD userInfo:nil]];
    }
    return result;
}

- (BOOL)__createMobileAdViewWithData:(GUJAdData*)adData
{
    BOOL result = NO;
    bannerXMLParser_ = [GUJBannerXMLParser parse:adData];
    result = [bannerXMLParser_ isValid];    
    if( result ) {
        @autoreleasepool {
            adImage_ = [GUJAnimatedGif getAnimationForGifAtUrl:[bannerXMLParser_ imageURL]];   
            
            // reset the size
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, adImage_.frame.size.height)];       
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            // allways center the adImage
            [adImage_ setCenter:self.center];
            adImage_.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
            
            [self addSubview:adImage_];                      
            if( adImage_ != nil ) {
                _logd_tm(self,@"AdImageSize:",[NSString stringWithFormat:@"width: %f height: %f",adImage_.frame.size.width,adImage_.frame.size.height],nil);
            }
        }     
    } else { // other data than banner xml               
        //setup the webview on mainthread
        [self performSelectorOnMainThread:@selector(__initializeWebView) withObject:nil waitUntilDone:YES];
        
        // load ad data
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kORMMAURLLocalhost,arc4random()]];        
        [webView_ loadHTMLString:[ORMMAHTMLTemplate htmlTemplateWithAdData:adData] baseURL:url];        
        [webView_ setDelegate:self];

        _logd_frame(webView_, webView_.frame);
        if( [GUJUtil iosVersion] > __IPHONE_4_2 ) {
            // if the webview can NOT go back, we have a clean instance            
            result = ![webView_ canGoBack];
        } else {
            result = YES;
        }        
    }
    return result;
}

#pragma mark overridden private super methods
- (void)__loadAd
{    
    if(![[[ORMMAStateObserver sharedInstance] state] isEqualToString:kORMMAParameterValueForStateExpanded] &&
       ![[[ORMMAStateObserver sharedInstance] state] isEqualToString:kORMMAParameterValueForStateResized]        
       ) {                    
        [self __unload];
        [super __loadAd];
    }
}

// override super method
- (void)__loadAdNotifcation:(NSNotification*)notification
{    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__loadAd) object:nil];        
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:self name:notification.name];
    [[ORMMAStateObserver sharedInstance] changeState:kORMMAParameterValueForStateLoading];
    [self __loadAd];
}

// override super method
- (void)__adDataLoaded:(GUJAdData*)adData
{
    /*
     * add to the parent vc to get acces to the application bounds.
     */
    @autoreleasepool {
        timeLoaded_     = [[NSDate date] timeIntervalSince1970];        
    }
    hasSuperView_   = ( [self superview] != nil );
    if( !hasSuperView_ ) {
        [[GUJUtil parentViewController].view addSubview:self];        
    }

    [self __initializeDeviceCapabilities];//build support string
    [super __adDataLoaded:adData];

    NSError *adDataError = nil;
    _logd_tm(self, [NSString stringWithFormat:@"SettingUpViewForBannerType: %i",[[GUJAdConfiguration sharedInstance] bannerType]],nil);
    if( [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeUndefined && (adData != nil  && [adData bytes] != nil) ) {
        adDataError = [NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNKNOWN_BANNER_FORMAT userInfo:nil];
        [[GUJNativeErrorObserver sharedInstance] distributeError:adDataError];     
    } else if( [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeMobile ) {
        if( ![self __createMobileAdViewWithData:adData] ) {        
            adDataError = [NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD userInfo:nil];
        }
    } else if([[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeRichMedia||
              [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeInterstitial) {
        /* Attetion!
         * We got no state cause this runs on main thread.
         * Further error handling and forwarding will be find in the methods body
         */ 
        [self performSelectorOnMainThread:@selector(__createRichMediaAdViewWithData:) withObject:adData waitUntilDone:YES];              
    } else { // should never be reached
        adDataError = [NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNKNOWN_BANNER_FORMAT userInfo:nil];
    }
    
    if( adDataError != nil ) {
        [[GUJNativeErrorObserver sharedInstance] distributeError:adDataError]; 
        if( [[self __superDelegate] respondsToSelector:@selector(bannerView:didFialLoadingAdWithError:)] ) {
            id delegate = [self __superDelegate];
            [delegate bannerView:self didFialLoadingAdWithError:adDataError];
        }    
    }
    
}

// override super method
- (void)__adDataFailedLoading
{
    [super __adDataFailedLoading];
}

// override super method
- (void)__unload
{
    [self hide];
    // set the default frame. needed for recalculating the ad size
    [self setFrame:kGUJAdViewDimensionDefault];
    
    // free local instances
    [[ORMMAHTMLTemplate sharedInstance] freeInstance];
    [[ORMMAWebBrowser sharedInstance] freeInstance];
    
    // stop the bridge
    [[ORMMAJavaScriptBridge sharedInstance] unload];
 
    [[GUJDeviceCapabilities sharedInstance] freeInstance];
    
    // stop and unload the webView
    [webView_ stopLoading];    
    if( ![webView_ isLoading] ) {
        [webView_ removeFromSuperview];
        webView_ = nil;
    }
    _logd_tm(self, @"__unload",nil);
    [super __unload];
}

// override super method
- (void)__free
{
    [[GUJNativeOrientationManager sharedInstance] freeInstance];        
    
    [[GUJNativePhoneCall sharedInstance] freeInstance];        
    
    [[GUJNativeCamera sharedInstance] freeInstance];
    
    [[GUJNativeShakeObserver sharedInstance] freeInstance];
    
    [[GUJNativeTiltObserver sharedInstance] freeInstance];   
    
    [[GUJNativeSizeObserver sharedInstance] stopObserver];  
    [[GUJNativeSizeObserver sharedInstance] freeInstance];  
    
    [[GUJNativeNetworkObserver sharedInstance] stopObserver];
    [[GUJNativeNetworkObserver sharedInstance] freeInstance];   
    
    [[GUJNativeOrientationManager sharedInstance] stopObserver];    
    [[GUJNativeOrientationManager sharedInstance] freeInstance];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
    _logd_tm(self, @"__free",nil);    
    
}

- (void)__reloadAd
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // perform a reload directly 
    if( timeLoaded_ > 0.0 ) { 
        // !Important!
        // check if reload time is greater then default reload time
        // otherwise reload with default time
        double reloadOffset = 0.0;
        @autoreleasepool {
            reloadOffset = ([[NSDate date] timeIntervalSince1970] - timeLoaded_);
        }
        if( reloadOffset > [[GUJAdConfiguration sharedInstance] reloadInterval] && canReload_ ) {
            [self performSelector:@selector(__loadAd) withObject:nil afterDelay:0.1];
        } else {
            [self performSelector:@selector(__loadAd) withObject:nil afterDelay:[[GUJAdConfiguration sharedInstance] reloadInterval]];
        }
    } else {
        if( canReload_ ) {
            [self performSelector:@selector(__loadAd) withObject:nil afterDelay:[[GUJAdConfiguration sharedInstance] reloadInterval]];
        }
    }    
    
    if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {
        [[self __superDelegate] bannerView:self receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeSystemMessage message:ORMMA_EVENT_MESSAGE_RELOAD_AD_VIEW]];
    }     
}

- (BOOL)__sizeToFitAdContent
{    
    BOOL result = NO;
    // hide the view
    self.hidden = YES;
    
    // determine the content size via the webview content
    [webView_ setScalesPageToFit:YES];
    CGRect webViewFrame = webView_.frame;
    webViewFrame.size = CGSizeMake(0.5f, 0.5f);
    [webView_ setFrame:webViewFrame];
    webViewFrame.size = [webView_ sizeThatFits:CGSizeZero];
    [webView_ setFrame:webViewFrame];

    // if content is loaded and visible, the size IS greader then 1.0f
    if( (webViewFrame.size.width > 1.0f) && (webView_.frame.size.height > 1.0f) ) {    
        
        CGRect adViewFrame  = self.frame;    
        CGRect parentFrame  = [GUJUtil frameOfFirstResponder];
        adViewFrame.size.width  = parentFrame.size.width;
        adViewFrame.size.height = webViewFrame.size.height;
   
        [self setFrame:adViewFrame];  
        [self setBounds:adViewFrame];
        [self setDefaultFrame:adViewFrame];
        [self setWebViewFrame:webViewFrame];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _logd_frame(self,adViewFrame);
  
        [webView_ setBackgroundColor:[UIColor clearColor]];
        
        webView_.bounds = self.bounds;
        webView_.center = self.center;
        webView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);            
        webView_.contentMode = UIViewContentModeScaleAspectFit;
        result = YES;
    } else {
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil]];
    }
    // remove from pseudo superview before unhide
    if( !hasSuperView_ ) {
        [self removeFromSuperview];
    }
    
    // show the view if everything is fine
    if( result ) {
        self.hidden = NO;
    } else {
        if( [[GUJAdConfiguration sharedInstance] willShowAdModal] ) {
            if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(interstitialViewDidFailLoadingWithError:)] ) {
                [[self __superDelegate] interstitialViewDidFailLoadingWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil]];
            }
        } else {
            if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(bannerView:didFialLoadingAdWithError:)] ) {
                [[self __superDelegate] bannerView:self didFialLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil]];
            }            
        }     
    }
    _logd_tm(self,@"__sizeToFitAdContent",[NSString stringWithFormat:@"%i",result],nil);
    return result;
}

- (void)__openInternalWebBrowser:(NSURLRequest*)urlRequest
{    
    [[ORMMAWebBrowser sharedInstance] setDelegate:self];
    [[ORMMAWebBrowser sharedInstance] navigateToURL:urlRequest];
    [GUJUtil showPresentModalViewController:[ORMMAWebBrowser sharedInstance]];        
}

#pragma mark webview delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{
    BOOL result = NO;
    if( !isVisible_ ) {
        result = YES;
    } else {
        if( [request URL] != nil && [[[request URL] description] rangeOfString:@"localhost"].location == NSNotFound ) {               
            canReload_ = NO;
            if( [self isInterstitial] ) {
                [self hideIinterstitialVC];
                if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
                    [[self __superDelegate] interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeUserInteraction message:ORMMA_EVENT_MESSAGE_AD_CLICKED]];
                } 
            } else {
                if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {
                    [[self __superDelegate] bannerView:self receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeUserInteraction message:ORMMA_EVENT_MESSAGE_AD_CLICKED]];
                } 
            }
            [self performSelector:@selector(__openInternalWebBrowser:) withObject:request afterDelay:0.5];
            
        }
    }
    return result;
}

- (void)__resizeAndDisplayAdView
{
    if( !isVisible_ && [self __sizeToFitAdContent] ) {
        [self show];  
    } else {
        NSError *error = [NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil];
        [[GUJNativeErrorObserver sharedInstance] distributeError:error];        
        if([self isInterstitial] && 
           [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(interstitialViewDidFailLoadingWithError:)]
           ) {
            [[self __superDelegate] interstitialViewDidFailLoadingWithError:error];
        } else if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(bannerView:didFialLoadingAdWithError:)] ) {
            [[self __superDelegate] bannerView:self didFialLoadingAdWithError:error];
        }
    }
}

- (void)__resizeAndDisplayAdViewWithDelay
{
    [self performSelector:@selector(__resizeAndDisplayAdView) withObject:nil afterDelay:kGUJDefaultAdViewResizeAndDisplayDelay];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*
     * If the device is NOT on Wi-Fi, we perform a delayed resize to ensure the ad is fully loaded in background
     */
    /*
     * Wi-Fi check skipped, cause Wi-Fi can also be very slow.
     //if( [[GUJUtil networkInterfaceName] isEqualToString:kNetworkInterfaceIdentifierForTypeEn0] ) {
     //  [self performSelectorOnMainThread:@selector(__resizeAndDisplayAdView) withObject:nil waitUntilDone:NO];        
     //} else {
     //  [self performSelectorOnMainThread:@selector(__resizeAndDisplayAdViewWithDelay) withObject:nil waitUntilDone:NO];
     //}
     */
    [self performSelectorOnMainThread:@selector(__resizeAndDisplayAdViewWithDelay) withObject:nil waitUntilDone:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
    if( ![webView_.request.URL.absoluteString isEqualToString:kORMMAURLAboutBlank] ) {
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAWebBrowserErrorDomain code:error.code userInfo:[error userInfo]]];
    }
}

@end // PrivateImplementation

@implementation ORMMAView

- (id)initWithFrame:(CGRect)frame andDelegate:(id<GUJAdViewDelegate>)delegate
{
    self = [super initWithFrame:frame andDelegate:delegate];
    if (self) {
        canReload_ = YES;
        defaultFrame_ = frame;
        [self setBackgroundColor:[UIColor clearColor]];         
        [self hide];     
    }
    return self;
}

- (void)setDefaultFrame:(CGRect)defaultFrame
{
    defaultFrame_ = defaultFrame;
}

- (CGRect)defaultFrame
{
    return defaultFrame_;
}

- (CGSize)defaultSize
{    
    return defaultFrame_.size;
}

- (CGPoint)defaultOrigin
{
    return defaultFrame_.origin;
}

- (void)setWebViewFrame:(CGRect)frame
{
    if( webView_ != nil ) {
        _logd_frame(webView_, frame);
        [webView_ setFrame:frame];
        [webView_ setCenter:self.center];
        webView_.autoresizingMask = ( UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);                  
    }
}

- (CGRect)webViewFrame
{
    CGRect result = CGRectZero;
    if( webView_ != nil ) {
        result = webView_.frame;
    }
    return result;
}

- (BOOL)canReload
{
    return canReload_;
}

- (void)show
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [self setAlpha:1.0];
    [UIView commitAnimations];
    [[ORMMAStateObserver sharedInstance] changeState:kORMMAParameterValueForStateDefault];    
    [[ORMMAViewableObserver sharedInstance] setViewable:YES];   
    isVisible_ = YES;

    if( [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeInterstitial ||
       [[GUJAdConfiguration sharedInstance] willShowAdModal] ) {     
        interstitialVC_ = [[ORMMAInterstitialViewController alloc] initWithNibName:nil bundle:nil];    
        [interstitialVC_ setDelegate:self];
        [interstitialVC_ addSubviewInset:self];                
        isVisible_ = [GUJUtil showPresentModalViewController:interstitialVC_];           
    }
    if( [self superview] != nil ) {
        [[self superview] bringSubviewToFront:self];
    }
    if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(bannerViewDidShow:)] ) {
        [[self __superDelegate] bannerViewDidShow:self];
    }
}

- (void)hide
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [self setAlpha:0.0];
    [UIView commitAnimations]; 
    [[ORMMAStateObserver sharedInstance] changeState:kORMMAParameterValueForStateHidden];    
    [[ORMMAViewableObserver sharedInstance] setViewable:NO];
    isVisible_ = NO;
    
    if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(bannerViewDidHide:)] ) {
        [[self __superDelegate] bannerViewDidHide:self];
    }    
    
    if( [self isInterstitial] ) {
        [self hideIinterstitialVC];       
    }
    
    // reload ad data 
    if( ![[GUJAdConfiguration sharedInstance] willShowAdModal] && [[GUJAdConfiguration sharedInstance] reloadInterval] > 0.0  ) {
        // remove all request if the default reload listner is not allredy gone
        [self __reloadAd];
    }
} 

- (BOOL)isVisible
{
    return isVisible_;    
}


- (BOOL)isInterstitial
{
    return ([[GUJAdConfiguration sharedInstance] willShowAdModal] && interstitialVC_ != nil );
}

- (void)hideIinterstitialVC
{
    if( [self isInterstitial] ) {
        [interstitialVC_ dismiss];
    }
}

- (UIWebView *)webView
{
    return webView_;
}

#pragma mark touch events
/*!
 * The touch event is only relevant for standard banner formats.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(( [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeMobile ) &&
       ( bannerXMLParser_ != nil ) &&
       ( [bannerXMLParser_ isValid] ) && 
       ( [bannerXMLParser_ imageLink] != nil )
       ) {
        [self __openURL:[bannerXMLParser_ imageLink]];
        if( [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {
            [[self __superDelegate] bannerView:self receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeUserInteraction]];
        }         
    }
}

#pragma mark modalviewcontroller delegate
- (void)modalViewControllerWillAppear
{
    _logd_tm(self, @"modalViewControllerWillAppear:",nil);        
    if([self isInterstitial] &&
       [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(interstitialViewWillAppear)] ) {
        [[self __superDelegate] interstitialViewWillAppear];
    }    
}

- (void)modalViewControllerDidAppear:(GUJModalViewController *)modalViewController
{
    _logd_tm(self, @"modalViewControllerDidAppear:",modalViewController,nil);    
    if([self isInterstitial] &&
       [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(interstitialViewDidAppear)] ) {
        [[self __superDelegate] interstitialViewDidAppear];
    }
}

- (void)modalViewControllerWillDisappear:(GUJModalViewController *)modalViewController 
{
    _logd_tm(self, @"modalViewControllerWillHide:",modalViewController,nil);
    if([self isInterstitial] &&
       [GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(interstitialViewWillDisappear)] ) {
        [[self __superDelegate] interstitialViewWillDisappear];
    }
    if( [[GUJAdConfiguration sharedInstance] willShowAdModal] ) {
        // important! free the instance        
        [[ORMMAViewController instance ] freeInstance];
    }
}

- (void)modalViewControllerDidDisappear
{
    _logd_tm(self, @"modalViewControllerDidDisappear:",nil);      
    if([GUJUtil typeIsNotNil:[self __superDelegate] andRespondsToSelector:@selector(interstitialViewDidDisappear)] ) {
        [[self __superDelegate] interstitialViewDidDisappear];
    }   
}

#pragma mark ORMMAWebBrowserDelegate
- (void)webBrowserWillShow 
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__loadAd) object:nil];
}

- (void)webBrowserWillHide
{        
    if( ![[GUJAdConfiguration sharedInstance] willShowAdModal] ) {
        canReload_ = YES;
    }
}

- (void)webBrowserFailedStartLoadWithRequest:(NSURLRequest*)error
{
    // give time to unload and perform open requests
    [[ORMMAWebBrowser sharedInstance] performSelector:@selector(dismissModalViewControllerAnimated:) withObject:kEmptyString afterDelay:1.0];
}
@end

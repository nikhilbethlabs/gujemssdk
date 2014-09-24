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

#import "ORMMAView+PrivateImplementation.h"

@implementation ORMMAView (PrivateImplementation)

#pragma mark private methods
- (void)__initializeDeviceCapabilities
{
    if( [[super adConfiguration] bannerType] != GUJBannerTypeUndefined ) {
        // create a string with all device capabilities
        [self setDeviceCapabilities:[[NSMutableString alloc] init]];
        for (NSNumber *capId in [[GUJDeviceCapabilities sharedInstance] deviceCapabilities] ) {
            if( ![[self deviceCapabilities] isEqualToString:kEmptyString] ) {
                [[self deviceCapabilities] appendString:@", "];
            }
            [[self deviceCapabilities] appendFormat:@"'%@'",GUJ_FORMAT_DEVICE_CAPABILITY_TO_NSSTRING([capId intValue])];
        }
        // formating and distribute the device capabilities as ormma support string
        [self setDeviceCapabilities:[NSMutableString stringWithFormat:@"[%@]",[self deviceCapabilities]]];
        [[self javascriptBridge] setOrmmaSupportString:[self deviceCapabilities]];
    }
}

- (void)__initializeWebView
{
    [self setFrame:CGRectOffset(kGUJAdViewDimensionDefault, 0.0f, [self initialAdViewFrame].origin.y)];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if( [self webView] != nil ) {
        [[self webView] removeFromSuperview];
        [self setWebView:nil];
    }
    
    [self setWebView:[[UIWebView alloc] initWithFrame:self.frame]];
    [[self webView] setBackgroundColor:[UIColor clearColor]];
    [[self webView] setOpaque:NO];
    [[self webView] setDelegate:self];
    
    // disable scrolling on webview
    if( ![[super adConfiguration] willShowAdModal] ) {
        id scrollView = [[[self webView] subviews] lastObject];
        if( [scrollView isKindOfClass:[UIScrollView class]] ) {
            [ORMMAUtil changeScrollView:scrollView scrolling:NO];
        }
    }
    
    [self addSubview:[self webView]];
    [[self webView] loadHTMLString:kEmptyString baseURL:nil];
    
    if([[super adConfiguration] bannerType] == GUJBannerTypeRichMedia ||
       [[super adConfiguration] bannerType] == GUJBannerTypeInterstitial ) {
        [[self javascriptBridge] attachToAdView:self];
    } else {
        // Mobile Banner loaded with adData
        // no initial setup needed
    }
}

- (void)__openURL:(NSURL*)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)__createRichMediaAdViewWithData:(GUJAdData*)adData completion:(void(^)(BOOL result))completion
{
    BOOL result = NO;
    
    [self __initializeWebView];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kORMMAURLLocalhost,arc4random()]];
    [[self webView] loadHTMLString:[ORMMAHTMLTemplate htmlTemplateWithAdData:adData] baseURL:url];
    
    result = ![[self webView] canGoBack];
    
    if( !result ) {
        [[self webView] removeFromSuperview];
        if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:)] ) {
            [[super delegate] bannerView:((GUJAdView*)self) didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD userInfo:nil]];
        } else {
            _log_t(self, [NSString stringWithFormat:@"[ERROR] %@: %i",kORMMAViewErrorDomain,ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD]);
        }
    }
    completion(result);
}

- (void)__createMobileAdViewWithData:(GUJAdData*)adData completion:(void(^)(BOOL result))completion
{
    BOOL result = NO;
    [self setBannerXMLParser:[GUJBannerXMLParser parse:adData]];
    result = [[self bannerXMLParser] isValid];
    
    if( result ) {
        @autoreleasepool {
            adImage_ = [GUJAnimatedGif getAnimationForGifAtUrl:[[self bannerXMLParser] imageURL]];
            
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
        [self __initializeWebView];
        // load ad data
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kORMMAURLLocalhost,arc4random()]];
        [[self webView] loadHTMLString:[ORMMAHTMLTemplate htmlTemplateWithAdData:adData] baseURL:url];
        [[self webView] setDelegate:self];
        
        // if the webview can NOT go back, we have a clean instance
        result = ![[self webView] canGoBack];
        if( !result ) {
            [[self webView] removeFromSuperview];
            if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:)] ) {
                [[super delegate] bannerView:((GUJAdView*)self) didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD userInfo:nil]];
            } else {
                _log_t(self, [NSString stringWithFormat:@"[ERROR] %@: %i",kORMMAViewErrorDomain,ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD]);
            }
        }
    }
    completion(result);
}

// override super method
- (BOOL)__sizeToFitAdContent
{
    BOOL result = NO;
    // hide the view
    [self setHidden:YES];
    
    // determine the content size via the webview content
    [[self webView] setScalesPageToFit:YES];
    
    CGRect webViewFrame = [self webView].frame;
    // webViewFrame.size = CGSizeMake(0.5f, 0.5f);
    // [[self webView] setFrame:webViewFrame];
    webViewFrame.size = [[self webView] sizeThatFits:CGSizeZero];
    [[self webView] setFrame:webViewFrame];
    
    // if content is loaded and visible, the size IS greader then 1.0f
    if( (webViewFrame.size.width > 1.0f) && (webViewFrame.size.height > 1.0f) ) {
        
        CGRect adViewFrame  = self.frame;
        CGRect parentFrame  = [GUJUtil frameOfFirstResponder];
        adViewFrame.size.width  = parentFrame.size.width;
        adViewFrame.size.height = webViewFrame.size.height;
        
        [self setFrame:adViewFrame];
        [self setBounds:adViewFrame];
        
        [self setInitialAdViewFrame:adViewFrame];
        [self setWebViewFrame:webViewFrame];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        [[self webView] setBounds:self.bounds];
        [[self webView] setCenter:self.center];
        [[self webView] setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
        [[self webView] setContentMode:UIViewContentModeScaleAspectFit];
        
        [self setFrame:[GUJUtil adjustFrameToBestFittingAdViewFrame:[self frame]]];
        [self.webView setFrame:[self frame]];
        
        result = YES;
    } else {
        if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:)] ) {
            [[super delegate] bannerView:((GUJAdView*)self) didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil]];
        } else {
            _log_t(self, [NSString stringWithFormat:@"[ERROR] %@: %i",kORMMAViewErrorDomain,ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE]);
        }
    }
    // remove from pseudo superview before unhide
    if( ![self hasSuperView] ) {
        [self removeFromSuperview];
    }
    
    // show the view if everything is fine
    if( result ) {
        self.hidden = NO;
    } else {
        if( [[super adConfiguration] willShowAdModal] ) {
            if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:)] ) {
                [[super delegate] interstitialView:(GUJAdView*)self didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil]];
            }
        } else {
            if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
                [[super delegate] bannerView:(GUJAdView*)self didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil]];
            }
        }
    }
    
    _logd_tm(self,@"__sizeToFitAdContent",[NSString stringWithFormat:@"%i",result],nil);
    _logd_frame(self, self.frame);
    return result;
}

- (void)__openInternalWebBrowser:(NSURLRequest*)urlRequest
{
    [[self webView] stopLoading];
    [self setInternalWebBrowser:[[ORMMAWebBrowser alloc] init]];
    [[self internalWebBrowser] setDelegate:self];
    [[self internalWebBrowser] navigateToURL:urlRequest];
    
    if( [self isInterstitial] ) {
        __weak ORMMAView *weakSelf = self;
        [self hideIinterstitialVC:^{
            [GUJUtil showPresentModalViewController:[weakSelf internalWebBrowser]];
        }];
    } else {
        [GUJUtil showPresentModalViewController:[self internalWebBrowser]];
    }
}

- (void)__resizeAndDisplayAdView
{
    if( ![self viewable] && [self __sizeToFitAdContent] ) {
        
        if( [self adViewCompletionHandler] != nil ) {
            if( [self adViewCompletionHandler](self,nil) ) {
                [self show];
            }
        } else if([GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(adViewController:canDisplayAdView:) andProtocol:@protocol(GUJAdViewControllerDelegate)]
                  ) {
            if( [[super delegate] adViewController:nil canDisplayAdView:(GUJAdView*)self] ) {
                [self show];
            }
        } else {
            [self show];
        }
        
    } else {
        NSError *error = [NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE userInfo:nil];
        if([self isInterstitial] &&
           [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)]
           ) {
            [[super delegate] interstitialView:(GUJAdView*)self didFailLoadingAdWithError:error];
        } else if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
            [[super delegate] bannerView:(GUJAdView*)self didFailLoadingAdWithError:error];
        }
    }
}

@end

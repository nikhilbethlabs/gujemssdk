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
#import "ORMMAView+WebViewDelegate.h"
#import "ORMMAView+PrivateImplementation.h"

@implementation ORMMAView (WebViewDelegate)

#pragma mark webview delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL result = NO;
    if( ![self viewable] && ![ORMMAUtil webViewHasORMMAContent:webView] ) {
        result = YES;
    } else {
        // recreate a non cached urlrequest
        request = [NSMutableURLRequest requestWithURL:[request URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kGUJDefaultAdReloadInterval];
        if( [ORMMAUtil webViewHasORMMAContent:webView] ) {
            // we need to reverse the handler result to get a propper result for the delegate method
            result = ![[self javascriptBridge] handleRequest:request];
        } else {
            if( [GUJUtil isValidInternalWebViewRequest:request] ) {
                if( [self isInterstitial] ) {
                    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
                        [[super delegate] interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeUserInteraction message:ORMMA_EVENT_MESSAGE_AD_CLICKED]];
                    }
                    [self __openInternalWebBrowser:[NSURLRequest requestWithURL:request.URL]];
                } else {
                    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:receivedEvent:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
                        [[super delegate] bannerView:(GUJAdView*)self receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeUserInteraction message:ORMMA_EVENT_MESSAGE_AD_CLICKED]];
                    }
                    // check if running on main thread
                    if ([NSThread isMainThread]) {
                        [self __openInternalWebBrowser:[NSURLRequest requestWithURL:request.URL]];
                    } else {
                        __weak NSURLRequest *weakRequest = [NSURLRequest requestWithURL:request.URL];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self __openInternalWebBrowser:weakRequest];
                        });
                    }
                }
            }
            
        }
    }
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if( [ORMMAUtil webViewHasORMMAContent:webView] ) {
        __weak ORMMAJavaScriptBridge *weakBridge = [self javascriptBridge];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kGUJDefaultAdViewResizeAndDisplayDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [weakBridge initializeORMMAAndDisplayAdView];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kGUJDefaultAdViewResizeAndDisplayDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self __resizeAndDisplayAdView];
        });
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if( webView.request.URL != nil && ![GUJUtil isValidInternalWebViewRequest:webView.request] ) {
        if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:)] ) {
            [[super delegate] bannerView:((GUJAdView*)self) didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAWebBrowserErrorDomain code:error.code userInfo:[error userInfo]]];
        } else {
            _log_t(self, [NSString stringWithFormat:@"[ERROR] %@: %@",kORMMAWebBrowserErrorDomain,error]);
        }
    }
}

@end

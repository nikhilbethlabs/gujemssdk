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

@implementation ORMMAUtil

+ (BOOL)isORMMAView:(id)view
{
    return [view isKindOfClass:[ORMMAView class]];
}

+ (NSString*)translateNetworkInterface:(NSString*)networkInterfaceName
{
    NSString *result = nil;
    if( [networkInterfaceName isEqualToString:kNetworkInterfaceIdentifierForTypeEn0] ) {
        result = kORMMANetworkIdentifierForWifi;
    } else if( [networkInterfaceName isEqualToString:kNetworkInterfaceIdentifierForTypePdp_ip0] ) {
        result = kORMMANetworkIdentifierForCellular;
    } else {
#ifndef __clang_analyzer__
        result = kORMMANetworkIdentifierForOffline;
#endif
#if(TARGET_IPHONE_SIMULATOR)
        result = kNetworkInterfaceIdentifierForTypeEn0;
#endif
    }
    return result;
}

+ (BOOL)webViewHasORMMAContent:(UIWebView*)webView
{
    return [ORMMAUtil webViewHasORMMAObject:webView] && [ORMMAUtil webViewHasORMMAReadyFunction:webView];
}

+ (BOOL)webViewHasORMMAObject:(UIWebView*)webView
{
    BOOL result = NO;
    if( webView != nil ) {
        NSString *jsResponse = [webView stringByEvaluatingJavaScriptFromString:kORMMAJavascriptTypeOfOrmmaView];
        result = ( jsResponse != nil && [jsResponse isEqualToString:kORMMAJavascriptObejctIdentifier] );
    }
    return result;
}

+ (BOOL)webViewHasORMMAReadyFunction:(UIWebView*)webView
{
    BOOL result = NO;
    if( webView != nil ) {
        NSString *jsResponse = [webView stringByEvaluatingJavaScriptFromString:kORMMAJavascriptTypeCheckOfOrmmaReadyFunction];
        result = (jsResponse != nil && [jsResponse isEqualToString:kORMMAParameterValueForBooleanTrue]);
    }
    return result;
}

+ (BOOL)isObviousAdViewRequestForWebView:(UIWebView*)webView
{
    BOOL result = NO;
    if( !([ORMMAUtil webViewHasORMMAObject:webView] && [ORMMAUtil webViewHasORMMAReadyFunction:webView]) ) {
        if( [webView request] != nil &&  [[webView request] URL] != nil ) {
            NSString *currentURLString = [[[webView request] URL] absoluteString];
            if(![currentURLString isEqualToString:kEmptyString] &&
               ![currentURLString isEqualToString:kGUJURLAboutBlank] &&
               ![currentURLString hasSuffix:kGUJURLSuffixLocalhost] ) {
                result = YES;
            }
        }
    }
    return result;
}

+ (BOOL)adViewHasValidAdSize:(UIWebView*)webView
{
    return ( webView != nil && ( webView.frame.size.width > 1.0f) && ( webView.frame.size.height > 1.0f) );
}

+ (void)changeScrollView:(UIScrollView*)scrollView scrolling:(BOOL)scroll
{
    ((UIScrollView*)scrollView).scrollEnabled = scroll;
    ((UIScrollView*)scrollView).showsHorizontalScrollIndicator = NO;
    ((UIScrollView*)scrollView).showsVerticalScrollIndicator = scroll;
    ((UIScrollView*)scrollView).bounces = scroll;
}


@end

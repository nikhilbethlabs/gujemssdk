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

#import "ORMMAView+OverriddenSuperMethods.h"
#import "ORMMAView+PrivateImplementation.h"

@implementation ORMMAView (OverriddenSuperMethods)

#pragma mark overridden private super methods
- (void)__loadAd
{
    if(![[self ormmaViewState] isEqualToString:kORMMAParameterValueForStateExpanded] &&
       ![[self ormmaViewState] isEqualToString:kORMMAParameterValueForStateResized]
       ) {
        [self setOrmmaViewState:kORMMAParameterValueForStateLoading];
        [self __unload];
        [super __loadAd];
    }
}

- (void)__reloadAd
{
    [super __reloadAd];
    if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:receivedEvent:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        [[super delegate] bannerView:(GUJAdView*)self receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeSystemMessage message:ORMMA_EVENT_MESSAGE_RELOAD_AD_VIEW]];
    }
}

// override super method
- (void)__adDataLoaded:(GUJAdData*)adData
{
    [self setOrmmaViewState:kORMMAParameterValueForStateHidden];
    /*
     * add to the parent vc to get acces to the application bounds.
     */
    [self setHasSuperView:( [self superview] != nil )];
    if( ![self hasSuperView] ) {
        [[GUJUtil parentViewController].view addSubview:self];
    }
    
    [self __initializeDeviceCapabilities];//build support string
    [super __adDataLoaded:adData];
    NSError *adDataError = nil;
    _logd_tm(self, [NSString stringWithFormat:@"SettingUpViewForBannerType: %i",[[super adConfiguration] bannerType]],nil);
    if( [[super adConfiguration] bannerType] == GUJBannerTypeUndefined && (adData != nil  && [adData bytes] != nil) ) {
        adDataError = [NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNKNOWN_BANNER_FORMAT userInfo:nil];
    } else if( [[super adConfiguration] bannerType] == GUJBannerTypeMobile ) {
        [self __createMobileAdViewWithData:adData completion:^(BOOL result) {
            if( !result ) {
                if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
                    [[super delegate] bannerView:(GUJAdView*)self didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD userInfo:nil]];
                }
            }
        }];
    } else if([[super adConfiguration] bannerType] == GUJBannerTypeRichMedia||
              [[super adConfiguration] bannerType] == GUJBannerTypeInterstitial) {
        [self __createRichMediaAdViewWithData:adData completion:^(BOOL result) {
            if( !result ) {
                if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
                    [[super delegate] bannerView:(GUJAdView*)self didFailLoadingAdWithError:[NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD userInfo:nil]];
                }
            }
            
        }];
    } else { // should never be reached
        adDataError = [NSError errorWithDomain:kORMMAViewErrorDomain code:ORMMA_ERROR_CODE_UNKNOWN_BANNER_FORMAT userInfo:nil];
    }
    if( adDataError != nil ) {
        if( [GUJUtil typeIsNotNil:[super delegate] andRespondsToSelector:@selector(bannerView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
            [[super delegate] bannerView:(GUJAdView*)self didFailLoadingAdWithError:adDataError];
        }
    }
    
}

// override super method
- (void)__unload
{
    [self hide];
    // set the default frame. needed for recalculating the ad size
    [self setFrame:kGUJAdViewDimensionDefault];
    
    // free local instances
    [[self internalWebBrowser] freeInstance];
    
    // stop the bridge
    [[self javascriptBridge] unload];
    
    [[GUJDeviceCapabilities sharedInstance] freeInstance];
    
    // stop and unload the webView
    [[self webView] stopLoading];
    if( ![[self webView] isLoading] ) {
        [[self webView] removeFromSuperview];
        [self setWebView:nil];
    }
    _logd_tm(self, @"__unload",nil);
    [super __unload];
}


@end

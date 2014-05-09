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
#import "GUJmOceanViewController.h"
#import "GUJAdConfiguration.h"
#import "_GUJAdView.h"
#import "GUJAdViewController+PrivateImplementation.h"
#import "GUJmOceanBridge.h"

@interface GUJAdView :UIView @end /* added in 2.0.1 */

@interface GUJmOceanViewController(PrivateImplementationDelegate)<GUJAdViewDelegate>

@end

@implementation GUJmOceanViewController

__strong GUJmOceanBridge *mOceanBridge;

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId
{
    return [GUJmOceanViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:nil];
}

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    
    GUJmOceanViewController *result = (GUJmOceanViewController*)[[super alloc] init];
    if( result != nil ) {
        if( delegate != nil ) {
            [result setDelegate:delegate];
        }
        [result setAdConfiguration:[[GUJAdConfiguration alloc] init]];
        [[result adConfiguration] setAdSpaceId:adSpaceId];
        [[result adConfiguration] addCustomConfiguration:[NSNumber numberWithInt:siteId] forKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID];
        [[result adConfiguration] addCustomConfiguration:[NSNumber numberWithInt:zoneId] forKey:kGUJ_MOCEAN_CONFIGURATION_KEY_ZONE_ID];
        [result setMOceanBackFill:YES];
        [result instanciate];
    }
    @synchronized(result) {
        return result;
    }
}

#
#pragma mark overridden methods
#
-(void)freeInstance
{
    [mOceanBridge freeInstance];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:mOceanBridge];
    mOceanBridge = nil;
    [super freeInstance];
    _logd_tm(self, @"freeInstance",nil);
}

@end

@implementation GUJmOceanViewController(PrivateImplementation)

- (void)__instantiateMOceanBridge
{
    [[self adConfiguration] setReloadInterval:0.0];// no reload
    mOceanBridge = [[GUJmOceanBridge alloc] init];
    [mOceanBridge setAdConfiguration:[self adConfiguration]];
    [mOceanBridge setGujAdView:(_GUJAdView*)[super _getGUJAdView]];
    [mOceanBridge setAdViewDelegate:[(_GUJAdView*)[super _getGUJAdView] delegate]];
    if(  [mOceanBridge isConfiguredForMASTAdRequest] ) {
        if( [GUJUtil iosVersion] > 60100 ) {
            [mOceanBridge performMASTAdRequest];
        } else {
            [mOceanBridge performSelectorOnMainThread:@selector(performMASTAdRequest) withObject:nil waitUntilDone:NO];
        }
    }
}

- (BOOL)__willPerformMOceanBackFillRequestWithAdView:(GUJAdView*)adView andError:(NSError *)error
{
    /*
     * Check if a mOcean request is possible when the previous ORMMA request fails.
     */
    BOOL result = NO;
    if( (error.code == GUJ_ERROR_CODE_INVALID_AD_FORMAT_HEADER) ||
       (error.code == GUJ_ERROR_CODE_INCORRECT_AD_FORMAT) ||
       (error.code == ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE ) ) {
        if( [adView respondsToSelector:@selector(hide)] ) {
            [adView performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:YES];
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        if( [self mOceanBackFill] ) {
            if( [GUJUtil iosVersion] > 60100 ) {
                if( [self respondsToSelector:@selector(__instantiateMOceanBridge)] ) {
                    [self __instantiateMOceanBridge];
                }
            } else {
                if( [self respondsToSelector:@selector(__instantiateMOceanBridge)] ) {
                    [self performSelectorOnMainThread:@selector(__instantiateMOceanBridge) withObject:nil waitUntilDone:NO];
                }
            }
            result = YES;
            _logd_tm(self,@"mOceanBackfill:Enabled",nil);
        }
        
    }
    return result;
}

- (void)interstitialView:(GUJAdView *)interstitialView didFailLoadingAdWithError:(NSError *)error
{
    if( ![self __willPerformMOceanBackFillRequestWithAdView:interstitialView andError:error] ) {
        _logd_tm(self,@"interstitialView:didFailLoadingAdWithError:",error,nil);
        [super interstitialView:interstitialView didFailLoadingAdWithError:error];
    }
}

- (void)view:(GUJAdView*)adView didFailToLoadAdWithUrl:(NSURL*)adUrl andError:(NSError*)error
{
    if( ![self __willPerformMOceanBackFillRequestWithAdView:adView andError:error] ) {
        _logd_tm(self,@"view:didFailToLoadAdWithUrl:andError:",error,[adUrl debugDescription],nil);
        [super view:adView didFailToLoadAdWithUrl:adUrl andError:error];
    }
}

@end

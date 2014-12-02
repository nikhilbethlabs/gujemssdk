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
#import "GUJAdView.h"

#import "GUJmOceanBridge.h"

@interface GUJmOceanViewController(PrivateImplementationDelegate)<GUJAdViewDelegate>

@end

@implementation GUJmOceanViewController

@synthesize mOceanBackFill;

static GUJmOceanViewController *instance_;

#
#pragma mark public methods
#
+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId
{
    instance_ = (GUJmOceanViewController*)[GUJmOceanViewController instanceForAdspaceId:adSpaceId delegate:nil];
    [instance_ setMOceanBackFill:NO];
    return instance_;
}

+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    instance_ = (GUJmOceanViewController*)[super instanceForAdspaceId:adSpaceId delegate:delegate];
    [instance_ setMOceanBackFill:NO];    
    return instance_; 
}

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId
{
    return [GUJmOceanViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:nil];
}

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    instance_ = (GUJmOceanViewController*)[super instanceForAdspaceId:adSpaceId delegate:delegate];
    [[GUJAdConfiguration sharedInstance] addCustomConfiguration:[NSNumber numberWithInt:siteId] forKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID];
    [[GUJAdConfiguration sharedInstance] addCustomConfiguration:[NSNumber numberWithInt:zoneId] forKey:kGUJ_MOCEAN_CONFIGURATION_KEY_ZONE_ID]; 
    if( [GUJUtil iosVersion] >= __IPHONE_4_0 ) {
        [instance_ setMOceanBackFill:YES];   
    } else {
        [instance_ setMOceanBackFill:NO];        
    }
    return instance_; 
}

#
#pragma mark overridden methods
#
-(void)freeInstance
{
    [super freeInstance];    
    [NSObject cancelPreviousPerformRequestsWithTarget:instance_];    
    if( [GUJmOceanBridge sharedInstance] ) {
        [[GUJmOceanBridge sharedInstance] freeInstance];
    }
    instance_ = nil;
    _logd_tm(self, @"freeInstance",nil);  
}

@end

@implementation GUJmOceanViewController(PrivateImplementation)

- (void)__instantiateMOceanBridge
{
    [[GUJAdConfiguration sharedInstance] setReloadInterval:0.0]; // no reload
    [GUJmOceanBridge instanceWithGUJAdView:[super performSelector:@selector(__adViewInstance)]];
    if( [GUJmOceanBridge sharedInstance] ) {
        // send event
        [[GUJmOceanBridge sharedInstance] performSelectorOnMainThread:@selector(performMASTAdRequest) withObject:nil waitUntilDone:NO];
    }
}

- (void)view:(GUJAdView*)adView didFailToLoadAdWithUrl:(NSURL*)adUrl andError:(NSError*)error
{    
    _logd_tm(self,@"view:didFailToLoadAdWithUrl:andError:",error,[adUrl debugDescription],nil);
    /*
     * Check if a mOcean request is possible when the previous ORMMA request fails.
     */ 
    if( (error.code == GUJ_ERROR_CODE_INVALID_AD_FORMAT_HEADER) || 
       (error.code == GUJ_ERROR_CODE_INCORRECT_AD_FORMAT) ||
       (error.code == ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE ) ) {
        if( [adView respondsToSelector:@selector(hide)] ) {
            [adView performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:YES];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:instance_];        
        if( mOceanBackFill && [GUJmOceanBridge isConfiguredForMASTAdRequest] ) {  
            _logd_tm(self,@"mOceanBackfill",nil);            
            [self performSelectorOnMainThread:@selector(__instantiateMOceanBridge) withObject:nil waitUntilDone:NO];
        }
        
    } else {
        if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(bannerView:didFialLoadingAdWithError:)] ) {
            [delegate_ bannerView:adView didFialLoadingAdWithError:error];
        }          
    }    
    
}

@end

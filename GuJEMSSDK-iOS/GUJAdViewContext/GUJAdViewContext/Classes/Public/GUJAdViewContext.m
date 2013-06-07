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
#import "GUJAdViewContext.h"
#import "GUJAdConfiguration.h"

#import "GUJXAXISViewController.h"

@implementation GUJAdViewContext

@synthesize mOceanBackFill;

static GUJAdViewContext         *instance_;
static GUJXAXISViewController   *sharedGUJVCinstance_;

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId
{    
    return [GUJAdViewContext instanceForAdspaceId:adSpaceId delegate:nil];
}

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    GUJADViewContextSDKDependencyCheck();      
    if( delegate != nil ) {
        sharedGUJVCinstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId delegate:delegate];   
    } else {
        sharedGUJVCinstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId];
    }
    if( instance_ == nil ) {
        instance_ = [[super alloc] init];
    }
    return instance_;
}

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId
{
    return [GUJAdViewContext instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:nil];
}

+ (GUJAdViewContext*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    GUJADViewContextSDKDependencyCheck();  
    if( delegate != nil ) {
        sharedGUJVCinstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:delegate];
    } else {
        sharedGUJVCinstance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId];
    }
    if( instance_ == nil ) {
        instance_ = [[super alloc] init];
    }
    return instance_;
}

+ (void)setReloadInterval:(NSTimeInterval)reloadInterval
{
    [[GUJAdConfiguration sharedInstance] setReloadInterval:reloadInterval];
}

+ (BOOL)disableLocationService
{
    [[GUJAdConfiguration sharedInstance] setDisableLocationService:YES];
    return [[GUJAdConfiguration sharedInstance] locationServiceDisabled];
}

- (GUJAdView*)adView
{
    return [sharedGUJVCinstance_ adView];
}

- (GUJAdView*)adViewWithOrigin:(CGPoint)origin
{
    return [sharedGUJVCinstance_ adViewWithOrigin:origin];
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords
{
    return [sharedGUJVCinstance_ adViewForKeywords:keywords];
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin
{
    return [sharedGUJVCinstance_ adViewForKeywords:keywords origin:origin];
}

- (void)interstitialAdView
{
    [sharedGUJVCinstance_ interstitialAdView];
}

- (void)interstitialAdViewForKeywords:(NSArray*)keywords
{
    [sharedGUJVCinstance_ interstitialAdViewForKeywords:keywords];
}

- (void)addAdServerRequestHeaderField:(NSString*)name value:(NSString*)value
{
    [sharedGUJVCinstance_ addAdServerRequestHeaderField:name value:value];
}

- (void)addAdServerRequestHeaderFields:(NSDictionary*)headerFields
{
    [sharedGUJVCinstance_ addAdServerRequestHeaderFields:headerFields];    
}

- (void)addAdServerRequestParameter:(NSString*)name value:(NSString*)value
{
    [sharedGUJVCinstance_ addAdServerRequestParameter:name value:value];
}

- (void)addAdServerRequestParameters:(NSDictionary*)requestParameters
{
    [sharedGUJVCinstance_ addAdServerRequestParameters:requestParameters];    
}

- (void)freeInstance
{
    [sharedGUJVCinstance_ freeInstance];
    if( instance_ != nil ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:instance_];
        instance_ = nil;
    }
}
@end

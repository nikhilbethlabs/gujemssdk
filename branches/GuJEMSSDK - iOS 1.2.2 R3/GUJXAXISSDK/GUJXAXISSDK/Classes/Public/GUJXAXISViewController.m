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
#import "GUJXAXISViewController.h"
#import "ORMMAXAXISView.h"
#import "GUJAdConfiguration.h"

@implementation GUJXAXISViewController

static GUJXAXISViewController *instance_;
static NSString *xaxisPlacementId_;

#
#pragma mark private methods
#
- (void)__setXAXISPlacementId:(NSString*)placementId
{
    xaxisPlacementId_ = [NSString stringWithFormat:@"%@",placementId];
}

- (void)__freeInstanceWithDelay:(NSNumber*)delay
{
    if( delay != nil ) {
        [instance_ performSelector:@selector(freeInstance) withObject:nil afterDelay:[delay floatValue]];
    }
}

#
#pragma mark overridden methods
#
- (GUJAdView*)adViewForType:(GUJBannerType)type frame:(CGRect)frame
{
    // setup the XAXIS ORMMA View object
    ORMMAXAXISView *adView = [[ORMMAXAXISView alloc] initWithFrame:frame andDelegate:(id)instance_];
    if( xaxisPlacementId_ != nil ) {
        // set the placement Id
        [adView setXAXISPlacementId:xaxisPlacementId_];
    }
    return [super performSelector:@selector(populateAdView:) withObject:adView];
}

-(void)freeInstance
{
    [super freeInstance];    
    [NSObject cancelPreviousPerformRequestsWithTarget:instance_];            
    instance_ = nil;
    _logd_tm(self, @"freeInstance",nil);  
        [[super performSelector:@selector(__adView)] performSelector:@selector(free)];
    // Keep xaxisPlacementId_ alive.    
}

#
#pragma mark public methods
#
+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId
{
    instance_ = (GUJXAXISViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId delegate:nil];
    return instance_;
}

+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    instance_ = (GUJXAXISViewController*)[super instanceForAdspaceId:adSpaceId delegate:delegate];
    return instance_; 
}

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId
{
    instance_ = (GUJXAXISViewController*)[GUJmOceanViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:nil];
    return instance_;
}

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    instance_ = (GUJXAXISViewController*)[super instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:delegate];
    return instance_; 
}


@end

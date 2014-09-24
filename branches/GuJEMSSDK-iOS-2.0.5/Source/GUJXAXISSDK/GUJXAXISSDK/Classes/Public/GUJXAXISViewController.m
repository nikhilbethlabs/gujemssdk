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
#import "GUJAdViewController+PrivateImplementation.h"

@implementation GUJXAXISViewController

static NSString *xaxisPlacementId_;

#
#pragma mark private methods
#
- (void)__setXAXISPlacementId:(NSString*)placementId
{
    xaxisPlacementId_ = [NSString stringWithFormat:@"%@",placementId];
}

#
#pragma mark overridden methods
#
- (GUJAdView*)adViewForType:(GUJBannerType)type frame:(CGRect)frame
{
    GUJAdView *adView = nil;
    // setup the XAXIS ORMMA View object
    adView = (GUJAdView*)[[ORMMAXAXISView alloc] initWithFrame:frame];
    [((ORMMAXAXISView*)adView) setDelegate:self];
    // set the placement Id
    [((ORMMAXAXISView*)adView) setXAXISPlacementId:xaxisPlacementId_];    
    return [super populateAdView:(_GUJAdView*)adView];;
}

-(void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];    
    [super freeInstance];
    _logd_tm(self, @"freeInstance",nil);
    // Keep xaxisPlacementId_ alive.
}

#
#pragma mark public methods
#
+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId
{
    ORMMAViewController *result = (ORMMAViewController*)[GUJXAXISViewController instanceForAdspaceId:adSpaceId delegate:nil];
    return result;
}

+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    ORMMAViewController *result = (ORMMAViewController*)[super instanceForAdspaceId:adSpaceId delegate:delegate];
    return result;
}

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId
{
    GUJmOceanViewController *result = (GUJmOceanViewController*)[GUJmOceanViewController instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:nil];
    return result;
}

+ (GUJmOceanViewController*)instanceForAdspaceId:(NSString*)adSpaceId site:(NSInteger)siteId zone:(NSInteger)zoneId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    GUJmOceanViewController *result = (GUJmOceanViewController*)[super instanceForAdspaceId:adSpaceId site:siteId zone:zoneId delegate:delegate];
    return result;
}


@end

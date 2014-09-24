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
#import "_GUJAdView.h"
#import "GUJServerConnection.h"

@implementation _GUJAdView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame delegate:nil];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<GUJAdViewDelegate,GUJAdViewControllerDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setDelegate:delegate];
        [self setInitialAdViewOrigin:CGPointMake(0.0,frame.origin.y)];
    }
    
    return self;
}

- (NSString*)adSpaceId
{
    NSString *result = nil;
    if( [self adConfiguration] != nil ) {
        result = [[self adConfiguration] adSpaceId];
    }
    return result;
}

- (void)__loadAd
{
    [self __loadAd:nil];
}

- (void)__loadAd:(gujAdViewCompletionHandler)completion
{
    if( ![self adViewIsLoadingAdData] ) {
        [self setAdViewIsLoadingAdData:YES];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__loadAd) object:nil];
        
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(viewWillLoadAd:)] ) {
            [[self delegate] viewWillLoadAd:((GUJAdView*)self)];
        };
        
        __strong id _safeSelf = self;
        [GUJServerConnection adServerRequestWithConfiguration:[self adConfiguration] completion:^(GUJServerConnection *connection, NSError *error) {
            if( [connection error] != nil || error != nil ) {
                [_safeSelf performSelectorOnMainThread:@selector(__adDataFailedLoading) withObject:nil waitUntilDone:NO];
                if( [GUJUtil typeIsNotNil:[_safeSelf delegate] andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
                    
                    [[_safeSelf delegate] view:((GUJAdView*)_safeSelf) didFailToLoadAdWithUrl:[connection url] andError:[connection error]];
                    
                }           
                if( completion != nil ) {
                    completion(self,[connection error]);
                }
            } else {
                [_safeSelf setAdData:[connection adData]];
                [_safeSelf performSelectorOnMainThread:@selector(__adDataLoaded:) withObject:[_safeSelf adData] waitUntilDone:NO];
                if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial && [GUJUtil typeIsNotNil:[_safeSelf delegate] andRespondsToSelector:@selector(interstitialViewDidLoadAdData:)] ) {
                    [[_safeSelf delegate] interstitialViewDidLoadAdData:(GUJAdView *)_safeSelf];
                } else if( [GUJUtil typeIsNotNil:[_safeSelf delegate] andRespondsToSelector:@selector(view:didLoadAd:)] ) {
                    [[_safeSelf delegate] view:((GUJAdView*)_safeSelf) didLoadAd:[_safeSelf adData]];
                }
                if( completion != nil ) {
                    completion(self,nil);
                }
            }
            [_safeSelf setLastAdLoadedTime:[[NSDate date] timeIntervalSince1970]];
            [_safeSelf setAdViewIsLoadingAdData:NO];
        }];
    }
    
    if( ![[self adConfiguration] willShowAdModal] && [[self adConfiguration] reloadInterval] > 0.0 ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [[self adConfiguration] reloadInterval] * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self __reloadAd];
        });
    }
}

- (void)__reloadAd
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // perform a reload directly
    if( [self lastAdLoadedTime] > 0.0 ) {
        // !Important!
        // check if reload time is greater then default reload time
        // otherwise reload with default time
        double reloadOffset = 0.0;
        @autoreleasepool {
            reloadOffset = ([[NSDate date] timeIntervalSince1970] - [self lastAdLoadedTime] );
        }
        if( reloadOffset > [[self adConfiguration] reloadInterval] ) {
            [self performSelector:@selector(__loadAd) withObject:nil afterDelay:0.1];
        } else {
            [self performSelector:@selector(__loadAd) withObject:nil afterDelay:[[self adConfiguration] reloadInterval]];
        }
    }
}

#pragma mark protected methods
/*!
 * Override this method in extending Classes to perform various changes, parsing, etc.
 * with the ad data object.
 *
 * Also, this is a good place to initilaize or start native interfaces.
 *
 * allways call: [super __adDataLoaded:]
 */
- (void)__adDataLoaded:(GUJAdData*)adData
{
    [[self adConfiguration] setInterstitialConnectAd:[GUJUtil isInterstitialConnectAd:adData]];
    // Custom data handling
}

/*!
 * Override this method to free adData, release or hide the banner view,
 * and/ or release native interfaces in custom implementations.
 *
 * allways call: [super __adDataFailedLoading]
 */
- (void)__adDataFailedLoading
{
    // Custom data handling
}

/*!
 * Unloads the current adView without destroying it.
 * Means: Free adData, reset ServerConnection and maybe unload or stop native interfaces.
 */
- (void)__unload
{
    // Custom data handling
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setAdData:nil];
    _logd_tm(self, @"__unload",nil);
}

- (void)__free
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
    _logd_tm(self, @"__free",nil);
}

@end

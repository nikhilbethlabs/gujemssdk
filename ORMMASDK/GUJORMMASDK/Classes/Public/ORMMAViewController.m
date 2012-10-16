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
#import "ORMMAViewController.h"
#import "ORMMAView.h"
#import "GUJAdData.h"
#import "ORMMAResourceBundleManager.h"

@interface ORMMAViewController(PrivateImplementation)<GUJAdViewDelegate,GUJAdViewControllerDelegate>
- (ORMMAView*)__adViewInstance;
@end

@implementation ORMMAViewController

static ORMMAViewController *instance_;

+ (ORMMAViewController*)instance
{
    return instance_;   
}

- (ORMMAView*)__adViewInstance
{
    return (ORMMAView*)[instance_ performSelector:@selector(__adView)];
}

+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId
{
    return [ORMMAViewController instanceForAdspaceId:adSpaceId delegate:nil];
}

+ (ORMMAViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{
    if( instance_ != nil ) {
        [instance_ performSelectorOnMainThread:@selector(freeInstance) withObject:nil waitUntilDone:YES];
    }
    if( instance_ == nil ) {
        instance_ = [[super alloc] init];
        if( delegate != nil ) {
            instance_->delegate_ = delegate;
        }
        [[GUJAdConfiguration sharedInstance] setAdSpaceId:adSpaceId];
        //
        if( [GUJUtil iosVersion] < __IPHONE_5_0 ) {
            [instance_ performSelectorOnMainThread:@selector(instanciate) withObject:nil waitUntilDone:YES];
        } else {
            [instance_ performSelector:@selector(instanciate)]; 
        }
        [[GUJAdConfiguration sharedInstance] setAdSpaceId:adSpaceId];       
    }
    @synchronized(instance_) {           
        return instance_;
    }
}

// overrides super method
- (GUJAdView*)adViewForType:(GUJBannerType)type frame:(CGRect)frame
{   
    if( [self __adViewInstance] != nil ) {
        [[self __adViewInstance] removeFromSuperview];
    }
    // making the type global
    [[GUJAdConfiguration sharedInstance] setBannerType:type];
    
    if( [GUJUtil iosVersion] < __IPHONE_5_0 ) {
        [instance_ performSelectorOnMainThread:@selector(__setAdView:) withObject:[[ORMMAView alloc] initWithFrame:frame andDelegate:instance_] waitUntilDone:YES];
    } else {
        [instance_ performSelector:@selector(__setAdView:) withObject:[[ORMMAView alloc] initWithFrame:frame andDelegate:instance_]];  
    }
    if( [GUJUtil iosVersion] < __IPHONE_5_0 ) {
        [instance_ performSelectorOnMainThread:@selector(__loadAdBannerData) withObject:nil waitUntilDone:YES];
    } else {
        [instance_ performSelectorOnMainThread:@selector(__loadAdBannerData) withObject:nil waitUntilDone:NO];
    }
    
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(bannerViewDidLoad:)] ) {
        [delegate_ bannerViewDidLoad:[self __adViewInstance]];
    }    
    return [self __adViewInstance];
}

// overrides super method
-(void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:instance_];    
    [[ORMMAWebBrowser sharedInstance] freeInstance];
    [[ORMMAResourceBundleManager sharedInstance] freeInstance];
    [super freeInstance];
    instance_ = nil;
    _logd_tm(self, @"freeInstance",nil);        
}

#pragma mark GUJAdViewControllerDelegate 
- (void)interstitialViewDidFailLoadingWithError:(NSError *)error
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(interstitialViewDidFailLoadingWithError:)] ) {
        [delegate_ interstitialViewDidFailLoadingWithError:error];
    } 
}

- (void)interstitialViewWillAppear 
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(interstitialViewWillAppear)] ) {
        [delegate_ interstitialViewWillAppear];
    }
}

- (void)interstitialViewDidAppear
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(interstitialViewDidAppear)] ) {
        [delegate_ interstitialViewDidAppear];
    }  
}

- (void)interstitialViewWillDisappear
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(interstitialViewWillDisappear)] ) {
        [delegate_ interstitialViewWillDisappear];
    }   
}

- (void)interstitialViewDidDisappear
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(interstitialViewDidDisappear)] ) {
        [delegate_ interstitialViewDidDisappear];
    } 
}

- (void)bannerView:(GUJAdView *)bannerView didFialLoadingAdWithError:(NSError *)error
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(bannerView:didFialLoadingAdWithError:)] ) {
        [delegate_ bannerView:bannerView didFialLoadingAdWithError:error];
    } 
}

@end

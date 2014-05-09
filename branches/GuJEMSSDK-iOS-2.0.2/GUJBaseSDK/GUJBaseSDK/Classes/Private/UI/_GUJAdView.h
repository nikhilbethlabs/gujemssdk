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
#import "GUJAdConfiguration.h"
#import "GUJAdData.h"
#import "GUJAdViewControllerDelegate.h"

@class GUJAdView;// defined in GUJAdViewController.h

@protocol GUJAdViewDelegate<NSObject>

@optional
- (void)viewWillLoadAd:(GUJAdView*)adView;
- (void)view:(GUJAdView*)adView didLoadAd:(GUJAdData*)adData;
- (void)view:(GUJAdView*)adView didFailToLoadAdWithUrl:(NSURL*)adUrl andError:(NSError*)error;
@end

/*!
 * The _GUJAdView.
 * Private parent view of GUJAdView that is defined as simple UIView in GUJAdViewController.h
 */
@interface _GUJAdView : UIView

@property (nonatomic,strong) GUJAdConfiguration *adConfiguration;
@property (nonatomic,strong) id delegate; // <GUJAdViewDelegate,GUJAdViewControllerDelegate>
@property (nonatomic,strong) GUJAdData *adData;
@property (nonatomic,assign) NSTimeInterval lastAdLoadedTime;
@property (nonatomic,assign) BOOL adViewIsLoadingAdData;
@property (nonatomic,assign) CGPoint initialAdViewOrigin;


@property (nonatomic,strong) gujAdViewCompletionHandler adViewCompletionHandler;

#pragma mark private methods
- (id)initWithFrame:(CGRect)frame delegate:(id<GUJAdViewDelegate,GUJAdViewControllerDelegate>)delegate;

- (NSString*)adSpaceId;

- (void)__loadAd;
- (void)__loadAd:(gujAdViewCompletionHandler)completion;
- (void)__reloadAd;

#pragma mark protected methods
//override these methods in custom implementations
- (void)__adDataLoaded:(GUJAdData*)adData;
- (void)__adDataFailedLoading;
- (void)__unload;

- (void)__free;

@end



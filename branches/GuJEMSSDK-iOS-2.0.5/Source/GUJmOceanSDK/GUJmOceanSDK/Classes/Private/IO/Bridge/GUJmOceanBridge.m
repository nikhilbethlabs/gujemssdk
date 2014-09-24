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
#import "GUJmOceanBridge.h"

@interface GUJmOceanBridge(PrivateImplementation)
- (id)__classForMASTAdView;
- (BOOL)__mOceanLibraryLinked;
- (BOOL)__performSelectorOnMASTAdView:(SEL)selector object:(id)object,...;
- (BOOL)__invokeSelectorOnMASTAdView:(SEL)selector arg:(void*)arg,...;
- (NSUInteger)__MASTSiteId;
- (NSUInteger)__MASTZoneId;
- (BOOL)__createMASTAdView;
- (BOOL)__createMASTInterstitialAdView;
- (void)__setupMASTAdView;
- (void)__updateMASTAdView;
- (void)__showMASTAdView;
- (void)__openInternalWebbrowserWithUrl:(NSURL*)url;
@end

@implementation GUJmOceanBridge(PrivateImplementation)

- (id)__classForMASTAdView
{
    return NSClassFromString(kGUJ_MOCEAN_MAST_AD_VIEW_CLASS);
}

- (BOOL)__mOceanLibraryLinked
{
    return ([self __classForMASTAdView] != nil);
}

- (BOOL)__performSelectorOnMASTAdView:(SEL)selector object:(id)object,...
{
    BOOL result = [GUJUtil typeIsNotNil:[self mastAdView] andRespondsToSelector:selector];
    if( result ) {
        id firstObject  = nil;
        id secondObject = nil;
        
        va_list args;
        va_start(args, object);
        for (id arg = object; arg != nil; arg = va_arg(args, id))
        {
            if( firstObject == nil ) {
                firstObject = arg;
            } else if( secondObject == nil ) {
                secondObject = arg;
            } else {
                break;
            }
        }
        va_end(args);
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [[self mastAdView] performSelector:selector withObject:firstObject withObject:secondObject];
    }
    return result;
}

- (BOOL)__invokeSelectorOnMASTAdView:(SEL)selector arg:(void*)arg,...
{
    BOOL result = [GUJUtil typeIsNotNil:[self mastAdView] andRespondsToSelector:selector];
    if( result ) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[[self mastAdView] methodSignatureForSelector:selector]];
        [inv setSelector:selector];
        [inv setTarget:[self mastAdView]];
        
        va_list args;
        va_start(args, arg);
        int index = 2;
        for (void* ptr = arg; ptr != nil; ptr = va_arg(args, void*))
        {
            [inv setArgument:ptr atIndex:index];
            index++;
        }
        va_end(args);
        
        [inv performSelector:@selector(invoke)];
    }
    return result;
}

- (NSUInteger)__MASTSiteId
{
    NSUInteger result = -1;
    NSObject *_siteId = [[self adConfiguration] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID];
    if( [_siteId isKindOfClass:[NSNumber class]] ) {
        result = [((NSNumber*)_siteId) integerValue];
    }
    return result;
}

- (NSUInteger)__MASTZoneId
{
    NSUInteger result = -1;
    
    NSObject *_zoneId = [[self adConfiguration] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_ZONE_ID];
    if( [_zoneId isKindOfClass:[NSNumber class]] ) {
        result = [((NSNumber*)_zoneId) integerValue];
    }
    return result;
}

- (BOOL)__createMASTAdView
{
    BOOL result = NO;
    if( [self gujAdView] != nil ) {

        
        /*
         * removed in 2.0.5 (29.04.2014)
        float adHeight = 0.0;
        
        if( [GUJUtil iPadDevice] ) {
            adHeight = kGUJAdViewDimensionPlaceHolder_iPad.size.height;
        } else { // iPhone & iPad
            adHeight = kGUJAdViewDimensionPlaceHolder_iPhone.size.height;
        }*/
        
        CGRect frame = CGRectMake(0.0f,
                                  0.0f,
                                  [GUJUtil sizeOfFirstResponder].width,
                                  [GUJUtil sizeOfFirstResponder].height); // adHeight
        
        [self setMastAdView:[[[self __classForMASTAdView] alloc] initWithFrame:frame]];
        _logd_frame([self mastAdView], frame);
        [[self gujAdView] addSubview:[self mastAdView]];
        [[self gujAdView] setNeedsDisplay];
        [[self gujAdView] setNeedsLayout];
        result = YES;
    } else {
        if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
            NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_UNABLE_TO_ATTACH];
            [[self adViewDelegate] view:(GUJAdView*)[self mastAdViewRef] didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:[self mastAdView]] andError:error];
        }
        _logd_tm(self, @"__createMASTAdView",@"CanNotAttachMASTAdViewToSuperView",nil);
    }
    return result;
}

- (void)__createInterstitalMASTAdViewContainer
{
    // setup the interstital container view
    [self setMastAdViewInterstitialView:[[UIView alloc] initWithFrame:[GUJUtil frameOfFirstResponder]]];
    [[self mastAdViewInterstitialView] setBackgroundColor:[UIColor blackColor]];
    if( ![UIApplication sharedApplication].statusBarHidden ) {
        float statusBarHeight   = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGRect mavivFrame       = [self mastAdViewInterstitialView].frame;
        mavivFrame.origin.y     = statusBarHeight;
        mavivFrame.size.height  = (mavivFrame.size.height - statusBarHeight);
        [[self mastAdViewInterstitialView] setFrame:mavivFrame];
    }
}

- (BOOL)__createMASTInterstitialAdView
{
    BOOL result = NO;
    if( [GUJUtil firstResponder] != nil ) {
        if( [self gujAdView] != nil && [[self gujAdView] superview] != nil ) {
            [[self gujAdView] removeFromSuperview];
        }
        
        [self __createInterstitalMASTAdViewContainer];
        [self setMastAdView:[[[self __classForMASTAdView] alloc] initWithFrame:[GUJUtil frameOfFirstResponder]]];
        
        if( [GUJUtil typeIsNotNil:[self mastAdView] andRespondsToSelector:@selector(setBackgroundColor:)] ) {
            [[self mastAdView] setBackgroundColor:[UIColor blackColor]];
        }
        if( [GUJUtil typeIsNotNil:[self mastAdView] andRespondsToSelector:@selector(setAutoresizingMask:)] ) {
            [[self mastAdView] setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
             UIViewAutoresizingFlexibleBottomMargin |
             UIViewAutoresizingFlexibleWidth |
             UIViewAutoresizingFlexibleHeight];
        }
        
        NSTimeInterval autoCloseTime        = (NSTimeInterval)kORMMAInterstitialDefaultTimeout;
        NSTimeInterval showCloseButtonTime  = (NSTimeInterval)kORMMAInterstitialShowCloseButtonTime;
        
        [self __invokeSelectorOnMASTAdView:@selector(setAutocloseInterstitialTime:) arg:&autoCloseTime,nil];
        [self __invokeSelectorOnMASTAdView:@selector(setShowCloseButtonTime:) arg:&showCloseButtonTime,nil];
        
        [[self mastAdViewInterstitialView] addSubview:[self mastAdView]];
        
        result = YES;
    } else {
        if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
            NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_UNABLE_TO_ATTACH];
            [[self adViewDelegate] view:(GUJAdView*)[self mastAdViewRef] didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:[self mastAdView]] andError:error];
        }
        _logd_tm(self, @"__createMASTInterstitialAdView",@"CanNotAttachMASTAdViewToSuperView",nil);
    }
    return result;
}

- (void)__setupMASTAdView
{
    _logd_tm(self, @"__setupMASTAdView",nil);
    BOOL canLoadAd  = NO;
    if( [self mastAdView] != nil ) {
        [self __performSelectorOnMASTAdView:@selector(stopEverythingAndNotfiyDelegateOnCleanup) object:nil];
        [self __performSelectorOnMASTAdView:@selector(removeFromSuperview) object:nil];
        [self setMastAdView:nil];
    }
    
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
        canLoadAd = [self __createMASTInterstitialAdView];
    } else {
        canLoadAd = [self __createMASTAdView];
    }
    
    [self setMastAdViewRef:[[GUJMASTAdViewRef alloc] init]];
    [[self mastAdViewRef] setMastAdViewRef:[self mastAdView]];
    [[self mastAdViewRef]  setGujAdViewRef:[self gujAdView]];
    
    if( canLoadAd && [self mastAdView] != nil ) {
        
        // set site id
        NSInteger site = [self __MASTSiteId];
        [self __invokeSelectorOnMASTAdView:@selector(setSite:) arg:&site,nil];
        
        // set zone id
        NSInteger zone = [self __MASTZoneId];
        
        [self __invokeSelectorOnMASTAdView:@selector(setZone:) arg:&zone,nil];
        
        // set show previous ad on error
        BOOL showPreviousAdOnError = YES;
        [self __invokeSelectorOnMASTAdView:@selector(setShowPreviousAdOnError:) arg:&showPreviousAdOnError,nil];
        
        // set the delegate
        __strong GUJmOceanBridge *strongSelf = self;
        [self __performSelectorOnMASTAdView:@selector(setDelegate:) object:strongSelf,nil];
        
        // set the logmode
        int logMode = 2;//kGUJ_MOCEAN_LOG_MODE;
        [self __invokeSelectorOnMASTAdView:@selector(setLogMode:) arg:&logMode];
        
        // set reload time intervall
        NSTimeInterval reloadInterval = [[self adConfiguration] reloadInterval];
        [self __invokeSelectorOnMASTAdView:@selector(setUpdateTimeInterval:) arg:&reloadInterval];
        
        // perform the mast update
        [self performSelectorOnMainThread:@selector(__updateMASTAdView) withObject:nil waitUntilDone:NO];
    } else {
        if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:)] ) {
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_SETUP_FAILD];
                [[self adViewDelegate] interstitialView:(GUJAdView*)[self gujAdView] didFailLoadingAdWithError:error];
            }
        } else {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_SETUP_FAILD];
                [[self adViewDelegate] view:(GUJAdView*)[self mastAdViewRef] didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:[self mastAdView]] andError:error];
            }
        }
    }
}

- (void)__updateMASTAdView
{
    BOOL canUpdate = NO;
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial &&
       [GUJUtil typeIsNotNil:[self mastAdView] andRespondsToSelector:@selector(update)] ) {
        canUpdate = YES;
    } else {
        if( [self gujAdView] != nil && [GUJUtil typeIsNotNil:[self mastAdView] andRespondsToSelector:@selector(update)] ) {
            canUpdate = YES;
        }
    }
    if( canUpdate ) {
        [[self mastAdView] performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];
        _logd_tm(self, @"__updateMASTAdView",nil);
    }
}

- (void)__showMASTAdView
{
    _logd_tm(self, @"__showMASTAdView",nil);
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial && [self mastAdView] != nil ) {
        if( [[GUJUtil firstResponder] respondsToSelector:@selector(view)] &&  [[GUJUtil firstResponder] view] != nil && [[self mastAdView] isKindOfClass:[UIView class]] ) {
            
            [[[GUJUtil firstResponder] view] addSubview:[self mastAdViewInterstitialView]];
            [[[GUJUtil firstResponder] view] bringSubviewToFront:[self mastAdViewInterstitialView]];
            
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialViewDidAppear)] ) {
                [[self adViewDelegate] performSelector:@selector(interstitialViewDidAppear)];
            }
            
        } else {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:)] ) {
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_INVALID_UI_OBJECT];
                [[self adViewDelegate] interstitialView:(GUJAdView*)[self gujAdView] didFailLoadingAdWithError:error];
            }
        }
    } else {
        
        if( [self mastAdView] != nil && [[self mastAdView] isKindOfClass:[UIView class]] ) {
            [[self gujAdView] setFrame:[[self mastAdView] frame]];
            BOOL canDisplayAd = YES;
            if( [[self gujAdView] adViewCompletionHandler] != nil ) {
                canDisplayAd = [[self gujAdView] adViewCompletionHandler]([self gujAdView],nil);
            } else if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(adViewController:canDisplayAdView:)] ) {
                canDisplayAd = [[self adViewDelegate] adViewController:nil canDisplayAdView:(GUJAdView*)[self gujAdView]];
            }
            if( canDisplayAd && [[self gujAdView] respondsToSelector:@selector(show)] ) {
                [[self gujAdView] performSelector:@selector(show)];
            }
            
            
        } else {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_INVALID_UI_OBJECT];
                [[self adViewDelegate] view:(GUJAdView*)[self mastAdViewRef] didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:[self mastAdView]] andError:error];
            }
        }
    }
}

- (void)__releaseMASTAdView
{
    _logd_tm(self, @"__releaseMASTAdView",nil);
    if( [self mastAdView] ) {
        [[self mastAdView] setDelegate:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:[self mastAdView]];
        if( [GUJUtil typeIsNotNil:[self mastAdView] andRespondsToSelector:@selector(stopEverythingAndNotfiyDelegateOnCleanup)] ) {
            [[self mastAdView] performSelectorOnMainThread:@selector(stopEverythingAndNotfiyDelegateOnCleanup) withObject:nil waitUntilDone:YES];
        }
        if( [self mastAdView] != nil && [[self mastAdView] isKindOfClass:[UIView class]] ) {
            [NSObject cancelPreviousPerformRequestsWithTarget:[self mastAdView]];
            [[self mastAdView] removeFromSuperview];
        }
        if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
            [NSObject cancelPreviousPerformRequestsWithTarget:[self mastAdViewInterstitialView]];
            [[self mastAdViewInterstitialView] removeFromSuperview];
        }
        // [self mastAdView] = nil; <--- crashes the fw when reloading the ad
    }
}

- (void)__openInternalWebbrowserWithUrl:(NSURL*)url
{
    BOOL shouldPresent = YES;
    BOOL isInterstitial = ( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial && [self mastAdView] != nil );
    if( [self internalWebBrowser] != nil ) {
        if( [[self internalWebBrowser] presentingViewController] != nil ) {
            if( [[self internalWebBrowser] isVisible] ) {
                shouldPresent = NO;
                __weak GUJmOceanBridge *weakSelf = self;
                [[self internalWebBrowser] dismissViewControllerAnimated:YES completion:^{
                    [weakSelf setInternalWebBrowser:[[ORMMAWebBrowser alloc] init]];
                    [[weakSelf internalWebBrowser] navigateToURL:[NSURLRequest requestWithURL:url]];
                    [GUJUtil showPresentModalViewController:[weakSelf internalWebBrowser] completion:^{
                        if( isInterstitial ) {
                            [[weakSelf mastAdViewInterstitialView] setHidden:YES];
                            [weakSelf __releaseMASTAdView];
                        }
                    }];
                }];
            }
        }
    }
    
    if( shouldPresent ) {
        [self setInternalWebBrowser:[[ORMMAWebBrowser alloc] init]];
        [[self internalWebBrowser] navigateToURL:[NSURLRequest requestWithURL:url]];
        __weak GUJmOceanBridge *weakSelf = self;
        [GUJUtil showPresentModalViewController:[self internalWebBrowser] completion:^{
            if( isInterstitial ) {
                [[weakSelf mastAdViewInterstitialView] setHidden:YES];
                [weakSelf __releaseMASTAdView];
            }
        }];
    }
}

@end


@implementation GUJmOceanBridge

- (void)attachToAdView:(_GUJAdView*)adView
{
    if( [self gujAdView] != nil ) {
        [[self gujAdView] removeFromSuperview];
    }
    [self setGujAdView:adView];
    [self setAdViewDelegate:[adView delegate]];
}

- (BOOL)isConfiguredForMASTAdRequest
{
    BOOL result = ( ( [[self adConfiguration] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID] != nil ) &&
                   ( [[self adConfiguration] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID] != nil )
                   );
    return result;
}

- (void)freeInstance
{
    [self __releaseMASTAdView];
}

- (void)performMASTAdRequest
{
    if( [self __mOceanLibraryLinked] && [self isConfiguredForMASTAdRequest] && [self gujAdView] != nil ) {
        [self __setupMASTAdView];
    } else {
        _logd_tm(self, @"performMASTAdRequest",@"mOceanLibraryNotLinked",nil);
        if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:)] ) {
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_LIBRARY_NOT_LINKED];
                [[self adViewDelegate] interstitialView:(GUJAdView*)[self gujAdView] didFailLoadingAdWithError:error];
            }
        } else {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate]  andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_LIBRARY_NOT_LINKED];
                [[self adViewDelegate]  view:(GUJAdView*)[self mastAdViewRef] didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:[self mastAdView]] andError:error];
            }
        }
        
    }
}

#pragma mark mOcean MAST Ad delegate
- (void)willReceiveAd:(id)sender
{
    dispatch_async([GUJUtil currentDispatchQueue], ^{
        if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialViewWillAppear)] ) {
                [[self adViewDelegate] performSelector:@selector(interstitialViewWillAppear)];
            }
        }
    });
}

- (void)didReceiveAd:(id)sender
{
    dispatch_async([GUJUtil currentDispatchQueue], ^{
        if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(view:didLoadAd:)] ) {
            [[self adViewDelegate] view:(GUJAdView*)[self gujAdView] didLoadAd:[GUJAdData dataWithData:[GUJmOceanUtil serverResponseForMASTAdView:[self mastAdView]]]];
        }
    });
    dispatch_sync([GUJUtil currentDispatchQueue], ^{
        [self __showMASTAdView];
    });
}

- (void)didReceiveThirdPartyRequest:(id)sender content:(NSDictionary*)content;
{
    _logd_tm(self, @"didReceiveThirdPartyRequest:",sender,content,nil);
}

- (void)didFailToReceiveAd:(id)sender withError:(NSError*)error
{
    error = [NSError errorWithDomain:kGUJmOceanErrorDomain code:GUJ_ERROR_CODE_MOCEAN_AD_FAILD_LOADING userInfo:[error userInfo]];
    dispatch_sync([GUJUtil currentDispatchQueue], ^{
        _logd_tm(self, @"didFailToReceiveAd:withError:",sender,error,nil);
        if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:)] ) {
                [[self adViewDelegate] interstitialView:(GUJAdView*)[self gujAdView] didFailLoadingAdWithError:error];
            }
        } else {
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
                [[self adViewDelegate] view:(GUJAdView*)[self mastAdViewRef] didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:[self mastAdView]] andError:error];
            }
        }
    });
}

- (void)adWillStartFullScreen:(id)sender
{
    _logd_tm(self, @"adWillStartFullScreen:",sender,nil);
    dispatch_sync([GUJUtil currentDispatchQueue], ^{
        if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
            [[self adViewDelegate] performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:kGUJ_MOCEAN_AD_VIEW_EVENT_START_FULL_SCREEN]];
        }
    });
}

- (void)adDidEndFullScreen:(id)sender
{
    _logd_tm(self, @"adDidEndFullScreen:",sender,nil);
    dispatch_async([GUJUtil currentDispatchQueue], ^{
        if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
            [[self adViewDelegate] performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:kGUJ_MOCEAN_AD_VIEW_EVENT_END_FULL_SCREEN]];
        }
    });
}

- (BOOL)adShouldOpen:(id)sender withUrl:(NSURL*)url
{
    _logd_tm(self, @"adShouldOpen:",sender,url,nil);
    dispatch_async([GUJUtil currentDispatchQueue], ^{
        if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
            [[self adViewDelegate] performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kGUJ_MOCEAN_AD_VIEW_EVENT_SHOULD_OPEN_URL,url.description]]];
        }
    });
    
    if ([NSThread isMainThread]) {
        [self __openInternalWebbrowserWithUrl:[NSURL URLWithString:[url description]]];
    } else {
        [self performSelectorOnMainThread:@selector(__openInternalWebbrowserWithUrl:) withObject:[NSURL URLWithString:[url description]] waitUntilDone:NO];
    }
    return NO;
}

- (void)didClosedAd:(id)sender usageTimeInterval:(NSTimeInterval)usageTimeInterval
{
    _logd_tm(self, @"didClosedAd:",sender,nil);
    if( sender == [self mastAdView] ) {
        if( [self mastAdView] != nil && [[self mastAdView] isKindOfClass:[UIView class]] ) {
            [[self mastAdView] performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        }
    } else {
        if( [GUJUtil typeIsNotNil:sender andRespondsToSelector:@selector(removeFromSuperview)] ) {
            [sender performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        }
        if( [self mastAdView] != nil && [[self mastAdView] isKindOfClass:[UIView class]] ) {
            [[self mastAdView] performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        }
    }
    if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
        dispatch_async([GUJUtil currentDispatchQueue], ^{
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialViewDidDisappear)] ) {
                [[self adViewDelegate] performSelector:@selector(interstitialViewDidDisappear)];
            }
        });
        // remove the interstital view
        [[self mastAdViewInterstitialView] removeFromSuperview];
    } else {
        dispatch_async([GUJUtil currentDispatchQueue], ^{
            if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(bannerViewDidHide:)] ) {
                [[self adViewDelegate] performSelector:@selector(bannerViewDidHide:) withObject:[self mastAdViewRef]];
            }
        });
    }
}

- (void)ormmaProcess:(id)sender event:(NSString*)event parameters:(NSDictionary*)parameters
{
#ifdef kGUJEMS_Debug
    @autoreleasepool {
        NSMutableString* entry = [NSMutableString stringWithString:@""];
        [entry appendFormat:@"\nsender: %@", [sender description]];
        [entry appendFormat:@"\nevent: %@", event];
        [entry appendFormat:@"\nparameters: %@", [parameters description]];
        
        _logd_tm(self, @"ormmaProcess:event:parameters:",entry,nil);
        dispatch_async([GUJUtil currentDispatchQueue], ^{
            if( [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
                if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
                    [[self adViewDelegate] performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kGUJ_MOCEAN_AD_VIEW_EVENT_SHOULD_OPEN_URL,entry]]];
                }
            } else {
                if( [GUJUtil typeIsNotNil:[self adViewDelegate] andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {
                    [[self adViewDelegate] performSelector:@selector(bannerView:receivedEvent:) withObject:sender withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kGUJ_MOCEAN_AD_VIEW_EVENT_SHOULD_OPEN_URL,entry]]];
                }
            }
        });
    }
#endif
}


@end

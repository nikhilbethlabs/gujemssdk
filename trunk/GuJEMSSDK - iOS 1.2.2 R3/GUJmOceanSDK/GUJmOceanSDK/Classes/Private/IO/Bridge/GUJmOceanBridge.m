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
    BOOL result = [GUJUtil typeIsNotNil:mastAdView_ andRespondsToSelector:selector];
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
        [mastAdView_ performSelector:selector withObject:firstObject withObject:secondObject];
    } 
    return result;
}

- (BOOL)__invokeSelectorOnMASTAdView:(SEL)selector arg:(void*)arg,...
{
    BOOL result = [GUJUtil typeIsNotNil:mastAdView_ andRespondsToSelector:selector];
    if( result ) {        
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[mastAdView_ methodSignatureForSelector:selector]];
        [inv setSelector:selector];
        [inv setTarget:mastAdView_];
        
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
    NSObject *_siteId = [[GUJAdConfiguration sharedInstance] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID];
    if( [_siteId isKindOfClass:[NSNumber class]] ) {
        result = [((NSNumber*)_siteId) integerValue];
    }
    return result;
}

- (NSUInteger)__MASTZoneId
{
    NSUInteger result = -1;
    NSObject *_zoneId = [[GUJAdConfiguration sharedInstance] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_ZONE_ID];
    if( [_zoneId isKindOfClass:[NSNumber class]] ) {
        result = [((NSNumber*)_zoneId) integerValue];
    }
    return result;
}

- (BOOL)__createMASTAdView
{
    BOOL result = NO;
    if( [gujAdView_ superview] != nil ) {
        CGPoint *initialOrigin = (__bridge CGPoint*)[gujAdView_ performSelector:@selector(__initialOrigin)];
        float adHeight = 0.0;
        
        if( [GUJUtil iPadDevice] ) {
            adHeight = kGUJAdViewDimensionPlaceHolder_iPad.size.height;
        } else { // iPhone & iPad 
            adHeight = kGUJAdViewDimensionPlaceHolder_iPhone.size.height;
        }
        
        CGRect frame = CGRectMake(gujAdView_.frame.origin.x,
                                                (initialOrigin->y+[GUJUtil statusBarOffset]), 
                                                [GUJUtil sizeOfFirstResponder].width,
                                                adHeight);
        
        mastAdView_ = [[[self __classForMASTAdView] alloc] initWithFrame:frame];  
        _logd_frame(mastAdView_, frame);
        if( [GUJUtil parentViewController] != nil && [GUJUtil parentViewController].view != nil ) {
            [[GUJUtil parentViewController].view  addSubview:mastAdView_];
            [[GUJUtil parentViewController].view setNeedsLayout];
            [[GUJUtil parentViewController].view setNeedsDisplay];   
            result      = YES;
        }
    } else {
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {    
            NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_UNABLE_TO_ATTACH];
            [adViewDelegate_ view:mastAdViewRef_ didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:mastAdView_] andError:error];
        }
        _logd_tm(self, @"__createMASTAdView",@"CanNotAttachMASTAdViewToSuperView",nil);
    }    
    return result;
}

- (void)__createInterstitalMASTAdViewContainer
{  
    // setup the interstital container view
    mastAdViewInterstitialView_ = [[UIView alloc] initWithFrame:[GUJUtil frameOfFirstResponder]];
    [mastAdViewInterstitialView_ setBackgroundColor:[UIColor blackColor]];    
    if( ![UIApplication sharedApplication].statusBarHidden ) {
        float statusBarHeight   = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGRect mavivFrame       = mastAdViewInterstitialView_.frame;
        mavivFrame.origin.y     = statusBarHeight;
        mavivFrame.size.height  = (mavivFrame.size.height - statusBarHeight);
        [mastAdViewInterstitialView_ setFrame:mavivFrame];
    }
}

- (BOOL)__createMASTInterstitialAdView
{
    BOOL result = NO; 
    if( [GUJUtil firstResponder] != nil ) {        
        if( gujAdView_ != nil && [gujAdView_ superview] != nil ) {
            [gujAdView_ removeFromSuperview];
        }
        
        [self __createInterstitalMASTAdViewContainer];
        
        mastAdView_  =  [[[self __classForMASTAdView] alloc] initWithFrame:[GUJUtil frameOfFirstResponder]]; 

        if( [GUJUtil typeIsNotNil:mastAdView_ andRespondsToSelector:@selector(setBackgroundColor:)] ) {
            [mastAdView_ setBackgroundColor:[UIColor blackColor]];
        } 
        if( [GUJUtil typeIsNotNil:mastAdView_ andRespondsToSelector:@selector(setAutoresizingMask:)] ) {
            [mastAdView_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | 
             UIViewAutoresizingFlexibleBottomMargin | 
             UIViewAutoresizingFlexibleWidth | 
             UIViewAutoresizingFlexibleHeight];
        }
        
        NSTimeInterval autoCloseTime        = (NSTimeInterval)kORMMAInterstitialDefaultTimeout;
        NSTimeInterval showCloseButtonTime  = (NSTimeInterval)kORMMAInterstitialShowCloseButtonTime;
        
        [self __invokeSelectorOnMASTAdView:@selector(setAutocloseInterstitialTime:) arg:&autoCloseTime,nil];
        [self __invokeSelectorOnMASTAdView:@selector(setShowCloseButtonTime:) arg:&showCloseButtonTime,nil];                        
        
        [mastAdViewInterstitialView_ addSubview:mastAdView_];
        
        result = YES;
    } else {
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {    
            NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_UNABLE_TO_ATTACH];
            [adViewDelegate_ view:mastAdViewRef_ didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:mastAdView_] andError:error];
        }
        _logd_tm(self, @"__createMASTInterstitialAdView",@"CanNotAttachMASTAdViewToSuperView",nil);
    }      
    return result;
}

- (void)__setupMASTAdView
{
    _logd_tm(self, @"__setupMASTAdView",nil);
    BOOL canLoadAd  = NO;                
    if( mastAdView_ != nil ) {
        [self __performSelectorOnMASTAdView:@selector(stopEverythingAndNotfiyDelegateOnCleanup) object:nil];        
        [self __performSelectorOnMASTAdView:@selector(removeFromSuperview) object:nil];                
        mastAdView_ = nil;
    }    
    
    if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
        canLoadAd = [self __createMASTInterstitialAdView];
    } else {        
        canLoadAd = [self __createMASTAdView];        
    }    
    
    mastAdViewRef_  = [[GUJMASTAdViewRef alloc] init];    
    [mastAdViewRef_ setMastAdViewRef:mastAdView_];
    [mastAdViewRef_ setGujAdViewRef:gujAdView_];    
    
    if( canLoadAd && mastAdView_ != nil ) {            
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
        [self __performSelectorOnMASTAdView:@selector(setDelegate:) object:[GUJmOceanBridge sharedInstance],nil];
        
        // set the logmode
        int logMode = kGUJ_MOCEAN_LOG_MODE;
        [self __invokeSelectorOnMASTAdView:@selector(setLogMode:) arg:&logMode];                          
        
        // set reload time intervall
        NSTimeInterval reloadInterval = [[GUJAdConfiguration sharedInstance] reloadInterval];
        [self __invokeSelectorOnMASTAdView:@selector(setUpdateTimeInterval:) arg:&reloadInterval];
        
        // perform the mast update
        [self performSelectorOnMainThread:@selector(__updateMASTAdView) withObject:nil waitUntilDone:NO];
    } else {
        if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewDidFailLoadingWithError:)] ) {    
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_SETUP_FAILD];
                [adViewDelegate_ performSelector:@selector(interstitialViewDidFailLoadingWithError:) withObject:error];
            }
        } else {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {    
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_SETUP_FAILD];
                [adViewDelegate_ view:mastAdViewRef_ didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:mastAdView_] andError:error];
            }           
        }
    }
    
}

- (void)__updateMASTAdView
{    
    BOOL canUpdate = NO;
    if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial && 
       [GUJUtil typeIsNotNil:mastAdView_ andRespondsToSelector:@selector(update)] ) {
        canUpdate = YES;
    } else {
        if( [gujAdView_ superview] != nil && [GUJUtil typeIsNotNil:mastAdView_ andRespondsToSelector:@selector(update)] ) {           
            canUpdate = YES;
        }
    }
    if( canUpdate ) {
        [mastAdView_ performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];
        _logd_tm(self, @"__updateMASTAdView",nil);        
    }
    
}

- (void)__showMASTAdView
{    
    _logd_tm(self, @"__showMASTAdView",nil);    
    if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial && mastAdView_ != nil ) {
        if( [[GUJUtil firstResponder] respondsToSelector:@selector(view)] &&  [[GUJUtil firstResponder] view] != nil && [mastAdView_ isKindOfClass:[UIView class]] ) {
            
            [[[GUJUtil firstResponder] view] addSubview:mastAdViewInterstitialView_];
            [[[GUJUtil firstResponder] view] bringSubviewToFront:mastAdViewInterstitialView_];
            
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewDidAppear)] ) {  
                [adViewDelegate_ performSelector:@selector(interstitialViewDidAppear)];
            }            
        } else {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewDidFailLoadingWithError:)] ) {    
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_INVALID_UI_OBJECT];
                [adViewDelegate_ performSelector:@selector(interstitialViewDidFailLoadingWithError:) withObject:error];
            }
        }
    } else {        
        if( mastAdView_ != nil && [mastAdView_ isKindOfClass:[UIView class]] ) {   
            if( [gujAdView_ superview] != nil ) {
                [gujAdView_ removeFromSuperview];
            }
            [[GUJUtil parentViewController].view bringSubviewToFront:mastAdView_];
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(bannerViewDidShow:)] ) {       
                [adViewDelegate_ performSelector:@selector(bannerViewDidShow:) withObject:mastAdViewRef_];
            }               
        } else {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {    
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_INVALID_UI_OBJECT];
                [adViewDelegate_ view:mastAdViewRef_ didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:mastAdView_] andError:error];
            }
        }
    }
}

- (void)__releaseMASTAdView
{
    _logd_tm(self, @"__releaseMASTAdView",nil);        
    if( mastAdView_ ) {
        [mastAdView_ setDelegate:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:mastAdView_];        
        if( [GUJUtil typeIsNotNil:mastAdView_ andRespondsToSelector:@selector(stopEverythingAndNotfiyDelegateOnCleanup)] ) {
            [mastAdView_ performSelectorOnMainThread:@selector(stopEverythingAndNotfiyDelegateOnCleanup) withObject:nil waitUntilDone:YES];
        }
        if( mastAdView_ != nil && [mastAdView_ isKindOfClass:[UIView class]] ) {  
            [mastAdView_ removeFromSuperview];
        }
        if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
            [mastAdViewInterstitialView_ removeFromSuperview];
        }
        // mastAdView_ = nil; <--- crashes the fw when reloading the ad
    } 
}


- (void)__openInternalWebbrowserWithUrl:(NSURL*)url
{
    [[ORMMAWebBrowser sharedInstance] performSelectorOnMainThread:@selector(navigateToURL:) withObject:[NSURLRequest requestWithURL:url] waitUntilDone:NO];
    [GUJUtil showPresentModalViewController:[ORMMAWebBrowser sharedInstance]]; 
}

@end


@implementation GUJmOceanBridge

static GUJmOceanBridge* sharedInstance_;

+ (GUJmOceanBridge*)sharedInstance
{
    return sharedInstance_;
}

+ (GUJmOceanBridge*)instanceWithGUJAdView:(GUJAdView*)adView
{ 
    if( sharedInstance_ != nil ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    }    
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[super alloc] init];
        sharedInstance_->gujAdView_ = adView;
    } else {
        if( sharedInstance_->gujAdView_ != nil ) {
            [sharedInstance_->gujAdView_ removeFromSuperview];
        }
        sharedInstance_->gujAdView_ = adView;
    }
    if( sharedInstance_->gujAdView_ != nil && [sharedInstance_->gujAdView_ __adViewDelegate] != nil ) {
        sharedInstance_->adViewDelegate_ = [sharedInstance_->gujAdView_ __adViewDelegate];
    }
    return sharedInstance_;  
}

+ (BOOL)isConfiguredForMASTAdRequest
{
    BOOL result = ( ( [[GUJAdConfiguration sharedInstance] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID] != nil ) &&
                   ( [[GUJAdConfiguration sharedInstance] getCustomConfigurationForKey:kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID] != nil ) 
                   );
    result = result && ( [GUJUtil iosVersion] >= __IPHONE_4_0 );
    return result;   
}

- (void)freeInstance
{
    [self __releaseMASTAdView];
    if( gujAdView_ ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:gujAdView_];
    }
    if( sharedInstance_ ) { 
        [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];                
        sharedInstance_ = nil;  
    }
}

- (void)performMASTAdRequest
{
    if( [self __mOceanLibraryLinked] && [GUJmOceanBridge isConfiguredForMASTAdRequest] && gujAdView_ != nil ) {
        [self performSelectorOnMainThread:@selector(__setupMASTAdView) withObject:nil waitUntilDone:YES];
    } else {
        _logd_tm(self, @"performMASTAdRequest",@"mOceanLibraryNotLinked",nil);
        if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewDidFailLoadingWithError:)] ) {    
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_LIBRARY_NOT_LINKED];
                [adViewDelegate_ performSelector:@selector(interstitialViewDidFailLoadingWithError:) withObject:error];
            }
        } else {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {    
                NSError *error = [GUJUtil errorForDomain:kGUJmOceanErrorDomain andCode:GUJ_MOCEAN_MAST_ERROR_CODE_LIBRARY_NOT_LINKED];
                [adViewDelegate_ view:mastAdViewRef_ didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:mastAdView_] andError:error];
            }           
        }
        
    }
}

#pragma mark mOcean MAST Ad delegate
- (void)willReceiveAd:(id)sender
{
    if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewWillAppear)] ) {  
            [adViewDelegate_ performSelector:@selector(interstitialViewWillAppear)];
        }
    } else {    
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(viewWillLoadAd:)] ) {
            [adViewDelegate_ viewWillLoadAd:mastAdViewRef_];
        }
    }
}

- (void)didReceiveAd:(id)sender
{    
    if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didLoadAd:)] ) {       
            [adViewDelegate_ view:mastAdViewRef_ didLoadAd:[GUJAdData dataWithData:[GUJmOceanUtil serverResponseForMASTAdView:mastAdView_]]];
        } 
    } else {
//#ifdef kGUJEMS_Debug        
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didLoadAd:)] ) {       
            [adViewDelegate_ view:mastAdViewRef_ didLoadAd:[GUJAdData dataWithData:[GUJmOceanUtil serverResponseForMASTAdView:mastAdView_]]];
        }   
//#endif        
    }
    [[GUJmOceanBridge sharedInstance] performSelectorOnMainThread:@selector(__showMASTAdView) withObject:nil waitUntilDone:YES];
}

- (void)didReceiveThirdPartyRequest:(id)sender content:(NSDictionary*)content;
{
    _logd_tm(self, @"didReceiveThirdPartyRequest:",sender,content,nil); 
}

- (void)didFailToReceiveAd:(id)sender withError:(NSError*)error
{
    _logd_tm(self, @"adWillStartFullScreen:",sender,error,nil);    
    if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewDidFailLoadingWithError:)] ) {  
            [adViewDelegate_ performSelector:@selector(interstitialViewDidFailLoadingWithError:) withObject:error];
        }
    } else {
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {      
            [adViewDelegate_ view:mastAdViewRef_ didFailToLoadAdWithUrl:[GUJmOceanUtil urlForMASTAdView:mastAdView_] andError:error];
        }
    }
}

- (void)adWillStartFullScreen:(id)sender
{
    _logd_tm(self, @"adWillStartFullScreen:",sender,nil);
    if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {      
        [adViewDelegate_ performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:kGUJ_MOCEAN_AD_VIEW_EVENT_START_FULL_SCREEN]];
    }    
}

- (void)adDidEndFullScreen:(id)sender
{
    _logd_tm(self, @"adDidEndFullScreen:",sender,nil);
    if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {      
        [adViewDelegate_ performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:kGUJ_MOCEAN_AD_VIEW_EVENT_END_FULL_SCREEN]];
    }      
}

- (BOOL)adShouldOpen:(id)sender withUrl:(NSURL*)url
{
    _logd_tm(self, @"adShouldOpen:",sender,url,nil);
    if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {      
        [adViewDelegate_ performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kGUJ_MOCEAN_AD_VIEW_EVENT_SHOULD_OPEN_URL,url.description]]];
    }          
    [sharedInstance_ performSelectorOnMainThread:@selector(__openInternalWebbrowserWithUrl:) withObject:[NSURL URLWithString:[url description]] waitUntilDone:NO];
    return NO;
}

- (void)didClosedAd:(id)sender usageTimeInterval:(NSTimeInterval)usageTimeInterval
{
    _logd_tm(self, @"didClosedAd:",sender,nil);  
    if( sender == mastAdView_ ) {
        if( mastAdView_ != nil && [mastAdView_ isKindOfClass:[UIView class]] ) {  
            [mastAdView_ performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        }
    } else {
        if( [GUJUtil typeIsNotNil:sender andRespondsToSelector:@selector(removeFromSuperview)] ) {
            [sender performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        }
        if( mastAdView_ != nil && [mastAdView_ isKindOfClass:[UIView class]] ) {  
            [mastAdView_ performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];            
        }
    }
    if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewDidDisappear)] ) {  
            [adViewDelegate_ performSelector:@selector(interstitialViewDidDisappear)];
        }        
        // remove the interstital view
        [mastAdViewInterstitialView_ removeFromSuperview];
    } else {   
        if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(bannerViewDidHide:)] ) {       
            [adViewDelegate_ performSelector:@selector(bannerViewDidHide:) withObject:mastAdViewRef_];
        }   
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
        if( [[GUJAdConfiguration sharedInstance] requestedBannerType] == GUJBannerTypeInterstitial ) {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {      
                [adViewDelegate_ performSelector:@selector(interstitialViewReceivedEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kGUJ_MOCEAN_AD_VIEW_EVENT_SHOULD_OPEN_URL,entry]]];
            }        
        } else {
            if( [GUJUtil typeIsNotNil:adViewDelegate_ andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {      
                [adViewDelegate_ performSelector:@selector(bannerView:receivedEvent:) withObject:sender withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kGUJ_MOCEAN_AD_VIEW_EVENT_SHOULD_OPEN_URL,entry]]];
            }       
        }
    } 
#endif    
}


@end

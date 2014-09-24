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
#import "ORMMAXAXISView.h"
#import "GUJXAXISViewController.h"
#import <objc/runtime.h>

@interface ORMMAXAXISView(PrivateImplementation)
- (id)__XAXISVideoSDK;
- (BOOL)__XAXISCanRegisterWithPublisherId;
- (BOOL)__XAXISCanPlayAdvertising ;
- (BOOL)__XAXISCanPrefetchAdvertising;
- (void)__reportEvent:(GUJAdViewEvent*)event;
- (void)__preSaveReportEvent:(NSString*)event;
- (void)__initXAXISVideoAd;
- (void)__playXAXISVideoAd;
- (void)__prefetchXAXISVideoAd;
- (void)__initXAXISVideoAdPlayback;
- (BOOL)__parseSmartStreamObject:(NSString*)utf8Data;
- (BOOL)__isSmartStreamObject:(GUJAdData*)adData;
- (BOOL)__shouldLoadXAXISVideoAd:(GUJAdData*)adData;
@end


@implementation ORMMAXAXISView(PrivateImplementation)

// override super method
- (void)__unload
{
    if( [GUJUtil typeIsNotNil:xaxisClass_ andRespondsToSelector:@selector(_exitAdvertising)] ) {
        [xaxisClass_ performSelector:@selector(_exitAdvertising)];
    }
    xaxisClass_ = nil;
    [super __unload];
}

// override super method
- (void)__free
{
    [self __unload];
    [super __free];
}

- (id)__XAXISVideoSDK
{
    if( xaxisClass_ == nil ) {
        @autoreleasepool {
            xaxisClass_ = NSClassFromString(kXAXISVideoAdSDKClass);
        }
    }
    @synchronized(xaxisClass_) {
        return xaxisClass_;
    }
}

- (BOOL)__XAXISCanRegisterWithPublisherId
{
    [self __XAXISVideoSDK];
    return ( (xaxisClass_ != nil) && [xaxisClass_ respondsToSelector:@selector(registerWithPublisherID:delegate:)]);
}

- (BOOL)__XAXISCanPlayAdvertising
{
    [self __XAXISVideoSDK];
    return ( (xaxisClass_ != nil) && [xaxisClass_ respondsToSelector:@selector(playAdvertising)]);
}

- (BOOL)__XAXISCanPrefetchAdvertising
{
    [self __XAXISVideoSDK];
    return ( (xaxisClass_ != nil) && [xaxisClass_ respondsToSelector:@selector(prefetchAdvertising)]);
}

- (void)__reportEvent:(GUJAdViewEvent*)event
{
    if( xaxisPlacementId_ != nil && event != nil && event.message != nil ) {
        if( [self trackingServerConnection] != nil ) {
            [NSObject cancelPreviousPerformRequestsWithTarget:[self trackingServerConnection]];
            [self setTrackingServerConnection:nil];
        }
        [self setTrackingServerConnection:[[GUJXAXSISTrackingServerConnection alloc] init]];
        dispatch_async([GUJUtil currentDispatchQueue], ^{
            [[self trackingServerConnection] sendAdServerRequestWithReportingAdSpaceId:event.message placementId:xaxisPlacementId_];
        });
    }
}

- (void)__preSaveReportEvent:(NSString*)event
{
    [self performSelectorOnMainThread:@selector(__reportEvent:) withObject:[GUJAdViewEvent eventForType:GUJAdViewEventTypeTracking message:event] waitUntilDone:YES];
}

- (void)__initXAXISVideoAd
{
    if( [self __XAXISCanRegisterWithPublisherId] ) {
        id _self = self;
        @autoreleasepool {
            SEL constructor = @selector(registerWithPublisherID:delegate:);
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[xaxisClass_ methodSignatureForSelector:constructor]];
            [inv setSelector:constructor];
            [inv setTarget:xaxisClass_];
            [inv setArgument:&xaxisPlacementId_ atIndex:2];
            [inv setArgument:&_self atIndex:3];
            [inv performSelector:@selector(invoke)];
        }
        _logd_tm(self, @"XAXISVideoSDK registerWithPublisherID:",xaxisPlacementId_,nil);
    }
}

- (void)__playXAXISVideoAd
{
    if( [self __XAXISCanPlayAdvertising] ) {
        [xaxisClass_ performSelectorOnMainThread:@selector(playAdvertising) withObject:nil waitUntilDone:NO];
        _logd_tm(self, @"XAXISVideoSDK playAdvertising",nil);
    }
}

- (void)__prefetchXAXISVideoAd
{
    if( [self __XAXISCanPlayAdvertising] ) {
        [xaxisClass_ performSelectorOnMainThread:@selector(prefetchAdvertising) withObject:nil waitUntilDone:NO];
        _logd_tm(self, @"XAXISVideoSDK __prefetchXAXISVideoAd",nil);
    }
}

- (void)__initXAXISVideoAdPlayback
{
    if( [[GUJUtil networkInterfaceName] isEqualToString:kNetworkInterfaceIdentifierForTypeEn0] ) {
        [self performSelectorOnMainThread:@selector(__playXAXISVideoAd) withObject:nil waitUntilDone:NO];
    } else {
#ifdef kXAXSIS_SHOULD_PREFETCH_CONTENT
        [self performSelectorOnMainThread:@selector(__prefetchXAXISVideoAd) withObject:nil waitUntilDone:NO];
#else
        [self performSelectorOnMainThread:@selector(__playXAXISVideoAd) withObject:nil waitUntilDone:NO];
#endif
    }
}

- (BOOL)__parseSmartStreamObject:(NSString*)utf8Data
{
    BOOL result = NO;
    int index = [utf8Data rangeOfString:kXAXISSmartStreamTagOpen].location+[kXAXISSmartStreamTagOpen length];
    
    if( (index != NSNotFound) && ([utf8Data length] > index) ) {
        
        NSString *placementId = [utf8Data substringFromIndex:index];
        index = [placementId rangeOfString:kXAXISSmartStreamTagClose].location;
        
        if( (index != NSNotFound) && ([placementId length] > index) ) {
            placementId = [placementId substringToIndex:index];
            
            if( (placementId != nil) &&
               ![placementId isEqualToString:kEmptyString] &&
               (xaxisPlacementId_ == nil) &&
               !initialPlacementId_ ) {
                @autoreleasepool {
                    placementId         = [placementId stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    xaxisPlacementId_   = [NSString stringWithFormat:@"%@",placementId];
                }
                initialPlacementId_ = YES;
                
                // important! setting the placement Id as static string at the delegate
                if( [[self delegate] respondsToSelector:@selector(__setXAXISPlacementId:)] ) {
                    [[self delegate] performSelector:@selector(__setXAXISPlacementId:) withObject:xaxisPlacementId_];
                }
                
                result = YES;
            }
        }
    }
    return result;
}

- (BOOL)__isSmartStreamObject:(GUJAdData*)adData
{
    BOOL result = NO;
    
    if( adData == nil ) {
        return result;
    }
    
    NSString *utf8Data = [adData asNSUTF8StringRepresentation];
    if( utf8Data != nil ) {
        if( ([utf8Data rangeOfString:kXAXISSmartStreamTagOpen].location != NSNotFound) &&
           ([utf8Data rangeOfString:kXAXISSmartStreamTagClose].location != NSNotFound) ) {
            // is video Ad
            result = YES;
            // test for initial placement id
            if( (xaxisPlacementId_ == nil) && ![xaxisPlacementId_ isEqualToString:kEmptyString] && !initialPlacementId_ ) {
                // parse SmartStreamObject
                result = [self __parseSmartStreamObject:utf8Data];
            }
        }
    }
    
    isXAXISVideoAd_ = result;
    _logd_tm(self,[NSString stringWithFormat:@"__isSmartStreamObject: %i",result],nil);
    return result;
}

- (BOOL)__shouldLoadXAXISVideoAd:(GUJAdData*)adData
{
    BOOL result = NO;
    result = (  ([[self adConfiguration] bannerType] == GUJBannerTypeRichMedia) ||
              ([[self adConfiguration] bannerType] == GUJBannerTypeInterstitial)
              );
    result = ( result && ([self __XAXISVideoSDK] != nil) );
    result = ( result && [self __isSmartStreamObject:adData] );
    result = ( result && (xaxisPlacementId_ != nil) );
    result = ( result && ![xaxisPlacementId_ isEqualToString:kEmptyString] );
    return result;
}

@end


@implementation ORMMAXAXISView

- (void)__adDataLoaded:(GUJAdData*)adData
{
    if( [self __shouldLoadXAXISVideoAd:adData] && (adData != nil  && [adData bytes] != nil) ) {
        // cause we do not call the super method we have to set the ConnectAd info manually
        [[self adConfiguration] setInterstitialConnectAd:[GUJUtil isInterstitialConnectAd:adData]];
        _logd_tm(self, @"isXAXISVideoAdWithPlacementId:",xaxisPlacementId_,nil);
        if( initialPlacementId_ ) {
            _logd_tm(self, @"isXAXISVideoAdWithPlacementId:initial",nil);
            [self performSelectorOnMainThread:@selector(__initXAXISVideoAd) withObject:nil waitUntilDone:YES];
        }
        [self performSelector:@selector(__initXAXISVideoAdPlayback) withObject:nil afterDelay:0.5];
    } else {
        [super __adDataLoaded:adData];
    }
}

- (BOOL)isXAXISVideoAd
{
    return isXAXISVideoAd_;
}

- (NSString*)getXAXISPlacementId
{
    return xaxisPlacementId_;
}

- (void)setXAXISPlacementId:(NSString*)placementId
{
    xaxisPlacementId_ = placementId;
}

#pragma mark XAXIS VideoAdSDK delegate
- (void)advertisingWillShow
{
    
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewDidAppear)] ) {
        [[self delegate] interstitialViewDidAppear];
    }
}

- (void)advertisingDidHide
{
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewDidDisappear)] ) {
        [[self delegate] interstitialViewDidDisappear];
    }
    if( [self respondsToSelector:@selector(__free)] ) {
        [self performSelectorOnMainThread:@selector(__free) withObject:nil waitUntilDone:NO];
    }
}

- (void)advertisingClicked
{
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
        [[self delegate] interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kXAXIS_EVENT_IDENTIFIER,kXAXIS_EVENT_CLICKED]]];
    }
}

- (void)advertisingPrefetchingDidComplete
{
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
        [[self delegate] interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kXAXIS_EVENT_IDENTIFIER,kXAXIS_EVENT_PREFETCHING_DID_COMPLETE]]];
    }
    [self performSelectorOnMainThread:@selector(__playXAXISVideoAd) withObject:nil waitUntilDone:NO];
}

- (void)advertisingNotAvailable
{
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        NSError *error = [NSError errorWithDomain:kORMMAXAXISVideoAdErrorDomain
                                             code:kXAXIS_ERROR_CODE_AD_UNAVAILABLE
                                         userInfo:nil];
        [[super delegate] interstitialView:(GUJAdView*)self didFailLoadingAdWithError:error];
    }
    if( [self respondsToSelector:@selector(__free)] ) {
        [self performSelectorOnMainThread:@selector(__free) withObject:nil waitUntilDone:NO];
    }
}

- (void)advertisingFailedToLoad:(NSError *)error
{
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialView:didFailLoadingAdWithError:) andProtocol:@protocol(GUJAdViewControllerDelegate)] ) {
        error = [NSError errorWithDomain:kORMMAXAXISVideoAdErrorDomain
                                    code:kXAXIS_ERROR_CODE_AD_FAILED_LOADING
                                userInfo:[error userInfo]];
        [[super delegate] interstitialView:(GUJAdView*)self didFailLoadingAdWithError:error];
    }
    [self performSelector:@selector(__preSaveReportEvent:) withObject:kXAXIS_REPORTING_PLACEMENT_ID_IP_FAILED afterDelay:kXAXIS_REPORTING_DELAY];
    if( [self respondsToSelector:@selector(__free)] ) {
        [self performSelectorOnMainThread:@selector(__free) withObject:nil waitUntilDone:NO];
    }
}

- (void)advertisingEventTracked:(NSString*)event
{
    _logd_tm(self, @"advertisingEventTracked:forPlacementId:",event,xaxisPlacementId_,nil);
    
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
        [[self delegate] interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeExternalFramework message:[NSString stringWithFormat:kXAXIS_EVENT_IDENTIFIER,event]]];
    }
    
    if( [event isEqualToString:kXAXIS_EVENT_PREFETCH] ) {
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(interstitialViewWillAppear)] ) {
            [[self delegate] interstitialViewWillAppear];
        }
    }
    
    @autoreleasepool {
        
        NSString *eventReportAdSpaceId = nil;
        if( [event isEqualToString:kXAXIS_EVENT_START] ) {
            eventReportAdSpaceId = kXAXIS_REPORTING_PLACEMENT_ID_IP_STARTED;
        }
        if( [event isEqualToString:kXAXIS_EVENT_IMPRESSION] ) {
            eventReportAdSpaceId = kXAXIS_REPORTING_PLACEMENT_ID_IP_IMPRESSION;
        }
        if( [event isEqualToString:kXAXIS_EVENT_FIRST_QUARTILE] ) {
            eventReportAdSpaceId = kXAXIS_REPORTING_PLACEMENT_ID_IP_FIRST_QUARTILE;
        }
        if( [event isEqualToString:kXAXIS_EVENT_MIDPOINT] ) {
            eventReportAdSpaceId = kXAXIS_REPORTING_PLACEMENT_ID_IP_MIDPOINT;
        }
        if( [event isEqualToString:kXAXIS_EVENT_THIRD_QUARTILE] ) {
            eventReportAdSpaceId = kXAXIS_REPORTING_PLACEMENT_ID_IP_THIRD_QUARTILE;
        }
        if( [event isEqualToString:kXAXIS_EVENT_COMPLETE] ) {
            eventReportAdSpaceId = kXAXIS_REPORTING_PLACEMENT_ID_IP_FINISHED;
        }
        if( eventReportAdSpaceId != nil ) {
            // forward the tracking event.
            [self performSelector:@selector(__preSaveReportEvent:) withObject:eventReportAdSpaceId afterDelay:kXAXIS_REPORTING_DELAY];
        }
        
    }
}


@end

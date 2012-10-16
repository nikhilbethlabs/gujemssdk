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
#import "GUJAdView.h"
#import "GUJServerConnection.h"

@implementation GUJAdView (Private) 
// private
id<GUJAdViewDelegate>   delegate_;
GUJAdData               *adData_;
BOOL                    adIsLoading_;

- (id)initWithFrame:(CGRect)frame andDelegate:(id<GUJAdViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        delegate_ = delegate;       
    }
    return self;
}

- (id<GUJAdViewDelegate>)__getDelegate
{
    return delegate_;
}

- (void)__performOptimizedAdServerRequest
{
    @autoreleasepool {                        
        [[GUJServerConnection instance] sendAdServerRequest];
        if( [[GUJServerConnection instance] error] != nil ) {
            if( [GUJUtil iosVersion] > __IPHONE_4_0 ) {        
                [self performSelectorOnMainThread:@selector(__adDataFaildLoading) withObject:nil waitUntilDone:NO];
            } else {
                [self __adDataFaildLoading];  
            }
            if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
                [delegate_ view:self didFailToLoadAdWithUrl:[[GUJServerConnection instance] url] andError:[[GUJServerConnection instance] error]];
            }        
        } else {
            adData_ = [[GUJServerConnection instance] adData];            
            if( [GUJUtil iosVersion] > __IPHONE_4_0 ) {      
                [self performSelectorOnMainThread:@selector(__adDataLoaded:) withObject:adData_ waitUntilDone:NO];
            } else {
                [self __adDataLoaded:adData_];  
            }
            if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(view:didLoadAd:)] ) {                
                [delegate_ view:self didLoadAd:adData_];                
            }     
        }
        adIsLoading_ = NO;
    }    
}

- (void)__performAdServerRequest
{
    if( [GUJUtil iosVersion] > __IPHONE_4_0 ) {       
        [self performSelectorInBackground:@selector(__performOptimizedAdServerRequest) withObject:nil];
    } else {
        [self __performOptimizedAdServerRequest];
    }
}

- (void)__loadAd
{
    if( !adIsLoading_ ) {
        adIsLoading_ = YES;
        
        if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(viewWillLoadAd:)] ) {
            [delegate_ viewWillLoadAd:self];
        }
        if( [GUJUtil iosVersion] < __IPHONE_4_0 ) {
            [self performSelectorOnMainThread:@selector(__performAdServerRequest) withObject:nil waitUntilDone:YES];
        } else {            
            [self performSelectorOnMainThread:@selector(__performAdServerRequest) withObject:nil waitUntilDone:NO];
        }
        if( [[GUJAdConfiguration sharedInstance] reloadInterval] > 0.0 ) {
            [self performSelector:@selector(__loadAd) withObject:nil afterDelay:[[GUJAdConfiguration sharedInstance] reloadInterval]];
        }
    }
}

- (void)__loadAdNotifcation:(NSNotification*)notification
{
    /*
     * You may can analyze the incomming notification if needed.
     */    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__loadAd) object:nil];
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:self name:notification.name];
    [self __loadAd];
}

#pragma mark protected methods
/*!
 * Override this method in extending Classes to perform various changes, parsing, etc. 
 * with the ad data object.
 *
 * Also, this is a good place to initilaize or start native interfaces.
 */
- (void)__adDataLoaded:(GUJAdData*)adData
{
#pragma unused(adData)
    // Custom data handling
}

/*! 
 * Override this method to free adData, release or hide the banner view,
 * and/ or release native interfaces in custom implementations.
 */
- (void)__adDataFaildLoading
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
    // Serverconnection uses strong properties, so only ios 4.2 can release it
    if( [GUJUtil iosVersion] > __IPHONE_4_1 ) {
        [[GUJServerConnection instance] releaseInstance];
    }
    adData_ = nil;
    _logd_tm(self, @"__unload",nil);
}

- (void)__free
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
    _logd_tm(self, @"__free",nil);    
}

@end

@implementation GUJAdView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andDelegate:nil];
}


@end

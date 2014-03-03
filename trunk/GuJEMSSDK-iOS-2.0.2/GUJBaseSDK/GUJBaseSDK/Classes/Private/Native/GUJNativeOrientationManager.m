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
#import "GUJNativeOrientationManager.h"

@implementation GUJNativeOrientationManager

static GUJNativeOrientationManager *sharedInstance_;

#pragma mark private methods
- (void)__startOrientationObserver
{
    [self setDeviceOrientation:[UIDevice currentDevice].orientation];
    // enable notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // register for local notification
    [GUJNotificationObserver addObserverForNotification:UIDeviceOrientationDidChangeNotification sender:[UIDevice currentDevice] receiver:[GUJNativeOrientationManager sharedInstance] selector:@selector(orientationChangedNotification:)];
    
}

- (void)__stopOrientationObserver
{
    // unregister for local notification
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [GUJNotificationObserver removeObserverForNotification:UIDeviceOrientationDidChangeNotification sender:[UIDevice currentDevice] receiver:[GUJNativeOrientationManager sharedInstance]];
}

+ (GUJNativeOrientationManager*)sharedInstance
{
    static dispatch_once_t _onceT;
    dispatch_once(&_onceT, ^{
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[GUJNativeOrientationManager alloc] init];
            if( sharedInstance_ ) {
                [sharedInstance_ __setRequiredDeviceCapability:GUJDeviceCapabilityOrientation];
            }
        }
    });
    [sharedInstance_ setDeviceOrientation:[UIDevice currentDevice].orientation];
    @synchronized(sharedInstance_) {
        return sharedInstance_;
    }
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [sharedInstance_ __stopOrientationObserver];
        [sharedInstance_ stopObserver];
    }
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (BOOL)isObserver
{
    return YES;
}

- (BOOL)startObserver
{
    [self __startOrientationObserver];
    return YES;
}

- (BOOL)stopObserver
{
    [self __stopOrientationObserver];
    return YES;
}

#pragma mark public methods

#pragma mark orientation changed observer
- (void)orientationChangedNotification:(NSNotification*)notification
{
    [[GUJNativeOrientationManager sharedInstance] setDeviceOrientation:((UIDevice*)notification.object).orientation];
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJDeviceOrientationChangedNotification object:[GUJNativeOrientationManager sharedInstance]]
     ];
}


@end

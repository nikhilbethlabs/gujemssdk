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
#import "GUJNativeKeyboardObserver.h"

@implementation GUJNativeKeyboardObserver

static GUJNativeKeyboardObserver *sharedInstance_;

#pragma mark private methods
- (void)__startKeyboardObserver
{
    [self setKeyboardIsVidible:NO];
    // enable notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // register for local notification
    [GUJNotificationObserver addObserverForNotification:UIKeyboardDidShowNotification sender:nil receiver:[GUJNativeKeyboardObserver sharedInstance] selector:@selector(keyboardChangedNotification:)];
    [GUJNotificationObserver addObserverForNotification:UIKeyboardDidHideNotification sender:nil receiver:[GUJNativeKeyboardObserver sharedInstance] selector:@selector(keyboardChangedNotification:)];
}

- (void)__stopKeyboardObserver
{
    // unregister for local notification
    [GUJNotificationObserver removeObserverForNotification:UIKeyboardDidShowNotification receiver:[GUJNativeKeyboardObserver sharedInstance]];
    [GUJNotificationObserver removeObserverForNotification:UIKeyboardDidHideNotification receiver:[GUJNativeKeyboardObserver sharedInstance]];
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
    [self __startKeyboardObserver];
    return YES;
}

- (BOOL)stopObserver
{
    [self __stopKeyboardObserver];
    [super stopObserver];
    return YES;
}

#pragma mark public methods
+ (GUJNativeKeyboardObserver*)sharedInstance
{
    static dispatch_once_t _onceT;
    dispatch_once(&_onceT, ^{
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[GUJNativeKeyboardObserver alloc] init];
            [sharedInstance_ __setRequiredDeviceCapability:GUJDeviceCapabilityUnkown];
        }
    });
    @synchronized(sharedInstance_) {
        return sharedInstance_;
    }
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [sharedInstance_ stopObserver];
    }
}


#pragma mark keyboard changed observer
- (void)keyboardChangedNotification:(NSNotification*)notification
{
    if( [notification.name isEqualToString:UIKeyboardDidShowNotification] ) {
        [self setKeyboardIsVidible:YES];
    } else {
        [self setKeyboardIsVidible:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJDeviceKeyboardStateChangedNotification object:[GUJNativeKeyboardObserver sharedInstance]]
     ];
}

@end

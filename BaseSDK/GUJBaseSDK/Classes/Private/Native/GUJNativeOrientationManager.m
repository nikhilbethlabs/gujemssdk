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
    
    deviceOrientation_ = [UIDevice currentDevice].orientation;
    // enable notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // register for local notification
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNativeOrientationManager sharedInstance] selector:@selector(orientationChangedNotification:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]]; 
  
    // register GUJNotificationObserver
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceOrientationChangedNotification object:nil]; 
}

- (void)__stopOrientationObserver
{            
    // unregister for local notification
    [[NSNotificationCenter defaultCenter] removeObserver:[GUJNativeOrientationManager sharedInstance] name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    // unregister GUJNotificationObserver
    [[NSNotificationCenter defaultCenter] removeObserver:[GUJNotificationObserver sharedInstance] name:GUJDeviceOrientationChangedNotification object:nil];
}

+ (GUJNativeOrientationManager*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeOrientationManager alloc] init];
        // set the current device orientation
        sharedInstance_->deviceOrientation_ = [UIDevice currentDevice].orientation;
    }
    @synchronized(sharedInstance_) {            
        return sharedInstance_;
    }
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [super init];        
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityOrientation];
        }
    }
    @synchronized(sharedInstance_) {            
        return sharedInstance_;
    }
}   

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [sharedInstance_ stopObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
    }
    sharedInstance_ = nil;
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJDeviceOrientationChangedNotification selector:selector];   
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJDeviceOrientationChangedNotification];   
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
- (UIDeviceOrientation)deviceOrientation
{
    return deviceOrientation_;
}

#pragma mark orientation changed observer
- (void)orientationChangedNotification:(NSNotification*)notification
{
    deviceOrientation_ = ((UIDevice*)notification.object).orientation;
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJDeviceOrientationChangedNotification object:[GUJNativeOrientationManager sharedInstance]]
     ];     
}


@end

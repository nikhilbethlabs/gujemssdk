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
#import "GUJNativeFrameWorkBridge.h"

@implementation GUJNativeFrameWorkBridge

static GUJNativeFrameWorkBridge *sharedInstance_;

+ (GUJNativeFrameWorkBridge*)sharedInstance
{
    if(!sharedInstance_) {
        sharedInstance_ = [[GUJNativeFrameWorkBridge alloc] init];
    }    
    return sharedInstance_;
}

- (void)freeInstance
{
    // implement this in all extending classes
}

- (BOOL)isAvailableForCurrentDevice
{
    return [[GUJDeviceCapabilities sharedInstance] deviceSupportsCapability:rquiredDeviceCapability_];
}

- (GUJNativeFrameWorkBridge*)nativeFrameWorkBridgeForDeviceCapability:(GUJDeviceCapability)capability
{
    GUJNativeFrameWorkBridge *result = nil;
    if( [[GUJDeviceCapabilities sharedInstance] deviceSupportsCapability:capability] ) {
        id nativeFWBClass = [[GUJDeviceCapabilities sharedInstance] nativeClassInstanceForCapability:capability];
        if ( nativeFWBClass != nil ) {
            result = (GUJNativeFrameWorkBridge*)nativeFWBClass;
        } else {
            _logd_tm(self, @"NativeFrameWorkBridgeFaildLoading",nil);
        }
    }
    
    return result;
}

- (BOOL)willPostNotification
{
    return NO;
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector notificationName:(NSString*)notificationName
{    
#pragma unused(receiver)
#pragma unused(selector)
#pragma unused(notificationName)    
    // implement in extending classes that posts notifications  
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
#pragma unused(receiver)
#pragma unused(selector)
    // implement in extending classes that posts notifications
}

- (void)unregisterForNotfication:(id)receiver notificationName:(NSString*)notificationName
{
#pragma unused(receiver)
#pragma unused(notificationName)    
     // implement in extending classes that posts notifications   
}

- (void)unregisterForNotfication:(id)receiver
{
#pragma unused(receiver)    
    // implement in extending classes that posts notifications
}

/*!
 * an extending class should return yes if its an observer.
 * if not, it must allways return false;
 */
- (BOOL)isObserver
{
    return NO;
}

/*!
 * if the extending class is a observer, this method should start the observer activity.
 * if not, it must allways return false;
 */
- (BOOL)startObserver 
{
    return NO;
}

/*!
 * if the extending class is a observer, this method should stop the observer activity.
 * if not, it must allways return false;
 */
- (BOOL)stopObserver
{
    return NO;
}

@end


@implementation GUJNativeFrameWorkBridge (Private)

- (void)__setRequiredDeviceCapability:(GUJDeviceCapability)capability
{
    rquiredDeviceCapability_ = capability;
}

@end
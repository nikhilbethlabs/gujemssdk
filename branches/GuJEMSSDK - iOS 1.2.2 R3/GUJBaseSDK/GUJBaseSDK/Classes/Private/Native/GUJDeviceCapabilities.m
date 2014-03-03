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
#import "GUJDeviceCapabilities.h"

NSString *const kGUJDeviceCapabilityNativeFrameworkBridgeClass[]  = { 
    kGUJNativeFrameworkBridgeClassForNetworkDeviceCapability, 
    kGUJNativeFrameworkBridgeClassForPhoneDeviceCapability,
    kGUJNativeFrameworkBridgeClassForSMSDeviceCapability,
    kGUJNativeFrameworkBridgeClassForEmailDeviceCapability,
    kGUJNativeFrameworkBridgeClassForTiltDeviceCapability,
    kGUJNativeFrameworkBridgeClassForScreenSizeDeviceCapability,
    kGUJNativeFrameworkBridgeClassForShakeDeviceCapability,
    kGUJNativeFrameworkBridgeClassForOrientationDeviceCapability,
    kGUJNativeFrameworkBridgeClassForHeadingDeviceCapability,
    kGUJNativeFrameworkBridgeClassForLocationDeviceCapability,
    kGUJNativeFrameworkBridgeClassForMapKitDeviceCapability,
    kGUJNativeFrameworkBridgeClassForCalendarDeviceCapability,
    kGUJNativeFrameworkBridgeClassForCameraDeviceCapability,
    kGUJNativeFrameworkBridgeClassForNativeAudioDeviceCapability,
    kGUJNativeFrameworkBridgeClassForNativeVideoDeviceCapability,
    nil
};

NSString *const kGUJDeviceCapabilitySystemDependencyClass[]  = { 
    kGUJSystemClassForNetworkDeviceCapability, 
    kGUJSystemClassForPhoneDeviceCapability,
    kGUJSystemClassForSMSDeviceCapability,
    kGUJSystemClassForEmailDeviceCapability,
    kGUJSystemClassForTiltDeviceCapability,
    kGUJSystemClassForScreenSizeDeviceCapability,
    kGUJSystemClassForShakeDeviceCapability,
    kGUJSystemClassForOrientationDeviceCapability,
    kGUJSystemClassForHeadingDeviceCapability,
    kGUJSystemClassForLocationDeviceCapability,
    kGUJSystemClassForMapKitDeviceCapability,
    kGUJSystemClassForCalendarDeviceCapability,
    kGUJSystemClassForCameraDeviceCapability,
    kGUJSystemClassForNativeAudioDeviceCapability,
    kGUJSystemClassForNativeVideoDeviceCapability,
    nil
};


@implementation GUJDeviceCapabilities

static GUJDeviceCapabilities *sharedInstance_;

- (BOOL)__canLoadClass:(NSString*)classToLoad
{
    BOOL result = NO;
    Class loadedClass = NSClassFromString(classToLoad);
    if( loadedClass != nil ) {
        result = YES;
    } else {
        _logd_tm(self, @"NativeClassNotFound:",classToLoad,nil);
    }
    return result;
}

- (id)__loadClass:(NSString*)classToLoad
{
    id result = nil;
    if( [self __canLoadClass:classToLoad] ) {
        Class loadedClass = NSClassFromString(classToLoad);
        if( loadedClass ) {
            result = [loadedClass new];
        }
    }
    return result;
}

+ (GUJDeviceCapabilities*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[super alloc] init];
    }
    return sharedInstance_;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    sharedInstance_ = nil;
}

- (BOOL)deviceSupportsCapability:(GUJDeviceCapability)capability
{
    BOOL result = NO;
    if((capability != GUJDeviceCapabilityUnkown) &&
       (capability != GUJDeviceCapabilityLevel1) &&
       (capability != GUJDeviceCapabilityLevel2) &&
       (capability != GUJDeviceCapabilityLevel3) 
       ) {
        result = [self __canLoadClass:kGUJDeviceCapabilitySystemDependencyClass[capability]];
    }
    return result;
}


- (id)nativeClassInstanceForCapability:(GUJDeviceCapability)capability
{
    id result = nil;
    result = [self __loadClass:kGUJDeviceCapabilityNativeFrameworkBridgeClass[capability]];
    return result;
}

- (id)systemClassForCapability:(GUJDeviceCapability)capability
{
    id result = nil;
    result = [self __loadClass:kGUJDeviceCapabilitySystemDependencyClass[capability]];
    return result;
}

- (NSArray*)deviceCapabilities
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObject:NSNUMBER_WITH_INT(GUJDeviceCapabilityLevel1)];
    
    int i = GUJDeviceCapabilityNetwork;
    while ( kGUJDeviceCapabilitySystemDependencyClass[i] ) {  
        if( [self deviceSupportsCapability:i] ) { 
            [result addObject:NSNUMBER_WITH_INT(i)];
        }
        i++;
    }
    if( [result count] > 1 ) {
        [result addObject:NSNUMBER_WITH_INT(GUJDeviceCapabilityLevel2)];
    }

    return result;
}

@end

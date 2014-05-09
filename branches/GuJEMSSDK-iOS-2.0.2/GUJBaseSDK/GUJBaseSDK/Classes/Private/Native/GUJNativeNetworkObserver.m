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
#import "GUJNativeNetworkObserver.h"

@implementation GUJNativeNetworkObserver

static GUJNativeNetworkObserver *sharedInstance_;

- (void)__startEventListener
{
    if( [self runLoop] == nil ) {
        [self setRunLoop:[NSRunLoop currentRunLoop]];
    }
    // checking every 10 seconds for network change
    @autoreleasepool {
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(__networkChangedListenerEvent) userInfo:nil repeats:YES]];
    }
    [[self runLoop] run];
}

- (void)__stopEventListener
{
    if( [self runLoop] != nil ) {
        CFRunLoopStop([[self runLoop] getCFRunLoop]);
    }
    if( [self timer] != nil ) {
        [[self timer] invalidate];
    }
    [self setTimer:nil];
    [self setRunLoop:nil];
}

- (void)__networkChangedListenerEvent
{
    
    if( [GUJUtil networkInterfaceName] != [self currentNetworkInterface] ) {
        @autoreleasepool {
            [self setCurrentNetworkInterface:[GUJUtil networkInterfaceName]];
            [self setCurrentNetworkInterfaceAddress:[GUJUtil internetAddressStringRepresentation]];
        }
        // post the notification
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:GUJDeviceNetworkChangedNotification object:self]
         ];
        
        _logd_tm(self, @"NetworkChanged:",[self currentNetworkInterface],[self currentNetworkInterfaceAddress],nil);
    }
}

+(GUJNativeNetworkObserver*)sharedInstance
{
    static dispatch_once_t _onceT;
    dispatch_once(&_onceT, ^{
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[GUJNativeNetworkObserver alloc] init];
        }
    });
    return sharedInstance_;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
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
    BOOL result = NO;
    if( ![self runLoop] ) {
        // start a thread to be safe and non-blocking
        [NSThread detachNewThreadSelector:@selector(__startEventListener) toTarget:self withObject:nil];
        result = YES;
    }
    return result;
}

- (BOOL)stopObserver
{
    BOOL result = NO;
    if( [self runLoop] ) {
        [self __stopEventListener];
        result = YES;
    }
    return result;
}

#pragma mark public methods
- (BOOL)isWiFi
{
    return ( [[self currentNetworkInterface] isEqualToString:kNetworkInterfaceIdentifierForTypeEn0] );
}

- (BOOL)isCellular
{
    return ( [[self currentNetworkInterface] isEqualToString:kNetworkInterfaceIdentifierForTypePdp_ip0] );
}

- (BOOL)isOflline
{
    return ( ![self isWiFi] && ![self isCellular] );
}

- (NSString*)networkInterfaceName
{
    return [self currentNetworkInterface];
}

- (NSString*)networkInterfaceAddressStringRepresentation
{
    return [self currentNetworkInterfaceAddress];
}

@end

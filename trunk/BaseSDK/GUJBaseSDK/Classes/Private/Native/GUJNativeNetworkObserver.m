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
    // register for notification forwarding
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceNetworkChangedNotification object:nil];  
    
    if( runLoop_ == nil ) {
        runLoop_ = [NSRunLoop currentRunLoop];
    }
    // checking every 10 seconds for network change
    @autoreleasepool {    
        timer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(__networkChangedListenerEvent) userInfo:nil repeats:YES];
    }
    [runLoop_ run];
}

- (void)__stopEventListener
{
    if( runLoop_ != nil ) {   
        CFRunLoopStop([runLoop_ getCFRunLoop]);
    }
    if( timer_ != nil ) {
        [timer_ invalidate];
    }    
    runLoop_ = nil;
    timer_   = nil;    
    // unregister GUJNotificationObserver notification forwarding
    [[NSNotificationCenter defaultCenter] removeObserver:[GUJNotificationObserver sharedInstance] name:GUJDeviceNetworkChangedNotification object:nil];              
}

- (void)__networkChangedListenerEvent
{
    
    if( [GUJUtil networkInterfaceName] != currentNetworkInterface_ ) {
        @autoreleasepool {            
            currentNetworkInterface_        = [GUJUtil networkInterfaceName];
            currentNetworkInterfaceAddress_ = [GUJUtil internetAddressStringRepresentation];
        }
        // post the notification
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:GUJDeviceNetworkChangedNotification object:[GUJNativeNetworkObserver sharedInstance]]
         ];               
        
        _logd_tm(self, @"NetworkChanged:",currentNetworkInterface_,currentNetworkInterfaceAddress_,nil);        
    }    
}

+(GUJNativeNetworkObserver*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeNetworkObserver alloc] init];
    }          
    return sharedInstance_;   
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {            
  
        }
    }           
    return self;
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
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJDeviceNetworkChangedNotification selector:selector];    
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJDeviceNetworkChangedNotification];   
}

- (BOOL)isObserver
{
    return YES;
}

- (BOOL)startObserver
{
    BOOL result = NO;
    if( !runLoop_ ) {        
        // start a thread to be safe and non-blocking
        [NSThread detachNewThreadSelector:@selector(__startEventListener) toTarget:self withObject:nil];    
        result = YES;
    }
    return result;
}

- (BOOL)stopObserver
{
    BOOL result = NO;   
    if( runLoop_ ) {
        [self __stopEventListener];        
        result = YES;
    }
    return result;
}

#pragma mark public methods
- (BOOL)isWiFi
{
    return ( [currentNetworkInterface_ isEqualToString:kNetworkInterfaceIdentifierForTypeEn0] );
}

- (BOOL)isCellular
{
    return ( [currentNetworkInterface_ isEqualToString:kNetworkInterfaceIdentifierForTypePdp_ip0] );
}

- (BOOL)isOflline
{
    return ( ![self isWiFi] && ![self isCellular] );
}

- (NSString*)networkInterfaceName
{
    return currentNetworkInterface_;
}

- (NSString*)networkInterfaceAddressStringRepresentation
{
    return currentNetworkInterfaceAddress_;
}

@end

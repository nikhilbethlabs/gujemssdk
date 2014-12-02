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
#import "GUJNotificationObserver.h"
#import <objc/message.h>

@implementation GUJNotificationObserver

static GUJNotificationObserver *sharedInstance_;

- (NSInvocationOperation*)__rebuildNSInvocationOperation:(NSInvocationOperation*)operation withNotification:(NSNotification*)notification
{
    NSInvocationOperation *result = nil;
    NSInvocation *invocation = [operation invocation];
    if( invocation ) {
        result = [[NSInvocationOperation alloc] initWithTarget:invocation.target selector:invocation.selector object:notification];
    }
    return result;
}

+(GUJNotificationObserver*)sharedInstance
{
    @autoreleasepool {    
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[GUJNotificationObserver alloc] init];
        }
        return sharedInstance_;
    }
}

- (void)freeInstance
{
    _logd_tm(self, @"freeInstance",nil);
    [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
    [notificationReceiver_ removeAllObjects];
    notificationReceiver_ = nil;
    sharedInstance_ = nil;
}

- (void)registerForNotification:(id)receiver name:(NSString*)notifcationName selector:(SEL)selector
{
    _logd_tm(self, @"registerForNotification:",receiver,notifcationName,nil);
    if( [receiver methodSignatureForSelector:selector] ) {  
        NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:receiver selector:selector object:notifcationName]; 
        if( notificationReceiver_ == nil ) {
            notificationReceiver_ = [[NSMutableDictionary alloc] init];
        }
        if( [notificationReceiver_ objectForKey:notifcationName] != nil ) {
            id invocationObj = [notificationReceiver_ objectForKey:notifcationName];
            NSMutableArray *receiverArray = nil;
            if( [invocationObj isKindOfClass:[NSArray class]] ) {
                receiverArray = [[NSMutableArray alloc] initWithArray:(NSArray*)invocationObj];
            } else {
                receiverArray = [[NSMutableArray alloc] init];
            }
            [receiverArray addObject:invocationObj];
            [notificationReceiver_ setObject:receiverArray forKey:notifcationName];
        } else {
            [notificationReceiver_ setObject:invocation forKey:notifcationName];
        }
    }
}

- (void)removeFromNotificationQueue:(id)receiver name:(NSString*)notifcationName
{   
    id receiverObj = [notificationReceiver_ objectForKey:notifcationName];
    if( receiverObj != nil ) {
        if( [receiverObj isKindOfClass:[NSArray class]] ) {
            NSArray *receiverArray = (NSArray*)receiverObj;
            for (NSObject *object in receiverArray) {
                if( [object isKindOfClass:[NSInvocationOperation class]] ) {
                    NSInvocation *invocation = [((NSInvocationOperation*)object) invocation];
                    if( invocation.target == receiver ) {
                        [notificationReceiver_ removeObjectForKey:notifcationName];
                        break;
                    }
                }
            }
            [notificationReceiver_ setObject:receiverArray forKey:notifcationName];
        } else {                             
            NSInvocation *invocation = [((NSInvocationOperation*)receiverObj) invocation];                    
            if( invocation.target == receiver ) {
                [notificationReceiver_ removeObjectForKey:notifcationName];
            }
        }
    }
}

- (void)receiveNotificationMessage:(NSNotification*)notification
{
    _logd_tm(self, @"Notification:",notification,nil);
    id receiver = [notificationReceiver_ objectForKey:notification.name];
    if( receiver != nil ) {
        if( [receiver isKindOfClass:[NSArray class]] ) {
            NSArray *receiverArray = (NSArray*)receiver;
            for (NSObject *object in receiverArray) {
                if( [object isKindOfClass:[NSInvocationOperation class]] ) {
                    NSInvocationOperation *invocationOperation = (NSInvocationOperation*)object;
                    invocationOperation = [self __rebuildNSInvocationOperation:invocationOperation withNotification:notification];
                    if( invocationOperation != nil ) {
                        [[invocationOperation invocation] invoke];
                    } 
                }
            }
        } else {
            NSInvocationOperation *invocationOperation = (NSInvocationOperation*)receiver;
            invocationOperation = [self __rebuildNSInvocationOperation:invocationOperation withNotification:notification];
            if( invocationOperation != nil ) {
                [[invocationOperation invocation] invoke];
            }
        }
    }
}

@end

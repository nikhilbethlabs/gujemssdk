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
#import "ORMMAStateObserver.h"

@implementation ORMMAStateObserver

static ORMMAStateObserver *sharedInstance_;


#pragma mark public methods
+(ORMMAStateObserver*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[ORMMAStateObserver alloc] init];
    }          
    return sharedInstance_;   
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {
            state_ = kORMMAParameterValueForStateLoading;         
        }
    }           
    return self;
}   

- (void)changeState:(NSString*)state
{
    state_ = state;
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJBannerStateChangedNotification object:[ORMMAStateObserver sharedInstance]]
     ];       
}

- (NSString*)state
{
    return state_;
}

- (BOOL)isState:(NSString*)state
{
    return ( [state_ isEqualToString:state] );
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJBannerStateChangedNotification selector:selector];    
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJBannerStateChangedNotification];   
}

- (BOOL)isObserver
{
    return YES;
}

- (BOOL)startObserver
{    
    // register for notification forwarding
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJBannerStateChangedNotification object:nil];    
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJBannerStateChangedNotification object:[ORMMAStateObserver sharedInstance]
     ]];       
    return YES;
}

- (BOOL)stopObserver
{    
    // unregister for notification forwarding
    [[NSNotificationCenter defaultCenter] removeObserver:[GUJNotificationObserver sharedInstance] name:GUJBannerStateChangedNotification object:nil];    
    return YES;
}


@end

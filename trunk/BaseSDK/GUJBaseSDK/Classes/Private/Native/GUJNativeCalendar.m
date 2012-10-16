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
#import "GUJNativeCalendar.h"

@implementation GUJNativeCalendar

static GUJNativeCalendar *sharedInstance_;

+(GUJNativeCalendar*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeCalendar alloc] init];
    }          
    return sharedInstance_;   
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityCamera];
        }
    }           
    return self;
}   

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    sharedInstance_ = nil;
}

- (BOOL)isAvailableForCurrentDevice 
{
    BOOL result = NO;
    if( [GUJUtil iosVersion] >= __IPHONE_4_0 ) {
        result = [super isAvailableForCurrentDevice];
    }
    return result;
}

- (BOOL)canAddEvent
{
    return [self isAvailableForCurrentDevice];
}

- (BOOL)addEvent:(NSDate*)startDate end:(NSDate*)endDate title:(NSString*)title description:(NSString*)description
{
    BOOL result = YES;
    if( NSClassFromString(@"EKEventStore") ) { 
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *event      = [EKEvent eventWithEventStore:eventStore];
        event.title         = title;
        event.notes         = description;
        event.startDate     = startDate;
        event.endDate       = [endDate dateByAddingTimeInterval:1.0];
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *error;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&error];
        if( error != nil ) {
            error_ = [GUJUtil errorForDomain:kGUJNativeCalendarManagerErrorDomain andCode:GUJ_ERROR_CALENDAR_UNAVAILABLE withUserInfo:[error userInfo]];
            result = NO;
        }
    }
    return result;
}
 
- (NSError*)lastError
{
    return error_;
}

@end

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
#import "GUJAdViewEvent.h"

@implementation GUJAdViewEvent
@synthesize type;
@synthesize message;
@synthesize attachment;
@synthesize timestamp;

+(GUJAdViewEvent*)eventForType:(GUJAdViewEventType)eventType 
{
    GUJAdViewEvent *result  = [[GUJAdViewEvent alloc] init];
    result->timestamp       = [[NSDate date] timeIntervalSince1970];
    result->type            = eventType;
    return result;
}

+(GUJAdViewEvent*)eventForType:(GUJAdViewEventType)eventType message:(NSString*)message
{
    GUJAdViewEvent *result  = [[GUJAdViewEvent alloc] init];
    result->timestamp       = [[NSDate date] timeIntervalSince1970];
    result->type            = eventType;
    result->message         = message;
    return result;
}

+(GUJAdViewEvent*)eventForType:(GUJAdViewEventType)eventType attachment:(NSObject*)attachment
{
    GUJAdViewEvent *result  = [[GUJAdViewEvent alloc] init];
    result->timestamp       = [[NSDate date] timeIntervalSince1970];
    result->type            = eventType;
    result->attachment      = attachment;
    return result;
}

+(GUJAdViewEvent*)eventForType:(GUJAdViewEventType)eventType message:(NSString*)message attachment:(NSObject*)attachment
{
    GUJAdViewEvent *result  = [[GUJAdViewEvent alloc] init];
    result->timestamp       = [[NSDate date] timeIntervalSince1970];
    result->type            = eventType;
    result->message         = message;
    result->attachment      = attachment;
    return result;
}

@end

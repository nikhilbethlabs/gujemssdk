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
#import "ORMMACallHandler.h"

// Level-1
#import "ORMMAExpandCallHandler.h"
#import "ORMMACloseCallHandler.h"
#import "ORMMAHideCallHandler.h"
#import "ORMMAShowCallHandler.h"
#import "ORMMAResizeCallHandler.h"
#import "ORMMAOpenCallHandler.h"

// Level-2
#import "ORMMAVideoCallHandler.h"
#import "ORMMAEmailCallHandler.h"
#import "ORMMASMSCallHandler.h"
#import "ORMMAPhoneCallHandler.h"
#import "ORMMAAudioCallHandler.h"
#import "ORMMACalendarCallHandler.h"
#import "ORMMAMapCallHandler.h"
#import "ORMMACameraCallHandler.h"

@implementation ORMMACallHandler

+ (ORMMACallHandler*)handlerForCall:(ORMMACall*)call
{
    ORMMACallHandler *result = nil;
    if( [call name] != nil ) {
        // level 1
        if( [[call name] isEqualToString:kORMMAParameterValueForCommandClose] ) {
            result = [[ORMMACloseCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandHide] ) {
            result = [[ORMMAHideCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandShow] ) {
            result = [[ORMMAShowCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandResize] ) {
            result = [[ORMMAResizeCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandExpand] ) {
            result = [[ORMMAExpandCallHandler alloc] init];
        } /*  Level-2 */
        else if( [[call name] isEqualToString:kORMMAParameterValueForCommandAudio] ) {
            result = [[ORMMAAudioCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandVideo] ) {
            result = [[ORMMAVideoCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandEmail] ) {
            result = [[ORMMAEmailCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandSMS] ) {
            result = [[ORMMASMSCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandPhone] ) {
            result = [[ORMMAPhoneCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandCalendar] ) {
            result = [[ORMMACalendarCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandMap] ) {
            result = [[ORMMAMapCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandCamera] ) {
            result = [[ORMMACameraCallHandler alloc] init];
        } else if( [[call name] isEqualToString:kORMMAParameterValueForCommandOpen] ) {
            result = [[ORMMAOpenCallHandler alloc] init];
        }
    }
    return result;
}

+ (void)handle:(ORMMACall*)call forAdView:(_GUJAdView*)adView completion:(void(^)(BOOL result))completion
{
    ORMMACallHandler *handler = [ORMMACallHandler handlerForCall:call];
    if( handler != nil ) {
        [handler setCall:call];
        [handler setAdView:adView];
        [handler performHandler:completion];
    } else {
        completion(NO);
    }
}

- (void)performHandler:(void(^)(BOOL result))completion
{
    completion(YES);
}

@end

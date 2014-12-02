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
#import "ORMMAEmailCallHandler.h"
#import "GUJNativeFrameWorkBridge.h"
#import "GUJNativeEmailComposer.h"
@implementation ORMMAEmailCallHandler

- (BOOL)__hasProperty:(NSString*)property
{
    return ([[call_ value] objectForKey:property] != nil);
}

- (BOOL)__hasProperty:(NSString*)property withValue:(NSString*)value
{
    BOOL result = ([[call_ value] objectForKey:property] != nil);
    if( result ) {
        if( ![((NSString*)[[call_ value] objectForKey:property]) isEqualToString:value] ) {
            result = NO;
        }
    }
    return result;
}

- (NSString*)__stringValueForProperty:(NSString*)property
{
    NSString *result = nil;
    if( [self __hasProperty:property] ) {
        result = [[call_ value] objectForKey:property];
        result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return result;
}

- (BOOL)performHandler
{
    BOOL result = NO;
    if( [call_ value] ) {
        [GUJNativeEmailComposer sharedInstance];
        NSString *recipient = [self __stringValueForProperty:@"recipient"];
        NSString *subject   = [self __stringValueForProperty:@"subject"];
        NSString *body      = [self __stringValueForProperty:@"body"];
        BOOL isHTML         = [self __hasProperty:@"html" withValue:@"Y"];
        
        if( recipient && subject && body ) {
        GUJNativeFrameWorkBridge *frameWorkBridge = [[GUJNativeFrameWorkBridge sharedInstance] nativeFrameWorkBridgeForDeviceCapability:GUJDeviceCapabilityEmail];
        if( frameWorkBridge != nil && [frameWorkBridge respondsToSelector:@selector(isAvailableForCurrentDevice)]) {
            result = (BOOL)[frameWorkBridge performSelector:@selector(isAvailableForCurrentDevice)];
            if( result ) {
                if( [frameWorkBridge respondsToSelector:@selector(composeEmailTo:subject:body:)] ) {
                    [[GUJNativeEmailComposer sharedInstance] setHTMLEmail:isHTML];
                    [[GUJNativeEmailComposer sharedInstance] composeEmailTo:recipient subject:subject body:body];
                }
            }
        }
        }
    }
    return result;
}


@end

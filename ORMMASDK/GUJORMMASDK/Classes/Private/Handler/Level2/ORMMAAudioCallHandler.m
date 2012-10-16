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
#import "ORMMAAudioCallHandler.h"
#import "ORMMAStateObserver.h"
#import "GUJNativeAudioPlayer.h"
#import <UIKit/UIKit.h>
@implementation ORMMAAudioCallHandler

- (float)__floatForPrameter:(NSString*)parameter
{
    float result = 0;
    if( parameter ) {
        result = [[NSNumber numberWithLongLong:[parameter longLongValue]] floatValue];
    }
    return result;
}

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

- (BOOL)performHandler
{
    BOOL result = NO;
    if(![[ORMMAStateObserver sharedInstance] isState:kORMMAParameterValueForStateHidden] &&
       ![[ORMMAStateObserver sharedInstance] isState:kORMMAParameterValueForStateLoading] ) {
        NSString *audioURL  = ([[call_ value] objectForKey:kORMMAParameterKeyForURL]);
        BOOL autoplay       = [self __hasProperty:kORMMAParameterKeyForAutoPlay];
        BOOL showControls   = [self __hasProperty:kORMMAParameterKeyForControls];
        BOOL loop           = [self __hasProperty:kORMMAParameterKeyForLoop];
        __attribute__((unused))
        BOOL fullScreen     = !([self __hasProperty:kORMMAParameterKeyForStartStyle withValue:@"normal"] );
        BOOL closeOnStop    = ([self __hasProperty:kORMMAParameterKeyForStopStyle withValue:@"exit"] );
        __attribute__((unused))
        float originX       = [self __floatForPrameter:kORMMAParameterKeyForOriginLeft];
        __attribute__((unused))
        float originY       = [self __floatForPrameter:kORMMAParameterKeyForOriginTop];
        
        if( !showControls ) {
            closeOnStop     = YES;
        } 
        
        // convert url string if needed
        audioURL = [audioURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *contentUrl = [NSURL URLWithString:audioURL];
        
        if( contentUrl ) {
            result = YES;      
            [[GUJNativeAudioPlayer sharedInstance] freeInstance];
            [[GUJNativeAudioPlayer sharedInstance] setShouldAutoplay:autoplay];
            [[GUJNativeAudioPlayer sharedInstance] setShouldLoop:loop];
            [[GUJNativeAudioPlayer sharedInstance] setControlsHidden:showControls];           
            [[GUJNativeAudioPlayer sharedInstance] playAudio:contentUrl];
        }
    }
    return result;
}

@end

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
#import "GUJNativeAudioPlayer.h"
#import <UIKit/UIKit.h>
#import "ORMMAView.h"

@implementation ORMMAAudioCallHandler

static GUJNativeAudioPlayer *_audioPlayer;

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
    return ([[[self call] value] objectForKey:property] != nil);
}

- (BOOL)__hasProperty:(NSString*)property withValue:(NSString*)value
{
    BOOL result = ([[[self call] value] objectForKey:property] != nil);
    if( result ) {
        if( ![((NSString*)[[[self call] value] objectForKey:property]) isEqualToString:value] ) {
            result = NO;
        }
    }
    return result;
}

- (void)performHandler:(void(^)(BOOL result))completion
{
    BOOL result = NO;
    NSString *_currentORMMAState = [((ORMMAView*)[self adView]) ormmaViewState];
    if(![_currentORMMAState isEqualToString:kORMMAParameterValueForStateInit] &&
       ![_currentORMMAState isEqualToString:kORMMAParameterValueForStateLoading] ) {
        NSString *audioURL  = ([[[self call] value] objectForKey:kORMMAParameterKeyForURL]);
        BOOL autoplay       = [self __hasProperty:kORMMAParameterKeyForAutoPlay];
        BOOL showControls   = [self __hasProperty:kORMMAParameterKeyForControls];
        BOOL loop           = [self __hasProperty:kORMMAParameterKeyForLoop];
        __attribute__((unused))
        BOOL fullScreen     = !([self __hasProperty:kORMMAParameterKeyForStartStyle withValue:@"normal"] );
        
#ifndef __clang_analyzer__
        // not yet implemented @sven
        BOOL closeOnStop    = ([self __hasProperty:kORMMAParameterKeyForStopStyle withValue:@"exit"] );
        if( !showControls ) {
            closeOnStop     = YES;
        }
#endif
        
        __attribute__((unused))
        float originX       = [self __floatForPrameter:kORMMAParameterKeyForOriginLeft];
        __attribute__((unused))
        float originY       = [self __floatForPrameter:kORMMAParameterKeyForOriginTop];
        
        // convert url string if needed
        audioURL = [audioURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *contentUrl = [NSURL URLWithString:audioURL];
        
        if( contentUrl ) {
            result = YES;
            if( _audioPlayer != nil ) {
                [_audioPlayer stopAudio];
            }
            _audioPlayer = [[GUJNativeAudioPlayer alloc] init];
            [_audioPlayer setAutoPlay:autoplay];
            [_audioPlayer setLoopPlayback:loop];
            [_audioPlayer setHideControls:showControls];
            [_audioPlayer playAudio:contentUrl];
        }
    }
    completion(result);
}

@end

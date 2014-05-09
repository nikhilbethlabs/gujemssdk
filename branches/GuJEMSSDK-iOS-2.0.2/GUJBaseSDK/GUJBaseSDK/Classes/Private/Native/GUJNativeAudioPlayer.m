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
#import "GUJNativeAudioPlayer.h"

@implementation GUJNativeAudioPlayer

- (void)__postChangeNotificationForState:(GUJAudioPlayerState)audioPlayerState
{
    [self setState:audioPlayerState];
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJNativeAudioPlayerNotification object:self]];
}

- (void)__initializePlayerWithURL:(NSURL*)audioURL
{
    NSError *error;
    [self setAudioPlayer:[[MPMoviePlayerController alloc] initWithContentURL:audioURL]];
    if (!error) {
        if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
            [[self audioPlayer] prepareToPlay];
        }
        [self __postChangeNotificationForState:GUJAudioPlayerStatePrepared];
        if( [self autoPlay] ) {
            [[self audioPlayer] play];
            [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStarted];
        }
    } else {
        [GUJUtil errorForDomain:kGUJNativeAudioPlayerErrorDomain andCode:GUJ_ERROR_CODE_GENERAL_UNDEFINED withUserInfo:[error userInfo]];
    }
    
    if( [self hideControls] ) {
        [[self audioPlayer] setControlStyle:MPMovieControlStyleNone];
    }
    
    if ([[self audioPlayer] respondsToSelector:@selector(loadState)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    }
}

#pragma mark MPMoviePlayer Notifications
- (void) moviePlaybackStateDidChange:(NSNotification*)notification
{
    if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
        MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);
        if( moviePlayerInstance.playbackState == MPMoviePlaybackStateInterrupted) {
            [self __postChangeNotificationForState:GUJAudioPlayerStateBeginInterruption];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStatePaused) {
            [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackPaused];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStatePlaying) {
            [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackPlaying];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStateStopped) {
            [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStopped];
        }
    }
}

- (void) audioPlayerLoadStateChanged:(NSNotification*)notification
{
    if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
        MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);
        if ([moviePlayerInstance loadState] != MPMovieLoadStateUnknown) {
            [[NSNotificationCenter 	defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayerInstance];
            
            [self __postChangeNotificationForState:GUJAudioPlayerStateLoaded];
            
            if( [self autoPlay] && [moviePlayerInstance playbackState] != MPMoviePlaybackStatePlaying ) {
                [[self audioPlayer] play];
            } else {
                [[self audioPlayer] pause];
            }
        } else {
            [self __postChangeNotificationForState:GUJMoviePlayerStateMovieFailedLoading];
        }
    }
}

- (void) audioPlayBackDidFinish:(NSNotification*)notification
{
    [[NSNotificationCenter 	defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    [[self audioPlayer] stop];
    [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStopped];
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if( [self audioPlayer] != nil ) {
        [[self audioPlayer] stop];
        [[NSNotificationCenter defaultCenter] removeObserver:[self audioPlayer]];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self setAudioPlayer:nil];
}

- (id)init
{
    if( self == nil ) {
        self = [super init];
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityNativeAudio];
            [self setAutoPlay:YES];
        }
    }
    return self;
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

#pragma mark public methods
- (BOOL)canPlayAudio
{
    BOOL result = NO;
    result = [super isAvailableForCurrentDevice];
    return result;
}

- (void)playAudio:(NSURL*)audioURL
{
    [self setAudioPlayer:[[MPMoviePlayerController alloc] initWithContentURL:audioURL]];
    if( [self audioPlayer] != nil ) {
        if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
            [[self audioPlayer] prepareToPlay];
        }
        [self __postChangeNotificationForState:GUJAudioPlayerStatePrepared];
        if( [self autoPlay] ) {
            [[self audioPlayer] play];
            [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStarted];
        }
    } else {
        [self setError:[GUJUtil errorForDomain:kGUJNativeAudioPlayerErrorDomain andCode:GUJ_ERROR_CODE_GENERAL_UNDEFINED withUserInfo:nil]];
    }
}

- (void)pauseAudio
{
    if( [self audioPlayer] != nil ) {
        [[self audioPlayer] pause];
        [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackPaused];
    }
}

- (void)stopAudio
{
    if( [self audioPlayer] != nil ) {
        [[self audioPlayer] stop];
        [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStopped];
    }
}

@end


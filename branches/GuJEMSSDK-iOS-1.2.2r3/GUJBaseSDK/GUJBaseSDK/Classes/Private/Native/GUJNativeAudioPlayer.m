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

static GUJNativeAudioPlayer *sharedInstance_;

- (void)__postChangeNotificationForState:(GUJAudioPlayerState)audioPlayerState
{
    state_ = audioPlayerState;
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJNativeAudioPlayerNotification object:[GUJNativeAudioPlayer sharedInstance]]];
}

- (void)__initializePlayerWithURL:(NSURL*)audioURL
{
    // register for notification forwarding    
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJNativeAudioPlayerNotification object:nil];    
    
    NSError *error;
    audioPlayer_ = [[MPMoviePlayerController alloc] initWithContentURL:audioURL]; 
    if (!error) {        
            if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
                [audioPlayer_ prepareToPlay];
            }
        [self __postChangeNotificationForState:GUJAudioPlayerStatePrepared];
        if( autoPlay_ ) {
            [audioPlayer_ play];
            [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStarted];            
        }
    } else {
        [GUJUtil errorForDomain:kGUJNativeAudioPlayerErrorDomain andCode:GUJ_ERROR_CODE_GENERAL_UNDEFINED withUserInfo:[error userInfo]];
    }
    
    if( [GUJUtil iosVersion] < __IPHONE_3_2 ) {
        audioPlayer_.movieControlMode = MPMovieControlStyleNone;
    } else {
        // set controlStyle to default for iOS > 3.2 
        if( hideControls_ ) {
            audioPlayer_.movieControlMode = MPMovieControlStyleNone;                    
        } else {
            audioPlayer_.movieControlMode = MPMovieControlStyleNone;
        }
    }
    
    if ([audioPlayer_ respondsToSelector:@selector(loadState)]) 
    {
        if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(audioPlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        }
	} else {     
        if( [GUJUtil iosVersion] < __IPHONE_3_2 ) {
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(audioPreloadDidFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(audioPlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {        
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];        
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
            [[NSNotificationCenter 	defaultCenter] removeObserver:sharedInstance_ name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayerInstance];  
            
            [self __postChangeNotificationForState:GUJAudioPlayerStateLoaded];         
            
            if( autoPlay_ && [moviePlayerInstance playbackState] != MPMoviePlaybackStatePlaying ) {     
                [audioPlayer_ play];
            } else {
                [audioPlayer_ pause];
            }
        } else {
            [self __postChangeNotificationForState:GUJMoviePlayerStateMovieFailedLoading];             
        }
    }
}

- (void) audioPreloadDidFinish:(NSNotification*)notification 
{
    if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
        MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);    
        [[NSNotificationCenter 	defaultCenter] removeObserver:sharedInstance_ name:MPMoviePlayerContentPreloadDidFinishNotification object:notification.object]; 
        [self __postChangeNotificationForState:GUJAudioPlayerStateLoaded];          
        if( autoPlay_ && [moviePlayerInstance playbackState] != MPMoviePlaybackStatePlaying ) {
                [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStarted];             
            [audioPlayer_ play];        
        } else {      
            [audioPlayer_ pause];
        }
    } else {
        [self __postChangeNotificationForState:GUJMoviePlayerStateMovieFailedLoading];            
    }
}

- (void) audioPlayBackDidFinish:(NSNotification*)notification 
{    
    [[NSNotificationCenter 	defaultCenter] removeObserver:sharedInstance_ name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    [audioPlayer_ stop];
    [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStopped];        
}

+(GUJNativeAudioPlayer*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeAudioPlayer alloc] init];
        // set autoplay yes as default
        sharedInstance_->autoPlay_ = YES;
    }          
    return sharedInstance_;   
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( audioPlayer_ != nil ) {
        [audioPlayer_ stop];
        [[NSNotificationCenter defaultCenter] removeObserver:audioPlayer_];
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
    }
    audioPlayer_    = nil;
    sharedInstance_ = nil;
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityNativeAudio];            
        }
    }           
    return self;
}   

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJNativeAudioPlayerNotification selector:selector];    
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJNativeAudioPlayerNotification];
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
    NSError *error;
    audioPlayer_ = [[MPMoviePlayerController alloc] initWithContentURL:audioURL]; 
    if (!error) {        
        if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
            [audioPlayer_ prepareToPlay];
        }
        [self __postChangeNotificationForState:GUJAudioPlayerStatePrepared];
        if( autoPlay_ ) {
            [audioPlayer_ play];
            [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStarted];            
        }
    } else {
        [GUJUtil errorForDomain:kGUJNativeAudioPlayerErrorDomain andCode:GUJ_ERROR_CODE_GENERAL_UNDEFINED withUserInfo:[error userInfo]];
    }
}

- (void)pauseAudio
{
    if( audioPlayer_ != nil ) {
        [audioPlayer_ pause];
        [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackPaused];
    }   
}

- (void)stopAudio
{
    if( audioPlayer_ != nil ) {
        [audioPlayer_ stop];
        [self __postChangeNotificationForState:GUJAudioPlayerStatePlaybackStopped];
    }
}

- (void)setShouldAutoplay:(BOOL)autoPlay
{
    autoPlay_ = autoPlay;
}

- (BOOL)willAutoplay
{
    return autoPlay_;
}


- (void)setShouldCloseOnStop:(BOOL)closeOnStop
{
    closeOnStop_ = closeOnStop;
}

- (BOOL)willCloseOnStop
{
    return closeOnStop_;
}

- (void)setShouldLoop:(BOOL)loopPlayback
{
    loopPlayback_ = loopPlayback;
}

- (BOOL)willLoop
{
    return loopPlayback_;
}

- (void)setControlsHidden:(BOOL)hideControls
{
    hideControls_ = hideControls;
}

- (BOOL)controlsHidden
{
    return hideControls_;
}

@end


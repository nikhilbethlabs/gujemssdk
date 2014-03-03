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
#import "GUJNativeFrameWorkBridge.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioSession.h>

#import "GUJModalViewController.h"

@interface GUJNativeMoviePlayer : GUJNativeFrameWorkBridge {
  @private
    GUJMoviePlayerState     state_;
    MPMoviePlayerController *nativeMoviePlayer_;    
    UIInterfaceOrientation  statusBarOrientation_;
    GUJModalViewController  *modalViewController_;
    UIView                  *containerView_;
    UIView                  *viewForEmbedding_;
    CGRect                  embeddedFrame_;
    CGSize                  naturalMovieSize_;
    BOOL                    embedded_;
    BOOL                    autoPlay_;
    BOOL                    closeOnStop_;
    BOOL                    loopPlayback_;
    BOOL                    hideControls_;
    BOOL                    audioMuted_;
    BOOL                    forceLandscape_;
}

+(GUJNativeMoviePlayer*)sharedInstance;

- (GUJMoviePlayerState)state;

- (BOOL)canPlayVideo;

- (void)playVideo:(NSURL*)videoURL;
- (void)stopVideo;

- (void)setForceLandscape:(BOOL)force;
- (BOOL)forceLandscape;

- (void)setViewForEmbeddedPlayer:(UIView*)view;
- (void)setViewForEmbeddedPlayer:(UIView*)view videoFrame:(CGRect)videoFrame;
- (BOOL)isEmbeddedPlayer;

- (void)setShouldAutoplay:(BOOL)autoPlay;
- (BOOL)willAutoplay;

- (void)setShouldCloseOnStop:(BOOL)closeOnStop;
- (BOOL)willCloseOnStop;

- (void)setShouldLoop:(BOOL)loopPlayback;
- (BOOL)willLoop;

- (void)setControlsHidden:(BOOL)hideControls;
- (BOOL)controlsHidden;

- (void)setAuidoMuted:(BOOL)audioMuted;
- (BOOL)isAudioMuted;


@end

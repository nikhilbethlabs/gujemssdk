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
#import "GUJNativeAPIInterface.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioSession.h>

#import "GUJModalViewController.h"

@interface GUJNativeMoviePlayer : GUJNativeAPIInterface

@property (nonatomic, assign) GUJMoviePlayerState     state;
@property (nonatomic, strong) MPMoviePlayerController *nativeMoviePlayer;
@property (nonatomic, assign) UIInterfaceOrientation  statusBarOrientation;
@property (nonatomic, strong) GUJModalViewController  *modalViewController;
@property (nonatomic, strong) UIView                  *containerView;
@property (nonatomic, strong) UIView                  *viewForEmbedding;
@property (nonatomic, assign) CGRect                  embeddedFrame;
@property (nonatomic, assign) CGSize                  naturalMovieSize;
@property (nonatomic, assign) BOOL                    embedded;
@property (nonatomic, assign) BOOL                    autoPlay;
@property (nonatomic, assign) BOOL                    closeOnStop;
@property (nonatomic, assign) BOOL                    loopPlayback;
@property (nonatomic, assign) BOOL                    hideControls;
@property (nonatomic, assign) BOOL                    audioMuted;
@property (nonatomic, assign) BOOL                    forceLandscape;

- (GUJMoviePlayerState)state;

- (BOOL)canPlayVideo;

- (void)playVideo:(NSURL*)videoURL;
- (void)stopVideo;

- (void)setViewForEmbeddedPlayer:(UIView*)view;
- (void)setViewForEmbeddedPlayer:(UIView*)view videoFrame:(CGRect)videoFrame;

@end

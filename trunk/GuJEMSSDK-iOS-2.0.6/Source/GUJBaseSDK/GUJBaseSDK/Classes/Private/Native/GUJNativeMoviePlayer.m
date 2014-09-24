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
#import "GUJNativeMoviePlayer.h"
@implementation GUJNativeMoviePlayer

#pragma mark private methods
- (void)__postChangeNotificationForState:(GUJMoviePlayerState)moviePlayerState
{
    [self setState:moviePlayerState];
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJNativeVideoPlayerNotification object:self]];
}

- (void)__changeInterfaceOrientationToLandscape
{
    [GUJUtil changeInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)__showVideoPlayerOnRootViewController
{
    if( [self modalViewController] == nil ) {
        [self setModalViewController:[[GUJModalViewController alloc] initWithNibName:nil bundle:nil]];
        [[self containerView] setBackgroundColor:[UIColor blackColor]];
        [[self modalViewController] setView:[self containerView]];
        // show the view controller
        [GUJUtil showPresentModalViewController:[self modalViewController]];
    }
}

- (void)__initializeMoviePlayerWithURL:(NSURL*)movieURL
{
    // safe
    if( [self nativeMoviePlayer] != nil ) {
        [[self nativeMoviePlayer] stop];
        [[self nativeMoviePlayer].view removeFromSuperview];
        [self setNativeMoviePlayer:nil];
    }
    
    // setup the container view
    [self setContainerView:[[UIView alloc] init]];
    // setup the movie player
    [self setNativeMoviePlayer:[[MPMoviePlayerController alloc] initWithContentURL:movieURL]];
    
    [[self nativeMoviePlayer] setScalingMode:MPMovieScalingModeAspectFit];
    [[self nativeMoviePlayer] setShouldAutoplay:NO];
    
    if( [self embedded] ) {
        [[self nativeMoviePlayer].view setFrame:[self embeddedFrame]];
        [[self nativeMoviePlayer] setControlStyle:MPMovieControlStyleEmbedded];
    } else {
        [[self nativeMoviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
        [[self nativeMoviePlayer] setFullscreen:YES];
    }
    
    [[self nativeMoviePlayer] setRepeatMode:MPMovieRepeatModeNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieNaturalSizeAvailable:)
                                                 name:MPMovieNaturalSizeAvailableNotification
                                               object:[self nativeMoviePlayer]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__closeMoviePlayer:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:nil];
    
    
    if( [self loopPlayback] ) {
        [[self nativeMoviePlayer] setRepeatMode:MPMovieRepeatModeOne];
    }
    
    if( [self audioMuted] ) {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    
    [[self nativeMoviePlayer] prepareToPlay];
    [[self nativeMoviePlayer] pause];
    [self __postChangeNotificationForState:GUJMoviePlayerStatePrepared];
}

- (void)__startEmbeddedVideoPlayer:(MPMoviePlayerController*)moviePlayerInstance
{
    if( [self embedded] ) {
        [moviePlayerInstance.view setFrame:[self embeddedFrame]];
        [[self viewForEmbedding] addSubview:moviePlayerInstance.view];
        [[self viewForEmbedding] bringSubviewToFront:moviePlayerInstance.view];
        [self __postChangeNotificationForState:GUJMoviePlayerStateEmbeddedPlayerStarted];
        
        if( [self audioMuted] ) {
            [[self nativeMoviePlayer] play];
        } else {
            [[self nativeMoviePlayer] pause];
        }
    }
}

- (void)__startFullScreenVideoPlayer:(MPMoviePlayerController*)moviePlayerInstance
{
    if( ![self embedded] ) {
        
        float statusBarHeight   = [UIApplication sharedApplication].statusBarFrame.size.height;
        float width             = [GUJUtil sizeOfKeyWindow].width;
        float height            = [GUJUtil sizeOfKeyWindow].height;
        if( [self forceLandscape] ) {
            height += statusBarHeight;
            // Rotate the view for landscape playback
            [[self containerView] setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
            [[self containerView] setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];
            
            // Set frame of movieplayer
            [moviePlayerInstance.view setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
            [moviePlayerInstance.view setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];
            
            [[self containerView] addSubview:moviePlayerInstance.view];
            [self performSelector:@selector(__changeInterfaceOrientationToLandscape) withObject:nil afterDelay:0.1];
        } else {
            [[self containerView] setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];
            [moviePlayerInstance.view setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];
            [[self containerView] addSubview:moviePlayerInstance.view];
        }
        [self performSelectorOnMainThread:@selector(__showVideoPlayerOnRootViewController) withObject:nil waitUntilDone:YES];
        
    }
    [self __postChangeNotificationForState:GUJMoviePlayerStateFullscreenPlayerStarted];
    
    if( [self autoPlay] ) {
        [[self nativeMoviePlayer] play];
    } else {
        [[self nativeMoviePlayer] pause];
    }
}

- (void) __stopVideoPlayer
{
    if( [self forceLandscape] ) {
        [GUJUtil changeInterfaceOrientation:[self statusBarOrientation]];
    }
    if( [[self nativeMoviePlayer] playbackState] == MPMoviePlaybackStatePlaying ) {
        [[self nativeMoviePlayer] stop];
    }
    
    if( ![self embedded] && [self closeOnStop] ) {
        if( [self modalViewController] != nil ) {
            [[self modalViewController] dismissModalViewControllerAnimated:YES];
            __weak id wSelf = self;
            [[self modalViewController] dismissViewControllerAnimated:YES completion:^{
                [wSelf setModalViewController:nil];
            }];
        }
    } else if( [self embedded] && [self nativeMoviePlayer] != nil && [self closeOnStop] ) {
        [[self nativeMoviePlayer].view removeFromSuperview];
    } else {
        if( [self nativeMoviePlayer] != nil ) {
            [[self nativeMoviePlayer] stop];
        }
    }
    if( [self closeOnStop] ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        if( self != nil ) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if( [self nativeMoviePlayer] != nil ) {
                [[NSNotificationCenter defaultCenter] removeObserver:[self nativeMoviePlayer]];
            }
        }
        [self setNativeMoviePlayer:nil];
    } else {
        [self __postChangeNotificationForState:GUJMoviePlayerStatePlaybackDidFinish];
    }
    
}

- (void) __closeMoviePlayer:(NSNotification*)notification
{
#pragma unused(notification)
    [self __stopVideoPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    if( [self modalViewController] != nil ) {
        [[self modalViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark public methods
- (id)init
{
    if( self == nil ) {
        self = [super init];
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityNativeVideo];
            // setting autoplay YES as default
            [self setAutoPlay:YES];
            // set as full screen player by default
            [self setEmbedded:NO];
            // set force landscape to NO
            [self setForceLandscape:NO];
            // shold close on stop
            [self setCloseOnStop:YES];
        }
    }
    @synchronized(self) {
        return self;
    }
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if( self != nil ) {
        if( [self nativeMoviePlayer] != nil ) {
            [[NSNotificationCenter defaultCenter] removeObserver:[self nativeMoviePlayer]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    if( [self nativeMoviePlayer] != nil ) {
        [[self nativeMoviePlayer] stop];
    }
    [[self modalViewController] dismissViewControllerAnimated:YES completion:nil];
    [self setNativeMoviePlayer:nil];
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

#pragma mark public methods
- (BOOL)canPlayVideo
{
    return [super isAvailableForCurrentDevice];
}

- (void)playVideo:(NSURL*)videoURL
{
    if ([NSThread isMainThread])
    {
        [self __initializeMoviePlayerWithURL:videoURL];
    } else {
        __weak NSURL *weakURL = videoURL;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self __initializeMoviePlayerWithURL:weakURL];
        });
    }
    
}

- (void)stopVideo
{
    if( [self canPlayVideo] && [self nativeMoviePlayer] != nil ) {
        [self __stopVideoPlayer];
    }
}

- (void)setViewForEmbeddedPlayer:(UIView*)view
{
    [self setViewForEmbeddedPlayer:view videoFrame:CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height)];
}

- (void)setViewForEmbeddedPlayer:(UIView*)view videoFrame:(CGRect)videoFrame
{
    [self setEmbedded:YES];
    [self setEmbeddedFrame:videoFrame];
    [self setViewForEmbedding:view];
}

#pragma mark MPMoviePlayer Notifications
- (void) moviePlaybackStateDidChange:(NSNotification*)notification
{
    if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
        MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);
        if( moviePlayerInstance.playbackState == MPMoviePlaybackStateInterrupted) {
            [self __postChangeNotificationForState:GUJMoviePlayerStateInterrupted];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStatePaused) {
            [self __postChangeNotificationForState:GUJMoviePlayerStatePaused];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStatePlaying) {
            [self __postChangeNotificationForState:GUJMoviePlayerStatePlaying];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStateSeekingBackward) {
            [self __postChangeNotificationForState:GUJMoviePlayerStateSeekingBackward];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStateSeekingForward) {
            [self __postChangeNotificationForState:GUJMoviePlayerStateSeekingForward];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStateStopped) {
            [self __postChangeNotificationForState:GUJMoviePlayerStateStopped];
        }
    }
    
}

- (void) movieNaturalSizeAvailable:(NSNotification*)notification
{
    if( notification.object ) {
        [self setNaturalMovieSize:((MPMoviePlayerController*)notification.object).naturalSize];
    }
}

- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
        MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);
        if ([moviePlayerInstance loadState] != MPMovieLoadStateUnknown) {
            [[NSNotificationCenter 	defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayerInstance];
            
            [self __postChangeNotificationForState:GUJMoviePlayerStateMovieLoaded];
            
            if( [self autoPlay] &&
               (   [moviePlayerInstance playbackState] == MPMoviePlaybackStateStopped ||
                [moviePlayerInstance playbackState] == MPMoviePlaybackStatePaused
                )) {
                   if( [self embedded] ) {
                       [self __startEmbeddedVideoPlayer:moviePlayerInstance];
                   } else {
                       if( [self modalViewController] == nil ) {
                           [self __startFullScreenVideoPlayer:moviePlayerInstance];
                       }
                   }
               } else {
                   
                   if( [moviePlayerInstance playbackState] == MPMoviePlaybackStatePaused ) {
                       [moviePlayerInstance pause];
                   } else if( [moviePlayerInstance playbackState] == MPMoviePlaybackStateInterrupted ) {
                       [moviePlayerInstance play];
                   }
                   
               }
        } else {
            [self __postChangeNotificationForState:GUJMoviePlayerStateMovieFailedLoading];
        }
    }
}
/*
 - (void) moviePreloadDidFinish:(NSNotification*)notification
 {
 if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
 MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);
 [[NSNotificationCenter 	defaultCenter] removeObserver:self name:MPMoviePlayerContentPreloadDidFinishNotification object:notification.object];
 [self __postChangeNotificationForState:GUJMoviePlayerStateMoviePreloaded];
 BOOL play = YES;
 // something above iOS 3.1.3
 if( [moviePlayerInstance respondsToSelector:@selector(playbackState)] ) {
 play = ([moviePlayerInstance playbackState] != MPMoviePlaybackStatePlaying);
 }
 if( [self autoPlay] && play ) {
 if( [self embedded] ) {
 [self __startEmbeddedVideoPlayer:moviePlayerInstance];
 } else {
 [self __startFullScreenVideoPlayer:moviePlayerInstance];
 }
 } else {
 BOOL pause = YES;
 if( [moviePlayerInstance respondsToSelector:@selector(playbackState)] ) {
 pause =  [moviePlayerInstance playbackState] != MPMoviePlaybackStateInterrupted;
 }
 if( pause ) {
 [moviePlayerInstance pause];
 }
 }
 } else {
 [self __postChangeNotificationForState:GUJMoviePlayerStateMovieFailedLoading];
 }
 }*/

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [[NSNotificationCenter 	defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    [self __stopVideoPlayer];
}

@end

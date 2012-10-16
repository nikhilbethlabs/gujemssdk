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

static GUJNativeMoviePlayer *sharedInstance_;

#pragma mark private methods
- (void)__postChangeNotificationForState:(GUJMoviePlayerState)moviePlayerState
{
    sharedInstance_->state_ = moviePlayerState;
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJNativeVideoPlayerNotification object:sharedInstance_]];
}

- (void)__changeInterfaceOrientationToLandscape
{
    [GUJUtil changeInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)__showVideoPlayerOnRootViewController
{   
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if( [rootVC isKindOfClass:[UIViewController class]] ) {         
        /*
         * it is a MUST to initialize the view controller here.
         * this method runs in an independen thread and may throw an exception if the vc is
         * allocated anywhere else.
         */
        // setup the container view controller
        if( modalViewController_ == nil ) {
            modalViewController_ = [[GUJModalViewController alloc] initWithNibName:nil bundle:nil];
            [containerView_ setBackgroundColor:[UIColor blackColor]];
            [modalViewController_ setView:containerView_];
            // show the view controller         
            [((UIViewController*)rootVC) presentModalViewController:modalViewController_ animated:YES];       
        }         
    }
}

- (void)__initializeMoviePlayerWithURL:(NSURL*)movieURL
{
    // safe
    if( nativeMoviePlayer_ != nil ) {
        [nativeMoviePlayer_ stop];
        [nativeMoviePlayer_.view removeFromSuperview];
        nativeMoviePlayer_ = nil;
    }
    
    // setup the container view 
    containerView_          = [[UIView alloc] init];
    
    // setup the movie player
    nativeMoviePlayer_ =  [[MPMoviePlayerController alloc] initWithContentURL:movieURL];                    
    
    [nativeMoviePlayer_ setScalingMode:MPMovieScalingModeAspectFit];
    if( [nativeMoviePlayer_ respondsToSelector:@selector(setScalingMode:)] ) {
        [nativeMoviePlayer_ setShouldAutoplay:NO];
    }
    if( [self isEmbeddedPlayer] ) {
        if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
            [nativeMoviePlayer_.view setFrame:embeddedFrame_];    
        }
        if( [nativeMoviePlayer_ respondsToSelector:@selector(setControlStyle:)] ) {
            [nativeMoviePlayer_ setControlStyle:MPMovieControlStyleEmbedded];
        } else {
            if( [GUJUtil iosVersion] < __IPHONE_3_2 ) {
                nativeMoviePlayer_.movieControlMode = MPMovieControlStyleFullscreen;
            } else {
                // set controlStyle to default for iOS > 3.2 
                if( hideControls_ ) {
                    nativeMoviePlayer_.movieControlMode = MPMovieControlStyleNone;                    
                } else {
                    nativeMoviePlayer_.movieControlMode = MPMovieControlStyleDefault;
                }
            }
        }
        if( [nativeMoviePlayer_ respondsToSelector:@selector(setRepeatMode:)] ) {
            [nativeMoviePlayer_ setRepeatMode:MPMovieRepeatModeNone];
        }
    } else {
        if( [nativeMoviePlayer_ respondsToSelector:@selector(setControlStyle:)] ) {
            if( hideControls_ ) {
                [nativeMoviePlayer_ setControlStyle:MPMovieControlStyleNone];                   
            } else {
                [nativeMoviePlayer_ setControlStyle:MPMovieControlStyleFullscreen];
            }
        }  else {
            // set controlStyle to default for iOS < 3.2 
            nativeMoviePlayer_.movieControlMode = MPMovieControlStyleDefault;
        }   
        if( [nativeMoviePlayer_ respondsToSelector:@selector(setFullscreen:)] ) {
            [nativeMoviePlayer_ setFullscreen:YES];
        }      
    }

    if ([nativeMoviePlayer_ respondsToSelector:@selector(loadState)]) 
    {
        if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        }
	} else {     
        if( [GUJUtil iosVersion] < __IPHONE_3_2 ) {
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(moviePreloadDidFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(movieNaturalSizeAvailable:) name:MPMovieNaturalSizeAvailableNotification object:nativeMoviePlayer_];
        
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];        
    }
    
    if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance_ 
                                                 selector:@selector(__closeMoviePlayer:) 
                                                     name:MPMoviePlayerDidExitFullscreenNotification 
                                                   object:nil];
    }
    
    if( loopPlayback_ ) {
        [nativeMoviePlayer_ setRepeatMode:MPMovieRepeatModeOne];    
    }    

    if( audioMuted_ ) {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    
    if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
        [nativeMoviePlayer_ prepareToPlay];
    }
    [nativeMoviePlayer_ pause];
    [self __postChangeNotificationForState:GUJMoviePlayerStatePrepared];    
}

- (void)__startEmbeddedVideoPlayer:(MPMoviePlayerController*)moviePlayerInstance 
{
    if( [self isEmbeddedPlayer] ) {
        if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
            [moviePlayerInstance.view setFrame:embeddedFrame_];
            [viewForEmbedding_ addSubview:moviePlayerInstance.view];              
            [viewForEmbedding_ bringSubviewToFront:moviePlayerInstance.view];
        }
        [self __postChangeNotificationForState:GUJMoviePlayerStateEmbeddedPlayerStarted];
        
        if( autoPlay_ ) {
            [nativeMoviePlayer_ play];
        } else {
            [nativeMoviePlayer_ pause];
        }
    } 
}

- (void)__startFullScreenVideoPlayer:(MPMoviePlayerController*)moviePlayerInstance 
{
    if( ![self isEmbeddedPlayer] && [GUJUtil iosVersion] >= __IPHONE_3_2 ) {// iOS 3.2 and greater
     
        float statusBarHeight   = [UIApplication sharedApplication].statusBarFrame.size.height;
        float width             = [GUJUtil sizeOfKeyWindow].width;
        float height            = [GUJUtil sizeOfKeyWindow].height;        
        if( forceLandscape_ ) {
            height += statusBarHeight;
            // Rotate the view for landscape playback            
            [containerView_ setTransform:CGAffineTransformMakeRotation(M_PI / 2)];   
            [containerView_ setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];
            
            // Set frame of movieplayer
            [moviePlayerInstance.view setTransform:CGAffineTransformMakeRotation(M_PI / 2)];    
            [moviePlayerInstance.view setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];
            
            [containerView_ addSubview:moviePlayerInstance.view];        
            [self performSelector:@selector(__changeInterfaceOrientationToLandscape) withObject:nil afterDelay:0.1];
        } else {
            [containerView_ setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];  
            [moviePlayerInstance.view setFrame:CGRectMake(0.0, -statusBarHeight, width, height)];  
            [containerView_ addSubview:moviePlayerInstance.view];            
        }
        [self performSelectorOnMainThread:@selector(__showVideoPlayerOnRootViewController) withObject:nil waitUntilDone:YES];     
        
    }
    [self __postChangeNotificationForState:GUJMoviePlayerStateFullscreenPlayerStarted];
    
    if( autoPlay_ ) {
        [nativeMoviePlayer_ play];
    } else {
        [nativeMoviePlayer_ pause];
    }
}

- (void) __stopVideoPlayer
{
    if( forceLandscape_ ) {
        [[UIApplication sharedApplication] setStatusBarOrientation:statusBarOrientation_ animated:NO];
    }
    if( [nativeMoviePlayer_ respondsToSelector:@selector(playbackState)] ) {
        if( [nativeMoviePlayer_ playbackState] == MPMoviePlaybackStatePlaying ) {
            [nativeMoviePlayer_ stop];
        } 
    } else {
        [nativeMoviePlayer_ stop];
    }
  
    if( ![self isEmbeddedPlayer] && closeOnStop_ && [GUJUtil iosVersion] >= __IPHONE_3_2  ) {
        if( modalViewController_ != nil ) {
            [modalViewController_ dismissModalViewControllerAnimated:YES];
            modalViewController_ = nil;
        }
    } else if( [self isEmbeddedPlayer] && nativeMoviePlayer_ != nil && closeOnStop_ && [GUJUtil iosVersion] > __IPHONE_3_2 ) {
        [nativeMoviePlayer_.view removeFromSuperview];
    } else {
        // close for pre ios 3.2
        if( [GUJUtil iosVersion] < __IPHONE_3_2 && closeOnStop_ ) { 
            if( modalViewController_ != nil ) {
                [modalViewController_ dismissModalViewControllerAnimated:NO];
                modalViewController_ = nil;
            } else if( nativeMoviePlayer_ != nil && [self isEmbeddedPlayer] ) {
                [nativeMoviePlayer_.view removeFromSuperview];
            }
        }
    }
    if( closeOnStop_ ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
        if( sharedInstance_ != nil ) {
            [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
            if( nativeMoviePlayer_ != nil ) {
                [[NSNotificationCenter defaultCenter] removeObserver:nativeMoviePlayer_];
            }
        }
        nativeMoviePlayer_ = nil;
    } else {
        [self __postChangeNotificationForState:GUJMoviePlayerStatePlaybackDidFinish];
    }
    
}

- (void) __closeMoviePlayer:(NSNotification*)notification
{
#pragma unused(notification)    
    [self __stopVideoPlayer];
    if( [GUJUtil iosVersion] >= __IPHONE_3_2 ) {
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_ name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    }
    if( modalViewController_ != nil ) {
        [modalViewController_ dismissModalViewControllerAnimated:YES];
    } 
}

#pragma mark public methods
+(GUJNativeMoviePlayer*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeMoviePlayer alloc] init];
        // setting autoplay YES as default
        sharedInstance_->autoPlay_          = YES;
        // set as full screen player by default
        sharedInstance_->embedded_          = NO;
        // set force landscape to NO
        sharedInstance_->forceLandscape_    = NO;
        // shold close on stop
        sharedInstance_->closeOnStop_       = YES;
    }
    @synchronized(sharedInstance_) {        
        return sharedInstance_;
    }
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [super init];        
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityNativeVideo];                        
            // register notification forwarding
            [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJNativeVideoPlayerNotification object:nil];            
        }
    }
    @synchronized(sharedInstance_) {            
        return sharedInstance_;
    }
}   

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        if( nativeMoviePlayer_ != nil ) {
            [[NSNotificationCenter defaultCenter] removeObserver:nativeMoviePlayer_];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];        
    }
    if( nativeMoviePlayer_ != nil ) {
        [nativeMoviePlayer_ stop];
    }
    nativeMoviePlayer_  = nil;
    [modalViewController_ dismissModalViewControllerAnimated:YES];
    modalViewController_ = nil;
    sharedInstance_     = nil;
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}
- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJNativeVideoPlayerNotification selector:selector];    
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJNativeVideoPlayerNotification];   
}

#pragma mark public methods
-(GUJMoviePlayerState)state
{
    return state_;
}

- (BOOL)canPlayVideo
{
    return [super isAvailableForCurrentDevice];
}

- (void)playVideo:(NSURL*)videoURL
{
    [self __initializeMoviePlayerWithURL:videoURL];
}

- (void)stopVideo
{
    if( [self canPlayVideo] && nativeMoviePlayer_ != nil ) {
        [self __stopVideoPlayer];
    }
}

- (void)setForceLandscape:(BOOL)force
{
    forceLandscape_ = force;
}

- (BOOL)forceLandscape
{
    return forceLandscape_;
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

- (void)setAuidoMuted:(BOOL)audioMuted
{
    audioMuted_ = audioMuted;
}

- (BOOL)isAudioMuted
{
    return audioMuted_;
}

- (void)setViewForEmbeddedPlayer:(UIView*)view
{
    [self setViewForEmbeddedPlayer:view videoFrame:CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height)];
}

- (void)setViewForEmbeddedPlayer:(UIView*)view videoFrame:(CGRect)videoFrame
{
    embedded_           = YES;
    embeddedFrame_      = videoFrame;
    viewForEmbedding_   = view;
}

- (BOOL)isEmbeddedPlayer 
{
    return embedded_;
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
            [self __postChangeNotificationForState:GUJMoviePlayerStateSeekingBackward];
        } else if( moviePlayerInstance.playbackState == MPMoviePlaybackStateStopped) {
            [self __postChangeNotificationForState:GUJMoviePlayerStateStopped];
        }        
    } 
}

- (void) movieNaturalSizeAvailable:(NSNotification*)notification
{
    if( notification.object ) {
        naturalMovieSize_ = ((MPMoviePlayerController*)notification.object).naturalSize;
    }
}

- (void) moviePlayerLoadStateChanged:(NSNotification*)notification 
{
    if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
        MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);
        
        if ([moviePlayerInstance loadState] != MPMovieLoadStateUnknown) {
            [[NSNotificationCenter 	defaultCenter] removeObserver:sharedInstance_ name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayerInstance];  

            [self __postChangeNotificationForState:GUJMoviePlayerStateMovieLoaded];         

            if( autoPlay_ && 
                (   [moviePlayerInstance playbackState] == MPMoviePlaybackStateStopped || 
                    [moviePlayerInstance playbackState] == MPMoviePlaybackStatePaused
                )) {     
                if( [self isEmbeddedPlayer] ) {
                    [self __startEmbeddedVideoPlayer:moviePlayerInstance];
                } else {     
                    if( modalViewController_ == nil ) {                             
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
            [self __postChangeNotificationForState:GUJMoviePlayerStateMovieFaildLoading];             
        }
    }
}

- (void) moviePreloadDidFinish:(NSNotification*)notification 
{
    if( notification.object != nil && [notification.object isKindOfClass:[MPMoviePlayerController class]] ) {
        MPMoviePlayerController *moviePlayerInstance = ((MPMoviePlayerController*)notification.object);    
        [[NSNotificationCenter 	defaultCenter] removeObserver:sharedInstance_ name:MPMoviePlayerContentPreloadDidFinishNotification object:notification.object]; 
        [self __postChangeNotificationForState:GUJMoviePlayerStateMoviePreloaded];      
        BOOL play = YES;
        // something above iOS 3.1.3
        if( [moviePlayerInstance respondsToSelector:@selector(playbackState)] ) {
            play = ([moviePlayerInstance playbackState] != MPMoviePlaybackStatePlaying);
        }
        if( autoPlay_ && play ) {
            if( [self isEmbeddedPlayer] ) {
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
        [self __postChangeNotificationForState:GUJMoviePlayerStateMovieFaildLoading];            
    }
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification 
{    
    [[NSNotificationCenter 	defaultCenter] removeObserver:sharedInstance_ name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    [self __stopVideoPlayer];
}

@end

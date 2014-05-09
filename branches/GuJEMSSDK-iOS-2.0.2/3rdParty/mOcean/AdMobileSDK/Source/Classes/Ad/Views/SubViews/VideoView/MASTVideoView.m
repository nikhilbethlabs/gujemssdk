//
//  VideoView.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/28/11.
//

#import "MASTVideoView.h"


@implementation MASTVideoView

@synthesize videoUrl = _videoUrl;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
		_player = [[MPMoviePlayerController alloc] init];
		[_player setRepeatMode:MPMovieRepeatModeOne];
		[_player setScalingMode:MPMovieScalingModeFill];
		_player.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_player.movieSourceType = MPMovieSourceTypeFile;
		[self addSubview:_player.view];
		
		_touchableViewController = [[MASTTouchableViewController alloc] initWithFrame:CGRectMake(0, 0, _player.view.frame.size.width, _player.view.frame.size.height - 40)];
        _touchableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_touchableViewController setDelegate:self];
		[self addSubview:_touchableViewController.view];
		
		_videoPlaying = NO;
    }
    return self;
}

- (void)dealloc {
	if (_request) {
		[_request release];
	}
	if (_videoUrl) {
		[_videoUrl release];
	}
	
	[_touchableViewController release];
	
    _player.initialPlaybackTime = -1;
	[_player.view removeFromSuperview];
	[_player stop];
	[_player release];
	
    [super dealloc];
}

- (void)showWithUrl:(NSString*)videoUrl request:(NSURLRequest *)newRequest {
	[self updateRequest:newRequest];
	
	if (_videoUrl) {
		[_videoUrl release];
	}
	_videoUrl = [videoUrl retain];
	
	[_player setContentURL:[NSURL URLWithString:videoUrl]];
    [self play];
    
    
    if (self.superview) {
        NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
        [senfInfo setObject:self.superview forKey:@"adView"];
        [senfInfo setObject:self forKey:@"subView"];
        
        [[MASTNotificationCenter sharedInstance] postNotificationName:kReadyAdDisplayNotification object:senfInfo];
    }
}

- (void)updateRequest:(NSURLRequest*)request {
	if (_request) {
		[_request release];
	}
	_request = [request retain];
}

- (void) play {
	if (!_videoPlaying) {
		_videoPlaying = YES;
		[_player play];
	}
}

- (void) pause {
	if (_videoPlaying) {
		_videoPlaying = NO;
		[_player pause];
	}
}

- (void) setFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    [_player setFullscreen:fullscreen animated:animated];
}

- (void) viewDidTouched {
    if (_request && self.superview) {
        NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_request, self.superview, nil]
                                                                       forKeys:[NSArray arrayWithObjects:@"request", @"adView", nil]];
        
        [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenURLNotification object:info];
    }
}

@end

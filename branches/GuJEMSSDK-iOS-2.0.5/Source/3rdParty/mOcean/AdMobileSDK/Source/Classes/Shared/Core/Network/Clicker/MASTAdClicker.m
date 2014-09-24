//
//  AdClicker.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 7/18/11.
//  Copyright 2011 AdMobile Mobile. A subsidiary of Mojiva, Inc. All rights reserved.
//

#import "MASTAdClicker.h"
#import "MASTAdView.h"
#import "MASTUtils.h"


@interface MASTAdClicker (PrivateMethods)

- (void)click:(NSNotification*)notification;
- (void)clean:(NSTimer*)timer;

@end

@implementation MASTAdClicker

static MASTAdClicker* sharedInstance = nil;


#pragma mark -
#pragma mark Singleton


- (id) init {
    self = [super init];
	if (self) {
		[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(click:) name:kVerifyRequestNotification object:nil];
        
        _infos = [NSMutableArray new];
        _connections = [NSMutableArray new];
        _timers = [NSMutableArray new];
        _urls = [NSMutableDictionary new];
	}
	
	return self;
}

+ (id)sharedInstance {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [[self alloc] init];
		}
	}
	return sharedInstance;
}

- (oneway void)superRelease {
	RELEASE_SAFELY(_infos);
	RELEASE_SAFELY(_connections);
	RELEASE_SAFELY(_timers);
	RELEASE_SAFELY(_urls);
    
	[super release];
}

+ (void)releaseSharedInstance {
	@synchronized(self) {
		[sharedInstance superRelease];
		sharedInstance = nil;
	}
}

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [super allocWithZone:zone];
		}
	}
	
	return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
	return sharedInstance;
}

- (id)retain {
	return sharedInstance;
}

- (unsigned)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	// Do nothing.
}

- (id)autorelease {
	return sharedInstance;
}


#pragma mark -
#pragma mark Public

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response) {        
        if (_connections && [_connections count] > 0) {
            @synchronized(self) {
                NSUInteger ind = [_connections indexOfObject:connection];
                if (ind != NSNotFound) {                    
                    [_urls setObject:[request URL] forKey:[NSString stringWithFormat:@"%d", [connection hash]]];
                }
            }
        }
    }
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [connection cancel];
    if (_connections && [_connections count] > 0) {
        @synchronized(self) {
            NSUInteger ind = [_connections indexOfObject:connection];
            if (ind != NSNotFound) {                
                NSDictionary* info = [_infos objectAtIndex:ind];
                NSTimer* timer = [_timers objectAtIndex:ind];
                
                if (timer && [timer isValid]) {
                    [timer invalidate];
                }
                
                NSURL* url = [_urls objectForKey:[NSString stringWithFormat:@"%d", [connection hash]]];
                
                if (url) {                    
                    NSMutableDictionary* sendInfo = [NSMutableDictionary dictionaryWithDictionary:info];
                    [sendInfo setObject:[NSURLRequest requestWithURL:url] forKey:@"request"];
                    
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenVerifiedRequestNotification object:sendInfo];
                } else {
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenVerifiedRequestNotification object:info];
                }
                
                [_infos removeObjectAtIndex:ind];
                [_connections removeObjectAtIndex:ind];
                [_timers removeObjectAtIndex:ind];
                
                [self clean:_cleanTimer];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_connections && [_connections count] > 0) {
        @synchronized(self) {
            NSUInteger ind = [_connections indexOfObject:connection];
            if (ind != NSNotFound) {                
                NSDictionary* info = [_infos objectAtIndex:ind];
                NSTimer* timer = [_timers objectAtIndex:ind];
                
                if (timer && [timer isValid]) {
                    [timer invalidate];
                }
                
                NSURL* url = [_urls objectForKey:[NSString stringWithFormat:@"%d", [connection hash]]];
                
                if (url) {
                    NSMutableDictionary* sendInfo = [NSMutableDictionary dictionaryWithDictionary:info];
                    [sendInfo setObject:[NSURLRequest requestWithURL:url] forKey:@"request"];
                    
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenVerifiedRequestNotification object:sendInfo];
                } else {
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenVerifiedRequestNotification object:info];
                }
                
                [_infos removeObjectAtIndex:ind];
                [_connections removeObjectAtIndex:ind];
                [_timers removeObjectAtIndex:ind];
                
                [self clean:_cleanTimer];
            }
        }
    }
}


#pragma mark -
#pragma mark Private


- (void)timerFire:(NSTimer*)timer {
    @synchronized(self) {
        NSUInteger ind = [_timers indexOfObject:timer];
        if (ind != NSNotFound) {
            NSDictionary* info = [_infos objectAtIndex:ind];            
            NSURLConnection* conn = [_connections objectAtIndex:ind];
            [conn cancel];
            
            [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenVerifiedRequestNotification object:info];
            
            [_infos removeObjectAtIndex:ind];
            [_connections removeObjectAtIndex:ind];
            [_timers removeObjectAtIndex:ind];
            
            [self clean:_cleanTimer];
        }
    }
}

- (void)clean:(NSTimer*)timer {
    @synchronized(self) {
        for (NSTimer* tim in _timers) {
            if ([tim isValid]) {
                [tim invalidate];
            }
        }
        for (NSURLConnection* connection in _connections) {
            [connection cancel];
        }
        
        [_timers removeAllObjects];
        [_infos removeAllObjects];
        [_connections removeAllObjects];
    }
}

- (void)click:(NSNotification*)notification {
    NSDictionary* info = [notification object];
	MASTAdView* adView = [info objectForKey:@"adView"];
    NSURLRequest* request = [info objectForKey:@"request"];
    
    if (info && adView && request) {
        @synchronized(self) {
            if (_infos && [_infos count] < 4) {
                NSURLRequest* checkRequest = [NSURLRequest requestWithURL:[request URL]];
                NSURLConnection* connection = [NSURLConnection connectionWithRequest:checkRequest delegate:self];
                
                NSTimer* timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(timerFire:) userInfo:nil repeats:NO];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                
                [_infos addObject:info];
                [_connections addObject:connection];
                [_timers addObject:timer];
                
                if (_cleanTimer) {
                    if ([_cleanTimer isValid]) {
                        [_cleanTimer invalidate];
                    }
                    [_cleanTimer release];
                }
                
                _cleanTimer = [NSTimer timerWithTimeInterval:CLEAN_INTERVAL target:self selector:@selector(clean:) userInfo:nil repeats:NO];
                [[NSRunLoop currentRunLoop] addTimer:_cleanTimer forMode:NSDefaultRunLoopMode];
                [_cleanTimer retain];
            }
        }
    }
}


@end

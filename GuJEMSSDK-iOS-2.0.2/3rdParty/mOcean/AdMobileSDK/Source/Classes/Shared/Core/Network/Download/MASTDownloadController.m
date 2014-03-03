//
//  DownloadController.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/21/11.
//

#import "MASTDownloadController.h"
#import "MASTNetworkQueue.h"

@interface MASTDownloadController (PrivateMethods)

- (void)registerObserver;
- (void)startAdDownloadNotification:(NSNotification*)notification;
- (void)cancelAdDownloadNotification:(NSNotification*)notification;
- (void)removeAdNotification:(NSNotification*)notification;

@end


@implementation MASTDownloadController

static MASTDownloadController* sharedInstance = nil;

#pragma mark -
#pragma mark Singleton

- (id) init {
    self = [super init];
	if (self) {
		_adRequests = [MASTAdRequests new];
		
		// TODO: add shared model
		//_sharedRequestQueue.userAgent = [SharedModel sharedInstance].userAgent;
		
		[self registerObserver];
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
	RELEASE_SAFELY(_adRequests);
	
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


- (void)cancelAll{
    [MASTNetworkQueue cancelAll];
}

- (void)downladAd:(MASTAdView*)adView {
    
	@synchronized(_adRequests) {        
		if (adView) {
            // remove old requests
            //[_adRequests removeAd:adView];
            
            // start new reqest
            NSString* url = [[adView adModel] url];
            
            if (url) {
                NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] 
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:NETWORK_TIMEOUT];
                
                [_adRequests addRequest:request forAd:adView];
                                
                NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:request, adView, nil]
                                                                               forKeys:[NSArray arrayWithObjects:@"request", @"adView", nil]];
                [[MASTNotificationCenter sharedInstance] postNotificationName:kGetAdServerResponseNotification object:info];
                
                [MASTNetworkQueue loadWithRequest:request completion:^(NSURLRequest *req, NSHTTPURLResponse *response, NSData *data, NSError *error) {
                    if (error) {                        
                        @synchronized(_adRequests) {
                            if ([_adRequests containsRequest:request]) {
                                NSMutableDictionary* sendInfo = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:error, adView, nil]
                                                                                                   forKeys:[NSArray arrayWithObjects:@"error", @"adView", nil]];
                                
                                // remove from ads request array
                                [_adRequests removeRequest:request];
                                
                                if ([NSThread isMainThread]) {
                                    [[MASTNotificationCenter sharedInstance] postNotificationName:kFailAdDownloadNotification object:sendInfo];
                                } else {
                                    [MASTNotificationCenterAdditions NC:[MASTNotificationCenter sharedInstance] postNotificationOnMainThreadWithName:kFailAdDownloadNotification object:sendInfo];
                                }
                            }
                        }
                    } else {
                        if ([_adRequests containsRequest:request]) {
                            NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            [responseString release];
                            
                            if (adView && req) {
                                NSMutableDictionary* infoBlock = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:request, data, adView, nil]
                                                                                                    forKeys:[NSArray arrayWithObjects:@"request", @"data", @"adView", nil]];
                                [[MASTNotificationCenter sharedInstance] postNotificationName:kFinishAdDownloadNotification object:infoBlock];
                            }
                            
                            // remove from ads request array
                            [_adRequests removeRequest:request];
                        }
                    }
                }];
            }
		}
	}
}


#pragma mark -
#pragma mark Private


- (void)registerObserver {
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(startAdDownloadNotification:) name:kStartAdDownloadNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(cancelAdDownloadNotification:) name:kAdStopUpdateNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(cancelAdDownloadNotification:) name:kAdCancelUpdateNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(cancelAdDownloadNotification:) name:kAdViewBecomeInvisibleNotification object:nil];
    
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(removeAdNotification:) name:kUnregisterAdNotification object:nil];
}

- (void)startAdDownloadNotification:(NSNotification*)notification {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self downladAd:[notification object]];
    });
}

- (void)cancelAdDownloadNotification:(NSNotification*)notification {
}

- (void)removeAdNotification:(NSNotification*)notification {
}

@end


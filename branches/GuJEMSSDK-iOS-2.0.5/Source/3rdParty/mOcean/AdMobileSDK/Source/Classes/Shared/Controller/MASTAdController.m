//
//  AdController.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/24/11.
//

#import "MASTAdController.h"

#import "MASTNotificationCenterAdditions.h"
#import "MASTUIViewAdditions.h"
#import "MASTUtils.h"


@interface MASTAdController ()

//- (void)visibleCheckerThread;

- (void)addAdView:(MASTAdView*)adView;
- (void)removeAdView:(MASTAdView*)adView;

- (void)registerObserver;
- (void)registerAd:(NSNotification*)notification;
- (void)unregisterAd:(NSNotification*)notification;
- (void)adDownloaded:(NSNotification*)notification;
- (void)adClicked:(NSNotification*)notification;
- (void)adOpenRequest:(NSNotification*)notification;
- (void)failToReceiveAd:(NSNotification*)notification;
- (void)trackExternalCampaignURL:(NSNotification*)notification;

@end


@implementation MASTAdController

static MASTAdController* sharedInstance = nil;

#pragma mark -
#pragma mark Singleton

- (id) init {
    self = [super init];
	if (self) {
		_ads = [NSMutableArray new];
		_adUpdateControllers = [NSMutableArray new];
		
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
	RELEASE_SAFELY(_ads);
	RELEASE_SAFELY(_adUpdateControllers);
	
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


#pragma mark -
#pragma mark Private



- (void)addAdView:(MASTAdView*)adView {
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
    
	@synchronized(_ads) {
		[_ads addObject:adView];
	}
    
	[pool drain];
}

- (void)removeAdView:(MASTAdView*)adView {
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	
	@synchronized(_ads) {
		NSUInteger ind = [_ads indexOfObject:adView];
		
		if (ind != NSNotFound) {
			MASTAdUpdater* updater = [_adUpdateControllers objectAtIndex:ind];
			[updater invalidate];
			[_adUpdateControllers removeObjectAtIndex:ind];
		}
		
		[_ads removeObject:adView];
	}
	
	[pool drain];
}

- (void)registerObserver {
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(registerAd:) name:kRegisterAdNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(unregisterAd:) name:kUnregisterAdNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(adDownloaded:) name:kFinishAdDownloadNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(adClicked:) name:kOpenURLNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(adOpenRequest:) name:kOpenVerifiedRequestNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(failToReceiveAd:) name:kFailAdDownloadNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(trackExternalCampaignURL:) name:kTrackUrlNotification object:nil];
}

- (void)statrLoad:(MASTAdView*)adView {
    [adView adModel];
}

- (void)registerAd:(NSNotification*)notification {
	MASTAdView* adView = [notification object];
    
    MASTAdUpdater* updater = [MASTAdUpdater new];
    updater.adView = adView;
    [_adUpdateControllers addObject:updater];
    [updater release];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addAdView:adView];
    });

    [self performSelector:@selector(statrLoad:) withObject:adView afterDelay:0.1];
}

- (void)unregisterAd:(NSNotification*)notification {
	MASTAdView* adView = [notification object];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self removeAdView:adView];
    });
}

- (void)processDownload:(NSNotification*)notification {
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
    
    NSDictionary *info = [notification object];
	MASTAdView* adView = [info objectForKey:@"adView"];
    //MASTAdModel* adModel = [adView adModel];
    
	NSData* data = [info objectForKey:@"data"];
	MASTAdDescriptor* adDescriptor = [MASTAdDescriptor descriptorFromContent:data frameSize:[adView adModel].frame.size];
    
	if (adDescriptor.adContentType == AdContentTypeInvalidParams) {
        [[MASTNotificationCenter sharedInstance] postNotificationName:kInvalidParamsServerResponseNotification object:adView];
    } else if (adDescriptor.adContentType == AdContentTypeEmpty) {
        NSMutableDictionary* errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setObject:adView forKey:@"adView"];
        [errorInfo setObject:[NSError errorWithDomain:kEmptyServerResponseNotification code:22 userInfo:nil] forKey:@"error"];        
        [[MASTNotificationCenter sharedInstance] postNotificationName:kEmptyServerResponseNotification object:errorInfo];
    } else if (adDescriptor.adContentType != AdContentTypeUndefined) {
        /*if (adModel && [adModel.descriptor.serverReponse isEqualToData:adDescriptor.serverReponse]) {
            if (adDescriptor.adContentType == AdContentTypeDefaultHtml) {
                [pool release];
                return;
            }
            [pool release];
            return;
        }*/
        
        NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
        
        NSUInteger ind = NSNotFound;
        @synchronized(_ads) {
            ind = [_ads indexOfObject:adView];
        }
		
        if (ind != NSNotFound) {
            [senfInfo setObject:adView forKey:@"adView"];
            [senfInfo setObject:adDescriptor forKey:@"descriptor"];
            [MASTNotificationCenterAdditions NC:[MASTNotificationCenter sharedInstance] postNotificationOnMainThreadWithName:kStartAdDisplayNotification object:senfInfo];
        }
    } else {
        if (adDescriptor.externalCampaign) {
            NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
            [senfInfo setObject:adView forKey:@"adView"];
            [senfInfo setObject:adDescriptor.externalContent forKey:@"dic"];
            [MASTNotificationCenterAdditions NC:[MASTNotificationCenter sharedInstance] postNotificationOnMainThreadWithName:kThirdPartyNotification object:senfInfo];
        } else {
            NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
            [senfInfo setObject:adView forKey:@"adView"];
            [senfInfo setObject:adDescriptor forKey:@"descriptor"];
            [MASTNotificationCenterAdditions NC:[MASTNotificationCenter sharedInstance] postNotificationOnMainThreadWithName:kFailAdDisplayNotification object:senfInfo];
        }
    }
    
    [pool release];
}

- (void)adDownloaded:(NSNotification*)notification {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processDownload:notification];
    });
}

- (void)adClicked:(NSNotification*)notification {
    NSDictionary *info = [notification object];
	MASTAdView* adView = [info objectForKey:@"adView"];
    NSURLRequest* request = [info objectForKey:@"request"];
    
    if (adView && request) {
            NSMutableDictionary* sendInfo = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:request, adView, nil]
                                                                               forKeys:[NSArray arrayWithObjects:@"request", @"adView", nil]];
            
            [[MASTNotificationCenter sharedInstance] postNotificationName:kVerifyRequestNotification object:sendInfo];
    }
}

- (void)adOpenRequest:(NSNotification*)notification {
    NSDictionary *info = [notification object];
	MASTAdView* adView = [info objectForKey:@"adView"];
    NSURLRequest* request = [info objectForKey:@"request"];
    
    if (adView && request) {
        // check url
        if ([MASTUtils isInternalURL:[request URL]]) {
            [[MASTNotificationCenter sharedInstance] postNotificationName:kShouldOpenInternalBrowserNotification object:info];
        } else {
            [[MASTNotificationCenter sharedInstance] postNotificationName:kShouldOpenExternalAppNotification object:info];
        }
    }
}

- (void)failToReceiveAd:(NSNotification*)notification {
    @synchronized(notification) {
        NSDictionary *info = [notification object];
        MASTAdView* adView = [info objectForKey:@"adView"];
        NSError* error = [info objectForKey:@"error"];
        
        MASTAdModel* model = [adView adModel];
        
        if (adView && error && model && model.descriptor && model.descriptor.campaignId) {
            if (model.excampaigns) {
                BOOL find = NO;
                for (NSString* campaing in model.excampaigns) {
                    if ([campaing isEqualToString:model.descriptor.campaignId]) {
                        find = YES;
                        break;
                    }
                }
                if (!find) {
                    [model.excampaigns addObject:model.descriptor.campaignId];
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kStartAdDownloadNotification object:adView];
                }
            }
            else {
                model.excampaigns = [NSMutableArray arrayWithObject:model.descriptor.campaignId];
                [[MASTNotificationCenter sharedInstance] postNotificationName:kStartAdDownloadNotification object:adView];
            }
        }
    }
}

- (void)sendTrackRequest:(NSURLRequest*)request {
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    [pool release];
}

- (void)trackExternalCampaignURL:(NSNotification*)notification {
    @synchronized(notification) {
        MASTAdView* adView = [notification object];        
        MASTAdModel* model = [adView adModel];
        
        if (adView && model && model.descriptor && model.descriptor.trackUrl) {
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.descriptor.trackUrl]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sendTrackRequest:request];
            });
        }
    }
}

@end

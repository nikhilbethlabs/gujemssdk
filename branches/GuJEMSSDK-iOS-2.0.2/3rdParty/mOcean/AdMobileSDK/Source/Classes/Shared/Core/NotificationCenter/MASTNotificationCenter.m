//
//  NotificationCenter.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import "MASTNotificationCenter.h"

#import "MASTDownloadController.h"
#import "MASTAdController.h"
#import "MASTInternalBrowser.h"
#import "MASTLogger.h"
#import "MASTSharedModel.h"
#import "MASTAdClicker.h"
#import "MASTInternalAVPlayer.h"


@implementation MASTNotificationCenter

static MASTNotificationCenter* sharedInstance = nil;

#pragma mark -
#pragma mark Singleton

- (id) init {
    self = [super init];
	if (self) {
	}
	
	return self;
}

+ (id)sharedInstance {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [[self alloc] init];
            
			
            if (![MASTLogger sharedInstance]) {
				// somtheing going wrong...
			}
            
            if (![MASTSharedModel sharedInstance]) {
				// somtheing going wrong...
			}
            
			if (![MASTAdController sharedInstance]) {
				// somtheing going wrong...
			}
			
            if (![MASTDownloadController sharedInstance]) {
				// somtheing going wrong...
			}
			
            if (![MASTAdClicker sharedInstance]) {
				// somtheing going wrong...
			}
			
			if ([NSThread isMainThread]) {
				if (![MASTInternalBrowser sharedInstance]) {
					// somtheing going wrong...
				}
			}
			else {
				[MASTInternalBrowser performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
			}
			
			if ([NSThread isMainThread]) {
				if (![MASTInternalAVPlayer sharedInstance]) {
					// somtheing going wrong...
				}
			}
			else {
				[MASTInternalAVPlayer performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
			}

		}
	}
	return sharedInstance;
}

- (oneway void)superRelease {	
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

@end

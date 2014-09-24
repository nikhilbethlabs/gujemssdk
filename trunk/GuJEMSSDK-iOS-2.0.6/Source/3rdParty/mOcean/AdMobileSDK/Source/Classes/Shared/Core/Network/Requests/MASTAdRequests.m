//
//  AdRequests.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import "MASTAdRequests.h"

#import "MASTNotificationCenter.h"
#import "MASTUtils.h"


@implementation MASTAdRequests

- (id)init {
	self = [super init];
	if (self) {		
		// never retain public AdView!
		_ads = [NSMutableArray new]; //CreateNonRetainingArray();
		//_ads = CreateNonRetainingArray();
		_requestListsForAds = [NSMutableArray new];
	}
	
	return self;
}

- (void)dealloc {
	RELEASE_SAFELY(_ads);
	RELEASE_SAFELY(_requestListsForAds);
	
	[super dealloc];
}

- (BOOL)containsRequest:(NSURLRequest*)request {
	BOOL result = NO;
    
    @synchronized(self) {
        NSUInteger i, count = [_ads count];
        for (i = 0; i < count; i++) {
            NSMutableArray* requests = [_requestListsForAds objectAtIndex:i];
            
            if ([requests containsObject:request]) {
                result = YES;
                return result;
            }
        }
    }
	
	return result;
}

- (void)addRequest:(NSURLRequest*)request forAd:(MASTAdView*)adView {
    @synchronized(self) {
        if ([_ads containsObject:adView]) {
            NSUInteger ind = [_ads indexOfObject:adView];
            if (ind == NSNotFound) {
                [_ads addObject:adView];
                NSMutableArray* requests = [NSMutableArray array];
                [requests addObject:request];
                [_requestListsForAds addObject:requests];
            }
            else {
                NSMutableArray* requests = [_requestListsForAds objectAtIndex:ind];
                [requests addObject:request];
                [_requestListsForAds replaceObjectAtIndex:ind withObject:requests];
            }
            
        }
        else {
            [_ads addObject:adView];
            
            NSMutableArray* requests = [NSMutableArray new];
            [requests addObject:request];
            [_requestListsForAds addObject:requests];
            [requests release];
        }
    }
}

- (void)removeRequest:(NSURLRequest*)request {
    @synchronized(self) {
        NSUInteger i, count = [_ads count];
        for (i = 0; i < count; i++) {
            NSMutableArray* requests = [_requestListsForAds objectAtIndex:i];
            
            if ([requests containsObject:request]) {
                [requests removeObject:request];
                
                if ([requests count] == 0) {
                    [_requestListsForAds removeObjectAtIndex:i];
                    [_ads removeObjectAtIndex:i];
                }
                else {
                    [_requestListsForAds replaceObjectAtIndex:i withObject:requests];
                }
                
                break;
            }
        }
    }
}

- (void)removeAd:(MASTAdView*)adView {
    @synchronized(self) {
        NSUInteger ind = [_ads indexOfObject:adView];
        if (ind != NSNotFound) {
            //NSArray* requests = [_requestListsForAds objectAtIndex:ind];
            
            /*
            for (NSURLRequest* req in requests) {
                [MURLRequestQueue cancelAsync:req];
            }
             */
            
            [_requestListsForAds removeObjectAtIndex:ind];
            [_ads removeObjectAtIndex:ind];
        }
    }
}

- (MASTAdView*)adForRequest:(NSURLRequest*)request {
	MASTAdView* ad = nil;
	
    @synchronized(self) {
        NSUInteger i, count = [_ads count];
        for (i = 0; i < count; i++) {
            NSMutableArray* requests = [_requestListsForAds objectAtIndex:i];
            
            if ([requests containsObject:request]) {
                ad = [_ads objectAtIndex:i];
                return ad;
            }
        }
    }
	
	return ad;
}

- (NSArray*)allRequestsForAd:(MASTAdView*)adView {
    @synchronized(self) {
        NSUInteger ind = [_ads indexOfObject:adView];
        if (ind != NSNotFound) {
            return [_requestListsForAds objectAtIndex:ind];
        }
    }
	return nil;
}

@end

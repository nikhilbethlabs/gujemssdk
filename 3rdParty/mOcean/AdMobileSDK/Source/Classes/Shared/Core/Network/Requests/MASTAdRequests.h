//
//  AdRequests.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import <Foundation/Foundation.h>

#import "MASTAdView.h"

@interface MASTAdRequests : NSObject {
	NSMutableArray*			_ads;
	NSMutableArray*			_requestListsForAds;
}

- (BOOL)containsRequest:(NSURLRequest*)request;
- (void)addRequest:(NSURLRequest*)request forAd:(MASTAdView*)adView;
- (void)removeRequest:(NSURLRequest*)request;
- (void)removeAd:(MASTAdView*)adView;
- (MASTAdView*)adForRequest:(NSURLRequest*)request;
- (NSArray*)allRequestsForAd:(MASTAdView*)adView;

@end

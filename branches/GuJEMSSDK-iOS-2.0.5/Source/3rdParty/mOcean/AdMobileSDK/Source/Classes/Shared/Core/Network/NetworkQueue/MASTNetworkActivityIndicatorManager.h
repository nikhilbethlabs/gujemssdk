//
//  NetworkActivityIndicatorManager.h
//
//  Created by Constantine on 10/5/11.
//

#import <Foundation/Foundation.h>


@interface MASTNetworkActivityIndicatorManager : NSObject {
@private
	NSInteger _activityCount;
    BOOL _enabled;
}

@property (readonly) NSInteger count;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

+ (MASTNetworkActivityIndicatorManager *)sharedManager;

- (void)incrementActivityCount;
- (void)decrementActivityCount;

@end

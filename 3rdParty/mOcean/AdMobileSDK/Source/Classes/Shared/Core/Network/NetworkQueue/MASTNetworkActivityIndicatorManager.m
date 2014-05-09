//
//  NetworkActivityIndicatorManager.m
//
//  Created by Constantine on 10/5/11.
//


#import "MASTNetworkActivityIndicatorManager.h"
#import "MASTRequestOperation.h"


@implementation MASTNetworkActivityIndicatorManager
@synthesize count = _activityCount;
@synthesize enabled = _enabled;


static dispatch_queue_t get_setter_queue() {
    static dispatch_queue_t _setterQueue;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_setterQueue = dispatch_queue_create("activity.indicator.setter", NULL);
	});
	return _setterQueue;
}

+ (MASTNetworkActivityIndicatorManager *)sharedManager {
    static MASTNetworkActivityIndicatorManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementActivityCount) name:OperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementActivityCount) name:OperationDidFinishNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)setActivityCount:(NSInteger)activityCount {
    [self willChangeValueForKey:@"count"];
    _activityCount = MAX(activityCount, 0);
    [self didChangeValueForKey:@"count"];

    if (self.enabled) {
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:self.count > 0];
    }
}

- (void)incrementActivityCount {
    dispatch_async(get_setter_queue(), ^(void) {
        _activityCount += 1;
    });
}

- (void)decrementActivityCount {
    dispatch_async(get_setter_queue(), ^(void) {
        _activityCount -= 1;
    });
}

@end

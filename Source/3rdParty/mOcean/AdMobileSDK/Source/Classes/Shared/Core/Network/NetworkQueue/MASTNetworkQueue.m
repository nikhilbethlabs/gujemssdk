//
//  NetworkQueue.m
//
//  Created by Constantine on 10/5/11.
//

#import "MASTNetworkQueue.h"
#import "MASTRequestOperation.h"
#import "MASTNetworkActivityIndicatorManager.h"
#import "MASTWebKitInfo.h"
#import "MASTConstants.h"

@implementation MASTNetworkQueue

static NSOperationQueue* get_network_operations_io_queue() {
    static NSOperationQueue* _networkIOQueue;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_networkIOQueue = [NSOperationQueue new];
        [MASTNetworkActivityIndicatorManager sharedManager];
	});
	return _networkIOQueue;
}

+ (void)loadWithRequest:(NSURLRequest *)urlRequest 
             completion:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error))completion {
    if (![NSThread isMainThread]) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlRequest URL] 
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:NETWORK_TIMEOUT];
        
        [(NSMutableDictionary*)[request allHTTPHeaderFields] removeObjectForKey:@"Keep-Alive"];
        [request setValue:[MASTWebKitInfo userAgent] forHTTPHeaderField:@"User-Agent"];

        dispatch_async(dispatch_get_main_queue(), ^{
            MASTRequestOperation* operation = [MASTRequestOperation operationWithRequest:urlRequest completion:completion];
            [get_network_operations_io_queue() addOperation:operation];
        });
    } else {
        MASTRequestOperation* operation = [MASTRequestOperation operationWithRequest:urlRequest completion:completion];
        [get_network_operations_io_queue() addOperation:operation];
    }
}

+ (void)cancelAll {
    [get_network_operations_io_queue() cancelAllOperations];
}

@end

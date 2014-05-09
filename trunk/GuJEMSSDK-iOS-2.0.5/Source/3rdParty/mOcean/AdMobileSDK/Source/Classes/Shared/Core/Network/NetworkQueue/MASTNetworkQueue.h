//
//  NetworkQueue.h
//
//  Created by Constantine on 10/5/11.
//

#import <Foundation/Foundation.h>

@interface MASTNetworkQueue : NSObject

+ (void)loadWithRequest:(NSURLRequest *)urlRequest 
             completion:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error))completion;

+ (void)cancelAll;

@end

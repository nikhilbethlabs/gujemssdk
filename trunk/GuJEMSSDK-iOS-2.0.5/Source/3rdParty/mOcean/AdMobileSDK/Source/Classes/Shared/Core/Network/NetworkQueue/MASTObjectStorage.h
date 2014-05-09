//
//  ObjectStorage.h
//
//  Created by Constantine on 10/3/11.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface MASTObjectStorage : NSObject

+ (BOOL)isCached:(NSString*)key;
+ (void)storeObject:(id <NSCoding>)obj key:(NSString*)key;
+ (void)objectForKey:(NSString*)key block:(void (^)(id obj))block;

@end

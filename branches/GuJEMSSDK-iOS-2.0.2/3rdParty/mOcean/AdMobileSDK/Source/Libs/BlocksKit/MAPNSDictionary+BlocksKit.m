//
//  MAPNSDictionary+BlocksKit.m
//

#import "MAPNSDictionary+BlocksKit.h"

void useCatagory3(){
    NSLog(@"do nothing, just for make catagory linked");
}

@implementation NSDictionary (MAPBlocksKit)

- (void)each:(MAPBlocksKeyValueBlock)block {
	NSParameterAssert(block != nil);
	
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		block(key, obj);
	}];
}

- (void)apply:(MAPBlocksKeyValueBlock)block {
	NSParameterAssert(block != nil);
	
	[self enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
		block(key, obj);
	}];
}

- (NSDictionary *)select:(MAPBlocksKeyValueValidationBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableDictionary *list = [NSMutableDictionary dictionaryWithCapacity:self.count];
	
	[self each:^(id key, id obj) {
		if (block(key, obj))
			[list setObject:obj forKey:key];
	}];
	
	if (!list.count)
		return nil;
	
	return list;
}

- (NSDictionary *)reject:(MAPBlocksKeyValueValidationBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableDictionary *list = [NSMutableDictionary dictionaryWithCapacity:self.count];
	
	[self each:^(id key, id obj) {
		if (!block(key, obj))
			[list setObject:obj forKey:key];
	}];
	
	if (!list.count)
		return nil;
	
	return list;	
}

- (NSDictionary *)map:(MAPBlocksKeyValueTransformBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];

	[self each:^(id key, id obj) {
		id value = block(key, obj);
		if (!value)
			value = [NSNull null];
		
		[result setObject:value forKey:key];
	}];
	
	return result;
}

@end

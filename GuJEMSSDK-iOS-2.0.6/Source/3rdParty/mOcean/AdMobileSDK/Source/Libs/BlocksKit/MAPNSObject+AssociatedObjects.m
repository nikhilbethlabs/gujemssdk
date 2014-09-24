//
//  MAPNSObject+AssociatedObjects.m
//

#import "MAPNSObject+AssociatedObjects.h"
#import <objc/runtime.h>

void useCatagory4(){
    NSLog(@"do nothing, just for make catagory linked");
}

@implementation NSObject (MAPAssociatedObjects)

#pragma mark - Instance Methods

- (void)associateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)associateCopyOfValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)weaklyAssociateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)associatedValueForKey:(const char *)key {
	return objc_getAssociatedObject(self, key);
}

- (void)removeAllAssociatedObjects {
	objc_removeAssociatedObjects(self);
}

#pragma mark - Class Methods

+ (void)associateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)associateCopyOfValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)weaklyAssociateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

+ (id)associatedValueForKey:(const char *)key {
	return objc_getAssociatedObject(self, key);
}

+ (void)removeAllAssociatedObjects {
	objc_removeAssociatedObjects(self);
}

@end

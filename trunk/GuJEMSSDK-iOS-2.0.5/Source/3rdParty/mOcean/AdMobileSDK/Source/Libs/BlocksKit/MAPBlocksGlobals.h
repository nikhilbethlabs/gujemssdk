//
//  MAPBlocksGlobals.h
//

#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>


typedef void (^MAPBlocksObservationBlock)(id obj, NSDictionary *change);
typedef void (^MAPBlocksKeyValueBlock)(id key, id obj);
typedef BOOL (^MAPBlocksKeyValueValidationBlock)(id key, id obj);
typedef id (^MAPBlocksKeyValueTransformBlock)(id key, id obj);
//
//  NotificationCenterAdditions.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import <Foundation/Foundation.h>


@interface MASTNotificationCenterAdditions : NSObject {}

+ (void)NC:(NSNotificationCenter*)notificationCenter postNotificationOnMainThreadWithName:(NSString*)name object:(id)object;
+ (void)NC:(NSNotificationCenter*)notificationCenter postNotificationOnMainThreadWithName:(NSString*)name object:(id)object userInfo:(NSDictionary *)userInfo waitUntilDone:(BOOL)waitUntilDone;

@end

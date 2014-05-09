//
//  NotificationCenterAdditions.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import "MASTNotificationCenterAdditions.h"
#import <pthread.h>

@implementation MASTNotificationCenterAdditions


+ (void)postNotificationDictionary:(NSDictionary*)info {
	NSNotificationCenter* notificationCenter = [info objectForKey:@"nc"];
	NSString *name = [info objectForKey:@"name"];
	id object = [info objectForKey:@"object"];
	NSDictionary *userInfo = [info objectForKey:@"userInfo"];
	
	[notificationCenter postNotificationName:name object:object userInfo:userInfo];
}


#pragma mark -
#pragma mark Public



+ (void)NC:(NSNotificationCenter*)notificationCenter postNotificationOnMainThreadWithName:(NSString*)name object:(id)object {
	if( pthread_main_np() ) return [notificationCenter postNotificationName:name object:object userInfo:nil];
	[MASTNotificationCenterAdditions NC:notificationCenter postNotificationOnMainThreadWithName:name object:object userInfo:nil waitUntilDone:NO];
}

+ (void)NC:(NSNotificationCenter*)notificationCenter postNotificationOnMainThreadWithName:(NSString*)name object:(id)object userInfo:(NSDictionary *)userInfo waitUntilDone:(BOOL)waitUntilDone {
	if( pthread_main_np() ) return [notificationCenter postNotificationName:name object:object userInfo:userInfo];
	
	NSMutableDictionary *info = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:3];
	if( name ) [info setObject:name forKey:@"name"];
	if( object ) [info setObject:object forKey:@"object"];
	if( userInfo ) [info setObject:userInfo forKey:@"userInfo"];
	[info setObject:notificationCenter forKey:@"nc"];
	
	[MASTNotificationCenterAdditions performSelectorOnMainThread:@selector(postNotificationDictionary:) withObject:info waitUntilDone:waitUntilDone];
	
	[info release];
}

@end
//
//  MASTOrmmaSharedDataSource.m
//  Copyright (c) Microsoft. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MASTOrmmaSharedDataSource.h"
#import "MASTNotificationCenter.h"
#import "MASTLocationManager.h"


@interface MASTOrmmaSharedDataSource() <UIAccelerometerDelegate>
@end

@implementation MASTOrmmaSharedDataSource

static MASTOrmmaSharedDataSource* sharedInstance = nil;

#pragma mark -
#pragma mark - Location

- (void)locationUpdated:(NSNotification*)notification
{
    CLLocation* location = [notification object];
	NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self, kOrmmaKeySender, location, kOrmmaKeyObject, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kOrmmaLocationUpdated object:dic];
}

#pragma mark -
#pragma mark - HeadingUpdated

- (void)headingUpdated:(NSNotification*)notification
{
    CLHeading* heading = [notification object];
    NSNumber* headingNumber = [NSNumber numberWithDouble:heading.trueHeading];
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self, kOrmmaKeySender, headingNumber, kOrmmaKeyObject, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kOrmmaHeadingUpdated object:dic];
}

#pragma mark -
#pragma mark Singleton

- (id)init {
    self = [super init];
    
	if (self) {
		[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(locationUpdated:) name:kLocationManagerLocationUpdate object:nil];
		[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(headingUpdated:) name:kLocationManagerHeadingUpdate object:nil];

		//Accelerometer
        [[MASTAccelerometer sharedInstance] registerMASTNotificationDeviceMotion];
     }
    
	return self;
}

+ (id)sharedInstance {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [[self alloc] init];
		}
	}
	return sharedInstance;
}

- (oneway void)superRelease {
	[super release];
}

+ (void)releaseSharedInstance {
	@synchronized(self) {
		[sharedInstance superRelease];
		sharedInstance = nil;
	}
}

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [super allocWithZone:zone];
		}
	}
	
	return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
	return sharedInstance;
}

- (id)retain {
	return sharedInstance;
}

- (unsigned)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	// Do nothing.
}

- (id)autorelease {
	return sharedInstance;
}

#pragma mark - OrmmaDataSource 

- (BOOL)supportLocationForAd:(id)sender
{
    BOOL support = [MASTLocationManager deviceLocationAvailable];
    if (support)
        support = [[MASTLocationManager sharedInstance] locationDetectionActive];
    
	return support;
}

- (BOOL)supportHeadingForAd:(id)sender
{
    BOOL support = [MASTLocationManager deviceHeadingAvailable];
    if (support)
        support = [[MASTLocationManager sharedInstance] locationDetectionActive];
    
	return support;
}

- (BOOL)supportTiltForAd:(id)sender
{
	return YES;
}


@end
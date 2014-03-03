/*
 * BSD LICENSE
 * Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer .
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * The source code is just allowed for private use, not for commercial use.
 *
 */

#import "GUJNativeLocationManager.h"

@interface GUJNativeLocationManager (Private)
- (void)__initLocationManager;
- (void)__postLocationUpdateNotification;
- (void)__postHeadingUpdateNotification;
@end

@implementation GUJNativeLocationManager

static GUJNativeLocationManager *sharedInstance_;

#pragma mark private mehtods
- (void)__initLocationManager
{
    if ([self locationManager] == nil) {
        [self setLocationManager:[[CLLocationManager alloc] init]];
        
        [self setAuthorizationStatus:kCLAuthorizationStatusNotDetermined];
        [self setLocationServiceAvailable:[CLLocationManager locationServicesEnabled]];
        [self setHeadingServiceAvailable:[CLLocationManager headingAvailable]];
        
        
        if( [self locationServiceAvailable] ) {
            [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
            [[self locationManager] setDistanceFilter:kCLDistanceFilterNone];
        }
        if( [self headingServiceAvailable] ) {
            [[self locationManager] setHeadingFilter:GUJNativeLocationManagerHeadingAccuracy];
        }
        
        [[self locationManager] setDelegate:self];
        // get current location
        if( [self locationManager].location != nil ) {
            [self setLocation:[self locationManager].location];
        }
    }
}

- (void)__postLocationUpdateNotification
{
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJDeviceLocationChangedNotification object:[GUJNativeLocationManager sharedInstance]]
     ];
}

- (void)__postHeadingUpdateNotification
{
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJDeviceHeadingChangedNotification object:[GUJNativeLocationManager sharedInstance]]
     ];
}

#pragma mark delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
#pragma unused(manager)
    [self setError:[GUJUtil errorForDomain:kGUJLocationManagerErrorDomain andCode:GUJ_ERROR_CODE_CORE_LOCATION withUserInfo:[error userInfo]]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
#pragma unused(manager)
    [self setAuthorizationStatus:status];
    if( status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted ) {
        [[GUJNativeLocationManager sharedInstance] stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
#pragma unused(manager)
    @autoreleasepool {
        [self setLocation:[newLocation copy]];
    }
    
    BOOL shouldUpdate = YES;
    if( oldLocation != nil ) {
        shouldUpdate = NO;
        if( [oldLocation distanceFromLocation:newLocation] > 1.0 ) {
            shouldUpdate = YES;
        }
    }
    if( shouldUpdate ) {
        [self __postLocationUpdateNotification];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
#pragma unused(manager)
    @autoreleasepool {
        [self setHeading:[newHeading copy]];
    }
    [self __postHeadingUpdateNotification];
}

#pragma mark public methods
+ (GUJNativeLocationManager*)sharedInstance
{
    static dispatch_once_t _onceT;
    dispatch_once(&_onceT, ^{
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[GUJNativeLocationManager alloc] init];
        }
    });
    return sharedInstance_;
}

- (id)init
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [super init];
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityLocation];
            if( [self isAvailableForCurrentDevice] ) {
                [self __initLocationManager];
            } else {
                [sharedInstance_ setLocationManagerDisabled:YES];
            }
        }
    }
    
    @synchronized(sharedInstance_) {
        return sharedInstance_;
    }
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [sharedInstance_ stopUpdatingHeading];
        [sharedInstance_ stopUpdatingLocation];
        [sharedInstance_ stopObserver];
    }
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

#pragma mark public methods
- (void)startUpdatingLocation
{
    if( ![self locationManagerDisabled] && [self locationServiceAvailable] ) {
        [[self locationManager] startUpdatingLocation];
        if( [self hasLocation] ) {
            [self __postLocationUpdateNotification];
        }
    }
}

- (void)stopUpdatingLocation
{
    if( ![self locationManagerDisabled] && [self locationServiceAvailable] ) {
        [[self locationManager] stopUpdatingLocation];
    }
}

- (void)startUpdatingHeading
{
    if( ![self locationManagerDisabled] && [self headingServiceAvailable] ) {
        [[self locationManager] startUpdatingHeading];
    }
}

- (void)stopUpdatingHeading
{
    if( ![self locationManagerDisabled] && [self headingServiceAvailable] ) {
        [[self locationManager] stopUpdatingHeading];
    }
}

- (BOOL)hasLocation
{
    return ( [self locationManager] != nil && [self location] != nil );
}

- (BOOL)hasHeading
{
    return ( [self locationManager] != nil && [self heading] != nil );
}

- (CLLocationDegrees)locationLatitude
{
    CLLocationDegrees result = 0.0;
    if( [self location] != nil ) {
        result = [[self location] coordinate].latitude;
    }
    return result;
}

- (CLLocationDegrees)locationLongitude
{
    CLLocationDegrees result = 0.0;
    if( _location != nil ) {
        result = [[self location] coordinate].longitude;
    }
    return result;
}

- (CLLocationAccuracy)accuracy
{
    CLLocationAccuracy result = 0.0;
    if( [self locationManager] != nil ) {
        result = [[self locationManager] desiredAccuracy];
    }
    return result;
}

- (NSString*)locationLatitudeStringRepresentation
{
    NSString *result = nil;
    if( [self location] != nil ) {
        result = [NSString stringWithFormat:kGUIJStringFormatForLocationDegrees,_location.coordinate.latitude];
    }
    return result;
}

- (NSString*)locationLongitudeStringRepresentation
{
    NSString *result = nil;
    if( [self location] != nil ) {
        result = [NSString stringWithFormat:kGUIJStringFormatForLocationDegrees,_location.coordinate.longitude];
    }
    return result;
}

- (NSString*)accuracyStringRepresentation
{
    NSString *result = nil;
    if( [self locationManager] != nil ) {
        result = [NSString stringWithFormat:kGUIJStringFormatForLocationDegrees,[[self locationManager] desiredAccuracy]];
    }
    return result;
}

- (double)headingInDegrees
{
    double result = -1.0;
    if ([self heading] != nil ) {
        result = [[self heading] magneticHeading];
    }
    return result;
}

- (NSString*)headingInDegreesStringRepresentation
{
    return [NSString stringWithFormat:kGUIJStringFormatForHeadingDegrees,roundf([self headingInDegrees])];
}

@end

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
@end

@implementation GUJNativeLocationManager
@synthesize locationManager         = _locationManager;
@synthesize location                = _location;
@synthesize heading                 = _heading;
@synthesize locationManagerDisabled = _locationManagerDisabled;

static GUJNativeLocationManager *sharedInstance_;

#pragma mark private mehtods
- (void)__initLocationManager
{       
    if (_locationManager == nil) {
        authorizationStatus_ = kCLAuthorizationStatusNotDetermined;        
        _locationManager = [[CLLocationManager alloc] init];
        
        if( [_locationManager respondsToSelector:@selector(locationServicesEnabled)] ) {
            locationAvailable_ = [_locationManager locationServicesEnabled];
        } else { // ios 3.x < 4.0
            locationAvailable_ = _locationManager.locationServicesEnabled;
        }        
        if( [_locationManager respondsToSelector:@selector(headingAvailable)] ) {
            headingAvailable_ = [_locationManager headingAvailable];
        } else {// ios 3.x < 4.0
            headingAvailable_ = _locationManager.headingAvailable;
        }
        
        if( locationAvailable_ ) {
            [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            [_locationManager setDistanceFilter:kCLDistanceFilterNone];
        }
        if( headingAvailable_ ) {
            [_locationManager setHeadingFilter:GUJNativeLocationManagerHeadingAccuracy];
        }
        [_locationManager setDelegate:self];
    }     
}

#pragma mark delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
#pragma unused(manager)
    error_ = [GUJUtil errorForDomain:kGUJLocationManagerErrorDomain andCode:GUJ_ERROR_CODE_CORE_LOCATION withUserInfo:[error userInfo]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
#pragma unused(manager)    
    authorizationStatus_ = status;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{    
#pragma unused(manager)    
    @autoreleasepool {
        _location = [newLocation copy];
    }
    if( runOnce_ ) {
        // delay to ensure all notifications where send.
        [self performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:0.5];
    }
    BOOL shouldUpdate = YES;
    if( oldLocation != nil ) {
        shouldUpdate = NO;
        if( ([oldLocation getDistanceFrom:newLocation] > 1.0) ) {
            shouldUpdate = YES;
        }
    }
    if( shouldUpdate ) {
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:GUJDeviceLocationChangedNotification object:[GUJNativeLocationManager sharedInstance]]
         ];   
    }
   
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{ 
#pragma unused(manager)    
    @autoreleasepool {
        _heading = [newHeading copy];
    }
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJDeviceHeadingChangedNotification object:[GUJNativeLocationManager sharedInstance]]
     ];      
}

#pragma mark public methods
+ (GUJNativeLocationManager*)sharedInstance
{
    if(!sharedInstance_) {
        sharedInstance_ = [[GUJNativeLocationManager alloc] init];
    }    
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
                _locationManagerDisabled = YES;
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

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJDeviceLocationChangedNotification selector:selector];
    
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJDeviceHeadingChangedNotification selector:selector];    
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJDeviceLocationChangedNotification];
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJDeviceHeadingChangedNotification];    
}

#pragma mark public methods
- (void)startUpdatingLocation
{
    if( !_locationManagerDisabled && locationAvailable_ ) {
        runOnce_ = NO;
        // register notification forwarding   
        [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceLocationChangedNotification object:nil];    
        [_locationManager startUpdatingLocation];
    }
}

- (void)startUpdatingLocationOnce
{
    if( !_locationManagerDisabled && locationAvailable_ ) {
        runOnce_ = YES;
        // register notification forwarding        
        [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceLocationChangedNotification object:nil];        
        [_locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation
{
    if( !_locationManagerDisabled && locationAvailable_ ) {
        runOnce_ = NO;
        [_locationManager stopUpdatingLocation]; 
        // unregister notification forwarding
        [[NSNotificationCenter defaultCenter] removeObserver:[GUJNotificationObserver sharedInstance] name:GUJDeviceLocationChangedNotification object:nil];        
    }
}

- (void)startUpdatingHeading
{
    if( !_locationManagerDisabled && headingAvailable_ ) {
        // heading changed notifications
        [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceHeadingChangedNotification object:nil];           
        [_locationManager startUpdatingHeading];
    }
}

- (void)stopUpdatingHeading
{
    if( !_locationManagerDisabled && headingAvailable_ ) {
        [_locationManager stopUpdatingHeading]; 
        // unregister notification forwarding
        [[NSNotificationCenter defaultCenter] removeObserver:[GUJNotificationObserver sharedInstance] name:GUJDeviceHeadingChangedNotification object:nil];            
    }
}

- (CLLocationDegrees)locationLatitude
{
    CLLocationDegrees result = 0.0;
    if( _location != nil ) {
        result = _location.coordinate.latitude;
    }  
    return result;
}

- (CLLocationDegrees)locationLongitude
{
    CLLocationDegrees result = 0.0;
    if( _location != nil ) {
        result = _location.coordinate.longitude;
    }  
    return result;  
}

- (CLLocationAccuracy)accuracy 
{
    CLLocationAccuracy result = 0.0;
    if( _locationManager != nil ) {
        result = [_locationManager desiredAccuracy];
    }
    return result;
}

- (NSString*)locationLatitudeStringRepresentation
{
    NSString *result = nil;
    if( _location != nil ) {
        result = [NSString stringWithFormat:kGUIJStringFormatForLocationDegrees,_location.coordinate.latitude];
    }
    return result;   
}

- (NSString*)locationLongitudeStringRepresentation
{
    NSString *result = nil;
    if( _location != nil ) {
        result = [NSString stringWithFormat:kGUIJStringFormatForLocationDegrees,_location.coordinate.longitude];
    }
    return result;
}

- (NSString*)accuracyStringRepresentation
{
    NSString *result = nil;
    if( _locationManager != nil ) {
        result = [NSString stringWithFormat:kGUIJStringFormatForLocationDegrees,[_locationManager desiredAccuracy]];
    }
    return result;
}

- (double)headingInDegrees
{
    double result = -1.0;
    if (_heading != nil ) {
        result = _heading.magneticHeading;
    }
    return result;
}

- (NSString*)headingInDegreesStringRepresentation
{
    return [NSString stringWithFormat:kGUIJStringFormatForHeadingDegrees,roundf([self headingInDegrees])];
}

- (CLAuthorizationStatus)authorizationStatus
{
    return authorizationStatus_;
}

- (NSError*)lastError
{
    return error_;
}

@end

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
#import <CoreLocation/CoreLocation.h>
#import "GUJNativeAPIInterface.h"


@interface GUJNativeLocationManager : GUJNativeAPIInterface <CLLocationManagerDelegate> {
  @protected
    CLAuthorizationStatus   authorizationStatus_;
}
@property (nonatomic, assign) BOOL                  locationManagerDisabled;
@property (nonatomic, assign) BOOL                  locationServiceAvailable;
@property (nonatomic, assign) BOOL                  headingServiceAvailable;
@property (nonatomic, assign) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, strong) CLLocation            *location;
@property (nonatomic, strong) CLHeading             *heading;

+ (GUJNativeLocationManager*)sharedInstance;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;

- (BOOL)hasLocation;
- (BOOL)hasHeading;

- (CLLocationDegrees)locationLatitude;
- (CLLocationDegrees)locationLongitude;
- (CLLocationAccuracy)accuracy;

- (NSString*)locationLatitudeStringRepresentation;
- (NSString*)locationLongitudeStringRepresentation;
- (NSString*)accuracyStringRepresentation;

- (double)headingInDegrees;
- (NSString*)headingInDegreesStringRepresentation;

- (CLAuthorizationStatus)authorizationStatus;


@end
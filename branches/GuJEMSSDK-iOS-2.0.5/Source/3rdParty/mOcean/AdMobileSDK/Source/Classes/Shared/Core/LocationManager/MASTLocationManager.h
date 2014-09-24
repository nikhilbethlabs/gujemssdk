//
//  MASTLocationManager.h
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Settings supplied in NSDictionary for the start notification.
// See CLLocation manager for more detail settings information
//
// NSString, can be nil, string presented to the user when iOS prompts for location authorization, defaults nil
extern NSString* kLocationManagerPurpose;
//
// NSNumber (boolean), also supply heading updates if available, defaults NO
extern NSString* kLocationManagerHeadingUpdates;
//
// NSNumber (boolean), use significant location service if available (better on battery), defaults YES
extern NSString* kLocationManagerSignificantUpdating;
//
// NSNumber (double), if not using significate location service, distance delta that triggers update, defaults 1000m
extern NSString* kLocationManagerDistanceFilter;
//
// NSNumber (double), if not using significant location service, location accuracy in meters, defaults kCLLocationAccuracyThreeKilometers
extern NSString* kLocationManagerDesiredAccuracy;
//
// NSNumber (double), if using heading updates, degrees delta that triggers update, defaults 45
extern NSString* kLocationManagerHeadingFilter;


@interface MASTLocationManager : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager*                  _locationManager;
	CLLocationCoordinate2D              _currentLocationCoordinate;
    
	CLLocation*                         _lastLocation;
	CLHeading*                          _lastHeading;
    
    BOOL                                _locationDetectionActive;
}

@property (readonly) CLLocation*                    lastLocation;
@property (readonly) CLHeading*                     lastHeading;

+ (MASTLocationManager*)sharedInstance;

+ (BOOL)deviceLocationAvailable;
+ (BOOL)deviceHeadingAvailable;

- (BOOL)locationDetectionActive;

@end

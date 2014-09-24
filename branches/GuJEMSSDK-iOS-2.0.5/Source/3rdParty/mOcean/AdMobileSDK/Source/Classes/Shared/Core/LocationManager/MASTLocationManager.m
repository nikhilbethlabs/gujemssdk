//
//  MASTLocationManager.m
//

#import "MASTLocationManager.h"
#import "MASTNotificationCenter.h"


NSString* kLocationManagerPurpose = @"kLocationManagerPurpose";
NSString* kLocationManagerHeadingUpdates = @"kLocationManagerHeadingUpdates";
NSString* kLocationManagerSignificantUpdating = @"kLocationManagerSignificantUpdating";
NSString* kLocationManagerDistanceFilter = @"kLocationManagerDistanceFilter";
NSString* kLocationManagerDesiredAccuracy = @"kLocationManagerDesiredAccuracy";
NSString* kLocationManagerHeadingFilter = @"kLocationManagerHeadingFilter";


@implementation MASTLocationManager

@synthesize lastLocation = _lastLocation;
@synthesize lastHeading = _lastHeading;


#pragma mark -
#pragma mark Singleton

static MASTLocationManager* sharedInstance = nil;
+ (id)sharedInstance {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [[self alloc] init];
		}
	}
	return sharedInstance;
}

#pragma mark -

- (id) init {
    self = [super init];
	if (self) {
        _locationDetectionActive = NO;
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(startLocationUpdate:) name:kLocationManagerStart object:nil];
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(stopLocationUpdate:) name:kLocationManagerStop object:nil];
	}
	return self;
}

- (void)dealloc {
    [_locationManager setDelegate:nil];
    [_locationManager stopUpdatingHeading];
    [_locationManager release];
    
    [_lastLocation release];
    [_lastLocation release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public

+ (BOOL)deviceLocationAvailable {
   
    if ([CLLocationManager respondsToSelector:@selector(authorizationStatus)]) {
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        if ((authStatus != kCLAuthorizationStatusNotDetermined) && (authStatus != kCLAuthorizationStatusAuthorized))    
            return NO;
    }
    
    if ([CLLocationManager locationServicesEnabled] == NO)
        return NO;
    
    return YES;
}

+ (BOOL)deviceHeadingAvailable {
    
    if ([CLLocationManager respondsToSelector:@selector(authorizationStatus)]) {
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        if ((authStatus != kCLAuthorizationStatusNotDetermined) && (authStatus != kCLAuthorizationStatusAuthorized))
            return NO;
    }
    
    if ([CLLocationManager headingAvailable] == NO)
        return NO;
    
    return YES;
}

- (BOOL)locationDetectionActive {
    return _locationDetectionActive;
}

- (void)startLocationUpdate:(NSNotification*)notification {
    @synchronized(self) {
        NSString* purpose = nil;
        BOOL headingUpdates = NO;
        BOOL significant = YES;
        CLLocationDistance distanceFilter = 1000;
        CLLocationAccuracy desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        CLLocationDegrees headingFilter = 45;
        
        if ((notification != nil) && [notification.object isKindOfClass:[NSDictionary class]]) {
            NSDictionary* settings = notification.object;
            
            id value = [settings valueForKey:kLocationManagerPurpose];
            if ([value isKindOfClass:[NSString class]])
                purpose = value;
            
            value = [settings valueForKey:kLocationManagerHeadingUpdates];
            if ([value isKindOfClass:[NSNumber class]])
                headingUpdates = [value boolValue];
            
            value = [settings valueForKey:kLocationManagerSignificantUpdating];
            if ([value isKindOfClass:[NSNumber class]])
                significant = [value boolValue];
            
            value = [settings valueForKey:kLocationManagerDistanceFilter];
            if ([value isKindOfClass:[NSNumber class]])
                distanceFilter = [value doubleValue];
            
            value = [settings valueForKey:kLocationManagerDesiredAccuracy];
            if ([value isKindOfClass:[NSNumber class]])
                desiredAccuracy = [value doubleValue];
            
            value = [settings valueForKey:kLocationManagerHeadingFilter];
            if ([value isKindOfClass:[NSNumber class]])
                headingFilter = [value doubleValue];
        }
        
        
        BOOL available = YES;
        if ([CLLocationManager respondsToSelector:@selector(authorizationStatus)]) {
            CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
            if ((authStatus != kCLAuthorizationStatusNotDetermined) && (authStatus != kCLAuthorizationStatusAuthorized))
                available = NO;
        }
        
        if (available && ([CLLocationManager locationServicesEnabled] == NO))
            available = NO;
        
        if (available == NO) {
            if (_locationManager != nil) {
                _locationManager.delegate = nil;
                [_locationManager stopUpdatingLocation];
                [_locationManager release];
                _locationManager = nil;
                
                [_lastLocation release];
                _lastLocation = nil;
                
                [_lastHeading release];
                _lastHeading = nil;
            }
        }
        
        [_locationManager stopUpdatingLocation];
        
        if (_locationManager == nil) {
            _locationManager = [CLLocationManager new];
            _locationManager.delegate = self;
            
        }
        
        if ((_locationDetectionActive == NO) && (purpose != nil))
            _locationManager.purpose = purpose;
        
        _locationManager.distanceFilter = distanceFilter;
        _locationManager.desiredAccuracy = desiredAccuracy;
        _locationManager.headingFilter = headingFilter;
        
        if (significant && [CLLocationManager significantLocationChangeMonitoringAvailable])
            [_locationManager startMonitoringSignificantLocationChanges];
        else
            [_locationManager startUpdatingLocation];
        
        if (headingUpdates && [CLLocationManager headingAvailable])
            [_locationManager startUpdatingHeading];
        
        _locationDetectionActive = YES;
    }
}

- (void)stopLocationUpdate:(NSNotification*)notification {
    @synchronized(self) {
        _locationDetectionActive = NO;
        [_locationManager stopUpdatingLocation];
        [_locationManager stopMonitoringSignificantLocationChanges];
        [_locationManager stopUpdatingHeading];
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[MASTNotificationCenter sharedInstance] postNotificationName:kLocationManagerError object:error];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation {
    if (_lastLocation != nil) {
        [_lastLocation release];
    }
    
    _lastLocation = [newLocation retain];
    
	[[MASTNotificationCenter sharedInstance] postNotificationName:kLocationManagerLocationUpdate object:_lastLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (_lastHeading != nil) {
        [_lastHeading release];
    }
    
    _lastHeading = [newHeading retain];
    
    [[MASTNotificationCenter sharedInstance] postNotificationName:kLocationManagerHeadingUpdate object:_lastHeading];
}

@end
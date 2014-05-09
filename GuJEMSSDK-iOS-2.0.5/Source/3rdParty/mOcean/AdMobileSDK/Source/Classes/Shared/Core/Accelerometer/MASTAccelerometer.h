//
//  MASTAccelerometer.h
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "OrmmaProtocols.h"


@interface MASTAccelerometer : NSObject

+ (MASTAccelerometer*)sharedInstance;
+ (CMMotionManager *)sharedMotionManagerInstance;
+ (void)stopMotionManagerUpdates;

- (void)registerMASTNotificationDeviceMotion;

@end
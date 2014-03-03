//
//  NotificationCenter.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import <Foundation/Foundation.h>

#import "MASTNotificationAtlas.h"
#import "MASTNotificationCenterAdditions.h"


@interface MASTNotificationCenter : NSNotificationCenter {

}

+ (MASTNotificationCenter*)sharedInstance;
+ (void)releaseSharedInstance;

@end

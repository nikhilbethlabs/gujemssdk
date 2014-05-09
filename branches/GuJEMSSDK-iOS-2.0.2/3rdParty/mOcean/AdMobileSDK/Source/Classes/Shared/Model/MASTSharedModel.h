//
//  SharedModel.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/1/11.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "MASTAdView.h"

#import "MASTAdView.h"
#import "MASTConstants.h"
#import "MASTReachability.h"

#import "MASTLocationManager.h"
#import "MASTWebKitInfo.h"
#import "MASTLocationManager.h"
#import "MASTUtils.h"


@interface MASTSharedModel : NSObject {

}

@property (retain) NSString*                ua;
@property (retain) NSString*                latitude;
@property (retain) NSString*                longitude;
@property (retain) NSString*                accuracy;
@property (retain) NSString*                mcc;
@property (retain) NSString*                mnc;

+ (MASTSharedModel*)sharedInstance;
+ (void)releaseSharedInstance;

- (NSString*)sharedUrlPart;

@end

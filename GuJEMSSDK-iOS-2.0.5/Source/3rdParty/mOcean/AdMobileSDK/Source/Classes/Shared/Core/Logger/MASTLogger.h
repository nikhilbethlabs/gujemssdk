//
//  Logger.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 8/19/10.
//

#import <Foundation/Foundation.h>

#import "MASTLogBasicFormatter.h"
#import "MASTNotificationCenter.h"
#import "MASTAdView.h"
#import "MASTAdView_Private.h"

@interface MASTLogger : NSObject {
    NSMutableDictionary*    _ads;
    NSMutableArray*         _allLogAds;
}

+ (MASTLogger*)sharedInstance;
+ (void)releaseSharedInstance;

@end

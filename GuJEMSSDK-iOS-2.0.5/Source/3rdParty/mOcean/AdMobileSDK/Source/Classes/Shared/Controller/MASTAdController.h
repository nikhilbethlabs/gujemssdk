//
//  AdController.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/24/11.
//

#import <Foundation/Foundation.h>


#import "MASTNotificationCenter.h"
#import "MASTAdView_Private.h"
#import "MASTAdDescriptor.h"
#import "MASTAdView.h"
#import "MASTAdModel.h"
#import "MASTAdUpdater.h"
#import "MASTLocationManager.h"


@interface MASTAdController : NSObject <UIWebViewDelegate>{
	NSMutableArray*		_ads;
	NSMutableArray*		_adUpdateControllers;
	
    MASTAdView*             _adView;
    
    BOOL                _isRequestRedirect;
    NSString*           _FirstRequestString;
    
}

+ (MASTAdController*)sharedInstance;
+ (void)releaseSharedInstance;

@end

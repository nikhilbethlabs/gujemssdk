//
//  AdUpdater.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/9/11.
//

#import <Foundation/Foundation.h>
#import "MASTAdView_Private.h"
#import "MASTAdView.h"
#import "MASTAdModel.h"

@interface MASTAdUpdater : NSObject {
	BOOL			_updateStarted;
    BOOL            _viewVisible;
	MASTAdView*			_adView;
    BOOL            _valid;
}

- (void)invalidate;

@property (assign) MASTAdView* adView;
@property (retain) NSTimer* updateTimer;
@property (assign) NSTimeInterval updateTimeInterval;

@end

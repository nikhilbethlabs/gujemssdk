//
//  ExpandViewController.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 12/16/11.
//

#import <UIKit/UIKit.h>

#import "MASTAdView.h"

@interface MASTExpandViewController : UIViewController

@property (nonatomic, retain) MASTAdView* adView;
@property (nonatomic, retain) UIView* expandView;

@property (assign) BOOL lockOrientation;
@property (retain) UIButton* closeButton;

- (void)useCustomClose:(BOOL)use;
- (id)initWithLockOrientation:(BOOL)_lockOrientation;

@end

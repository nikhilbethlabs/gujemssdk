//
//  TouchableViewController.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 7/30/10.
//

#import <UIKit/UIKit.h>

@protocol TouchableViewDelegate <NSObject>
@required
- (void) viewDidTouched;
@end

@interface MASTTouchableViewController : UIViewController {
	id <TouchableViewDelegate>	_delegate;
}

@property (nonatomic, assign) id <TouchableViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

@end


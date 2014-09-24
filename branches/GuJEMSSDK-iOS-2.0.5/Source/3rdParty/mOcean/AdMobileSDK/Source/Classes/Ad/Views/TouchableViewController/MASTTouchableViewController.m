//
//  TouchableViewController.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 7/30/10.
//

#import "MASTTouchableViewController.h"

@implementation MASTTouchableViewController

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
		UIView* _tmpView = [[UIView alloc] initWithFrame:frame];
		[_tmpView setBackgroundColor:[UIColor clearColor]];
        [self setView:_tmpView];
		[_tmpView release];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_delegate && [_delegate respondsToSelector:@selector(viewDidTouched)]) {
		[_delegate viewDidTouched];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [super dealloc];
}


@end
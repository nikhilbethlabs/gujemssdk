//
//  ExpandViewController.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 12/16/11.
//

#import "MASTExpandViewController.h"
#import "MASTUtils.h"
#import "MASTExpandView.h"
#import "MASTConstants.h"

@implementation MASTExpandViewController

@synthesize adView, expandView, lockOrientation, closeButton;


#pragma mark - View lifecycle

- (id)init {
    self = [super init];
    if (self) {
        lockOrientation = NO;
    }
    return self;
}

- (id)initWithLockOrientation:(BOOL)_lockOrientation {
    self = [super init];
    if (self) {
        lockOrientation = _lockOrientation;
    }
    return self;
}

- (void)dealloc {
    self.closeButton = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    if (!lockOrientation) {
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return !lockOrientation || interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)buttonsAction:(id)sender {
    if ([self.expandView isKindOfClass:[MASTExpandView class]]) {
        [(MASTExpandView*)self.expandView close];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCloseExpandNotification" object:self.expandView];
        self.closeButton.hidden = YES;
        [self.closeButton removeFromSuperview];
        self.closeButton = nil;
    }
}

- (void)useCustomClose:(BOOL)use {
    if (!self.closeButton) {
        
        // ORMMA guaranteed close area
        UIButton* invisButton = [UIButton buttonWithType:UIButtonTypeCustom];
        invisButton.frame = CGRectMake(self.view.frame.size.width - ORMMA_SQARE_CLOSE_SIZE, 0,
                                       ORMMA_SQARE_CLOSE_SIZE, ORMMA_SQARE_CLOSE_SIZE);
        invisButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [invisButton addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:invisButton];
        
        
        UIImage* closeImage = [MASTUtils closeImage];
        if (closeImage) {            
            self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.closeButton.frame = CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
            [self.closeButton setImage:closeImage forState:UIControlStateNormal];
            [self.closeButton addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
            self.closeButton.frame = CGRectMake(self.view.frame.size.width - self.closeButton.frame.size.width - 11, 11, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
            self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            [self.view addSubview:self.closeButton];
        }
    }
    
    self.closeButton.hidden = use;
}

@end

//
//  ExpandWebView.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import <UIKit/UIKit.h>

@interface MASTExpandWebView : UIView <UIWebViewDelegate> {
    CGRect                      _defaultFrame;
}

@property (assign) UIView*  adView;
@property (retain) UIButton* closeButton;

- (void)loadUrl:(NSString*)url;
- (void)close;

@end
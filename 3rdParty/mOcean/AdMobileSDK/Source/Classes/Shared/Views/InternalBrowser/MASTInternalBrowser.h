//
//  InternalBrowser.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import <UIKit/UIKit.h>

#import "MASTAdView.h"
#import "MASTConstants.h"
#import "QSStrings.h"


@interface MASTInternalBrowser : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	CGRect							_origFrame;
	UIWebView*						_webView;
    UILabel*                        _titleLabel;
    
    UIToolbar*                      _navbar;
    UIToolbar*                      _toolbar;
    
    UIBarButtonItem*                _backButton;
    UIBarButtonItem*                _forwardButton;
    UIBarButtonItem*                _refreshButton;
    UIBarButtonItem*                _stopButton;
    UIBarButtonItem*                _actionButton;
    UIBarButtonItem*                _activityItem;
    UIActionSheet*                  _actionSheet;
    
	BOOL							_opening;
    UIViewController*               _viewConreoller;
	UIDevice*						_device;
    
    UIImage*                        _backIcon;
    UIImage*                        _forwardIcon;
}

@property (assign) UIViewController*    viewConreoller;
@property (assign) MASTAdView*              sendAdView;
@property (retain) NSURL*               URL;
@property (retain) NSURL*               loadingURL;

+ (MASTInternalBrowser*)sharedInstance;
+ (void)releaseSharedInstance;
- (void)close;

@end

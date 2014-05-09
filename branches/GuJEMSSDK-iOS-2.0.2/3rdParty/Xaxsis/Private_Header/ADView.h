
#import <UIKit/UIKit.h>
#import "ADJavaScriptBridge.h"

@class ADView, ADJavaScriptBridge;

@protocol ADViewDelegate <NSObject>

- (void)adView:(ADView*)adView consoleOutput:(NSString*)output;

@end



@interface ADView : UIView<UIWebViewDelegate> {
    UIWebView   *_webView;
    ADJavaScriptBridge  *_bridge;
    id<ADViewDelegate> _delegate;
    NSTimer             *_timeoutTimer;
}

@property (nonatomic, retain) id<ADViewDelegate> delegate;
@property (nonatomic, retain) UIWebView     *webView;

- (void)loadCreativeURL:(NSURL*)creativeURL;
- (void)cancelAd;
- (void)_cancelTimeout;

@end

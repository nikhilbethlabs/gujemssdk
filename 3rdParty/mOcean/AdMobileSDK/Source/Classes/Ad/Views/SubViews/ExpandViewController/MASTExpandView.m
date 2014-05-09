//
//  MASTExpandView.m
//

#import "MASTExpandView.h"

#import "MASTUIWebViewAdditions.h"

@interface MASTExpandView()
@property (nonatomic, retain) UIWebView*        webView;
@end

@implementation MASTExpandView

@synthesize adView, webView;


- (void)buttonsAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCloseExpandNotification" object:self.adView];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (frame.size.width == 0.0 && frame.size.height == 0.0) {
            frame = CGRectMake(frame.origin.x, frame.origin.y, 0, 1);
        }
        UIWebView* wView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		wView.delegate = self;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        wView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		//[wView disableBouncesForWebView];
		
        wView.allowsInlineMediaPlayback = YES;
        wView.mediaPlaybackRequiresUserAction = NO;
        wView.opaque = NO;
        wView.backgroundColor = [UIColor clearColor];
        
        self.webView = wView;
        [wView release];

		[self addSubview:self.webView];

        _defaultFrame = self.frame;
    }
    return self;
}

- (void)close {
    [self buttonsAction:self];
}

- (void)dealloc {
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
    
    self.adView = nil;
	self.webView = nil;
    
    [super dealloc];
}

- (void)loadUrl:(NSString *)url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

#pragma mark - UIWebViewDelegate


- (void)webViewDidFinishLoad:(UIWebView *)view {    
    if (adView) {
        /*
        NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
        [senfInfo setObject:self.superview forKey:@"adView"];
        [senfInfo setObject:self forKey:@"subView"];
        [[NotificationCenter sharedInstance] postNotificationName:kReadyAdDisplayNotification object:senfInfo];
         */
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (adView) {
        [self buttonsAction:self];
    }
}

- (BOOL)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    }
    return YES;
}

@end
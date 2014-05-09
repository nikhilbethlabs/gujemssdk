//
//  MASTAdWebView.m
//

#import "MASTAdWebView.h"

#import "MASTOrmmaAdaptor.h"
#import "MASTOrmmaConstants.h"
#import "MASTUIWebViewAdditions.h"
#import "MASTWebkitInfo.h"

@interface MASTAdWebView()

@property (nonatomic, retain) UIWebView*        webView;
@property (nonatomic, retain) MASTOrmmaAdaptor*  ormmaAdaptor;
@property (nonatomic, copy) CompletionBlock     completion;

@end

@implementation MASTAdWebView

@synthesize adView, ormmaDelegate, ormmaDataSource;
@synthesize webView, ormmaAdaptor, completion;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (frame.size.width == 0.0 && frame.size.height == 0.0) {
            frame = CGRectMake(frame.origin.x, frame.origin.y, 0, 1);
        }
        UIWebView* wView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        self.webView = wView;
		self.webView.delegate = self;
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.webView disableBouncesForWebView];
		
        self.webView.allowsInlineMediaPlayback = YES;
        self.webView.mediaPlaybackRequiresUserAction = NO;
        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor clearColor];
        
		[self addSubview:self.webView];
        
        _defaultFrame = self.frame;
    }
    return self;
}

- (void)dealloc {
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
    
    [self.ormmaAdaptor invalidate];
    
    self.adView = nil;
    self.ormmaDelegate = nil;
    self.ormmaDataSource = nil;
	self.webView = nil;
    self.ormmaAdaptor = nil;
    self.completion = nil;
    
    [super dealloc];
}

- (void)loadHTML:(NSString*)html completion:(CompletionBlock)block injectionHeaderCode:(NSString*)injectionHeader {
    self.completion = block;
    self.ormmaAdaptor = [[[MASTOrmmaAdaptor alloc] initWithWebView:self.webView adView:self.adView] autorelease];
    self.ormmaAdaptor.ormmaDelegate = self.ormmaDelegate;
    self.ormmaAdaptor.ormmaDataSource = self.ormmaDataSource;
    
    CGSize sz = self.bounds.size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    NSString* injectionWidth = [NSString stringWithFormat:@"%@", [[NSNumber numberWithFloat:sz.width * scale] description]];
    NSString* injectionScale = @"1.0";
    if ([[UIScreen mainScreen] scale] > 1)
        injectionScale = @"0.5";
    
    // Default viewport
    /*
     * @somo 06.03.13
     * This viewport results a problem on retina devices.
     * We've removed the initial-scale=%@; minimum-scale=%@; to fix it.
     * @sven
     */
    //NSString* injectionHeaderCode = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=%@; initial-scale=%@; minimum-scale=%@; user-scalable=0;\"/>", injectionWidth, injectionScale, injectionScale];

     NSString* injectionHeaderCode = [NSString stringWithFormat:@"<meta name='viewport' content='user-scalable=no initial-scale=1.0' />", injectionWidth, injectionScale, injectionScale];
    
    
    // Default body style to center content.
    injectionHeaderCode = [injectionHeaderCode stringByAppendingString:@"<style>body{margin:0;padding:0;display:-webkit-box;-webkit-box-orient:horizontal;-webkit-box-pack:center;-webkit-box-align:center;}</style>"];
    
    if ([injectionHeader length] > 0)
        injectionHeaderCode = injectionHeader;
    
    html = [NSString stringWithFormat:@"<html><head>%@<script type=\"text/javascript\">%@</script><script type=\"text/javascript\">%@</script></head><body>%@</body></html>", injectionHeaderCode, ORMMA_JS, [self.ormmaAdaptor getDefaultsJSCode], html];
    
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)reset {
    if ([self.ormmaAdaptor isDefaultState] == NO)
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:(@"about:blank")]]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)view {
    [self.ormmaAdaptor webViewDidFinishLoad:view];
    if (self.completion) {
        self.completion(nil);
        self.completion = nil;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.completion) {
        self.completion(error);
        self.completion = nil;
    }
}

- (BOOL)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.ormmaAdaptor isOrmma:request]) {
        [self.ormmaAdaptor webView:view shouldStartLoadWithRequest:request navigationType:navigationType];
        return NO;
    } else {
        if (navigationType == UIWebViewNavigationTypeLinkClicked) {
            if (adView) {
                NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:request, adView, nil]
                                                                               forKeys:[NSArray arrayWithObjects:@"request", @"adView", nil]];
                
                [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenURLNotification object:info];
            }
            
            return NO;
        }
        else if (navigationType == UIWebViewNavigationTypeOther) {
            return YES;
        }
    }
    
	return NO;
}

@end
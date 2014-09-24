//
//  AdWebView.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import "MASTAdWebView.h"
#import "MASTAdInterstitialView.h"

#import "MASTNotificationCenter.h"
#import "MASTOrmmaAdaptor.h"
#import "MASTOrmmaConstants.h"
#import "MASTUIWebViewAdditions.h"

@interface MASTAdWebView()
@property (nonatomic, retain) UIWebView*        webView;
@property (nonatomic, retain) MASTOrmmaAdaptor*     ormmaAdaptor;
@end

@implementation MASTAdWebView

@synthesize adView, webView, ormmaAdaptor;

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
		[wView disableBouncesForWebView];
		
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

- (void)dealloc {
    self.adView = nil;
    self.webView.delegate = nil;
	self.webView = nil;
    self.ormmaAdaptor = nil;
    
    [super dealloc];
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)encodingName baseURL:(NSURL *)baseURL {
    NSString* html = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    if([[html lowercaseString] rangeOfString:[@"ormma" lowercaseString]].location != NSNotFound ||
       [[html lowercaseString] rangeOfString:[@"mraid" lowercaseString]].location != NSNotFound) {
        // replce ormma placeholder
        self.ormmaAdaptor = [[[MASTOrmmaAdaptor alloc] initWithWebView:self.webView adView:(MASTAdView*)self.superview] autorelease];
        self.ormmaAdaptor.interstitial = [self.adView isKindOfClass:[MASTAdView class]];
        
        NSString* js = [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>", [self.ormmaAdaptor getDefaultsJSCode]];
        
        html = [html stringByReplacingOccurrencesOfString:ORMMA_PLACEHOLDER withString:js];
    }
    
    [self.webView loadData:[html dataUsingEncoding:NSUTF8StringEncoding] MIMEType:MIMEType textEncodingName:encodingName baseURL:baseURL];
}

- (void)closeOrmma {
    if (self.ormmaAdaptor) {
        [self.ormmaAdaptor moveToDefaultState];
    }
}

#pragma mark - UIWebViewDelegate


- (void)webViewDidFinishLoad:(UIWebView *)view {
    [self.ormmaAdaptor webViewDidFinishLoad:view];
    
    if (self.superview) {
        NSString* contentWidth = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('contentwidth').offsetWidth"];
        NSString* contentHeight = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('contentheight').offsetHeight"];
        
        NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
        [senfInfo setObject:self.superview forKey:@"adView"];
        [senfInfo setObject:self forKey:@"subView"];
        [senfInfo setObject:contentWidth forKey:@"contentWidth"];
        [senfInfo setObject:contentHeight forKey:@"contentHeight"];
        [[MASTNotificationCenter sharedInstance] postNotificationName:kReadyAdDisplayNotification object:senfInfo];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (adView) {
        NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
        [senfInfo setObject:adView forKey:@"adView"];
        [senfInfo setObject:self forKey:@"subView"];
        [[MASTNotificationCenter sharedInstance] postNotificationName:kFailAdDisplayNotification object:senfInfo];
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
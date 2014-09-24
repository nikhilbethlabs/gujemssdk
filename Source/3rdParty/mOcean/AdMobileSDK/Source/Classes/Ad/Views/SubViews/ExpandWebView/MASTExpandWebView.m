//
//  AdWebView.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import "MASTExpandWebView.h"

#import "MASTNotificationCenter.h"
#import "MASTUIWebViewAdditions.h"
#import "MASTConstants.h"
#import "QSStrings.h"

@interface MASTExpandWebView()
@property (nonatomic, retain) UIWebView*        webView;
@end

@implementation MASTExpandWebView

@synthesize adView, webView, closeButton;

- (BOOL)saveToMojivaFolderData:(NSData*)data name:(NSString*)name {
    BOOL result = NO;
    NSString* dirPath = [NSHomeDirectory() stringByAppendingPathComponent:kPathForFolderCache];
    NSString* fileName = name;
    NSString* path = [dirPath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if ([data writeToFile:path atomically:YES]) {
            result = YES;
        }
    }
    else {
        result = YES;
    }
    return result;
}

- (void)buttonsAction:(id)sender {    
    NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
    [senfInfo setObject:self.adView forKey:@"adView"];
    [[MASTNotificationCenter sharedInstance] postNotificationName:kCloseExpandNotification object:senfInfo];
    [self removeFromSuperview];
}

- (void)prepareResources {
    NSString* dirPath = [NSHomeDirectory() stringByAppendingPathComponent:kPathForFolderCache];
    
    NSString* path = [dirPath stringByAppendingPathComponent:@"closeIcon.png"];
    UIImage* closeIcon = nil;
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        NSData* imageData = [QSStrings decodeBase64WithString:kCloseIconB64];
        NSData* imageData2x = [QSStrings decodeBase64WithString:kCloseIcon2xB64];
        if ([self saveToMojivaFolderData:imageData name:@"closeIcon.png"] &&
            [self saveToMojivaFolderData:imageData2x name:@"closeIcon@2x.png"]) {
            closeIcon = [UIImage imageWithContentsOfFile:path];
        }
    } else {
        closeIcon = [UIImage imageWithContentsOfFile:path];
    }
    
    if (closeIcon) {
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.frame = CGRectMake(0, 0, closeIcon.size.width, closeIcon.size.height);
        [self.closeButton setImage:closeIcon forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
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
        
        [self prepareResources];
        if (self.closeButton) {
            self.closeButton.frame = CGRectMake(self.frame.size.width - self.closeButton.frame.size.width - 11, 11, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
            self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:self.closeButton];
        }

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
    self.closeButton = nil;
    
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
        if (adView) {
            NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:request, adView, nil]
                                                                           forKeys:[NSArray arrayWithObjects:@"request", @"adView", nil]];
            
            [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenURLNotification object:info];
        }
        
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    }
    return YES;
}

@end
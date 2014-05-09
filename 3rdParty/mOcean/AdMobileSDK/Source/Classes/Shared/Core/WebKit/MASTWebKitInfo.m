//
//  WebKitInfo.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/24/11.
//

#import "MASTWebKitInfo.h"
#import "MASTConstants.h"

@implementation MASTWebKitInfo

@synthesize ua;


static MASTWebKitInfo* sharedInstance = nil;


#pragma mark -
#pragma mark Singleton


- (id) init {
    self = [super init];
    
	if (self) {
        _webView = [UIWebView new];
		[_webView setDelegate:self];
		[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kGoogleUrl]]];
        
        NSString* uaString = [_webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        if (uaString  && [uaString length] > 0) {
            self.ua = uaString;
            [[MASTNotificationCenter sharedInstance] postNotificationName:kUaDetectedNotification object:uaString];
        }
        else {
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kGoogleUrl]]];
        }
	}
	
	return self;
}

+ (id)sharedInstance {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [[self alloc] init];
		}
	}
	return sharedInstance;
}

- (oneway void)superRelease {
    [_webView release];
	[super release];
}

+ (void)releaseSharedInstance {
	@synchronized(self) {
		[sharedInstance superRelease];
		sharedInstance = nil;
	}
}

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [super allocWithZone:zone];
		}
	}
	
	return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
	return sharedInstance;
}

- (id)retain {
	return sharedInstance;
}

- (unsigned)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	// Do nothing.
}

- (id)autorelease {
	return sharedInstance;
}


#pragma mark -
#pragma mark Public
+ (NSString*)userAgent {
    return sharedInstance.ua;
}

//


#pragma mark -
#pragma mark Private


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString* uaString = [request valueForHTTPHeaderField:@"User-Agent"];
    self.ua = uaString;
    [[MASTNotificationCenter sharedInstance] postNotificationName:kUaDetectedNotification object:uaString];
	
	return NO;
}


@end

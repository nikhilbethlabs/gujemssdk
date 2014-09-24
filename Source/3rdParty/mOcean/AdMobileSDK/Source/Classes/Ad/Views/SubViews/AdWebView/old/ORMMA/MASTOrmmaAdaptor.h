//
//  OrmmaAdaptor.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 8/23/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <EventKit/EventKit.h>

#ifdef INCLUDE_LOCATION_MANAGER
#import <CoreLocation/CoreLocation.h>
#endif

#import "MASTAdView.h"
#import "MASTNotificationCenter.h"
#import "UIAlertView+Blocks.h"

typedef enum ORMMAStateEnum {
	ORMMAStateHidden = -1,
	ORMMAStateDefault = 0,
	ORMMAStateResized,
	ORMMAStateExpanded
} ORMMAState;

@interface MASTOrmmaAdaptor : NSObject <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

- (id)initWithWebView:(UIWebView*)webView adView:(MASTAdView*)ad;

- (NSString*)getDefaultsJSCode;
- (void)moveToDefaultState;

- (BOOL)isOrmma:(NSURLRequest *)request; 
- (void)webViewDidFinishLoad:(UIWebView*)webView;
- (void)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@property (assign) BOOL     interstitial;

@end

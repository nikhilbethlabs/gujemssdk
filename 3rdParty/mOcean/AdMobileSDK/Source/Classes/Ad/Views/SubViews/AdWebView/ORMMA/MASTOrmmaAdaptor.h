//
//  MASTOrmmaAdaptor.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OrmmaProtocols.h"

@interface MASTOrmmaAdaptor : NSObject

@property (nonatomic, assign) id <OrmmaDelegate>        ormmaDelegate;
@property (nonatomic, assign) id <OrmmaDataSource>      ormmaDataSource;

- (id)initWithWebView:(UIWebView*)webView adView:(UIView*)ad;

- (NSString*)getDefaultsJSCode;
- (void)invalidate;
- (void)moveToDefaultState;

- (BOOL)isOrmma:(NSURLRequest *)request; 
- (void)webViewDidFinishLoad:(UIWebView*)webView;
- (void)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

- (BOOL)isDefaultState;

@end

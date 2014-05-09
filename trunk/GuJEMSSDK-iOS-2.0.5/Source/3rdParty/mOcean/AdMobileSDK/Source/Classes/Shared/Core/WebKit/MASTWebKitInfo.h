//
//  WebKitInfo.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/24/11.
//

#import <Foundation/Foundation.h>

#import "MASTNotificationCenter.h"


@interface MASTWebKitInfo : NSObject <UIWebViewDelegate> {
    UIWebView*          _webView;
}

@property (retain) NSString*        ua;

+ (MASTWebKitInfo*)sharedInstance;
+ (void)releaseSharedInstance;
+ (NSString*)userAgent;

@end

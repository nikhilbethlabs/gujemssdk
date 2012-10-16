/*
 * BSD LICENSE
 * Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer .
 * Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The source code is just allowed for private use, not for commercial use.
 * 
 */
#import "ORMMAResourceBundleManager.h"

/*!
 * implement to receive ORMMAWebBrowser display states and error messages.
 */ 
@protocol ORMMAWebBrowserDelegate<NSObject>

- (void) webBrowserWillShow;
- (void) webBrowserWillHide;
@optional
- (void)webBrowserFaildStartLoadWithRequest:(NSURLRequest*)error;

@end

/*!
 * Internal UIWebBrowser.
 * Should appear modal. 
 * Can forward the current URL to the native device WebBrowser.
 */
@interface ORMMAWebBrowser : UIViewController<UIWebViewDelegate> {
  @private
    id<ORMMAWebBrowserDelegate> delegate_;
    ORMMAResourceBundleManager  *ormmaResources_;
    UIActivityIndicatorView     *progressIndicator_;
    UIView                      *webViewContainer_;
    UIWebView                   *webView_;
    UIToolbar                   *navigationBar_;
    NSMutableArray              *navigationBarItems_;
@protected
    BOOL        defaultStatusBarState_;    
}

+ (ORMMAWebBrowser*)sharedInstance;
- (void)setDelegate:(id<ORMMAWebBrowserDelegate>)delegate;
- (void)navigateToURL:(NSURLRequest*)urlRequest;
- (void)freeInstance;

@end

/*!
 * Handles internal browser events and userinteractions.
 * Creates the user interface.
 */
@interface ORMMAWebBrowser(PrivateImplementation)
- (void)navigateBack:(id)sender;
- (void)navigateForward:(id)sender;
- (void)refresh:(id)sender;
- (void)openExternal:(id)sender;
- (void)close:(id)sender;
- (UIBarButtonItem*)__createControllButton:(NSString*)image target:(id)target action:(SEL)selector;
- (UIBarButtonItem*)__createFlexibleSpace;
- (void)__createUI;
@end

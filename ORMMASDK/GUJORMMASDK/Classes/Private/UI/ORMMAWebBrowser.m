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
#import "ORMMAWebBrowser.h"

@implementation ORMMAWebBrowser(PrivateImplementation)

#pragma mark private methods
- (void)navigateBack:(id)sender
{
    [webView_ goBack];
}

- (void)navigateForward:(id)sender
{
    [webView_ goForward];
}

- (void)refresh:(id)sender
{
    [webView_ reload];
}

- (void)openExternal:(id)sender
{     
    [[UIApplication sharedApplication] openURL:webView_.request.URL];
}

- (void)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (UIBarButtonItem*)__createControllButton:(NSString*)image target:(id)target action:(SEL)selector
{
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithImage:[ormmaResources_ loadImageResource:image] style:UIBarButtonItemStylePlain target:target action:selector];
    
    return result;   
}

- (UIBarButtonItem*)__createFlexibleSpace
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (void)__createUI
{
    @autoreleasepool {        
        ormmaResources_    = [ORMMAResourceBundleManager instanceForBundle:kORMMAResourceBundleName];
        progressIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        webViewContainer_  = [[UIView alloc] initWithFrame:[GUJUtil frameOfFirstResponder]];
        [webViewContainer_ setBackgroundColor:[UIColor greenColor]];
        
        // ensure that we are in portrait
        if( webViewContainer_.frame.size.width > webViewContainer_.frame.size.height ) {
            CGRect frame         = webViewContainer_.frame;
            float stausBarOffset = 0.0f;
            if( ![[UIApplication sharedApplication] isStatusBarHidden] ) {
                stausBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
            }
            frame.size.width    = webViewContainer_.frame.size.height+stausBarOffset;
            frame.size.height   = webViewContainer_.frame.size.width-stausBarOffset;
            [webViewContainer_ setFrame:frame];
            _logd_frame(self, webViewContainer_.frame);
        } else {
            CGRect frame         = webViewContainer_.frame;
            float stausBarOffset = 0.0f;
            if( ![[UIApplication sharedApplication] isStatusBarHidden] ) {
                stausBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
            }
            frame.size.height    = webViewContainer_.frame.size.height-stausBarOffset;
            [webViewContainer_ setFrame:frame];
            _logd_frame(self, webViewContainer_.frame);            
        }
        
        // create the navigation bar
        navigationBar_          = [[UIToolbar alloc] init];
        [navigationBar_ setBarStyle:UIBarStyleDefault];        
        // create navigation bar items
        navigationBarItems_= [[NSMutableArray alloc] init];        
        [navigationBarItems_ addObject:[self __createControllButton:kORMMAResourceNameForBackImage target:self action:@selector(navigateBack:)]];
        [navigationBarItems_ addObject:[self __createFlexibleSpace]];
        [navigationBarItems_ addObject:[self __createControllButton:kORMMAResourceNameForForwardImage target:self action:@selector(navigateForward:)]];
        [navigationBarItems_ addObject:[self __createFlexibleSpace]];
        [navigationBarItems_ addObject:[self __createControllButton:kORMMAResourceNameForRefreshImage target:self action:@selector(refresh:)]];
        [navigationBarItems_ addObject:[self __createFlexibleSpace]];     
        [navigationBarItems_ addObject:[self __createControllButton:kORMMAResourceNameForOpenBrowserImage target:self action:@selector(openExternal:)]];
        [navigationBarItems_ addObject:[self __createFlexibleSpace]];
        [navigationBarItems_ addObject:[self __createControllButton:kORMMAResourceNameForCloseImage target:self action:@selector(close:)]];
        [navigationBar_ setItems:navigationBarItems_];      
        
        // size the navigation bar
        [navigationBar_ sizeToFit];
        CGRect navBarFrame      = navigationBar_.frame;
        navBarFrame.size.width  = webViewContainer_.frame.size.width;
        navBarFrame.size.height = 45.0f;
        navBarFrame.origin.y    = webViewContainer_.frame.size.height-navBarFrame.size.height;        
        [navigationBar_ setFrame:navBarFrame];
        
        // size the webview
        CGRect webViewFrame = webViewContainer_.frame;
        webViewFrame.size.height = (webViewFrame.size.height-navBarFrame.size.height);
        webView_ = [[UIWebView alloc] initWithFrame:webViewFrame];
        progressIndicator_.center = webView_.center;
    }    
    [webView_ setDelegate:self];    
    [webViewContainer_ addSubview:webView_];
    [webViewContainer_ addSubview: navigationBar_];    
    [webViewContainer_ addSubview:progressIndicator_];
    self.view = webViewContainer_;
}

@end

@implementation ORMMAWebBrowser

static ORMMAWebBrowser *sharedInstance_;

#pragma mark public methods
+ (ORMMAWebBrowser*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[super alloc] init];
    }
    @synchronized(sharedInstance_) {        
        return sharedInstance_;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {              
        [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:NO];
        [self __createUI];
    }
    return self;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
    }
    if( webView_ != nil ) {
        [webView_ stopLoading];
        webView_.delegate = nil;
    }    
    webView_ = nil;
    sharedInstance_ = nil;
}

- (void)setDelegate:(id<ORMMAWebBrowserDelegate>)delegate
{
    delegate_ = delegate;
}

- (void)navigateToURL:(NSURLRequest*)urlRequest
{
    @autoreleasepool {
        [webView_ loadRequest:[NSURLRequest requestWithURL:[urlRequest URL]]];        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(webBrowserWillShow)] ) {
        [delegate_ webBrowserWillShow];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(webBrowserWillHide)] ) {
        [delegate_ webBrowserWillHide];
    }    
}

- (void)dismiss
{    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark web view delegate methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL result = YES;
    if( ![[[[request URL] description] lowercaseString] hasPrefix:kGUJHTTPProtocolIdentifier] && 
        ![[[[request URL] description] lowercaseString] hasPrefix:kGUJWebViewAboutBlankIdentifier] ) {
        result = NO;   
        if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(webBrowserFaildStartLoadWithRequest:)] ) {
            @autoreleasepool {
                [delegate_ webBrowserFaildStartLoadWithRequest:[request copy]];
            }
        }
        _logd_tm(self, @"shouldStartLoadWithRequest NativeURL:",[[request URL] description],nil);
        [GUJUtil openNativeURL:[NSURL URLWithString:[[request URL]description]]];
    } 
    [progressIndicator_ startAnimating];
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [progressIndicator_ stopAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ( !([error.domain isEqualToString:kRedefinedWebKitErrorDomain] && error.code == 102) ) 
    {
        if ( !(([error.domain isEqualToString:NSURLErrorDomain] && error.code == -999)) )
        {
            [progressIndicator_ stopAnimating];
            [webView stopLoading];
            [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAWebBrowserErrorDomain code:error.code userInfo:[error userInfo]]]; 
            // !!!: discuss: should self hide on error?
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}
@end

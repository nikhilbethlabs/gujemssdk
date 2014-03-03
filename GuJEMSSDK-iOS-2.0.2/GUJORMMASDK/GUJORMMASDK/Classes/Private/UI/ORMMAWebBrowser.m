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
#import "GUJAdViewEvent.h"

@implementation ORMMAWebBrowser(PrivateImplementation)

#pragma mark private methods
- (void)navigateBack:(id)sender
{
    [[self webView] goBack];
}

- (void)navigateForward:(id)sender
{
    [[self webView] goForward];
}

- (void)refresh:(id)sender
{
    [[self webView] reload];
}

- (void)openExternal:(id)sender
{
    [[UIApplication sharedApplication] openURL:[[[self webView] request] URL]];
}

- (void)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (UIBarButtonItem*)__createControllButton:(NSString*)image target:(id)target action:(SEL)selector
{
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithImage:[[self ormmaResourceBundle] loadImageResource:image] style:UIBarButtonItemStylePlain target:target action:selector];
    
    return result;
}

- (UIBarButtonItem*)__createFlexibleSpace
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (void)__createUI:(BOOL)isLandscape
{
    @autoreleasepool {
        if( [GUJUtil firstResponder] == nil ) {
            _log_t(self, [NSString stringWithFormat:@"[%@] NoFirstResponderToAttachWebView",kGUJUIKitErrorDomain]);
            [self setError:[NSError errorWithDomain:kGUJUIKitErrorDomain code:ORMMA_ERROR_CODE_FIRST_RESPONDER_NOT_FOUND userInfo:nil]];
            return;
        }
        [self setOrmmaResourceBundle:[ORMMAResourceBundleManager instanceForBundle:kORMMAResourceBundleName]];
        
        [self setActivityIndicator:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [self setWebViewContainerView:[[UIView alloc] initWithFrame:[GUJUtil frameOfFirstResponder]]];
        [[self webViewContainerView] setBackgroundColor:[UIColor clearColor]];
        
        // TODO shrink this part of code
        if( isLandscape ) {
            // ensure that we are in Landscape
            if( [self webViewContainerView].frame.size.width > [self webViewContainerView].frame.size.height ) {
                CGRect frame         = [self webViewContainerView].frame;
                float stausBarOffset = 0.0f;
                if( ![[UIApplication sharedApplication] isStatusBarHidden] ) {
                    stausBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
                    /*!
                     * Check the height against a pseudo height cause
                     * we saw some strange values of statusBarFrame on some devices.
                     */
                    if( stausBarOffset > 50.0 ) {
                        stausBarOffset = kGUJDefaultStatusBarHeight;
                    }
                }
                if( [GUJUtil frameOfKeyWindow].size.height >= self.view.frame.size.height && ![[UIApplication sharedApplication] isStatusBarHidden] ) {
                    frame.size.height    = [self webViewContainerView].frame.size.height-stausBarOffset;
                }
                [[self webViewContainerView] setFrame:frame];
                _logd_frame(self, [self webViewContainerView].frame);
            }
            
        } else { // is portrait
            
            // ensure that we are in portrait
            if( [self webViewContainerView].frame.size.width > [self webViewContainerView].frame.size.height ) {
                CGRect frame         = [self webViewContainerView].frame;
                float stausBarOffset = 0.0f;
                if( ![[UIApplication sharedApplication] isStatusBarHidden] ) {
                    stausBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
                    /*!
                     * Check the height against a pseudo height cause
                     * we saw some strange values of statusBarFrame on some devices.
                     */
                    if( stausBarOffset > 50.0 ) {
                        stausBarOffset = kGUJDefaultStatusBarHeight;
                    }
                }
                frame.size.width    = [self webViewContainerView].frame.size.height+stausBarOffset;
                frame.size.height   = [self webViewContainerView].frame.size.width-stausBarOffset;
                [[self webViewContainerView] setFrame:frame];
                _logd_frame(self, [self webViewContainerView].frame);
            } else {
                CGRect frame         = [self webViewContainerView].frame;
                float stausBarOffset = 0.0f;
                if( ![[UIApplication sharedApplication] isStatusBarHidden] ) {
                    stausBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
                }
                if( [GUJUtil frameOfKeyWindow].size.height > self.view.frame.size.height ) {
                    frame.size.height    = [self webViewContainerView].frame.size.height-stausBarOffset;
                }
                [[self webViewContainerView] setFrame:frame];
                _logd_frame(self, [self webViewContainerView].frame);
            }
            
        } // portrait
        
        // create the navigation bar
        [self setToolBar:[[UIToolbar alloc] init]];
        [[self toolBar] setBarStyle:UIBarStyleDefault];
        
        // create navigation bar items
        [self setToolBarItems:[[NSMutableArray alloc] init]];
        [[self toolBarItems] addObject:[self __createControllButton:kORMMAResourceNameForBackImage target:self action:@selector(navigateBack:)]];
        [[self toolBarItems] addObject:[self __createFlexibleSpace]];
        [[self toolBarItems] addObject:[self __createControllButton:kORMMAResourceNameForForwardImage target:self action:@selector(navigateForward:)]];
        [[self toolBarItems] addObject:[self __createFlexibleSpace]];
        [[self toolBarItems] addObject:[self __createControllButton:kORMMAResourceNameForRefreshImage target:self action:@selector(refresh:)]];
        [[self toolBarItems] addObject:[self __createFlexibleSpace]];
        [[self toolBarItems] addObject:[self __createControllButton:kORMMAResourceNameForOpenBrowserImage target:self action:@selector(openExternal:)]];
        [[self toolBarItems] addObject:[self __createFlexibleSpace]];
        [[self toolBarItems] addObject:[self __createControllButton:kORMMAResourceNameForCloseImage target:self action:@selector(close:)]];
        [[self toolBar] setItems: [self toolBarItems]];
        
        // size the navigation bar
        [[self toolBar] sizeToFit];
        CGRect navBarFrame      = [self toolBar].frame;
        navBarFrame.size.width  = [self webViewContainerView].frame.size.width;
        navBarFrame.size.height = 45.0f;
        navBarFrame.origin.y    = [self webViewContainerView].frame.size.height-navBarFrame.size.height;
        [[self toolBar] setFrame:navBarFrame];
        
        // size the webview
        CGRect webViewFrame = [self webViewContainerView].frame;
        webViewFrame.size.height = (webViewFrame.size.height-navBarFrame.size.height);
        
        [self setWebView:[[UIWebView alloc] initWithFrame:webViewFrame]];
        [[self activityIndicator] setCenter:[self webView].center];
    }
    [[self webView] setDelegate:self];
    [[self webViewContainerView] addSubview:[self webView]];
    [[self webViewContainerView] addSubview: [self toolBar]];
    [[self webViewContainerView] addSubview:[self activityIndicator]];
    [self setView:[self webViewContainerView]];
}

@end

@implementation ORMMAWebBrowser

#pragma mark public methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if( [GUJUtil isPortraitLayout] ) {
            [self __createUI:NO];
        } else if( [GUJUtil isLandscapeLayout] ) {
            [self __createUI:YES];
        } else { // UIDeviceOrientationUnknown            
            [GUJUtil changeInterfaceOrientation:UIInterfaceOrientationPortrait];
            [self __createUI:NO];
        }
    }
    return self;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if( self != nil ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    if( [self webView] != nil ) {
        [[self webView] stopLoading];
        [[self webView] setDelegate:nil];
    }
    [self setWebView:nil];
}

- (void)navigateToURL:(NSURLRequest*)urlRequest
{
    @autoreleasepool {
        [[self webView] loadRequest:[NSURLRequest requestWithURL:[urlRequest URL]]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(webBrowserWillShow)] ) {
        [[self delegate] webBrowserWillShow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setIsVisible:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(webBrowserWillHide)] ) {
        [[self delegate] webBrowserWillHide];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self setIsVisible:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark web view delegate methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL result = YES;
    if( ![[[[request URL] description] lowercaseString] hasPrefix:kGUJHTTPProtocolIdentifier] &&
       ![[[[request URL] description] lowercaseString] hasPrefix:kGUJHTTPSProtocolIdentifier] &&
       ![[[[request URL] description] lowercaseString] hasPrefix:kGUJWebViewAboutBlankIdentifier] ) {
        result = NO;
        if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(webBrowserFailedStartLoadWithRequest:)] ) {
            @autoreleasepool {
                [[self delegate] webBrowserFailedStartLoadWithRequest:[request copy]];
            }
        }
        _logd_tm(self, @"shouldStartLoadWithRequest NativeURL:",[[request URL] description],nil);
        [GUJUtil openNativeURL:[NSURL URLWithString:[[request URL]description]]];
    }
    if( result ) {
        [[self activityIndicator] setHidden:NO];
        [[self activityIndicator] startAnimating];
    }
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[self activityIndicator] stopAnimating];
    [[self activityIndicator] setHidden:YES];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[self activityIndicator] stopAnimating];
    [[self activityIndicator] setHidden:YES];
    if( !([error.domain isEqualToString:kRedefinedWebKitErrorDomain] && error.code == 102) ) {
        if( !(([error.domain isEqualToString:NSURLErrorDomain] && error.code == -999)) ) {
            [webView stopLoading];
            [self setError:[NSError errorWithDomain:kORMMAWebBrowserErrorDomain code:error.code userInfo:[error userInfo]]];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}



@end

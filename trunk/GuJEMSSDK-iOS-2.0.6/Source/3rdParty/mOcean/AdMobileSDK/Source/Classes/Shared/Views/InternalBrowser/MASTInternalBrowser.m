//
//  InternalBrowser.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import "MASTInternalBrowser.h"

#import "MASTNotificationCenter.h"
#import "MASTDownloadController.h"
#import "MASTUIViewAdditions.h"
#import "MASTMessages.h"

#define degreesToRadian(x) ((x) / 180.0 * M_PI)

@interface MASTInternalBrowser ()

- (BOOL)saveToMojivaFolderData:(NSData*)data name:(NSString*)name;
- (void)prepareResources;
- (void)registerObserver;
- (void)openURLinInternalBrowser:(NSNotification*)notification;

- (void)updateFrames:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
- (void)replaceItemWithToolbar:(UIToolbar*)toolbar tag:(NSInteger)tag withItem:(UIBarButtonItem*)item;
- (void)backAction;
- (void)forwardAction;
- (void)refreshAction;
- (void)stopAction;
- (void)shareAction;

@end


@implementation MASTInternalBrowser

@synthesize viewConreoller = _viewConreoller, sendAdView, URL, loadingURL;

static MASTInternalBrowser* sharedInstance = nil;


#pragma mark -
#pragma mark Singleton

- (id) init {	
	self = [super init];
	if (self) {
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.view.backgroundColor = [UIColor whiteColor];
		_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        
		[self.view addSubview:_webView];
        
        [self prepareResources];
        
		UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil] autorelease];
        
        UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [imgButton setImage:_backIcon forState:UIControlStateNormal];
        imgButton.frame = CGRectMake(0.0, 0.0, _backIcon.size.width, _backIcon.size.height);
        [imgButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backButton = [[UIBarButtonItem alloc] initWithCustomView:imgButton];        
        _backButton.tag = 2;
        _backButton.enabled = NO;
        
        imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [imgButton setImage:_forwardIcon forState:UIControlStateNormal];
        imgButton.frame = CGRectMake(0.0, 0.0, _backIcon.size.width, _backIcon.size.height);
        [imgButton addTarget:self action:@selector(forwardAction) forControlEvents:UIControlEventTouchUpInside];
        _forwardButton =
        [[UIBarButtonItem alloc] initWithCustomView:imgButton];
        _forwardButton.tag = 1;
        _forwardButton.enabled = NO;
        _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                          UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
        _refreshButton.tag = 3;
        _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                       UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
        _stopButton.tag = 3;
        _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
        
        _toolbar = [[UIToolbar alloc] init];
		_toolbar.barStyle = UIBarStyleBlack;
		_toolbar.translucent = YES;
        //_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
        _toolbar.items = [NSArray arrayWithObjects:
                          flexItem,
                          _backButton,
                          flexItem,
                          _forwardButton,
                          flexItem,
                          _refreshButton,
                          flexItem,
                          _actionButton,
                          flexItem,
                          nil];
        
        [_toolbar sizeToFit];
        _toolbar.frame = CGRectMake(0, self.view.frame.size.height - _toolbar.frame.size.height, self.view.frame.size.width, _toolbar.frame.size.height);
        
        [self.view addSubview:_toolbar];
		
		_navbar = [[UIToolbar alloc] init];
		_navbar.barStyle = UIBarStyleBlack;
		_navbar.translucent = YES;
        _navbar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
		[_navbar sizeToFit];
		
        
        UIActivityIndicatorView* spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [spinner startAnimating];
        _activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
         
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = kLoadingTitle;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.opaque = NO;
        _titleLabel.shadowColor = [UIColor darkGrayColor];
        [_titleLabel sizeToFit];
        [_titleLabel setFrame:CGRectMake(60, 10.0f, _toolbar.frame.size.width - 120, _titleLabel.frame.size.height)];
        
        UIBarItem* titleItem = [[[UIBarButtonItem alloc] initWithCustomView:_titleLabel] autorelease];
        
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
									   target:self action:@selector(close)];
		
		[_navbar setItems:[NSArray arrayWithObjects:_activityItem,flexItem,titleItem,flexItem,doneButton,nil]];
		[doneButton release];
        
		[self.view addSubview:_navbar];
		
		_opening = NO;
        
		[self registerObserver];
        
        _device = [UIDevice currentDevice];
		[_device retain];
        [_device beginGeneratingDeviceOrientationNotifications];
	}
	
	return self;
}

- (void)dealloc {
    _webView.delegate = nil;
    [_webView stopLoading];
    
    [_navbar release];
    [_titleLabel release];
    [_activityItem release];
    [_device release];
    
    [super dealloc];
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
	RELEASE_SAFELY(_device);
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


- (void)viewWillDisappear:(BOOL)animated {
    _opening = NO;
    [super viewWillDisappear:animated];
}


#pragma mark -
#pragma mark Private


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

- (void)prepareResources {
    NSString* dirPath = [NSHomeDirectory() stringByAppendingPathComponent:kPathForFolderCache];
    
    NSString* path = [dirPath stringByAppendingPathComponent:@"backIcon.png"];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        NSData* imageData = [QSStrings decodeBase64WithString:kBackIconB64];
        NSData* imageData2x = [QSStrings decodeBase64WithString:kBackIcon2xB64];
        if ([self saveToMojivaFolderData:imageData name:@"backIcon.png"] &&
            [self saveToMojivaFolderData:imageData2x name:@"backIcon@2x.png"]) {
            _backIcon = [[UIImage imageWithContentsOfFile:path] retain];
        }
    }
    else {
        _backIcon = [[UIImage imageWithContentsOfFile:path] retain];
    }
    
    path = [dirPath stringByAppendingPathComponent:@"forwardIcon.png"];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        NSData* imageData = [QSStrings decodeBase64WithString:kForwardIconB64];
        NSData* imageData2x = [QSStrings decodeBase64WithString:kForwardIcon2xB64];
        if ([self saveToMojivaFolderData:imageData name:@"forwardIcon.png"] &&
            [self saveToMojivaFolderData:imageData2x name:@"forwardIcon@2x.png"]) {
            _forwardIcon = [[UIImage imageWithContentsOfFile:path] retain];
        }
    }
    else {
        _forwardIcon = [[UIImage imageWithContentsOfFile:path] retain];
    }
}

- (void)registerObserver {
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(openURLinInternalBrowser:) name:kOpenInternalBrowserNotification object:nil];
}

- (void)openURLinInternalBrowser:(NSNotification*)notification {
	@synchronized(self) {
		if (!_opening && !self.view.window) {
            NSDictionary *info = [notification object];
            MASTAdView* adView = [info objectForKey:@"adView"];
            NSURLRequest* request = [info objectForKey:@"request"];
            
            if (request && adView) { 
                _opening = YES;
                
                self.sendAdView = adView;
                self.viewConreoller = [adView viewControllerForView];
                
                // remove all load/update ad requests 
                [[MASTDownloadController sharedInstance] cancelAll];
                
                self.URL = [request URL];
                [_webView loadRequest:request];
                
                UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                if (vc) {
                    self.viewConreoller = vc;
                }
                [self updateFrames:[UIApplication sharedApplication].statusBarOrientation duration:0.0];
                
                [self.viewConreoller presentModalViewController:self animated:YES];
            }
		}
	}
}

- (void)openURLinkExternalBrowser:(NSURLRequest*)request {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:self.sendAdView forKey:@"adView"];
    [info setObject:request forKey:@"request"];
    [[MASTNotificationCenter sharedInstance] postNotificationName:kShouldOpenExternalAppNotification object:info];
}

- (void)updateFrames:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    
    if (UIDeviceOrientationIsLandscape(interfaceOrientation)) {        
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
    }
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        frame = CGRectMake(frame.origin.x, frame.origin.y + 20, frame.size.width, frame.size.height - 20);
    }
    
    [_navbar sizeToFit];
    [_toolbar sizeToFit];

	_webView.frame = CGRectMake(0, _navbar.frame.size.height, frame.size.width, frame.size.height - _navbar.frame.size.height - _toolbar.frame.size.height);
    [_titleLabel setFrame:CGRectMake(60, 10.0f, frame.size.width - 120, _titleLabel.frame.size.height)];
    
    [UIView beginAnimations:@"resize" context:nil];
    [UIView setAnimationDuration:duration];
    
    _toolbar.frame = CGRectMake(0, _webView.frame.origin.y + _webView.frame.size.height, frame.size.width, _navbar.frame.size.height);
    
    [UIView commitAnimations];
    
    _webView.scalesPageToFit = YES;
}

- (void)close {
	@synchronized(self) {
        if (_opening == NO)
            return;
        
        _opening = NO;
        [self.viewConreoller dismissModalViewControllerAnimated:YES];
        
        // slow
		[_webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
		
		//fast
		//[_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
        
        [[MASTNotificationCenter sharedInstance] postNotificationName:kCloseInternalBrowserNotification object:self.sendAdView];
	}
}

- (void)replaceItemWithToolbar:(UIToolbar*)toolbar tag:(NSInteger)tag withItem:(UIBarButtonItem*)item {
    NSInteger buttonIndex = 0;
    for (UIBarButtonItem* button in toolbar.items) {
        if (button.tag == tag) {
            NSMutableArray* newItems = [NSMutableArray arrayWithArray:toolbar.items];
            [newItems replaceObjectAtIndex:buttonIndex withObject:item];
            toolbar.items = newItems;
            break;
        }
        ++buttonIndex;
    }
}

- (void)backAction {
    [_webView goBack];
}

- (void)forwardAction {
    [_webView goForward];
}

- (void)refreshAction {
    [_webView reload];
}

- (void)stopAction {
    [_webView stopLoading];
}

- (void)shareAction {
    if (nil == _actionSheet) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:kOpenLinkInSafariTitle,
                        nil];
        
        if (self.view.window.frame.size.height > 480) {
            // iPad
            [_actionSheet showFromBarButtonItem:_actionButton animated:YES];
            
        }  else {
            // iPhone/iPod
            [_actionSheet showInView: self.view];
        }
        
    } else {
        [_actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        [_actionSheet release];
        _actionSheet = nil;
    }
    
}


#pragma mark -
#pragma mark Orientation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL rotate = [self.viewConreoller shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    return rotate;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _toolbar.frame = CGRectMake(0, _toolbar.frame.size.height + self.view.frame.size.height, _toolbar.frame.size.width, _toolbar.frame.size.height);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateFrames:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
}


#pragma mark -
#pragma mark UIWebViewDelegate


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    /*
    if ([[TTNavigator navigator].URLMap isAppURL:request.URL]) {
        [_loadingURL release];
        _loadingURL = [[NSURL URLWithString:@"about:blank"] retain];
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    */
    
    // Let the web view deal with about: schema as-is.
    if ([[[request URL] scheme] isEqualToString:@"about"])
        return YES;
    
    if (![MASTUtils isInternalScheme:[request URL]] && _opening) {
        [self openURLinkExternalBrowser:request];
        self.loadingURL = nil;
        [self close];
        return NO;
    }
    
    self.loadingURL = [request URL];
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView*)webView {
    _titleLabel.text = kLoadingTitle;
    _activityItem.customView.hidden = NO;
    [self replaceItemWithToolbar:_navbar tag:1 withItem:_activityItem];
    
    //[_toolbar replaceItemWithTag:3 withItem:_stopButton];
    [self replaceItemWithToolbar:_toolbar tag:3 withItem:_stopButton];
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
}


- (void)webViewDidFinishLoad:(UIWebView*)webView {
    self.loadingURL = nil;
    
    _titleLabel.text = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _activityItem.customView.hidden = YES;
    
    //[_toolbar replaceItemWithTag:3 withItem:_refreshButton];
    [self replaceItemWithToolbar:_toolbar tag:3 withItem:_refreshButton];
    
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
}


- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    [self openURLinkExternalBrowser:[NSURLRequest requestWithURL:self.loadingURL]];
    self.loadingURL = nil;
    [self webViewDidFinishLoad:webView];
    [self close];
}


#pragma mark -
#pragma mark UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {    
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:self.URL];
    }
    
    [_actionSheet release];
    _actionSheet = nil;
}

@end

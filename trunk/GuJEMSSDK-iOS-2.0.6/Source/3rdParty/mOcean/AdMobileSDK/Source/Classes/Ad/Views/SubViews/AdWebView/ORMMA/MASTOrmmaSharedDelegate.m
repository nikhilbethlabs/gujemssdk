//
//  MASTOrmmaSharedDelegate.m
//

#import "MASTOrmmaSharedDelegate.h"
#import "MASTExpandView.h"
#import "MASTOrmmaHelper.h"
#import "MASTUIColorAdditions.h"
#import "MASTExpandViewController.h"
#import "MASTUIWebViewAdditions.h"
#import "MASTInternalAVPlayer.h"
#import "MASTNotificationCenter.h"
#import "MASTNetworkQueue.h"
#import "MASTConstants.h"
#import "MASTAdView_Private.h"

@interface MASTOrmmaSharedDelegate ()

@property (nonatomic, retain) MASTExpandViewController *expandVC;
@property (nonatomic, retain) MASTExpandView *expandView;
@property (nonatomic, retain) NSMutableDictionary *adControls;
@property (nonatomic, assign) CGRect defaultFrame;
@property (nonatomic, assign) BOOL statusBarHidden;

-(UIViewController*)viewControllerForView:(UIView*)view;
-(CGRect)loadDefaultFrame:(NSDictionary*)frameValue;
-(void)saveOptions:(id)adControl;
-(void)loadOptions:(id)adControl;

@end

@implementation MASTOrmmaSharedDelegate

@synthesize expandVC, expandView, defaultFrame, adControls, statusBarHidden;

static MASTOrmmaSharedDelegate *sharedDelegate = nil;

#pragma mark - Public method

+ (id)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^ { 
        sharedDelegate = [self new]; 
        sharedDelegate.adControls = [NSMutableDictionary new];
    });
    return sharedDelegate;
}

#pragma mark - Private methods

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.expandVC = nil;
    self.expandView = nil;
    self.adControls = nil;
    
    [super dealloc];
}

- (UIViewController*)viewControllerForView:(UIView*)view {
    id nextResponder = [view nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [self viewControllerForView:nextResponder];
    } else {
        return nil;
    }
}

- (CGRect)loadDefaultFrame:(NSDictionary*)frameValue {
    float x = [[frameValue objectForKey:@"frameX"] floatValue];
    float y = [[frameValue objectForKey:@"frameY"] floatValue];
    float width = [[frameValue objectForKey:@"sizeWidth"] floatValue];
    float height = [[frameValue objectForKey:@"sizeHeight"] floatValue];
    
    return CGRectMake(x, y, width, height); 
}

- (void)saveOptions:(id)adControl {
    NSMutableDictionary *options = [[NSMutableDictionary new] autorelease];
    
    if (self.expandVC)
        [options setObject:self.expandVC forKey:@"expandVC"];
    
    if (self.expandView) 
        [options setObject:self.expandView forKey:@"expandView"];

    [options setObject:[NSNumber numberWithInt:self.defaultFrame.origin.x] forKey:@"frameX"];
    [options setObject:[NSNumber numberWithInt:self.defaultFrame.origin.y] forKey:@"frameY"];
    [options setObject:[NSNumber numberWithInt:self.defaultFrame.size.width] forKey:@"sizeWidth"];
    [options setObject:[NSNumber numberWithInt:self.defaultFrame.size.height] forKey:@"sizeHeight"];
    
    [self.adControls setObject:options forKey:[NSString stringWithFormat:@"%ld", adControl]];
}

- (void)loadOptions:(id)adControl {
    NSDictionary *options = [self.adControls objectForKey:[NSString stringWithFormat:@"%ld", adControl]];
    
    self.expandVC = [options objectForKey:@"expandVC"];
    self.expandView = [options objectForKey:@"expandView"];
    self.defaultFrame = [self loadDefaultFrame:options];
}

#pragma mark - Support delegate methods

- (BOOL)supportAudioForAd:(id)sender {
    return YES;
}

- (BOOL)supportVideoForAd:(id)sender {
    return YES;
}

- (BOOL)supportMASTForAd:(id)sender {
    return YES;
}

- (BOOL)supportCalendarForAd:(id)sender {
    if (NSClassFromString(@"EKEventStore")) {
		return YES; 
	}
    return NO;
}

- (BOOL)supportEmailForAd:(id)sender {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)supportSmsForAd:(id)sender {
    Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (smsClass != nil) {
        if ([smsClass canSendText]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)supportPhoneForAd:(id)sender {
    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        return YES;
    }
    return NO;
}

- (CGSize)maxSizeForAd:(id)sender {
    UIView* superview = [sender superview];
    if (superview == nil)
        return CGSizeZero;
    
    CGSize maxSize = superview.bounds.size;
    return maxSize;
}

#pragma mark - Main delegate methods

- (void)showAd:(id)sender {
    UIView *adControl = sender;
    if (adControl.hidden) {
        adControl.hidden = NO;
    }
}

- (void)hideAd:(id)sender {
    UIView *adControl = sender;
    adControl.hidden = YES;
}

- (void)closeFromState:(ORMMAState)state ad:(id)sender {
    UIView *adControl = sender;
    
    //load options
    [self loadOptions:adControl];
    
    if (state == ORMMAStateExpanded) {
        UIView* adWebView = [self.expandVC.view viewWithTag:ORMMA_WEBVIEW_TAG];
        
        if (!self.statusBarHidden)
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        [self.expandVC dismissModalViewControllerAnimated:NO];
        
        if (self.expandView && self.expandVC) {
            // we need to close expandView
            self.expandView = nil;
        } else {
            // Put the web view ("the ad") back on the ad view.
            CGRect frame = adControl.bounds;
            adWebView.frame = frame;
            [adControl insertSubview:adWebView atIndex:0];
        }
        self.expandVC = nil;
        
        SEL removeUpdateFlagSel = sel_registerName("removeUpdateFlag:");
        if ([sender respondsToSelector:removeUpdateFlagSel]) {
            [sender performSelector:removeUpdateFlagSel withObject:@"expand"];
        }
    } else {
        adControl.frame = self.defaultFrame;
    }
}

- (void)expandURL:(NSString*)url parameters:(NSDictionary*)parameters ad:(id)sender {
    UIView *adControl = sender;
    UIView *adWebView = [adControl viewWithTag:ORMMA_WEBVIEW_TAG];

    CGFloat w = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"width"];
    CGFloat h = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"height"];
    BOOL lockOrientation = [MASTOrmmaHelper booleanFromDictionary:parameters forKey:@"lockOrientation"];
    BOOL useCustomClose = [MASTOrmmaHelper booleanFromDictionary:parameters forKey:@"useCustomClose"];
    
    BOOL useBackground = [MASTOrmmaHelper booleanFromDictionary:parameters forKey:@"useBackground"];
    UIColor* backgroundColor = [UIColor colorWithHexString:[[MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"backgroundColor"] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    CGFloat backgroundOpacity = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"backgroundOpacity"];
    
    UIColor* expandBackgroundColor = nil;
    
    NSArray* rgba = [backgroundColor arrayFromRGBAComponents];
    if (useBackground && backgroundColor && rgba && [rgba count] >= 3) {
        CGFloat r = [(NSNumber*)[rgba objectAtIndex:0] floatValue];
        CGFloat g = [(NSNumber*)[rgba objectAtIndex:1] floatValue];
        CGFloat b = [(NSNumber*)[rgba objectAtIndex:2] floatValue];
        expandBackgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:backgroundOpacity];
    } else {
        expandBackgroundColor = [UIColor whiteColor];
    }
    
    self.expandVC = [[[MASTExpandViewController alloc] initWithLockOrientation:lockOrientation] autorelease];
    self.expandVC.view.backgroundColor = expandBackgroundColor;
    
    UIViewController* rootVC = [self viewControllerForView:adControl];
    
    if (rootVC) {
        SEL setUpdateFlagSel = sel_registerName("setUpdateFlag:");
        if ([sender respondsToSelector:setUpdateFlagSel]) {
            [sender performSelector:setUpdateFlagSel withObject:@"expand"];
        }
        
        self.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        if (!self.statusBarHidden)
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        [rootVC presentModalViewController:self.expandVC animated:NO];
    }
    
    if (url) {                        
        self.expandView = [[[MASTExpandView alloc] initWithFrame:CGRectMake(0, 0, w, h)] autorelease];
        self.expandView.adView = adControl;
        self.expandView.backgroundColor = expandBackgroundColor;
        
        [self.expandVC.view addSubview:self.expandView];
        
        [self.expandView loadUrl:url];
        
        self.expandVC.expandView = self.expandView;
        [self.expandVC useCustomClose:NO];
    } else {        
        // to make shure
        self.expandView = nil;
        self.expandVC.view.backgroundColor = expandBackgroundColor;
        
        // Move the web view from the ad view to the expand view.
        [self.expandVC.view addSubview:adWebView];
        
        // resize
        adWebView.frame = CGRectMake(0.0, 0.0, w, h);
        
        self.expandVC.expandView = adControl;
        [self.expandVC useCustomClose:useCustomClose];
    }
    
    //save options
    [self saveOptions:adControl];
}

- (void)resize:(CGSize)size ad:(id)sender {
    UIView *adControl = sender;
    self.defaultFrame = adControl.frame;
    
    CGRect currentFrame = adControl.frame;
    CGRect availableBounds = adControl.superview.bounds;
    
    CGRect resizedFrame = currentFrame;
    resizedFrame.size.width = size.width;
    resizedFrame.size.height = size.height;
    
    if (CGRectContainsRect(availableBounds, resizedFrame) == NO) {
        // The new size doesn't fit within the parent's bounds,
        // repositon the origin so that it does.
        
        CGFloat maxY = CGRectGetMaxY(availableBounds);
        CGFloat newY = CGRectGetMaxY(resizedFrame);
        if (newY > maxY) {
            CGFloat delta = newY - maxY;
            resizedFrame.origin.y -= delta;
        }
        
        CGFloat maxX = CGRectGetMaxX(availableBounds);
        CGFloat newX = CGRectGetMaxX(resizedFrame);
        if (newX > maxX) {
            CGFloat delta = newX - maxX;
            resizedFrame.origin.x -= delta;
        }
    }
    
    adControl.frame = resizedFrame;
    
    // The above will also trigger an observer change for the frame which will incorrectly
    // set the model to the resized frame.  Future ads should be obtained with the callers/autosized
    // desired frame and not a resized from from another ad.  The following forces the frame
    // on the model to be preserved.
    if ([adControl isKindOfClass:[MASTAdView class]])
        [[(MASTAdView*)adControl adModel] setFrame:currentFrame];
    
    //save options
    [self saveOptions:adControl];
}

- (void)phone:(NSString*)number ad:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)sms:(NSString*)to body:(NSString*)body ad:(id)sender {
    UIView *adControl = sender;
    if (body && to && NSClassFromString(@"MFMessageComposeViewController") && [MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *vc = [[[MFMessageComposeViewController alloc] init] autorelease];
        NSArray *recipients = [NSArray arrayWithObject:to];
        vc.recipients = recipients;
        vc.body = body;
        vc.messageComposeDelegate = self;
        
        UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (!rvc) {
            rvc = [self viewControllerForView:[UIApplication sharedApplication].keyWindow];
        }
        if (!rvc) {
            rvc = [self viewControllerForView:adControl];
        }
        [rvc presentModalViewController:vc animated:YES];
    }
}

- (void)email:(NSString*)to subject:(NSString*)subject body:(NSString*)body useHtml:(BOOL)useHtml ad:(id)sender {
    UIView *adControl = sender;
    MFMailComposeViewController *vc = [[[MFMailComposeViewController alloc] init] autorelease];
    NSArray *recipients = [NSArray arrayWithObject:to];
    [vc setToRecipients:recipients];
    [vc setSubject:subject];
    [vc setMessageBody:body  isHTML:useHtml];
    vc.mailComposeDelegate = self;
	
    UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rvc) {
        rvc = [self viewControllerForView:[UIApplication sharedApplication].keyWindow];
    }
    if (!rvc) {
        rvc = [self viewControllerForView:adControl];
    }
    [rvc presentModalViewController:vc animated:YES];
}

- (void)calendar:(NSString*)title body:(NSString*)body date:(NSDate*)date ad:(id)sender {
    // handle internally
    EKEventStore* eventStore = [[[EKEventStore alloc] init] autorelease];
    EKEvent* ekEvent = [EKEvent eventWithEventStore:eventStore];
    ekEvent.title = title;
	
    ekEvent.notes = body;
	
    ekEvent.startDate = date;
    ekEvent.endDate   = [[NSDate alloc] initWithTimeInterval:600 sinceDate:ekEvent.startDate];
    [ekEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    [eventStore saveEvent:ekEvent span:EKSpanThisEvent error:nil];
}

- (void)openMapWithPOI:(NSString*)poi ad:(id)sender {
    NSString* encoded = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                           (CFStringRef)poi, 
                                                                           NULL, 
                                                                           (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", 
                                                                           CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString* args = [encoded autorelease];
    NSString* urlString = [kGoogleMapsUrl stringByAppendingString:args];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)playAudio:(NSString*)url parameters:(NSDictionary*)parameters ad:(id)sender {
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [info setObject:url forKey:@"url"];
    if (self.expandVC) {
        [info setObject:self.expandVC.view forKey:@"adView"];
    } else {
        [info setObject:sender forKey:@"adView"];
    }
    
    [[MASTInternalAVPlayer sharedInstance] playAudio:info];
}

- (void)playVideo:(NSString*)url parameters:(NSDictionary*)parameters ad:(id)sender {
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [info setObject:url forKey:@"url"];
    if (self.expandVC) {
        [info setObject:self.expandVC.view forKey:@"adView"];
    } else {
        [info setObject:sender forKey:@"adView"];
    }
    
    [[MASTInternalAVPlayer sharedInstance] playVideo:info];
}

- (void)sendRequest:(NSString*)url display:(NSString*)display response:(void (^)(NSString* response))response ad:(id)sender {
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [MASTNetworkQueue loadWithRequest:request completion:^(NSURLRequest *req, NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {
        if (!error && data && [data length] > 0) {
            NSString* responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            response(responseString);
        }
    }];
}

#pragma mark - MFMessageComposeViewController Delegete


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    /*UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
	 if (!rvc) {
	 rvc = [self viewControllerForView:[UIApplication sharedApplication].keyWindow];
	 }
	 if (!rvc) {
	 rvc = [self.adView viewControllerForView];
	 }
	 [rvc dismissModalViewControllerAnimated:YES];*/
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark - MFMailComposeViewController Delegate


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    /*UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
	 if (!rvc) {
	 rvc = [[UIApplication sharedApplication].keyWindow viewControllerForView];
	 }
	 if (!rvc) {
	 rvc = [self.adView viewControllerForView];
	 }
	 [rvc dismissModalViewControllerAnimated:YES];*/
    [controller dismissModalViewControllerAnimated:YES];
}

@end

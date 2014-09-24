//
//  OrmmaAdaptor.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 8/23/11.
//

#import "MASTOrmmaAdaptor.h"
#import "MASTOrmmaConstants.h"
#import "MASTOrmmaHelper.h"
#import "MASTUIViewAdditions.h"
#import "Reachability.h"
#import "MASTNotificationCenter.h"
#import "MASTLocationManager.h"
#import "MASTAccelerometer.h"
#import "MASTSharedModel.h"
#import "MASTNetworkQueue.h"
#import "MASTObjectStorage.h"
#import "MASTExpandWebView.h"
#import "MASTExpandViewController.h"
#import "MASTUIColorAdditions.h"
#import "MASTMessages.h"

#define ORMMA_SHAME     @"ormma"

@interface MASTOrmmaAdaptor() <UIAccelerometerDelegate>

@property (nonatomic, retain) UIWebView*        webView;
@property (nonatomic, retain) MASTAdView*           adView;
@property (nonatomic, retain) MASTExpandWebView*    expandView;
@property (nonatomic, retain) MASTExpandViewController* expandVC;

@property (nonatomic, assign) ORMMAState        nonHideState;
@property (nonatomic, assign) ORMMAState        currentState;
@property (nonatomic, assign) CGRect            defaultFrame;
@property (nonatomic, retain) UIView*           lastSuperView;
@property (nonatomic, retain) UIColor*          lastBackgroundColor;
@property (nonatomic, assign) CGSize            maxSize;

- (void)viewVisible:(NSNotification*)notification;
- (void)viewInvisible:(NSNotification*)notification;
- (void)invalidate:(NSNotification*)notification;
- (void)frameChanged:(NSNotification*)notification;
- (void)orientationChanged:(NSNotification *)notification;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)handleReachabilityChangedNotification:(NSNotification *)notification;
- (void)locationDetected:(NSNotification*)notification;
- (void)headingDetected:(NSNotification*)notification;
- (void)expandViewClosed:(NSNotification*)notification;
- (void)evalJS:(NSString*)js;
- (void)click:(NSString*)url;

@end

@implementation MASTOrmmaAdaptor

@synthesize webView, adView, expandView, expandVC, nonHideState, currentState, defaultFrame, lastSuperView, lastBackgroundColor, maxSize, interstitial;

- (id)initWithWebView:(UIWebView*)view adView:(MASTAdView*)ad {
    self = [super init];
    if (self) {
        self.webView = view;
        self.adView = ad;
        self.defaultFrame = ad.frame;
        
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(viewVisible:) name:kAdViewBecomeVisibleNotification object:nil];
		[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(viewInvisible:) name:kAdViewBecomeInvisibleNotification object:nil];        
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(invalidate:) name:kUnregisterAdNotification object:nil];
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(frameChanged:) name:kAdViewFrameChangedNotification object:nil];
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(locationDetected:) name:kNewLocationDetectedNotification object:nil];
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(headingDetected:) name:kLocationUpdateHeadingNotification object:nil];
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(expandViewClosed:) name:kCloseExpandNotification object:nil];
        [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(moveToDefaultState) name:kORMMASetDefaultStateNotification object:nil];
        
        // setup our network reachability        
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self
							   selector:@selector(orientationChanged:)
								   name:UIDeviceOrientationDidChangeNotification
								 object:nil];
		[notificationCenter addObserver:self 
							   selector:@selector(keyboardWillShow:) 
								   name:UIKeyboardWillShowNotification
								 object:nil];
		[notificationCenter addObserver:self 
							   selector:@selector(keyboardWillHide:) 
								   name:UIKeyboardWillHideNotification
								 object:nil];
		[notificationCenter addObserver:self
							   selector:@selector(handleReachabilityChangedNotification:)
								   name:kReachabilityChangedNotification
								 object:nil];
        
		// start up reachability notifications
        Reachability* reachability = [Reachability reachabilityForInternetConnection];
        if ([reachability respondsToSelector:@selector(startNotifier)]) {
            [reachability startNotifier];
        }
        
        [[MASTAccelerometer sharedInstance] addDelegate:self];
    }
    
    return self;
}

- (void)dealloc {
    self.adView = nil;
    self.webView = nil;
    [[MASTNotificationCenter sharedInstance] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MASTAccelerometer sharedInstance] removeDelegate:self];
    [super dealloc];
}

- (BOOL)isOrmma:(NSURLRequest *)request {
    return [[[request URL] scheme] isEqualToString:ORMMA_SHAME];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [self evalJS:[MASTOrmmaHelper signalReadyInWebView]];
}

- (NSString*)getDefaultsJSCode {
    NSMutableString* result = [NSMutableString string];
    UIDevice* device = [UIDevice currentDevice];
    UIDeviceOrientation orientation = device.orientation;
    
    // Register up case 'Ormma' object
    [result appendString:[MASTOrmmaHelper registerOrmmaUpCaseObject]];
    
    // Default state
    self.currentState = ORMMAStateDefault;
    self.nonHideState = self.currentState;
    [result appendString:[MASTOrmmaHelper setState:self.currentState]];
    
    // Viewable
    [result appendString:[MASTOrmmaHelper setViewable:[webView isViewVisible]]];
    
    // Network
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    [result appendString:[MASTOrmmaHelper setNetwork:[reachability currentReachabilityStatus]]];
    
    // Frame size
    [result appendString:[MASTOrmmaHelper setSize:self.webView.frame.size]];
    
    // Max size
    UIViewController* parentVC = [self.adView viewControllerForView];
    
    if (parentVC && parentVC.view) {
        self.maxSize = parentVC.view.frame.size;
    } else {
        UIView* sv = self.adView.superview;
        if (sv) {
            self.maxSize = sv.frame.size;
        } else {
            self.maxSize = self.webView.frame.size;
        }
    }
    
    [result appendString:[MASTOrmmaHelper setMaxSize:self.maxSize]];
    
    // Screen size
	CGSize screenSize = [MASTOrmmaHelper screenSizeForOrientation:orientation];	
    [result appendString:[MASTOrmmaHelper setScreenSize:screenSize]];
    
    // Default position
    [result appendString:[MASTOrmmaHelper setDefaultPosition:self.adView.frame]];
    
    // Orientation
    [result appendString:[MASTOrmmaHelper setOrientation:orientation]];
    
    // Placement
    [result appendString:[MASTOrmmaHelper setPlacementInterstitial:self.interstitial]];
    
    CGFloat expandHeight = screenSize.height;
    if (![UIApplication sharedApplication].isStatusBarHidden) {
        expandHeight -= 20.0f;
    }
    
    // Expand properties expandProperties
    [result appendString:[MASTOrmmaHelper setExpandPropertiesWithMaxSize:CGSizeMake(screenSize.width, expandHeight)]];
    
    // Location
    MASTSharedModel* sharedModel = [MASTSharedModel sharedInstance];
    if (sharedModel && sharedModel.latitude && sharedModel.longitude && sharedModel.accuracy) {
        [result appendString:[MASTOrmmaHelper setLatitude:[sharedModel.latitude floatValue] longitude:[sharedModel.longitude floatValue] accuracy:[sharedModel.accuracy floatValue]]];
    }
    
#ifdef INCLUDE_LOCATION_MANAGER
    // Heading
    if ([LocationManager headingAvailable] && [LocationManager sharedInstance].currentHeading) {
        [result appendString:[OrmmaHelper setHeading:[LocationManager sharedInstance].currentHeading.trueHeading]];
    }
#endif
    
    NSMutableArray* supports = [NSMutableArray array];
    [supports addObject:ORMMA_LEVEL_1];
    [supports addObject:ORMMA_LEVEL_2];
    [supports addObject:ORMMA_LEVEL_3];
    [supports addObject:ORMMA_ORIENTATION];
    [supports addObject:ORMMA_NETWORK];
    [supports addObject:ORMMA_SCREEN];
    [supports addObject:ORMMA_SHAKE];
    [supports addObject:ORMMA_SIZE];
    [supports addObject:ORMMA_TILT];
    [supports addObject:ORMMA_AUDIO];
    [supports addObject:ORMMA_VIDEO];
    [supports addObject:ORMMA_MAP];
    
	if (NSClassFromString(@"EKEventStore")) {
		[supports addObject:ORMMA_CALENDAR]; 
	}

#ifdef INCLUDE_LOCATION_MANAGER
    if ([LocationManager headingAvailable]) {
        [supports addObject:ORMMA_HEADING];
    }
    
    if ([LocationManager sharedInstance].locationManager) {
        [supports addObject:ORMMA_LOCATION];
    }
#endif
    
    if ([device.model isEqualToString:@"iPhone"]) {
        [supports addObject:ORMMA_IPHONE];
    }
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            [supports addObject:ORMMA_EMAIL];
        }
    }
    
    Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (smsClass != nil) {
        if ([smsClass canSendText]) {
            [supports addObject:ORMMA_SMS];
        }
    }
    
    /*
    Class cameraClass = (NSClassFromString(@"UIImagePickerController"));
    if (cameraClass != nil) {
        if ([cameraClass isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [supports addObject:@"'camera'"];
        }
    }*/
    
    [result appendString:[MASTOrmmaHelper setSupports:supports]];
    
    return result;
}

- (void)evalJS:(NSString*)js {
    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
    /*if ([NSThread isMainThread]) {
        [self.webView stringByEvaluatingJavaScriptFromString:js];
    } else {
        [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
    }*/
}
         
         
- (void)click:(NSString*)url {
    if (self.adView) {
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:request, self.adView, nil]
                                                                       forKeys:[NSArray arrayWithObjects:@"request", @"adView", nil]];
        
        [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenURLNotification object:info];
    }
}

- (void)processEvent:(NSString*)event parameters:(NSDictionary*)parameters {
    if ([event isEqualToString:ORMMA_EVENT_ENABLED]) {
        //
    } else if ([event isEqualToString:ORMMA_EVENT_SHOW]) {
        if (self.adView.hidden) {
            self.currentState = self.nonHideState;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            [self.adView setHidden:NO];
        }
    } else if ([event isEqualToString:ORMMA_EVENT_HIDE]) {
        self.nonHideState = self.currentState;
        self.currentState = ORMMAStateHidden;
        [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
        [self.adView setHidden:YES];
    } else if ([event isEqualToString:ORMMA_EVENT_CLOSE]) {
        // if we're in the default state already, there is nothing to do
        if (self.currentState == ORMMAStateDefault) {
            // do same as hide command
            self.nonHideState = self.currentState;
            self.currentState = ORMMAStateHidden;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            [self.adView setHidden:YES];
        } else if (self.currentState == ORMMAStateHidden) {
            // hidden ad, nothing to do
        } else if (self.currentState == ORMMAStateExpanded) {
            [expandVC dismissModalViewControllerAnimated:YES]; 
            
            if (self.expandView && self.expandVC) {
                // we need to close expandView
                [self.expandView close];
                self.expandView = nil;
                
                self.currentState = ORMMAStateDefault;
                self.nonHideState = self.currentState;
                [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            } else {
                self.adView.frame = [self.lastSuperView convertRect:self.adView.frame fromView:self.adView.superview];
                [self.lastSuperView addSubview:self.adView];
                self.lastSuperView = nil;
                
                self.adView.backgroundColor = self.lastBackgroundColor;
                self.lastBackgroundColor = nil;
                
                // resize to normal frame without animation
                self.adView.frame = self.defaultFrame;
                self.currentState = ORMMAStateDefault;
                self.nonHideState = self.currentState;
                [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
                
                // resize to normal frame with animation
                /*[UIView animateWithDuration:0.2 animations:^(void) {
                    self.adView.frame = self.defaultFrame;
                } completion:^(BOOL finished) {
                    self.currentState = ORMMAStateDefault;
                    self.nonHideState = self.currentState;
                    [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
                }];*/
            }
            
            expandVC = nil;
        } else {
            self.adView.frame = self.defaultFrame;
            self.currentState = ORMMAStateDefault;
            self.nonHideState = self.currentState;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            /*[UIView animateWithDuration:0.2 animations:^(void) {
                self.adView.frame = self.defaultFrame;
            } completion:^(BOOL finished) {
                self.currentState = ORMMAStateDefault;
                self.nonHideState = self.currentState;
                [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            }];*/
        }
    } else if ([event isEqualToString:ORMMA_EVENT_EXPAND]) {
        if (self.currentState != ORMMAStateDefault) {
            // Already Expanded
            [self evalJS:[MASTOrmmaHelper fireError:kErrorExpandInvalidStateMessage forEvent:event]];
        } else {            
            NSString* url = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
            CGFloat w = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"width"];
            CGFloat h = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"height"];
            UIDevice* device = [UIDevice currentDevice];
            UIDeviceOrientation orientation = device.orientation;
            CGSize screenSize = [MASTOrmmaHelper screenSizeForOrientation:orientation];	
            
            if (w > screenSize.width) {
                [self evalJS:[MASTOrmmaHelper fireError:kErrorExpandLargerSizeMessage forEvent:event]];
            } else {
                if (h > screenSize.height) {
                    [self evalJS:[MASTOrmmaHelper fireError:kErrorExpandLargerSizeMessage forEvent:event]];
                } else {
                    //[[NotificationCenter sharedInstance] postNotificationName:kAdStopUpdateNotification object:self.adView];
                    
                    self.currentState = ORMMAStateExpanded;
                    self.nonHideState = self.currentState;
                    [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
                    
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
                    
                    self.expandVC = [[[MASTExpandViewController alloc] init] autorelease];
                    UIViewController* rootVC = [self.adView.superview viewControllerForView];
                    if (rootVC) {
                        [rootVC presentModalViewController:self.expandVC animated:NO];
                    }
                    
                    if (url) {                        
                        self.expandView = [[[MASTExpandWebView alloc] initWithFrame:CGRectMake(0, 0, w, h)] autorelease];
                        self.expandView.adView = self.adView;
                        self.expandView.backgroundColor = expandBackgroundColor;
                        
                        [expandVC.view addSubview:self.expandView];

                        [self.expandView loadUrl:url];
                    } else {
                        // to make shure
                        self.expandView = nil;
                        self.lastBackgroundColor = self.adView.backgroundColor;
                        self.adView.backgroundColor = expandBackgroundColor;
                        
                        CGRect newFrame = [self.adView.superview convertRect:self.adView.frame toView:expandVC.view];
                        self.lastSuperView = self.adView.superview;
                        [expandVC.view addSubview:self.adView];
                        self.adView.frame = newFrame;
                        
                        CGFloat originY = 20;
                        if ([UIApplication sharedApplication].isStatusBarHidden) {
                            originY = 0;
                        }
                        
                        // resize
                        
                        self.adView.frame = CGRectMake(newFrame.origin.x, originY, w, h);
                        [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
                        /*[UIView animateWithDuration:0.2 animations:^(void) {
                            self.adView.frame = CGRectMake(newFrame.origin.x, originY, w, h);
                        } completion:^(BOOL finished) {
                            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
                        }];*/
                    }
                }
            }
        }
    } else if ([event isEqualToString:ORMMA_EVENT_RESIZE]) {
        if (self.currentState != ORMMAStateDefault) {
            // Already Resized
            [self evalJS:[MASTOrmmaHelper fireError:kErrorResizeInvalidStateMessage forEvent:event]];
        } else {
            self.currentState = ORMMAStateResized;
            self.nonHideState = self.currentState;
            CGFloat w = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"w"];
            if (w > maxSize.width) {
                [self evalJS:[MASTOrmmaHelper fireError:kErrorResizeLargerSizeMessage forEvent:event]];
            } else {
                CGFloat h = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"h"];
                if (h > maxSize.height) {
                    [self evalJS:[MASTOrmmaHelper fireError:kErrorResizeLargerSizeMessage forEvent:event]];
                } else {
                    //[[NotificationCenter sharedInstance] postNotificationName:kAdStopUpdateNotification object:self.adView];
                    
                    self.adView.frame = CGRectMake(self.adView.frame.origin.x, self.adView.frame.origin.y, w, h);
                    [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
                    /*[UIView animateWithDuration:0.2 animations:^(void) {
                        self.adView.frame = CGRectMake(self.adView.frame.origin.x, self.adView.frame.origin.y, w, h);
                    } completion:^(BOOL finished) {
                        [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
                    }];*/
                }
            }
        }
    } else if ([event isEqualToString:ORMMA_EVENT_ADDASSET]) {
        //
    } else if ([event isEqualToString:ORMMA_EVENT_REMOVEASSET]) {
        //
    } else if ([event isEqualToString:ORMMA_EVENT_REMOVE_ALL_ASSET]) {
        //
    } else if ([event isEqualToString:ORMMA_EVENT_CALENDAR]) {        
        NSString *dateString = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                                  forKey:@"date"];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyyMMddHHmm"];
        NSDate *date = [formatter dateFromString:dateString];
        
        NSString *title = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                             forKey:@"title"];
        NSString *body = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                            forKey:@"body"];
        if (date && title && body) {
            // handle internally
            EKEventStore* eventStore = [[[EKEventStore alloc] init] autorelease];
            EKEvent* ekEvent = [EKEvent eventWithEventStore:eventStore];
            ekEvent.title = title;
            
            ekEvent.notes = body;
            
            ekEvent.startDate = date;
            ekEvent.endDate   = [[[NSDate alloc] initWithTimeInterval:600 
                                                           sinceDate:ekEvent.startDate] autorelease];
            [ekEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
            
            RIButtonItem *noItem = [RIButtonItem item];
            noItem.label = @"No";
            
            RIButtonItem *yesItem = [RIButtonItem item];
            yesItem.label = @"Yes";
            yesItem.action = ^ {
                BOOL status = [eventStore saveEvent:ekEvent 
                                               span:EKSpanThisEvent 
                                              error:nil]; 
                if (status) {
                    UIAlertView *eventSavedSuccessfully = [[[UIAlertView alloc] initWithTitle:kAlertEventStatutsTitle
                                                                                     message:kAlertEventAddedMessage 
                                                                                    delegate:nil 
                                                                           cancelButtonTitle:@"Ok" 
                                                                           otherButtonTitles:nil] autorelease];
                    [eventSavedSuccessfully show];
                } else {
                    UIAlertView *eventSavedUNSuccessfully = [[[UIAlertView alloc] initWithTitle:kAlertEventStatutsTitle 
                                                                                       message:kAlertEventNotAddedMessage
                                                                                      delegate:nil 
                                                                             cancelButtonTitle:@"Ok" 
                                                                             otherButtonTitles:nil] autorelease];
                    [eventSavedUNSuccessfully show];
                }
            };
            
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:kAlertEventStatutsTitle
                                                                message:kAlertEventSaveMessage
                                                       cancelButtonItem:noItem 
                                                       otherButtonItems:yesItem, nil] autorelease];
            [alertView show];         
        }
    } else if ([event isEqualToString:ORMMA_EVENT_CAMERA]) {
        //
    } else if ([event isEqualToString:ORMMA_EVENT_EMAIL]) {
        NSString *to = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"to"];
        NSString *subject = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"subject"];
        NSString *body = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"body"];
        BOOL html = [MASTOrmmaHelper booleanFromDictionary:parameters forKey:@"html"];
        if (body && to && subject) {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *vc = [[[MFMailComposeViewController alloc] init] autorelease];
                NSArray *recipients = [NSArray arrayWithObject:to];
                [vc setToRecipients:recipients];
                [vc setSubject:subject];
                [vc setMessageBody:body  isHTML:html];
                vc.mailComposeDelegate = self;
                
                UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
                if (!rvc) {
                    rvc = [[UIApplication sharedApplication].keyWindow viewControllerForView];
                }
                if (!rvc) {
                    rvc = [self.adView viewControllerForView];
                }
                [rvc presentModalViewController:vc animated:YES];
            } else {
                [self evalJS:[MASTOrmmaHelper fireError:kErrorDeviceCannotSendEmailMessage forEvent:event]];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:kErrorEmailFieldsNotRequiredMessage forEvent:event]];
        }
    } else if ([event isEqualToString:ORMMA_EVENT_PHONE]) {
        NSString *phoneNumber = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                                   forKey:@"number"];
        [self click:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
    } else if ([event isEqualToString:ORMMA_EVENT_SMS]) {
        NSString *to = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"to"];
        NSString *body = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"body"];
        if (body && to && NSClassFromString(@"MFMessageComposeViewController") && [MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *vc = [[[MFMessageComposeViewController alloc] init] autorelease];
            NSArray *recipients = [NSArray arrayWithObject:to];
            vc.recipients = recipients;
            vc.body = body;
            vc.messageComposeDelegate = self;
            
            UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (!rvc) {
                rvc = [[UIApplication sharedApplication].keyWindow viewControllerForView];
            }
            if (!rvc) {
                rvc = [self.adView viewControllerForView];
            }
            [rvc presentModalViewController:vc animated:YES];
        }
    } else if ([event isEqualToString:ORMMA_EVENT_OPEN]) {
        NSString *url = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                           forKey:@"url"];
        [self click:url];
    } else if ([event isEqualToString:ORMMA_EVENT_OPEN_MAP]) {
        NSString *poi = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                           forKey:@"url"];
        [self click:[NSString stringWithFormat:@"%@%@", kGoogleMapsUrl, [poi stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    } else if ([event isEqualToString:ORMMA_EVENT_PLAY_AUDIO]) {
        NSString *url = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:url forKey:@"url"];
        [info setObject:self.adView forKey:@"adView"];
        [info setObject:parameters forKey:@"properties"];
        [[MASTNotificationCenter sharedInstance] postNotificationName:kPlayAudioNotification object:info];
    } else if ([event isEqualToString:ORMMA_EVENT_PLAY_VIDEO]) {
        NSString *url = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:url forKey:@"url"];
        [info setObject:self.adView forKey:@"adView"];
        [info setObject:parameters forKey:@"properties"];
        [[MASTNotificationCenter sharedInstance] postNotificationName:kPlayVideoNotification object:info];
    } else if ([event isEqualToString:ORMMA_EVENT_REQUEST]) {
        NSString *uri = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"uri"];
        NSString *display = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"display"];
        NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]];
        
        if ([display isEqualToString:@"proxy"]) {
            Reachability* reachability = [Reachability reachabilityForInternetConnection];
            if ([reachability currentReachabilityStatus] == NotReachable) {
                [MASTObjectStorage objectForKey:uri block:^(id obj) {
                    NSData* cachedData = obj;
                    if (cachedData) {
                        [self evalJS:[MASTOrmmaHelper fireResponseEvent:cachedData uri:uri]];
                    }
                }];
            } else {
                [MASTNetworkQueue loadWithRequest:req completion:^(NSURLRequest *r, NSHTTPURLResponse *response, NSData *data, NSError *error) {
                    if (!error) {
                        [self evalJS:[MASTOrmmaHelper fireResponseEvent:data uri:uri]];
                        [MASTObjectStorage storeObject:data key:uri];
                    }
                }];
            }
        } else if ([display isEqualToString:@"ignore"]) {
            [MASTNetworkQueue loadWithRequest:req completion:^(NSURLRequest *r, NSHTTPURLResponse *response, NSData *data, NSError *error) {
                if (!error) {
                    [MASTObjectStorage storeObject:data key:uri];
                }
            }];
        } else {
            [MASTNetworkQueue loadWithRequest:req completion:^(NSURLRequest *r, NSHTTPURLResponse *response, NSData *data, NSError *error) {
                if (!error) {
                    [self evalJS:[MASTOrmmaHelper fireResponseEvent:data uri:uri]];
                }
            }];
        }
    } else if ([event isEqualToString:ORMMA_EVENT_SERVICE]) {
        NSString *name = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"name"];
        NSString *enabled = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"enabled"];
        if ([name isEqualToString:@"headingChange"] && [enabled isEqualToString:@"Y"]) {
            [[MASTLocationManager sharedInstance] startUpdatingHeading];
        }
    }
    
    // send callback
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    [info setObject:self.adView forKey:@"adView"];
    [info setObject:event forKey:@"event"];
    [info setObject:parameters forKey:@"dic"];
    [[MASTNotificationCenter sharedInstance] postNotificationName:kORMMAEventNotification object:info];
}

- (void)moveToDefaultState {
    if (self.currentState == ORMMAStateResized || self.currentState == ORMMAStateExpanded) {
        [self processEvent:ORMMA_EVENT_CLOSE parameters:[NSDictionary dictionary]];
    }
}

- (void)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self isOrmma:request]) {
        //NSLog(@"Dev log: %@", [[request URL] absoluteString]);
        
        // notify JS that we've completed the last request
        NSString* event = [[[request URL] host] lowercaseString];
        NSDictionary* parameters = [MASTOrmmaHelper parametersFromJSCall:[[request URL] query]];
        [self evalJS:[MASTOrmmaHelper nativeCallComplete:event]];
        
        [self processEvent:event parameters:parameters];
    }
}

- (void)viewVisible:(NSNotification*)notification {
	MASTAdView* adViewNotify = [notification object];
    if (adViewNotify == self.adView) {
        [self evalJS:[MASTOrmmaHelper setViewable:YES]];
	}
}

- (void)viewInvisible:(NSNotification*)notification {
	MASTAdView* adViewNotify = [notification object];
    if (adViewNotify == self.adView) {
        [self evalJS:[MASTOrmmaHelper setViewable:NO]];
	}
}

- (void)invalidate:(NSNotification*)notification {
	MASTAdView* adViewNotify = [notification object];
    if (adViewNotify == self.adView) {
        self.adView = nil;
        self.webView = nil;
		[[MASTNotificationCenter sharedInstance] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[MASTAccelerometer sharedInstance] removeDelegate:self];
	}
}

- (void)frameChanged:(NSNotification*)notification {
    NSDictionary* info = [notification object];
	MASTAdView* adViewNotify = [info objectForKey:@"adView"];
    if (adViewNotify == self.adView) {
        NSValue* frameValue = [info objectForKey:@"newFrame"];
        CGRect newFrame = [frameValue CGRectValue];
        
        if (self.currentState != ORMMAStateResized && self.currentState != ORMMAStateExpanded) {
            self.defaultFrame = newFrame;
        }
        
        [self evalJS:[MASTOrmmaHelper setSize:newFrame.size]];
        [self evalJS:[MASTOrmmaHelper setDefaultPosition:newFrame]];
	}
}


#pragma mark - Notification Center Dispatch Methods


- (void)orientationChanged:(NSNotification *)notification {
	UIDevice *device = [UIDevice currentDevice];
    UIDeviceOrientation orientation = device.orientation;
    
    [self evalJS:[MASTOrmmaHelper setOrientation:orientation]];
    
	CGSize screenSize = [MASTOrmmaHelper screenSizeForOrientation:orientation];	
    [self evalJS:[MASTOrmmaHelper setScreenSize:screenSize]];
    
    // TODO
    //[self.bridgeDelegate rotateExpandedWindowsToCurrentOrientation];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    [self evalJS:[MASTOrmmaHelper setKeyboardShow:true]];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    [self evalJS:[MASTOrmmaHelper setKeyboardShow:false]];
}


- (void)handleReachabilityChangedNotification:(NSNotification *)notification {
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
	[self evalJS:[MASTOrmmaHelper setNetwork:[reachability currentReachabilityStatus]]];
}

- (void)locationDetected:(NSNotification*)notification {
#ifdef INCLUDE_LOCATION_MANAGER
    CLLocation* location = [notification object];
    [self evalJS:[OrmmaHelper setLatitude:location.coordinate.latitude longitude:location.coordinate.longitude accuracy:location.horizontalAccuracy]];
#endif   
}

- (void)headingDetected:(NSNotification*)notification {
#ifdef INCLUDE_LOCATION_MANAGER
    CLHeading* heading = [notification object];
    [self evalJS:[OrmmaHelper setHeading:heading.trueHeading]];
#endif
}

- (void)expandViewClosed:(NSNotification*)notification {
    NSDictionary* info = [notification object];
	MASTAdView* adViewNotify = [info objectForKey:@"adView"];
    if (adViewNotify == self.adView) {
        self.currentState = ORMMAStateDefault;
        self.nonHideState = self.currentState;
        [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
	}
}


#pragma mark - Accelerometer Delegete

         
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// Send accelerometer data
    [self evalJS:[MASTOrmmaHelper setTilt:acceleration]];
	
	// Deal with shakes
    BOOL shake = NO;
    CGFloat kDefaultShakeIntensity = 1.5;
    if ((acceleration.x > kDefaultShakeIntensity) || (acceleration.x < (-1 * kDefaultShakeIntensity))) {
        shake = YES;
    }
    
    if ((acceleration.x > kDefaultShakeIntensity) || (acceleration.x < (-1 * kDefaultShakeIntensity))) {
        shake = YES;
    }
    
    if ((acceleration.x > kDefaultShakeIntensity) || (acceleration.x < (-1 * kDefaultShakeIntensity))) {
        shake = YES;
    }
    
    if (shake) {
        // Shake detected
        [self evalJS:[MASTOrmmaHelper fireShakeEventInWebView]];
    }
}


#pragma mark - MFMessageComposeViewController Delegete


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rvc) {
        rvc = [[UIApplication sharedApplication].keyWindow viewControllerForView];
    }
    if (!rvc) {
        rvc = [self.adView viewControllerForView];
    }
    [rvc dismissModalViewControllerAnimated:YES];
}


#pragma mark - MFMailComposeViewController Delegate


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    UIViewController* rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rvc) {
        rvc = [[UIApplication sharedApplication].keyWindow viewControllerForView];
    }
    if (!rvc) {
        rvc = [self.adView viewControllerForView];
    }
    [rvc dismissModalViewControllerAnimated:YES];
}


@end

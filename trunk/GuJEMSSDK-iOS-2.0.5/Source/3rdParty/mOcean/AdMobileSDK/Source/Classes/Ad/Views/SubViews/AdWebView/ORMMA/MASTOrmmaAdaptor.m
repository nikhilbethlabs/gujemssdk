//
//  MSFTOrmmaAdaptor.m
//

#import "MASTOrmmaAdaptor.h"
#import "MASTOrmmaConstants.h"
#import "MASTOrmmaHelper.h"
#import "MASTReachability.h"
#import "MAPNSObject+BlockObservation.h"
#import "Macros.h"
#import "MASTNotificationCenter.h"
#import "MASTOrmmaSharedDataSource.h"
#import "MASTAdView_Private.h"


#define ORMMA_SHAME     @"ormma"

@interface MASTOrmmaAdaptor()

@property (nonatomic, assign) BOOL              valid;
@property (nonatomic, assign) UIWebView*        webView;
@property (nonatomic, assign) UIView*           adView;
@property (nonatomic, assign) ORMMAState        nonHideState;
@property (nonatomic, assign) ORMMAState        currentState;

- (void)evalJS:(NSString*)js;

@end

@implementation MASTOrmmaAdaptor

@synthesize ormmaDelegate, ormmaDataSource;
@synthesize valid, webView, adView, nonHideState, currentState;

- (id)initWithWebView:(UIWebView*)view adView:(UIView*)ad {
    self = [super init];
    if (self) {
        self.webView = view;
        self.adView = ad;
        self.valid = YES;
        self.ormmaDataSource = [MASTOrmmaSharedDataSource sharedInstance];
		
        [[NSNotificationCenter defaultCenter] addObserverForName:kOrmmaLocationUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary* info = [note object];
			CLLocation* location = [info objectForKey:kOrmmaKeyObject];
            [self evalJS:[MASTOrmmaHelper setLatitude:location.coordinate.latitude longitude:location.coordinate.longitude accuracy:location.horizontalAccuracy]];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kOrmmaHeadingUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary* info = [note object];
            NSNumber* heading = [info objectForKey:kOrmmaKeyObject];
            [self evalJS:[MASTOrmmaHelper setHeading:[heading floatValue]]];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kOrmmaTiltUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary* info = [note object];
            CMAccelerometerData* acceleration = [info objectForKey:kOrmmaKeyObject];
            [self evalJS:[MASTOrmmaHelper setTilt:acceleration]];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kOrmmaShake object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self evalJS:[MASTOrmmaHelper fireShakeEventInWebView]];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            [self evalJS:[MASTOrmmaHelper setOrientation:orientation]];
            
            CGSize screenSize = [MASTOrmmaHelper screenSizeForOrientation:orientation];	
            [self evalJS:[MASTOrmmaHelper setScreenSize:screenSize]];
            
            CGSize expandSize = screenSize;
            [self evalJS:[MASTOrmmaHelper setExpandPropertiesWithMaxSize:expandSize]];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (self.valid) {
                [self evalJS:[MASTOrmmaHelper setKeyboardShow:YES]];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (self.valid) {
                [self evalJS:[MASTOrmmaHelper setKeyboardShow:NO]];
            }
        }];
        [[MASTNotificationCenter sharedInstance] addObserverForName:kAdViewBecomeVisibleNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (note.object == self.adView && valid) {
                [self evalJS:[MASTOrmmaHelper setViewable:YES]];
            }
        }];
        [[MASTNotificationCenter sharedInstance] addObserverForName:kAdViewBecomeInvisibleNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (note.object == self.adView && valid) {
                [self evalJS:[MASTOrmmaHelper setViewable:NO]];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"kCloseExpandNotification" object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (note.object == self.adView && valid) {
                [self evalJS:@"ormma.close();"];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            MASTReachability* reachability = [MASTReachability reachabilityForInternetConnection];
            [self evalJS:[MASTOrmmaHelper setNetwork:[reachability currentReachabilityStatus]]];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:kOrmmaShake object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self evalJS:[MASTOrmmaHelper fireShakeEventInWebView]];
        }];
        
		[[MASTNotificationCenter sharedInstance] addObserverForName:kORMMASetDefaultStateNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (note.object == self.adView) {
                [self moveToDefaultState];
            }
        }];
        
        [self.webView addObserverForKeyPath:@"frame" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
            NSValue* frameValue = [change objectForKey:@"new"];
            CGRect newFrame = [frameValue CGRectValue];
            
            [self evalJS:[MASTOrmmaHelper setSize:newFrame.size]];
            [self evalJS:[MASTOrmmaHelper setDefaultPosition:newFrame]];
        }];
    }
    
    return self;
}

- (void)dealloc {
    self.webView = nil;
    self.adView = nil;
    self.ormmaDelegate = nil;
    self.ormmaDataSource = nil;

	[super dealloc];
}

- (BOOL)isOrmma:(NSURLRequest *)request {
    return [[[request URL] scheme] isEqualToString:ORMMA_SHAME];
}

- (void)webViewDidFinishLoad:(UIWebView*)view {
    [self evalJS:[MASTOrmmaHelper signalReadyInWebView]];
}

- (NSString*)getDefaultsJSCode {
    NSMutableString* result = [NSMutableString string];
    
    // Register up case 'Ormma' object
    [result appendString:[MASTOrmmaHelper registerOrmmaUpCaseObject]];
    
    // Default state
    self.currentState = ORMMAStateDefault;
    self.nonHideState = self.currentState;
    [result appendString:[MASTOrmmaHelper setState:self.currentState]];
    
    // Viewable
    [result appendString:[MASTOrmmaHelper setViewable:(!self.webView.window)]];
    
    // Network
    MASTReachability* reachability = [MASTReachability reachabilityForInternetConnection];
    [result appendString:[MASTOrmmaHelper setNetwork:[reachability currentReachabilityStatus]]];
    
    // Frame size
    [result appendString:[MASTOrmmaHelper setSize:self.webView.frame.size]];
    
    // Default position
    [result appendString:[MASTOrmmaHelper setDefaultPosition:self.adView.frame]];
    
    // Placement
    [result appendString:[MASTOrmmaHelper setPlacementInterstitial:NO]];
    
    // Orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [result appendString:[MASTOrmmaHelper setOrientation:orientation]];
    
    // Screen size
    CGSize screenSize = [MASTOrmmaHelper screenSizeForOrientation:orientation];
    [result appendString:[MASTOrmmaHelper setScreenSize:screenSize]];
    
    // Expand properties expandProperties
    CGSize expandSize = screenSize;
    [result appendString:[MASTOrmmaHelper setAllExpandPropertiesWithMaxSize:expandSize]];
        
    NSMutableArray* supports = [NSMutableArray array];
    [supports addObject:@"'level-1'"];
    [supports addObject:@"'level-2'"];
    [supports addObject:@"'level-3'"];
    [supports addObject:@"'network'"];
    [supports addObject:@"'screen'"];
    [supports addObject:@"'shake'"];
    [supports addObject:@"'size'"];
    [supports addObject:@"'orientation'"];
    
    if (self.ormmaDataSource) {        
        // Location
        if ([self.ormmaDataSource respondsToSelector:@selector(supportLocationForAd:)]) {
            if ([self.ormmaDataSource supportLocationForAd:self.adView]) {
                [supports addObject:@"'location'"];
                
                CLLocation* location = [[MASTLocationManager sharedInstance] lastLocation];
                if (location != nil) {
                    [self evalJS:[MASTOrmmaHelper setLatitude:location.coordinate.latitude longitude:location.coordinate.longitude accuracy:location.horizontalAccuracy]];
                }
            }  
        }
        
        // Heading
        if ([self.ormmaDataSource respondsToSelector:@selector(supportHeadingForAd:)]) {
            if ([self.ormmaDataSource supportHeadingForAd:self.adView]) {
                [supports addObject:@"'heading'"];
                
                CLHeading* heading = [[MASTLocationManager sharedInstance] lastHeading];
                if (heading != nil) {
                    NSNumber* headingNumber = [NSNumber numberWithDouble:heading.trueHeading];
                    [self evalJS:[MASTOrmmaHelper setHeading:[headingNumber floatValue]]];
                }
            }
        }
        
        if ([self.ormmaDataSource respondsToSelector:@selector(supportTiltForAd:)]) {
            if ([self.ormmaDataSource supportTiltForAd:self.adView]) {
                [supports addObject:@"'tilt'"];
            }
        }       
    }
    
    if (self.ormmaDelegate) {        
        if ([self.ormmaDelegate respondsToSelector:@selector(supportCalendarForAd:)]) {
            if ([self.ormmaDelegate supportCalendarForAd:self.adView]) {
                [supports addObject:@"'calendar'"];
            }
        }
        
        if ([self.ormmaDelegate respondsToSelector:@selector(supportPhoneForAd:)]) {
            if ([self.ormmaDelegate supportPhoneForAd:self.adView]) {
                [supports addObject:@"'phone'"];
            }
        }
        
        if ([self.ormmaDelegate respondsToSelector:@selector(supportEmailForAd:)]) {
            if ([self.ormmaDelegate supportEmailForAd:self.adView]) {
                [supports addObject:@"'email'"];
            }
        }
        
        if ([self.ormmaDelegate respondsToSelector:@selector(supportSmsForAd:)]) {
            if ([self.ormmaDelegate supportSmsForAd:self.adView]) {
                [supports addObject:@"'sms'"];
            }
        }
        
        if ([self.ormmaDelegate respondsToSelector:@selector(supportAudioForAd:)]) {
            if ([self.ormmaDelegate supportAudioForAd:self.adView]) {
                [supports addObject:@"'audio'"];
            }
        }
        
        if ([self.ormmaDelegate respondsToSelector:@selector(supportVideoForAd:)]) {
            if ([self.ormmaDelegate supportVideoForAd:self.adView]) {
                [supports addObject:@"'video'"];
            }
        }
        
        if ([self.ormmaDelegate respondsToSelector:@selector(supportMapForAd:)]) {
            if ([self.ormmaDelegate supportMapForAd:self.adView]) {
                [supports addObject:@"'map'"];
            }
        }
        
        // Max size
        if ([self.ormmaDelegate respondsToSelector:@selector(maxSizeForAd:)]) {
            CGSize maxSize = [self.ormmaDelegate maxSizeForAd:self.adView];
            [result appendString:[MASTOrmmaHelper setMaxSize:maxSize]];
        }
    }
    
    [result appendString:[MASTOrmmaHelper setSupports:supports]];
    
    return result;
}

- (void)invalidate {
    self.valid = NO;    
    [self.webView removeAllBlockObservers];
    self.ormmaDelegate = nil;
    self.ormmaDataSource = nil;
    self.webView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MASTNotificationCenter sharedInstance] removeObserver:self];
}

- (void)moveToDefaultState
{
    if (self.currentState == ORMMAStateDefault)
        return;
    
    if (self.currentState == ORMMAStateExpanded || self.currentState == ORMMAStateResized) {
        if ([self.ormmaDelegate respondsToSelector:@selector(closeFromState:ad:)]) {
            [self.ormmaDelegate closeFromState:self.currentState ad:self.adView];
        }
    }
    
    self.currentState = ORMMAStateDefault;
    self.nonHideState = self.currentState;
    [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
}

- (void)evalJS:(NSString*)js {
    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}

- (void)processEvent:(NSURLRequest*)request {
    NSString* event = [[[request URL] host] lowercaseString];
	NSLog(@"event = %@",event);
    NSString* query = [[request URL] query];
    NSDictionary* parameters = [MASTOrmmaHelper parametersFromJSCall:query];
    
    
    if ([self.ormmaDelegate respondsToSelector:@selector(debug:ad:)]) {
        [self.ormmaDelegate debug:query ad:self.adView];
    }
    
    if ([event isEqualToString:@"ormmaenabled"]) {
        //
    } else if ([event isEqualToString:@"show"]) {
        self.currentState = self.nonHideState;
        [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
        
        if ([self.ormmaDelegate respondsToSelector:@selector(showAd:)]) {
            [self.ormmaDelegate showAd:self.adView];
        }
        
        if (self.currentState == ORMMAStateDefault) {
            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStartUpdateNotification object:self.adView];
        }
    } else if ([event isEqualToString:@"hide"]) {
        if (self.currentState == ORMMAStateDefault) {
            self.nonHideState = self.currentState;
            self.currentState = ORMMAStateHidden;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            
            if ([self.ormmaDelegate respondsToSelector:@selector(hideAd:)]) {
                [self.ormmaDelegate hideAd:self.adView];
            }

            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStopUpdateNotification object:self.adView];
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot hide an ad that is not in the default state." forEvent:event]];
        }
    } else if ([event isEqualToString:@"close"]) {
        if (self.currentState == ORMMAStateDefault) {
            // do same as hide command
            self.nonHideState = self.currentState;
            self.currentState = ORMMAStateHidden;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            
            if ([self.ormmaDelegate respondsToSelector:@selector(hideAd:)]) {
                [self.ormmaDelegate hideAd:self.adView];
            }
        } else if (self.currentState == ORMMAStateHidden) {
            // hidden ad, nothing to do
        } else if (self.currentState == ORMMAStateExpanded || self.currentState == ORMMAStateResized) {            
            if ([self.ormmaDelegate respondsToSelector:@selector(closeFromState:ad:)]) {
                [self.ormmaDelegate closeFromState:self.currentState ad:self.adView];
            }
            
            self.currentState = ORMMAStateDefault;
            self.nonHideState = self.currentState;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];

            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStartUpdateNotification object:self.adView];
        }
    } else if ([event isEqualToString:@"expand"]) {
        if (self.currentState == ORMMAStateDefault) {
            self.currentState = ORMMAStateExpanded;
            self.nonHideState = self.currentState;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            
            NSString* url = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
            if ([self.ormmaDelegate respondsToSelector:@selector(expandURL:parameters:ad:)]) {
                [self.ormmaDelegate expandURL:url parameters:parameters ad:self.adView];
            }

            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStopUpdateNotification object:self.adView];
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot expand an ad that is not in the default state." forEvent:event]];
        }
    } else if ([event isEqualToString:@"resize"]) {
        if (self.currentState != ORMMAStateDefault) {
            // Already Resized
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot resize an ad that is not in the default state." forEvent:event]];
        } else {
            self.currentState = ORMMAStateResized;
            self.nonHideState = self.currentState;
            [self evalJS:[MASTOrmmaHelper setState:self.currentState]];
            
            CGFloat w = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"w"];
            CGFloat h = [MASTOrmmaHelper floatFromDictionary:parameters forKey:@"h"];
            if ([self.ormmaDelegate respondsToSelector:@selector(resize:ad:)]) {
                [self.ormmaDelegate resize:CGSizeMake(w, h) ad:self.adView];
            }
            
            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStopUpdateNotification object:self.adView];
        }
    } else if ([event isEqualToString:@"addasset"]) {
        //
    } else if ([event isEqualToString:@"removeasset"]) {
        //
    } else if ([event isEqualToString:@"removeallassets"]) {
        //
    } else if ([event isEqualToString:@"calendar"]) {
        NSString *dateString = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                                      forKey:@"date"];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyyMMddHHmm"];
        NSDate *date = [formatter dateFromString:dateString];
        
        NSString *title = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                                 forKey:@"title"];
        NSString *body = [MASTOrmmaHelper requiredStringFromDictionary:parameters 
                                                               forKey:@"body"];
        if (date && IS_POPULATED_STRING(title) && IS_POPULATED_STRING(body)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(calendar:body:date:ad:)]) {
                [self.ormmaDelegate calendar:title body:body date:date ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot create calendar event: date, title and body are required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"camera"]) {
        //
    } else if ([event isEqualToString:@"email"]) {
        NSString *to = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"to"];
        NSString *subject = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"subject"];
        NSString *body = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"body"];
        BOOL html = [MASTOrmmaHelper booleanFromDictionary:parameters forKey:@"html"];
        if (IS_POPULATED_STRING(body) && IS_POPULATED_STRING(to) && IS_POPULATED_STRING(subject)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(email:subject:body:useHtml:ad:)]) {
                [self.ormmaDelegate email:to subject:subject body:body useHtml:html ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot send email: body, subject and to are required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"phone"]) {
        NSString *phoneNumber = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"number"];
        if (IS_POPULATED_STRING(phoneNumber)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(phone:ad:)]) {
                [self.ormmaDelegate phone:phoneNumber ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot call: phone number is required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"sms"]) {
        NSString *to = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"to"];
        NSString *body = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"body"];
        if (IS_POPULATED_STRING(body) && IS_POPULATED_STRING(to)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(sms:body:ad:)]) {
                [self.ormmaDelegate sms:to body:body ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot send sms: body and to are required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"open"]) {
        NSString *url = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
        if (IS_POPULATED_STRING(url)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot open url: url is required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"openmap"]) {
        NSString *poi = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
        if (IS_POPULATED_STRING(poi)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(openMapWithPOI:ad:)]) {
                [self.ormmaDelegate openMapWithPOI:poi ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot open map: poi is required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"playaudio"]) {
        NSString *url = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
        if (IS_POPULATED_STRING(url)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(playAudio:parameters:ad:)]) {
                [self.ormmaDelegate playAudio:url parameters:parameters ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot play audio: url is required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"playvideo"]) {
        NSString *url = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"url"];
        if (IS_POPULATED_STRING(url)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(playVideo:parameters:ad:)]) {
                [self.ormmaDelegate playVideo:url parameters:parameters ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot play video: url is required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"request"]) {
        NSString *uri = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"uri"];
        NSString *display = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"display"];
        if (IS_POPULATED_STRING(uri)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(sendRequest:display:response:ad:)]) {
                [self.ormmaDelegate sendRequest:uri display:display response:^(NSString *response) {
                    if (IS_POPULATED_STRING(response)) {
                        [self evalJS:[MASTOrmmaHelper fireResponseEvent:response uri:uri]];
                    } else {
                        [self evalJS:[MASTOrmmaHelper fireError:@"Cannot send request: error while sending request." forEvent:event]];
                    }
                } ad:self.adView];
            }
        } else {
            [self evalJS:[MASTOrmmaHelper fireError:@"Cannot send request: uri is required." forEvent:event]];
        }
    } else if ([event isEqualToString:@"service"]) {
        NSString *name = [MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"name"];
        BOOL enabled = [[MASTOrmmaHelper requiredStringFromDictionary:parameters forKey:@"enabled"] isEqualToString:@"enabled"];
        if (IS_POPULATED_STRING(name)) {
            if ([self.ormmaDelegate respondsToSelector:@selector(service:enabled:ad:)]) {
                [self.ormmaDelegate service:name enabled:enabled ad:self.adView];
            }
        }
    }
        
    // send callback
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    [info setObject:self.adView forKey:@"adView"];
    [info setObject:event forKey:@"event"];
    [info setObject:parameters forKey:@"dic"];
    [[MASTNotificationCenter sharedInstance] postNotificationName:kORMMAEventNotification object:info];

}

- (void)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self isOrmma:request]) {
        //NSLog(@"Dev log: %@", [[request URL] absoluteString]);
        
        // notify JS that we've completed the last request
        NSString* event = [[[request URL] host] lowercaseString];
        [self evalJS:[MASTOrmmaHelper nativeCallComplete:event]];
        
        [self processEvent:request];
    }
}

- (BOOL)isDefaultState {
    if (self.currentState == ORMMAStateDefault)
        return YES;
    
    return NO;
}

@end
//
//  AdView.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import "MASTAdView.h"
#import "MASTAdView_Private.h"
#import "MASTAdDescriptor.h"
#import "MASTUIViewAdditions.h"
#import "MASTUtils.h"
#import "QSStrings.h"

#import "MASTNotificationCenter.h"
#import "MASTLocationManager.h"

#import "MASTAdWebView.h"
#import "MASTVideoView.h"

#import "MASTLocationManager.h"
#import "MASTMessages.h"

#import "MAPNSObject+BlockObservation.h"
#import "MASTOrmmaSharedDelegate.h"
#import "MASTOrmmaSharedDataSource.h"

@interface MASTAdView()  

- (void)closeInterstitial:(NSNotification*)notification;
- (void)scheduledButtonAction;

@end

@implementation MASTAdView

@synthesize closeButton, ormmaDataSource, ormmaDelegate;
@dynamic adModel, uid;

@dynamic delegate, isLoading, testMode, logMode, isAdChangeAnimated, injectionHeaderCode, track, updateTimeInterval,
defaultImage, site, zone, premium, type, keywords, minSize, maxSize, textColor, additionalParameters,
adServerUrl, country, region, city, area, metro, dma, zip, carrier, latitude, longitude, adCallTimeout, autoCollapse, showPreviousAdOnError, autocloseInterstitialTime, showCloseButtonTime, udid;


+ (void)setLocationDetectionEnabledWithPupose:(NSString*)purpose
                          significantUpdating:(BOOL)significantUpdating
                               headingUpdates:(BOOL)headingUpdates
                               distanceFilter:(CLLocationDistance)distanceFilter
                              desiredAccuracy:(CLLocationAccuracy)desiredAccuracy
                                headingfilter:(CLLocationDegrees)headingfilter {
    
    NSMutableDictionary* settings = [NSMutableDictionary dictionary];
    [settings setValue:purpose forKey:kLocationManagerPurpose];
    [settings setValue:[NSNumber numberWithBool:significantUpdating] forKey:kLocationManagerSignificantUpdating];
    [settings setValue:[NSNumber numberWithBool:headingUpdates] forKey:kLocationManagerHeadingUpdates];
    [settings setValue:[NSNumber numberWithDouble:distanceFilter] forKey:kLocationManagerDistanceFilter];
    [settings setValue:[NSNumber numberWithDouble:desiredAccuracy] forKey:kLocationManagerDesiredAccuracy];
    [settings setValue:[NSNumber numberWithDouble:headingfilter] forKey:kLocationManagerHeadingFilter];
    
    [[MASTNotificationCenter sharedInstance] postNotificationName:kLocationManagerStart object:settings];
}

+ (void)setLocationDetectionEnabled:(BOOL)enabled {
    
    NSString* notifcationName = kLocationManagerStop;
    
    if (enabled)
        notifcationName = kLocationManagerStart;
    
    [[MASTNotificationCenter sharedInstance] postNotificationName:notifcationName object:nil];
}

+ (BOOL)isLocationDetectionEnabled {
    BOOL isLocationDetectionEnabled = [[MASTLocationManager sharedInstance] locationDetectionActive];
    return isLocationDetectionEnabled;
}

#pragma mark -

- (id)init {
	return nil;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		_adModel = [MASTAdModel new];
		((MASTAdModel*)_adModel).adView = self;
		((MASTAdModel*)_adModel).frame = frame;
		_observerSet = NO;
		
        [self registerObserver];
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
			   site:(NSInteger)site
			   zone:(NSInteger)zone {
    
    self = [super initWithFrame:frame];
    if (self) {
		_adModel = [MASTAdModel new];
		((MASTAdModel*)_adModel).adView = self;
		((MASTAdModel*)_adModel).frame = frame;
		_observerSet = NO;
		
		[self setSite:site];
		[self setZone:zone];
		
        [self registerObserver];
        [self setDefaultValues];
    }
    return self;
}

- (oneway void)release {
	if ([self retainCount] == 3 && _observerSet) {
        _observerSet = NO;
        [[MASTNotificationCenter sharedInstance] postNotificationName:kUnregisterAdNotification object:self];
        [self removeObserver:self forKeyPath:@"frame"];
        [self removeObserver:self forKeyPath:@"hidden"];
        [[MASTNotificationCenter sharedInstance] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [super release];
    }
    else if ([self retainCount] == 1 && ![NSThread isMainThread]) {
        [super performSelectorOnMainThread:@selector(release) withObject:nil waitUntilDone:NO];
    }
    else {
        [super release];
    }
}

- (void)dealloc {    
    // disable logging
    [self setLogMode:AdLogModeNone];
    self.closeButton = nil;
    
    ((MASTAdModel*)_adModel).adView = nil;
    self.delegate = nil; 
    RELEASE_SAFELY(_adModel);
    
	self.ormmaDelegate = nil;
    self.ormmaDataSource = nil;
	
    [super dealloc];
}

- (void)resetState {
    // Stop the timer and the view from listening to any updates.
    [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStopUpdateNotification object:self];
    
    if ([[_adModel currentAdView] isKindOfClass:[MASTAdWebView class]]) {
        [(MASTAdWebView*)[_adModel currentAdView] reset];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClosedAd:usageTimeInterval:)]) {
            NSDate* _startDate = ((MASTAdModel*)_adModel).startDisplayDate;
            NSTimeInterval timeInterval = -[_startDate timeIntervalSinceNow];
            [self.delegate didClosedAd:self usageTimeInterval:timeInterval];
        }
    }
    else if (self.showCloseButtonTime != 0 || self.autocloseInterstitialTime != 0) {
        //close interstitial
        id currentAdView = [_adModel currentAdView];
        if (currentAdView != nil) {
            [self scheduledButtonAction];
        }
    }
    
    //cloase ORMMA and set it in default state
    [[MASTNotificationCenter sharedInstance] postNotificationName:kORMMASetDefaultStateNotification object:self];
}

#pragma mark -
#pragma mark Public

- (void)callUpdateInBackground {
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
    
    // Resart the timer and notify the ad to accept updates
    [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStartUpdateNotification object:self];
    [[MASTNotificationCenter sharedInstance] postNotificationName:kAdUpdateNowNotification object:self];
    
    [pool release];
}

- (void)update {
    [self resetState];
    [self performSelectorInBackground:@selector(callUpdateInBackground) withObject:nil];
}

- (void)stopEverythingAndNotfiyDelegateOnCleanup {
    //stop ad update and cancel all network proccess
    [_adModel cancelAllNetworkConnection];
    
    //close internal browser
    [_adModel closeInternalBrowser];
    
    [self resetState];
}

#pragma mark -
#pragma mark Private

- (void)setDefaultValues {
    self.backgroundColor = [UIColor clearColor];
    self.updateTimeInterval = DEFAULT_UPDATE_TIMEINTERVAL; // 2min
    self.isAdChangeAnimated = NO;
    self.internalOpenMode = NO;
    self.testMode = NO;
    self.premium = AdPremiumBoth;
    self.adCallTimeout = DEFAULT_TIMEOUT_VALUE; //1 sec
    self.maxSize = CGSizeZero;
    self.autoCollapse = YES;
    self.showPreviousAdOnError = YES;
    self.autocloseInterstitialTime = -1;
    self.showCloseButtonTime = -1;
    
    [self setLogMode:AdLogModeErrorsOnly];
    
    ((MASTAdModel*)_adModel).loading = NO;
    ((MASTAdModel*)_adModel).track = -1;
    ((MASTAdModel*)_adModel).isDisplayed = NO;
    
    if ([[MASTLocationManager sharedInstance] locationDetectionActive]) {
        CLLocation* location = [[MASTLocationManager sharedInstance] lastLocation];
        if (location != nil) {
            if (location.horizontalAccuracy >= 0) {
                self.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
                self.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
            }
        }
    }
}

- (void)registerObserver {
    // callback
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(startAdDownload:) name:kGetAdServerResponseNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(adDisplayd:) name:kAdDisplayedNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(openInternalBrowser:) name:kOpenInternalBrowserNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(adShouldOpenBrowser:) name:kShouldOpenInternalBrowserNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(adShouldOpenExternalApp:) name:kShouldOpenExternalAppNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(closeInternalBrowser:) name:kCloseInternalBrowserNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(failToReceiveAd:) name:kInvalidParamsServerResponseNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(failToReceiveAd:) name:kEmptyServerResponseNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(failToReceiveAd:) name:kFailAdDownloadNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(failToReceiveAd:) name:kFailAdDisplayNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(ormmaEvent:) name:kORMMAEventNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(receiveThirdParty:) name:kThirdPartyNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(closeInterstitial:) name:kInterstitialAdCloseNotification object:nil];
    
	
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(addDefaultImage:) name:kAdDisplayDefaultImage object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(visibleAd:) name:kAdViewBecomeVisibleNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(invisibleAd:) name:kAdViewBecomeInvisibleNotification object:nil];
    
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(locationUpdate:) name:kLocationManagerLocationUpdate object:nil];
    
    // If the timer stops, then stop reciving events that update the ad.
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(startUpdate:) name:kAdStartUpdateNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(stopUpdate:) name:kAdStopUpdateNotification object:nil];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
	[[MASTNotificationCenter sharedInstance] postNotificationName:kRegisterAdNotification object:self];
	
	_observerSet = YES;
}

- (void)locationUpdate:(NSNotification*)notification {
    CLLocation* location = [notification object];
    if (location.horizontalAccuracy > 0) {
        self.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        self.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    }
}

- (void)startUpdate:(NSNotification*)notification {
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(adDownloaded:) name:kStartAdDisplayNotification object:nil];
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(updateAd:) name:kUpdateAdDisplayNotification object:nil];
    [[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(dislpayAd:) name:kReadyAdDisplayNotification object:nil];
}

- (void)stopUpdate:(NSNotification*)notification {
    [[MASTNotificationCenter sharedInstance] removeObserver:self name:kStartAdDisplayNotification object:nil];
    [[MASTNotificationCenter sharedInstance] removeObserver:self name:kUpdateAdDisplayNotification object:nil];
    [[MASTNotificationCenter sharedInstance] removeObserver:self name:kReadyAdDisplayNotification object:nil];
}

- (void)adDownloaded:(NSNotification*)notification {
	NSDictionary *info = [notification object];
	MASTAdView* adView = [info objectForKey:@"adView"];
	MASTAdDescriptor* descriptor = [info objectForKey:@"descriptor"];
	
	if (adView == self) {

        // Lock user interaction until the ad is displayed.
        self.userInteractionEnabled = NO;
        
        MASTAdModel* model = [self adModel];
        
        if (descriptor.adContentType == AdContentTypeDefaultHtml) {
			if (!self.ormmaDataSource) {
				self.ormmaDataSource = [MASTOrmmaSharedDataSource sharedInstance];
			}
			
			if (!self.ormmaDelegate) {
				self.ormmaDelegate = [MASTOrmmaSharedDelegate sharedInstance];
			}
			
            MASTAdWebView* adWebView = [[MASTAdWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            adWebView.tag = ORMMA_WEBVIEW_TAG;
            adWebView.adView = self;
            adWebView.hidden = YES;
			adWebView.ormmaDelegate = self.ormmaDelegate;
			adWebView.ormmaDataSource = self.ormmaDataSource;
			NSString *strHTML = [[[NSString alloc] initWithData:descriptor.serverReponse encoding:NSUTF8StringEncoding] autorelease]; 
            
			[adWebView loadHTML:strHTML 
                     completion:^(NSError *error)
            {
				if (error)
				{
					NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
					[senfInfo setObject:self forKey:@"adView"];
					[senfInfo setObject:adWebView forKey:@"subView"];
					[[MASTNotificationCenter sharedInstance] postNotificationName:kFailAdDisplayNotification object:senfInfo];
				}
				else
				{
					NSMutableDictionary* senfInfo = [NSMutableDictionary dictionary];
					[senfInfo setObject:self forKey:@"adView"];
					[senfInfo setObject:adWebView forKey:@"subView"];
					[[MASTNotificationCenter sharedInstance] postNotificationName:kReadyAdDisplayNotification object:senfInfo];

					[self addSubview:adWebView];
				}
			}
            injectionHeaderCode:(NSString*)adView.adModel.injectionHeaderCode];
            
            [adWebView release];            
            model.descriptor = descriptor;
		}
	}
}


- (void)updateAd:(NSNotification*)notification {
	NSDictionary *info = [notification object];
	MASTAdView* adView = [info objectForKey:@"adView"];
	
	if (adView == self) {
        MASTAdModel* model = [self adModel];
        if (model.currentAdView) {
            // all code removed
        }
    }
}

- (void)addDefaultImage:(NSNotification*)notification {
	MASTAdView *adView = [notification object];
    
    if (adView == self) {        
        MASTAdModel* model = [self adModel];
        UIImage* defaultImage = model.defaultImage;
        UIView* currentAdView = model.currentAdView;
        
        if (defaultImage) {
            // background
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            imageView.image = defaultImage;
            [self addSubview:imageView];
            [imageView release];
            
            if (!currentAdView) {
                // current view for animation
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                imageView.image = defaultImage;
                model.currentAdView = imageView;
                [self addSubview:imageView];
                [imageView release];
            }
        }
	}
}

- (void)showCloseButton {
    [self bringSubviewToFront:self.closeButton];
	self.closeButton.hidden = NO;
}

- (void)scheduledButtonAction {
    [self buttonsAction:self];
}

- (void)dislpayAd:(NSNotification*)notification {
	NSDictionary *info = [notification object];
	MASTAdView* adView = [info objectForKey:@"adView"];
	UIView* subView = [info objectForKey:@"subView"];
	
	if (adView == self) {        
        MASTAdModel* model = [self adModel];
        UIView* currentAdView = model.currentAdView;
        if (subView != currentAdView) {            
            if ([currentAdView isKindOfClass:[MASTAdWebView class]]) {
                //MASTAdWebView* adWebView = (MASTAdWebView*)currentAdView;
                //[adWebView closeOrmma];
            }
            
            UIView *oldView = currentAdView;
            [self adModel].snapshotRAWData = nil;
            
            model.currentAdView = subView;
            self.hidden = NO;
            subView.hidden = NO;
         
            // switch animation
            if (model.isAdChangeAnimated && currentAdView && subView) {
                CGRect prevAdFrame = subView.frame;
                CGRect startAdFrame = CGRectMake(prevAdFrame.origin.x-prevAdFrame.size.width, prevAdFrame.origin.y, prevAdFrame.size.width, prevAdFrame.size.height);
                subView.frame = startAdFrame;
                subView.alpha = 0.3;
                
                [UIView animateWithDuration:0.2 animations:^{
                    subView.frame = prevAdFrame;
                    CGRect newFrameForOldImage = CGRectMake(prevAdFrame.origin.x+prevAdFrame.size.width, prevAdFrame.origin.y, prevAdFrame.size.width, prevAdFrame.size.height);
                    currentAdView.frame = newFrameForOldImage;
                    subView.alpha = 1.0;
                    currentAdView.alpha = 0.3;
                    
                } completion:^(BOOL finished) {
                    [oldView removeFromSuperview];
                }];
            } else if (oldView) {
                [oldView removeFromSuperview];
            }
            
            if (!self.closeButton) {
                [self prepareResources];
                if (self.closeButton) {                    
                    self.closeButton.frame = CGRectMake(self.frame.size.width - self.closeButton.frame.size.width - 11, 11, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
                    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
                }
            }
            [self addSubview:self.closeButton];
            
            
            
            if (((MASTAdModel*)_adModel).showCloseButtonTime >= 0) {
                self.closeButton.hidden = YES;
                
                [NSTimer scheduledTimerWithTimeInterval:((MASTAdModel*)_adModel).showCloseButtonTime
                                                 target:self 
                                               selector:@selector(showCloseButton)
                                               userInfo:nil 
                                                repeats:NO];
            }
            
            if (((MASTAdModel*)_adModel).autocloseInterstitialTime >= 0) {
                [NSTimer scheduledTimerWithTimeInterval:((MASTAdModel*)_adModel).autocloseInterstitialTime
                                                 target:self 
                                               selector:@selector(scheduledButtonAction) 
                                               userInfo:nil 
                                                repeats:NO];
            }
            
            if (!((MASTAdModel*)_adModel).isDisplayed) {
                ((MASTAdModel*)_adModel).startDisplayDate = [NSDate date];
                ((MASTAdModel*)_adModel).isDisplayed = YES;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[MASTNotificationCenter sharedInstance] postNotificationName:kAdDisplayedNotification object:self];
            });
            
            self.userInteractionEnabled = YES;
        }
	}
}

- (void)visibleAd:(NSNotification*)notification {
}

- (void)invisibleAd:(NSNotification*)notification {
}

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
    
    NSString* path = [dirPath stringByAppendingPathComponent:@"closeIcon.png"];
    UIImage* closeIcon = nil;
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        NSData* imageData = [QSStrings decodeBase64WithString:kCloseIconB64];
        NSData* imageData2x = [QSStrings decodeBase64WithString:kCloseIcon2xB64];
        if ([self saveToMojivaFolderData:imageData name:@"closeIcon.png"] &&
            [self saveToMojivaFolderData:imageData2x name:@"closeIcon@2x.png"]) {
            closeIcon = [UIImage imageWithContentsOfFile:path];
        }
    } else {
        closeIcon = [UIImage imageWithContentsOfFile:path];
    }
    
    if (closeIcon && !self.closeButton) {
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.frame = CGRectMake(0, 0, closeIcon.size.width, closeIcon.size.height);
        [self.closeButton setImage:closeIcon forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
        self.closeButton.hidden = YES;
    }
}

- (void)buttonsAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClosedAd:usageTimeInterval:)]) {
        NSDate* _startDate = ((MASTAdModel*)_adModel).startDisplayDate;
        NSTimeInterval timeInterval = -[_startDate timeIntervalSinceNow];
        [self.delegate didClosedAd:self usageTimeInterval:timeInterval];
    } else {
        if (self.superview && self.window) {
            if ([sender isKindOfClass:[NSNotification class]]) {
                NSNotification* notification = sender;
                if ([notification object] == self) {
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kInterstitialAdCloseNotification object:self];
                    self.hidden = YES;
                } else if ([[notification object] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* info = [notification object];
                    MASTAdView* adView = [info objectForKey:@"adView"];
                    if (adView == self) {
                        [[MASTNotificationCenter sharedInstance] postNotificationName:kInterstitialAdCloseNotification object:self];
                        self.hidden = YES;
                    }
                }
            } else {
                [[MASTNotificationCenter sharedInstance] postNotificationName:kInterstitialAdCloseNotification object:self];
                self.hidden = YES;
            }
        }
    }
}

- (void)deviceOrientationDidChange:(NSNotification*)notification {
	MASTAdModel* model = [self adModel];
    model.snapshotRAWData = nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    NSData* rawData = [self adModel].snapshotRAWData;
    NSDate* lastTime = [self adModel].snapshotRAWDataTime;
    if (!(rawData && lastTime && abs([lastTime timeIntervalSinceNow]) < 1)) {
        // update cached data
        
        rawData = [self ARGBData];
        lastTime = [NSDate date];
        [self adModel].snapshotRAWData = rawData;
        [self adModel].snapshotRAWDataTime = lastTime;
    }
    
    if ([self isPointTransparent:point rawData:rawData]) {
        return NO;
    }
    
    return [super pointInside:point withEvent:event];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    BOOL newState = !self.hidden && newWindow;
    BOOL oldSate = [self adModel].visibleState;
    
    if (oldSate != newState) {
        // set new value
        [self adModel].visibleState = newState;
        
        if (oldSate == NO) {
            // ad become visible
            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdViewBecomeVisibleNotification object:self];
        } else {
            // ad become invisible
            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdViewBecomeInvisibleNotification object:self];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {    
    if ([keyPath isEqualToString:@"view.frame"] || [keyPath isEqualToString:@"frame"]) {
        //CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null]) {
            //oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            
            ((MASTAdModel*)_adModel).frame = newFrame;
        }        
        
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:self forKey:@"adView"];
        [info setObject:[NSValue valueWithCGRect:newFrame] forKey:@"newFrame"];
        
        [[MASTNotificationCenter sharedInstance] postNotificationName:kAdViewFrameChangedNotification object:info];
    } else if ([keyPath isEqualToString:@"hidden"]) {
        BOOL newState = [self isViewVisible];
        BOOL oldSate = [self adModel].visibleState;
        
        if (oldSate != newState) {
            // set new value
            [self adModel].visibleState = newState;
            
            if (oldSate == NO) {
                // ad become visible
                [[MASTNotificationCenter sharedInstance] postNotificationName:kAdViewBecomeVisibleNotification object:self];
            } else {
                // ad become invisible
                [[MASTNotificationCenter sharedInstance] postNotificationName:kAdViewBecomeInvisibleNotification object:self];
            }
        }
    }
}


#pragma mark - Callback


//- (void)willReceiveAd:(id)sender;
- (void)startAdDownload:(NSNotification*)notification {
    NSDictionary *info = [notification object];
    MASTAdView* adView = [info objectForKey:@"adView"];
	
	if (adView == self) {
        [self adModel].loading = YES;
        
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(willReceiveAd:)]) {
            [delegate willReceiveAd:self];
        }
    }
}

//- (void)didReceiveAd:(id)sender;
- (void)adDisplayd:(NSNotification*)notification {
    MASTAdView* adView = [notification object];
	
	if (adView == self) {
        [self adModel].loading = NO;
        
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(didReceiveAd:)]) {
            [delegate didReceiveAd:self];
        }
    }
}

//- (void)adWillStartFullScreen:(id)sender;
- (void)openInternalBrowser:(NSNotification*)notification {
    NSDictionary *info = [notification object];
    MASTAdView* adView = [info objectForKey:@"adView"];
	
	if (adView == self) {
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(adWillStartFullScreen:)]) {
            [delegate adWillStartFullScreen:self];
        }
    }
}

//- (void)adDidEndFullScreen:(id)sender;
- (void)closeInternalBrowser:(NSNotification*)notification {
    MASTAdView* adView = [notification object];
	
	if (adView == self) {
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(adDidEndFullScreen:)]) {
            [delegate adDidEndFullScreen:self];
        }
    }
}

- (void)showDefaultImage:(MASTAdView*)adView {
    for (UIView *subView in [adView subviews]) {
        if (![subView isKindOfClass:[UIImageView class]]) {
            subView.hidden = YES;
        }
    }
}

- (void)hiddenAllSubviews:(MASTAdView*)adView {
    for (UIView *subView in [adView subviews]) {
        subView.hidden = YES;
    }
}

- (MASTAdView*)adViewFromNotification:(NSNotification*)notification {
    NSString* name = [notification name];
    MASTAdView *adView;
    
    if ([name isEqualToString:kInvalidParamsServerResponseNotification]) {
        adView = [notification object];
    } else {
        NSDictionary* info = [notification object];
        adView = [info objectForKey:@"adView"];
    }
    return adView;
}

//- (void)didFailToReceiveAd:(id)sender withError:(NSError*)error;
- (void)failToReceiveAd:(NSNotification*)notification {
    NSString* name = [notification name];
    MASTAdView *adView = [self adViewFromNotification:notification];
    
    BOOL isSetDefaultImage = YES;
    if (![self.adModel isFirstDisplay]) {
        if (self.showPreviousAdOnError) {
            isSetDefaultImage = NO;
        }
    }
    
    if (isSetDefaultImage) {
        if (self.defaultImage) {
            [self showDefaultImage:adView];
        } else {
            if (self.autoCollapse) 
                adView.hidden = YES;
            
            //[self hiddenAllSubviews:adView];
        }
    }
    
    if ([name isEqualToString:kInvalidParamsServerResponseNotification]) {
        MASTAdView* ad = [notification object];
        if (ad == self) {
            id <MASTAdViewDelegate> delegate = [self adModel].delegate;
            
            if (delegate && [delegate respondsToSelector:@selector(didFailToReceiveAd: withError:)]) {
                NSError* error = [NSError errorWithDomain:kErrorInvalidParamsMessage code:1010 userInfo:nil];
                [delegate didFailToReceiveAd:self withError:error];
            }
        }
        
    } else if ([name isEqualToString:kFailAdDownloadNotification]) {
        NSDictionary* info = [notification object];
        MASTAdView* ad = [info objectForKey:@"adView"];
        NSError* error = [info objectForKey:@"error"];
        if (ad == self) {
            id <MASTAdViewDelegate> delegate = [self adModel].delegate;
            
            if (delegate && [delegate respondsToSelector:@selector(didFailToReceiveAd: withError:)]) {
                [delegate didFailToReceiveAd:self withError:error];
            }
        }
    } else if ([name isEqualToString:kFailAdDisplayNotification]) {
        NSDictionary* info = [notification object];
        MASTAdView* ad = [info objectForKey:@"adView"];
        //NSObject* subview = [info objectForKey:@"subView"];
        if (ad == self) {
            id <MASTAdViewDelegate> delegate = [self adModel].delegate;
            
            if (delegate && [delegate respondsToSelector:@selector(didFailToReceiveAd: withError:)]) {
                NSError* error = [NSError errorWithDomain:kErrorFailDisplayMessage code:1011 userInfo:nil];
                [delegate didFailToReceiveAd:self withError:error];
            }
        }
    } else if ([name isEqualToString:kEmptyServerResponseNotification]) {
        NSDictionary* info = [notification object];
        MASTAdView* ad = [info objectForKey:@"adView"];
        if (ad == self) {
            id <MASTAdViewDelegate> delegate = [self adModel].delegate;
            
            if (delegate && [delegate respondsToSelector:@selector(didFailToReceiveAd: withError:)]) {
                NSError* error = [NSError errorWithDomain:kErrorNoAdsMessage code:22 userInfo:nil];
                [delegate didFailToReceiveAd:self withError:error];
            }
        }
    }
    
    [self adModel].loading = NO;
}

- (void)receiveThirdParty:(NSNotification*)notification {
    NSDictionary *info = [notification object];
    MASTAdView* adView = [info objectForKey:@"adView"];
    NSDictionary* dic = [info objectForKey:@"dic"];
	
	if (adView == self) {
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(didReceiveThirdPartyRequest:content:)]) {
            [delegate didReceiveThirdPartyRequest:self content:dic];
        }
    }
}

- (void)ormmaEvent:(NSNotification*)notification {
    NSDictionary *info = [notification object];
    MASTAdView* adView = [info objectForKey:@"adView"];
    NSString* event = [info objectForKey:@"event"];
    NSDictionary* dic = [info objectForKey:@"dic"];
	
	if (adView == self) {
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(ormmaProcess:event:parameters:)]) {
            [delegate ormmaProcess:self event:event parameters:dic];
        }
    }
}

//- (BOOL)adShouldOpen:(id)sender withUrl:(NSURL*)url;
- (void)adShouldOpenBrowser:(NSNotification*)notification {
    NSDictionary *info = [notification object];
    MASTAdView* adView = [info objectForKey:@"adView"];
    NSURLRequest* request = [info objectForKey:@"request"];
	
	if (adView == self) {
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        BOOL result = YES;
        if (delegate && [delegate respondsToSelector:@selector(adShouldOpen:withUrl:)]) {
            result = [delegate adShouldOpen:self withUrl:[request URL]];
        }
        if (result) {
            MASTAdModel* model = [adView adModel];
            
            if (model.internalOpenMode) {
                UIViewController* controller = [adView viewControllerForView];
                if (controller) {                    
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kOpenInternalBrowserNotification object:info];
                } else {
                    [[MASTNotificationCenter sharedInstance] postNotificationName:kCantOpenInternalBrowserNotification object:adView];
                    [[UIApplication sharedApplication] openURL:[request URL]];
                }
            }
            else {
                // open safari
                [[UIApplication sharedApplication] openURL:[request URL]];
            }
        }
    }
}

- (void)adShouldOpenExternalApp:(NSNotification*)notification {
    NSDictionary *info = [notification object];
    MASTAdView* adView = [info objectForKey:@"adView"];
    NSURLRequest* request = [info objectForKey:@"request"];
	
	if (adView == self) {
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        BOOL result = YES;
        if (delegate && [delegate respondsToSelector:@selector(adShouldOpen:withUrl:)]) {
            result = [delegate adShouldOpen:self withUrl:[request URL]];
        }
        
        if (result) {
            [[UIApplication sharedApplication] openURL:[request URL]];
        }
    }
}

//- (void) didClosedInterstitialAd:(id)sender usageTimeInterval:(NSTimeInterval)usageTimeInterval;
- (void)closeInterstitial:(NSNotification*)notification {
    MASTAdView* adView = [notification object];
	
	if (adView == self) {
        id <MASTAdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(didClosedAd:usageTimeInterval:)]) {
            NSDate* _startDate = ((MASTAdModel*)_adModel).startDisplayDate;
            NSTimeInterval timeInterval = -[_startDate timeIntervalSinceNow];
            [delegate didClosedAd:self usageTimeInterval:timeInterval];
        }
    }
}

#pragma mark -
#pragma mark Propertys

- (MASTAdModel*)adModel {
	return ((MASTAdModel*)_adModel);
}

- (NSString*)uid {
    return [NSString stringWithFormat:@"%ld", self];
}

// @property (assign) id <AdViewDelegate> delegate;
- (void)setDelegate:(id <MASTAdViewDelegate>)delegate {
	((MASTAdModel*)_adModel).delegate = (id <MASTAdViewDelegate>)delegate;
}

- (id <MASTAdViewDelegate>)delegate {
	return ((MASTAdModel*)_adModel).delegate;
}

//@property (readonly) BOOL readyForDisplay;
- (BOOL)isLoading {
	return [self adModel].loading;
}

//@property BOOL	testMode;
- (void)setTestMode:(BOOL)testMode {
	((MASTAdModel*)_adModel).testMode = testMode;
}

- (BOOL)testMode {
	return ((MASTAdModel*)_adModel).testMode;
}

//@property AdLogMode	logMode;
- (void)setLogMode:(AdLogMode)logMode {
    AdLogMode oldValue = ((MASTAdModel*)_adModel).logMode;
    AdLogMode newValue = logMode;
	((MASTAdModel*)_adModel).logMode = newValue;
    
    if (oldValue != newValue) {
        if (newValue == AdLogModeErrorsOnly) {
            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStartLoggingErrorsNotification object:self];
        } else if (newValue == AdLogModeAll) {
            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStartLoggingAllNotification object:self];
        } else if (newValue == AdLogModeNone) {
            // stop logging for this ad
            [[MASTNotificationCenter sharedInstance] postNotificationName:kAdStopLoggingNotification object:self];
        }
    }
}

- (AdLogMode)logMode {
	return ((MASTAdModel*)_adModel).logMode;
}

//@property BOOL	isAdChangeAnimated;
- (void)setIsAdChangeAnimated:(BOOL)isAdChangeAnimated {
	((MASTAdModel*)_adModel).isAdChangeAnimated = isAdChangeAnimated;
}

- (BOOL)animateMode {
	return ((MASTAdModel*)_adModel).isAdChangeAnimated;
}

- (void)setInjectionHeaderCode:(NSString *)injectionHeaderCode {
    ((MASTAdModel*)_adModel).injectionHeaderCode = injectionHeaderCode;
}

- (NSString*)injectionHeaderCode {
    return ((MASTAdModel*)_adModel).injectionHeaderCode;
}

//@property BOOL	internalOpenMode;
- (void)setInternalOpenMode:(BOOL)internalOpenMode {
	((MASTAdModel*)_adModel).internalOpenMode = internalOpenMode;
}

- (BOOL)internalOpenMode {
	return ((MASTAdModel*)_adModel).internalOpenMode;
}

- (void)setTrack:(BOOL)track {
    if (track) {
        ((MASTAdModel*)_adModel).track = 1;
    } else {
        ((MASTAdModel*)_adModel).track = 0;
    }
}

- (BOOL)track {
	return ((MASTAdModel*)_adModel).track > 0;
}

//@property NSTimeInterval	updateTimeInterval;
- (void)setUpdateTimeInterval:(NSTimeInterval)updateTimeInterval {
	// filter
	if (updateTimeInterval > 0 && updateTimeInterval < 5) {
		updateTimeInterval = 5;
	}
	
	NSTimeInterval oldValue = ((MASTAdModel*)_adModel).updateTimeInterval;
	
	// set new value to model
	((MASTAdModel*)_adModel).updateTimeInterval = updateTimeInterval;
	
    // Update the value regardless of the stop or start notion.
    if (updateTimeInterval != oldValue) {
		[[MASTNotificationCenter sharedInstance] postNotificationName:kAdChangeUpdateTimeIntervalNotification object:self];
	}
}

- (NSTimeInterval)updateTimeInterval {
	return ((MASTAdModel*)_adModel).updateTimeInterval;
}

//@property (retain) UIImage*	defaultImage;
- (void)setDefaultImage:(UIImage*)defaultImage {
	((MASTAdModel*)_adModel).defaultImage = defaultImage;
    
    [[MASTNotificationCenter sharedInstance] postNotificationName:kAdDisplayDefaultImage object:self];
}

- (UIImage*)defaultImage {
	return ((MASTAdModel*)_adModel).defaultImage;
}


//@property (retain) NSString*	site;
- (void)setSite:(NSInteger)site {
	[((MASTAdModel*)_adModel) setSite:site];
}

- (NSInteger)site {
	return [((MASTAdModel*)_adModel) site];
}

//@property (retain) NSString*	zone;
- (void)setZone:(NSInteger)zone {
	[((MASTAdModel*)_adModel) setAdZone:zone];
}

- (NSInteger)zone {
	return [((MASTAdModel*)_adModel) adZone];
}

//@property AdPremium		premiumFilter;
- (void)setPremium:(AdPremium)premium {
	((MASTAdModel*)_adModel).premiumFilter = premium;
}

- (AdPremium)premium {
	return ((MASTAdModel*)_adModel).premiumFilter;
}

//@property AdType		type;
- (void)setType:(AdType)type {
	((MASTAdModel*)_adModel).type = type;
}

- (AdType)type {
	return ((MASTAdModel*)_adModel).type;
}

//@property (retain) NSString*	keywords;
- (void)setKeywords:(NSString*)keywords {
	((MASTAdModel*)_adModel).keywords = keywords;
}

- (NSString*)keywords {
	return ((MASTAdModel*)_adModel).keywords;
}

//@property CGSize	minSize;
- (void)setMinSize:(CGSize)minSize {
	((MASTAdModel*)_adModel).minSize = minSize;
}

- (CGSize)minSize {
	return ((MASTAdModel*)_adModel).minSize;
}

//@property CGSize	maxSize;
- (void)setMaxSize:(CGSize)maxSize {
	((MASTAdModel*)_adModel).maxSize = maxSize;
}

- (CGSize)maxSize {
	return ((MASTAdModel*)_adModel).maxSize;
}

//@property (retain) NSString*	paramBG;
- (void)setBackgroundColor:(UIColor*)backgroundColor {
	((MASTAdModel*)_adModel).paramBG = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

//@property (retain) NSString*	paramLINK;
- (void)setTextColor:(UIColor*)textColor {
	((MASTAdModel*)_adModel).paramLINK = textColor;
}

- (UIColor*)textColor {
	return ((MASTAdModel*)_adModel).paramLINK;
}

//@property (retain) NSString*	additionalParameters;
- (void)setAdditionalParameters:(NSDictionary*)additionalParameters {
	((MASTAdModel*)_adModel).additionalParameters = additionalParameters;
}

- (NSDictionary*)additionalParameters {
	return ((MASTAdModel*)_adModel).additionalParameters;
}

//@property (retain) NSString*	adServerUrl;
- (void)setAdServerUrl:(NSString*)adServerUrl {
	((MASTAdModel*)_adModel).adServerUrl = adServerUrl;
}

- (NSString*)adServerUrl {
	return ((MASTAdModel*)_adModel).adServerUrl;
}

//@property (retain) NSString*            country;
- (void)setCountry:(NSString*)country {
	((MASTAdModel*)_adModel).country = country;
}

- (NSString*)country {
	return ((MASTAdModel*)_adModel).country;
}

//@property (retain) NSString*            region;
- (void)setRegion:(NSString*)region {
	((MASTAdModel*)_adModel).region = region;
}

- (NSString*)region {
	return ((MASTAdModel*)_adModel).region;
}

//@property (retain) NSString*            city;
- (void)setCity:(NSString*)city {
	((MASTAdModel*)_adModel).city = city;
}

- (NSString*)city {
	return ((MASTAdModel*)_adModel).city;
}

//@property (retain) NSString*            area;
- (void)setArea:(NSString*)area {
	((MASTAdModel*)_adModel).area = area;
}

- (NSString*)area {
	return ((MASTAdModel*)_adModel).area;
}

//@property (retain) NSString*            metro;
- (void)setMetro:(NSString*)metro {
	[self setDma:metro];
}

- (NSString*)metro {
	return [self dma];
}

- (void)setDma:(NSString *)dma
{
    ((MASTAdModel*)_adModel).dma = dma;
}

- (NSString*)dma {
    return ((MASTAdModel*)_adModel).dma;
}

//@property (retain) NSString*            zip;
- (void)setZip:(NSString*)zip {
	((MASTAdModel*)_adModel).zip = zip;
}

- (NSString*)zip {
	return ((MASTAdModel*)_adModel).zip;
}

//@property (retain) NSString*            carrier
- (void)setCarrier:(NSString*)carrier {
	((MASTAdModel*)_adModel).carrier = carrier;
}

- (NSString*)carrier {
	return ((MASTAdModel*)_adModel).carrier;
}

//@property (retain) NSString*            lat;
- (void)setLatitude:(NSString*)latitude {
	((MASTAdModel*)_adModel).latitude = latitude;
}

- (NSString*)latitude {
	return ((MASTAdModel*)_adModel).latitude;
}

//@property (retain) NSString*            lon;
- (void)setLongitude:(NSString*)longitude {
	((MASTAdModel*)_adModel).longitude = longitude;
}

- (NSString*)longitude {
	return ((MASTAdModel*)_adModel).longitude;
}

//@property (assign) NSInteger            timeout;

- (void)setAdCallTimeout:(NSInteger)adCallTimeout {
    // filter
    if (adCallTimeout > MAX_TIMEOUT_VALUE) {
        adCallTimeout = MAX_TIMEOUT_VALUE;
    } else if (adCallTimeout < MIN_TIMEOUT_VALUE) {
        adCallTimeout = MIN_TIMEOUT_VALUE;
    }
    
    ((MASTAdModel*)_adModel).adCallTimeout = adCallTimeout;
}

- (NSInteger)adCallTimeout {
    return ((MASTAdModel*)_adModel).adCallTimeout;
}

- (void)setAutoCollapse:(BOOL)autoCollapse {
    ((MASTAdModel*)_adModel).autoCollapse = autoCollapse;
}

- (BOOL)autoCollapse {
    return ((MASTAdModel*)_adModel).autoCollapse;
}

- (void)setShowPreviousAdOnError:(BOOL)showPreviousAdOnError {
    ((MASTAdModel*)_adModel).showPreviousAdOnError = showPreviousAdOnError;
}

- (BOOL)showPreviousAdOnError {
    return ((MASTAdModel*)_adModel).showPreviousAdOnError;
}

//@property NSTimeInterval showCloseButtonTime;
- (void)setShowCloseButtonTime:(NSTimeInterval)timeInterval {
	((MASTAdModel*)_adModel).showCloseButtonTime = timeInterval;
}

- (NSTimeInterval)showCloseButtonTime {
	return ((MASTAdModel*)_adModel).showCloseButtonTime;
}

//@property NSTimeInterval autocloseInterstitialTime;
- (void)setAutocloseInterstitialTime:(NSTimeInterval)timeInterval {
	((MASTAdModel*)_adModel).autocloseInterstitialTime = timeInterval;
}

- (NSTimeInterval)autocloseInterstitialTime {
	return ((MASTAdModel*)_adModel).autocloseInterstitialTime;
}

- (void)setUdid:(NSString *)u {
    ((MASTAdModel*)_adModel).udid = u;
}

- (NSString*)getUdid {
    return ((MASTAdModel*)_adModel).udid;
}

@end

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
#import "ORMMAJavaScriptBridge.h"
#import "ORMMAView.h"
#import "ORMMAView+PrivateImplementation.h"

#import "GUJNativeOrientationManager.h"

@implementation ORMMAJavaScriptBridge

#define kORMMACallErrorIdentifier                   @"error"
#define kORMMACallHeadingChangeIdentifier           @"headingChange"
#define kORMMACallKeyboardChangeIdentifier          @"keyboardChange"
#define kORMMACallLocationChangeIdentifier          @"locationChange"
#define kORMMACallNetworkChangeIdentifier           @"networkChange"
#define kORMMACallOrientationChangeIdentifier       @"orientationChange"
#define kORMMACallScreenChangeIdentifier            @"screenChange"
#define kORMMACallSizeChangeIdentifier              @"sizeChange"
#define kORMMACallStateChangeIdentifier             @"stateChange"
#define kORMMACallShakeChangeIdentifier             @"shake"
#define kORMMACallTiltChangeIdentifier              @"tiltChange"
#define kORMMACallViewableChangeIdentifier          @"viewableChange"

#define kORMMACallViewableObserverKeyPath           @"viewable"
#define kORMMACallORMMAViewStateObserverKeyPath     @"ormmaViewState"


#define kORMMACallNativeCallStateTrue               @"Y"
#define kORMMACallNativeCallStateFalse              @"N"

#define kORMMACalResponseStateTrue                  @"1"
#define kORMMACalResponseStateFalse                 @"0"

- (id)initWithAdView:(id)adView
{
    self = [super init];
    if( self ) {
        [self attachToAdView:adView];
    }
    return self;
}

- (void)attachToAdView:(id)adView
{
    if( [ORMMAUtil isORMMAView:adView] ) {
        [self setOrmmaView:adView];
        // [[[self ormmaView] webView] setDelegate:self];
    } else {
        [self __distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_FAILED_TO_ASSIGN_OBJ userInfo:nil]];
    }
}

- (BOOL)isAttachedToAdView
{
    return ([[self ormmaView] webView] != nil );
}

- (BOOL)isAttachedToAdView:(id)adView
{
    return [[self ormmaView] isEqual:adView];
}

- (ORMMACommandState)executeCommand:(ORMMACommand*)command
{
    if( [command state] == ORMMACommandStatePrepared ) {
        if( [[self ormmaView] webView] != nil ) {
            NSString *cmdResult = [[[self ormmaView] webView] stringByEvaluatingJavaScriptFromString:[command stringRepresentation]];
            [command setCommandResult:cmdResult];
            _logd_tm(self,@"executeCommand:",[command stringRepresentation],@"Result:",cmdResult,nil);
            if( [cmdResult isEqualToString:kEmptyString] ) {
                [command setCommandState:ORMMACommandStateFailed];
            } else {
                [command setCommandState:ORMMACommandStateSucceed];
            }
        } else {
            [command setCommandState:ORMMACommandStateFailed];
        }
    }
    return [command state];
    
}

- (void)unload
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[self internalWebBrowser] freeInstance];
    [[[self ormmaView] webView] setDelegate:[self ormmaView]];
    [self setOrmmaSupportString:nil];
    [self setOrmmaInit:NO];
    [self setOrmmaSetup:NO];
}

- (BOOL)handleRequest:(NSURLRequest *)request
{
    BOOL result = YES;
    // parse the current url and check if its an call object
    ORMMACall *call = [ORMMACall parse:[[request URL] description]];
    if( [call isValidCall] ) {
        if( [self ormmaSetup] ) {
            /*
             * if ORMMA is setted up, we start to handle every call-back
             * normally all event-handlers will be initalized and native services will be activated at the beginning.
             */
            [self performSelectorOnMainThread:@selector(__handleCall:) withObject:call waitUntilDone:YES];
        } else {
            /*
             * initial callback received
             */
            if( [call isServiceCall] ) {
                [self performSelectorOnMainThread:@selector(__handleCall:) withObject:call waitUntilDone:YES];
            } else {
                /* we can not receive calls other than service calls before the setup phase.
                 * so all this invalid cammands, except the close command, will be ignored.
                 * (!) this can/will/must interrupt a invalid banner implementation.
                 */
                if( [[call name] isEqualToString:kORMMAParameterValueForCommandClose] ) {
                    [self performSelectorOnMainThread:@selector(__handleCall:) withObject:call waitUntilDone:YES];
                } else {
                    _logd_tm(self, @"UndefinedORMMACall",[call name],nil);
                }
            }
        }
    } else { // open internal or extranel URL-Requests
        if( ([self ormmaSetup] && [self ormmaInit]) || [ORMMAUtil isObviousAdViewRequestForWebView:[[self ormmaView] webView]] ) {
            if( [ORMMAUtil isObviousAdViewRequestForWebView:[[self ormmaView] webView]] ) {
                if( [[self ormmaView] isInterstitial] ) {
                    if( [GUJUtil typeIsNotNil:[[self ormmaView] delegate] andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
                        [[[self ormmaView] delegate] interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeSystemMessage message:ORMMA_EVENT_MESSAGE_RELOAD_AD_VIEW]];
                    }
                } else {
                    if( [GUJUtil typeIsNotNil:[[self ormmaView] delegate] andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {
                        [[[self ormmaView] delegate] bannerView:(GUJAdView*)[self ormmaView] receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeSystemMessage message:ORMMA_EVENT_MESSAGE_RELOAD_AD_VIEW]];
                    }
                }
                // finnaly open the internal browser
                if ([NSThread isMainThread]) { // check if running on main thread
                    [[self ormmaView] __openInternalWebBrowser:[NSURLRequest requestWithURL:request.URL]];
                } else {
                    __weak NSURLRequest *weakRequest = [NSURLRequest requestWithURL:request.URL];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [[self ormmaView] __openInternalWebBrowser:weakRequest];
                    });
                }
            } else { /* non obvious request. discard! */}
        } else {
            // extrenal URLS
            result = NO;
        }
    }
    return result;
}

- (void)initializeORMMAAndDisplayAdView
{
    if( ![self ormmaInit] ) {
        if( [ORMMAUtil webViewHasORMMAContent:[[self ormmaView] webView]] ) {
            [self setOrmmaInit:YES];
            // resize ad in ormma view
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kGUJDefaultAdViewResizeAndDisplayDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [[self ormmaView] __resizeAndDisplayAdView];
                
                if ([NSThread isMainThread]) {
                    [self __performInitialORMMASequence];
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self __performInitialORMMASequence];
                    });
                }
                
                if( ![ORMMAUtil adViewHasValidAdSize:[[self ormmaView] webView]] ) { // ad view size is invalid
                    [self __distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_UNABLE_TO_COMPLETE userInfo:nil]];
                    [[self ormmaView] hide];
                    [[[self ormmaView] webView] loadHTMLString:kEmptyString baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kORMMAProtocolIdentifier,kORMMAParameterValueForCommandClose]]];
                }
            });
        } else {
            /*
             * A RichMedia Ad that does not implement ORMMA has been loaded. Show the contents.
             */
            _logd_tm(self, @"webViewDidFinishLoad:",@"No ORMMA-Object or ORMMAReady-Function found",nil);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kGUJDefaultAdViewResizeAndDisplayDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [[self ormmaView] __resizeAndDisplayAdView];
            });
        }
    } else {
        // error: initORMMA is not FALSE. Something went wrong. Unload the ad now.
        if( [GUJUtil typeIsNotNil:[[self ormmaView] delegate] andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
            [[[self ormmaView] delegate] view:(GUJAdView*)[self ormmaView] didFailToLoadAdWithUrl:nil andError:[GUJUtil errorForDomain:kORMMAJavaScriptBridgeErrorDomain andCode:ORMMA_ERROR_CODE_ILLEGAL_ORMMA_STATE]];
        }
    }
}

@end

/*
 * implementation of ORMMAJavaScriptBridge(InitialSequence)
 */
@implementation ORMMAJavaScriptBridge(PrivateInitialSequence)

- (void)__performInitialORMMASequence
{
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter stringParameter:kORMMAParameterValueForStateHidden
                                                   forKey:kORMMAParameterKeyForState]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter stringParameter:[ORMMAUtil translateNetworkInterface:[[GUJNativeNetworkObserver sharedInstance] networkInterfaceName]]
                                                   forKey:kORMMAParameterKeyForNetwork]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter sizeParameter:[GUJUtil sizeOfFirstResponder]
                                                 forKey:kORMMAParameterKeyForScreenSize]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter sizeParameter:[[self ormmaView] webViewFrame].size
                                                 forKey:kORMMAParameterKeyForSize]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter sizeParameter:[GUJUtil sizeOfFirstResponder]
                                                 forKey:kORMMAParameterKeyForMaxSize]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter rectParameter:[self ormmaView].frame
                                                 forKey:kORMMAParameterKeyForDefaultPosition]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter parameter:NSNUMBER_WITH_INT( [[GUJNativeOrientationManager sharedInstance] deviceOrientation] )
                                             forKey:kORMMAParameterKeyForOrientation]]
     ];
    if( [self ormmaSupportString] != nil ) {
        [self executeCommand:[ORMMACommand fireChangeEventCommand:
                              [ORMMAParameter parameter:[self ormmaSupportString]
                                                 forKey:kORMMAParameterKeyForSupports]]
         ];
    }
    
    [self executeCommand:[ORMMACommand commandWithString:kORMMACommandStringForSignalReady]];
    [self setOrmmaSetup:YES];
    
}

@end // PrivateInitialSequence

/*
 * implementation of ORMMAJavaScriptBridge(PrivateNotificationHandling)
 */
@implementation ORMMAJavaScriptBridge(PrivateNotificationHandling)

- (void)__nativeNotification:(NSNotification*)notification
{
    _logd_tm(self, @"__nativeNotification:",notification.name,nil);
    if( [notification.name isEqualToString:GUJDeviceOrientationChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeOrientationManager class]] ) {
            UIDeviceOrientation orientation = [((GUJNativeOrientationManager*)notification.object) deviceOrientation];
            [self executeCommand:[ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:NSNUMBER_WITH_INT(GUJ_FORMAT_ORIENTATION_IN_DEGREES(orientation)) forKey:kORMMAParameterKeyForOrientation]]];
            _logd_tm(self, @"orientationChanged:",NSNUMBER_WITH_INT(GUJ_FORMAT_ORIENTATION_IN_DEGREES(orientation)),NSNUMBER_WITH_INT(orientation),nil);
        }
    }
    
    if( [notification.name isEqualToString:GUJBannerSizeChangeNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[ORMMAView class]] ) {
            // in this case the resized object MUST be the ormma view
            ORMMAView *resizedObject = (ORMMAView*)notification.object;
            if( resizedObject == [self ormmaView] ) {
                _logd_tm(self, @"(NSNotification*)sizeChanged:",nil);
                ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter sizeParameter:[self ormmaView].frame.size forKey:kORMMAParameterKeyForSize]];
                // the observer is not synced
                // must run on mainthread cause the webview is maybe processing a redraw which causes a crash when calling directly
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
                
            }
        }
    }
    
    if([notification.name isEqualToString:GUJDeviceSuperviewSizeChangedNotification] ||
       [notification.name isEqualToString:GUJDeviceScreenSizeChangedNotification]) {
        if( notification.object != nil && [notification.object isKindOfClass:[UIView class]] ) {
            _logd_tm(self, @"(NSNotification*)sreenChanged:",nil);
            ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter sizeParameter:((UIView*)notification.object).frame.size forKey:kORMMAParameterKeyForScreenSize]];
            [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
        }
    }
    
    if( [notification.name isEqualToString:GUJDeviceKeyboardStateChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeKeyboardObserver class]] ) {
            _logd_tm(self, @"(NSNotification*)keyboardChanged:",nil);
            [self executeCommand:[ORMMACommand fireChangeEventCommand:
                                  [ORMMAParameter boolParameter:[((GUJNativeKeyboardObserver*)notification.object) keyboardIsVidible] forKey:kORMMAParameterKeyForKeyboardState]]
             ];
        }
    }
    
    if( [notification.name isEqualToString:GUJDeviceLocationChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeAPIInterface class]] ) {
            GUJNativeAPIInterface *locationManager = ((GUJNativeAPIInterface*)notification.object);
            if( locationManager != nil && [locationManager respondsToSelector:@selector(locationLatitudeStringRepresentation)] ) {
                // we got the locationmanager
                NSString *lat = [locationManager performSelector:@selector(locationLatitudeStringRepresentation)];
                NSString *lon = [locationManager performSelector:@selector(locationLongitudeStringRepresentation)];
                NSString *acc = [locationManager performSelector:@selector(accuracyStringRepresentation)];
                NSString *locationString = [NSString stringWithFormat:kORMMAStringFormatForLocationParameter,lat,lon,acc];
                _logd_tm(self, @"(NSNotification*)locationChanged:",locationString,nil);
                [self executeCommand:[ORMMACommand fireChangeEventCommand:
                                      [ORMMAParameter parameter:locationString
                                                         forKey:kORMMAParameterKeyForLocation]]
                 ];
                
            }
        }
    }
    
    if( [notification.name isEqualToString:GUJDeviceNetworkChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeNetworkObserver class]] ) {
            GUJNativeNetworkObserver *networkObserver = ((GUJNativeNetworkObserver*)notification.object);
            NSString *interfaceName = [ORMMAUtil translateNetworkInterface:[networkObserver networkInterfaceName]];
            _logd_tm(self, @"(NSNotification*)networkChange:",interfaceName,nil);
            ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter stringParameter:interfaceName forKey:kORMMAParameterKeyForNetwork]];
            // the observer is not synced
            // must run on mainthread cause the webview is maybe stoll processing before the command is thrown
            [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
            
        }
    }
    if( [notification.name isEqualToString:GUJDeviceShakeNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeShakeObserver class]] ) {
            if( [((GUJNativeShakeObserver*)notification.object) acceleration] != nil ) {
                float interval  = [((GUJNativeShakeObserver*)notification.object) interval];
                float intensity = [((GUJNativeShakeObserver*)notification.object) intensity];
                NSString *accelerationString = [NSString stringWithFormat:kORMMAStringFormatForShakeParameter,interval,intensity];
                _logd_tm(self, @"(NSNotification*)shake:",accelerationString,nil);
                ORMMACommand *changeCmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:accelerationString forKey:kORMMAParameterKeyForShakeProperties]];
                
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:changeCmd waitUntilDone:YES];
                ORMMACommand *cmd = [ORMMACommand fireShakeEventCommand:accelerationString];
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
            }
        }
    }
    if( [notification.name isEqualToString:GUJDeviceTiltNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeTiltObserver class]] ) {
            UIAcceleration *acceleration = [((GUJNativeTiltObserver*)notification.object) acceleration];
            if( acceleration != nil ) {
                NSString *accelerationString = [NSString stringWithFormat:kORMMAStringFormatForTiltParameter,acceleration.x,acceleration.y,acceleration.z];
                _logd_tm(self, @"(NSNotification*)tilt:",accelerationString,nil);
                ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:accelerationString forKey:kORMMAParameterKeyForTilt]];
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
            }
        }
    }
    if( [notification.name isEqualToString:GUJDeviceHeadingChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeAPIInterface class]] ) {
            GUJNativeAPIInterface *locationManager = ((GUJNativeAPIInterface*)notification.object);
            if( locationManager != nil && [locationManager respondsToSelector:@selector(headingInDegreesStringRepresentation)] ) {
                NSString *headingString = [locationManager performSelector:@selector(headingInDegreesStringRepresentation)];
                _logd_tm(self, @"(NSNotification*)heading:",headingString,nil);
                ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:headingString forKey:kORMMAParameterKeyForHeading]];
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
            }
        }
    }
}

@end //PrivateNotificationHandling

/*
 * implementation of ORMMAJavaScriptBridge(PrivateORMMACallHandling)
 */
@implementation ORMMAJavaScriptBridge(PrivateORMMACallHandling)


- (void)__distributeError:(NSError*)error
{
    if( [self shouldReportErrors] ) {
        if( [error debugDescription] != nil ) {
            [self executeCommand:[ORMMACommand fireErrorEventCommand:[error debugDescription] key:[error domain]]];
        } else {
            [self executeCommand:[ORMMACommand fireErrorEventCommand:[error localizedFailureReason] key:[error domain]]];
        }
    } else {
        //error
    }
}

/**
 * Handle a ORMMA-ServiceCall.
 * This method does not validate a call.
 * You must PRE-Validate the call to ensure passing a valid serviceCall.
 */
- (BOOL)__handleServiceCall:(ORMMACall*)serviceCall
{
    BOOL result = YES;
    _logd_tm(self, @"__handleServiceCall:",serviceCall.name,nil);
    // error reporting to ORMMA-Ad
    if( [serviceCall isCallForIdentifier:kORMMACallErrorIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [self setShouldReportErrors:YES];
        } else {
            [self setShouldReportErrors:NO];
        }
    }
    
    // heading
    if( [serviceCall isCallForIdentifier:kORMMACallHeadingChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceHeadingChangedNotification sender:[GUJNativeLocationManager sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeLocationManager sharedInstance] startUpdatingHeading];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceHeadingChangedNotification receiver:self];
            [[GUJNativeLocationManager sharedInstance] stopUpdatingHeading];
        }
    }
    
    // location
    if( [serviceCall isCallForIdentifier:kORMMACallLocationChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceLocationChangedNotification sender:[GUJNativeLocationManager sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeLocationManager sharedInstance] startUpdatingLocation];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceLocationChangedNotification receiver:self];
            [[GUJNativeLocationManager sharedInstance] stopUpdatingHeading];
        }
    }
    
    // orientation
    if( [serviceCall isCallForIdentifier:kORMMACallOrientationChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceOrientationChangedNotification sender:[GUJNativeOrientationManager sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeOrientationManager sharedInstance] startObserver];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceOrientationChangedNotification receiver:self];
            [[GUJNativeOrientationManager sharedInstance] stopObserver];
        }
    }
    
    // keyboard
    if( [serviceCall isCallForIdentifier:kORMMACallKeyboardChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceKeyboardStateChangedNotification sender:[GUJNativeKeyboardObserver sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeKeyboardObserver sharedInstance] startObserver];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceKeyboardStateChangedNotification receiver:self];
            [[GUJNativeKeyboardObserver sharedInstance] stopObserver];
        }
    }
    
    // network
    if( [serviceCall isCallForIdentifier:kORMMACallNetworkChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceNetworkChangedNotification sender:[GUJNativeNetworkObserver sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeNetworkObserver sharedInstance] startObserver];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceNetworkChangedNotification receiver:self];
            [[GUJNativeNetworkObserver sharedInstance] stopObserver];
        }
    }
    
    // screen
    if( [serviceCall isCallForIdentifier:kORMMACallScreenChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceSuperviewSizeChangedNotification sender:[GUJNativeSizeObserver sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeSizeObserver sharedInstance] listenForResizingSuperview:[self ormmaView]];
            [[GUJNativeSizeObserver sharedInstance] startObserver];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceSuperviewSizeChangedNotification receiver:self];
            [[GUJNativeSizeObserver sharedInstance] stopListeningForResizingSuperview];
        }
    }
    
    // size
    if( [serviceCall isCallForIdentifier:kORMMACallSizeChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJBannerSizeChangeNotification sender:[GUJNativeSizeObserver sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeSizeObserver sharedInstance] listenForResizingAdView:[self ormmaView]];
            [[GUJNativeSizeObserver sharedInstance] startObserver];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJBannerSizeChangeNotification receiver:self];
            [[GUJNativeSizeObserver sharedInstance] stopListeningForResizingAdView];
        }
    }
    
    // state
    if( [serviceCall isCallForIdentifier:kORMMACallStateChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[self ormmaView] addObserver:self forKeyPath:kORMMACallORMMAViewStateObserverKeyPath options:0 context:(__bridge void *)self];
            // fire the current state
            [[self ormmaView] setOrmmaViewState:[[self ormmaView] state]];
        } else {
            [[self ormmaView] removeObserver:self forKeyPath:kORMMACallORMMAViewStateObserverKeyPath context:(__bridge void *)self];
        }
    }
    
    // titlt
    if( [serviceCall isCallForIdentifier:kORMMACallTiltChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceTiltNotification sender:[GUJNativeTiltObserver sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeTiltObserver sharedInstance] startObserver];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceTiltNotification receiver:self];
            [[GUJNativeTiltObserver sharedInstance] stopObserver];
        }
    }
    
    // shake
    if( [serviceCall isCallForIdentifier:kORMMACallShakeChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [GUJNotificationObserver addObserverForNotification:GUJDeviceShakeNotification sender:[GUJNativeShakeObserver sharedInstance] receiver:self selector:@selector(__nativeNotification:)];
            [[GUJNativeShakeObserver sharedInstance] startObserver];
        } else {
            [GUJNotificationObserver removeObserverForNotification:GUJDeviceShakeNotification receiver:self];
            [[GUJNativeShakeObserver sharedInstance] stopObserver];
        }
    }
    
    // viewable
    if( [serviceCall isCallForIdentifier:kORMMACallViewableChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[self ormmaView] addObserver:self forKeyPath:kORMMACallViewableObserverKeyPath options:0 context:(__bridge void *)self];
            // fire the current viewable state
            [[self ormmaView] setViewable:[[self ormmaView] viewable]];
        } else {
            [[self ormmaView] removeObserver:self forKeyPath:kORMMACallViewableObserverKeyPath context:(__bridge void *)self];
        }
    }
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [object isEqual:[self ormmaView]]  ) {
        if( [keyPath isEqualToString:kORMMACallORMMAViewStateObserverKeyPath] ) {
            NSString *state = [((ORMMAView*)object) ormmaViewState];
            _logd_tm(self, @"(NSNotification*)stateChanged:",state,nil);
            [self executeCommand:[ORMMACommand fireChangeEventCommand:
                                  [ORMMAParameter stringParameter:state
                                                           forKey:kORMMAParameterKeyForState]]
             ];
        } else if( [keyPath isEqualToString:kORMMACallViewableObserverKeyPath] ) {
            NSString *state = kORMMACalResponseStateFalse;
            if( [((ORMMAView*)object) viewable] ) {
                state = kORMMACalResponseStateTrue;
            }
            _logd_tm(self, @"(NSNotification*)viewableChanged:",state,nil);
            [self executeCommand:[ORMMACommand fireChangeEventCommand:
                                  [ORMMAParameter stringParameter:state
                                                           forKey:kORMMAParameterKeyForViewable]]
             ];
        }
    }
}


- (void)__handleCall:(ORMMACall*)call
{
    if( [call isValidCall] ) {
        if( [call isServiceCall] ) { // native service calls
            _logd_tm(self, @"ServiceCall:",[call name],nil);
            if( [self __handleServiceCall:call] ) {
                [self executeCommand:[ORMMACommand nativeCallSucceededCommand]];
            } else {
                _logd_tm(self, @"Unknown Service-Call:",[call name],nil);
                [self executeCommand:[ORMMACommand nativeCallFailedCommand]];
                [self __distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_ORMMA_CALL_UNHANDLED userInfo:nil]];
            }
        } else { // all other calls;
            _logd_tm(self, @"Call:",[call name],nil);
            __strong ORMMAJavaScriptBridge *_weakBridge = self;
            [ORMMACallHandler handle:call forAdView:[self ormmaView] completion:^(BOOL result) {
                if( result ) {
                    [_weakBridge executeCommand:[ORMMACommand nativeCallSucceededCommand]];
                } else {
                    _logd_tm(self, @"Call-Faild:",[call name],nil);
                    [_weakBridge executeCommand:[ORMMACommand nativeCallFailedCommand]];
                    [_weakBridge __distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_ORMMA_CALL_UNHANDLED userInfo:nil]];
                }
            }];
        }
    } else {
        _logd_tm(self, @"Unknown Call:",[call name],nil);
        [self executeCommand:[ORMMACommand nativeCallFailedCommand]];
        [self __distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_COMMAND_FAILED_OR_UNKNOWN userInfo:nil]];
    }
}
@end // PrivateORMMACallHandling

